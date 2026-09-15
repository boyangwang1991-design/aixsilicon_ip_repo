"""Execute resolved PC configurations through the root FuseSoC parameter target.

Schema negatives use the independent LRS semantic checker. Legal configurations
really elaborate and read DUT capabilities/default words. Other planned methods
remain explicitly unexecuted until their independent signoff runs are supplied.
"""
from pathlib import Path
import argparse
import datetime
import json
import os
import shutil
import subprocess
import sys
import yaml
from check_parameter_plan import validate
from run_uvm import P, digest, inputs as simulation_inputs, run, runtime_inventory

def inputs():
    return simulation_inputs([Path(__file__),P/'scripts/check_parameter_plan.py'])


def packed_config(c):
    words=[0]*16
    fields=[('WIN_EN',0),('PREWARN_EN',1),('BOOT_EN',2),('SERVICE_MODE',3),('SUP_MODE',5),
            ('RESPONSE_MODE',7),('ALLOW_LOCAL_RECOVERY',8),('PAUSE_SLEEP',9),('PAUSE_DEBUG',10),
            ('WAKE_EN',11),('SERVICE_PATH',12)]
    words[0]=sum(c[k]<<bit for k,bit in fields)
    words[1]=c['PRESCALE']
    for name,index in [('WIN_MIN',2),('TIMEOUT',4),('PRETIMEOUT',6),('BOOT_TIMEOUT',8)]:
        words[index]=c[name]&0xffffffff;words[index+1]=c[name]>>32
    for index,name in enumerate(['SEQ_LIMIT','REQUIRE_MASK','FAULT_POLICY','LOCAL_DELAY','FINAL_DELAY','RECOVERY_LIMIT'],10):
        words[index]=c[name]
    overrides={x['client']:x['values'] for x in c['CLIENT_OVERRIDES']}
    for index in range(32):
        cl=overrides.get(index,c['CLIENT_DEFAULT'])
        words += [cl['OWNER_SOURCE'],cl['MIN_ALIVE']|(cl['MAX_ALIVE']<<16),cl['LAST_STEP'],
                  cl['DEADLINE_MIN']&0xffffffff,cl['DEADLINE_MIN']>>32,
                  cl['DEADLINE_MAX']&0xffffffff,cl['DEADLINE_MAX']>>32]
    assert len(words)==240
    return "7680'h"+''.join(f'{word:08x}' for word in reversed(words))


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config',action='append',default=[])
    args=parser.parse_args()
    model=yaml.safe_load((P/'model/parameter_space.yaml').read_text())
    cases=model['support_matrix']['configs']
    if set(args.config)-{c['id'] for c in cases}:parser.error('unknown configuration')
    if args.config:cases=[c for c in cases if c['id'] in args.config]
    subprocess.run([sys.executable,str(P/'scripts/prepare_dependencies.py')],cwd=P,check=True)
    stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%f')
    out=P/'build/reports/parameters'/stamp;out.mkdir(parents=True)
    before=inputs()
    record=dict(schema='watchdog-parameter-execution/1.0',inputs=before,configurations=[],status='running')
    for case in cases:
        cdir=out/case['id'];cdir.mkdir()
        values=case['params'];errors=validate(values,model['parameters'])
        expected=case.get('expect_fail',{})
        item=dict(config_id=case['id'],parameters=values,expected=expected,diagnostics=errors,
                  methods={},status='fail')
        if expected.get('stage')=='Schema':
            item['methods']['Schema']=dict(status='pass' if errors else 'fail',rejected=bool(errors))
            item['status']=item['methods']['Schema']['status']
        elif errors:
            item['detail']='unexpected schema rejection'
        else:
            config=cdir/'watchdog_parameter_config.sv'
            lines=['package watchdog_parameter_config;', 'import watchdog_pkg::*;']
            lines += [f'localparam int {k}={v};' for k,v in values.items() if k!='DEFAULT_CFG']
            lines += ["localparam config_t DEFAULT_CFG[NUM_CHANNELS]='{"+
                      ','.join(packed_config(c) for c in values['DEFAULT_CFG'])+'};','endpackage']
            config.write_text('\n'.join(lines)+'\n')
            adapter=P/'build/parameter_adapter/watchdog_parameter_config.sv'
            adapter.parent.mkdir(parents=True,exist_ok=True)
            adapter.write_bytes(config.read_bytes())
            build=P/'build/parameters'/stamp/case['id']
            command=['fusesoc','--verbose','--cores-root','.', '--cores-root','build/dependency_adapter',
                     'run','--target','param_check','--build-root',str(build),'aixsilicon:ip:watchdog:1.0.0']
            log=cdir/'execution.log'
            if shutil.disk_usage(P).free<500*1024*1024:
                log.write_text('Resource precheck: less than 500 MiB free; tool not started\n');code=125
            else:code=run(command,P,log,1800)
            raw=log.read_text(errors='replace')
            passed=code==0 and 'WATCHDOG_PARAMETER_CHECK PASS' in raw and inputs()==before and digest(adapter)==digest(config)
            execution=dict(command=command,exit_code=code,tool='VCS W-2024.09-SP1_Full64',
                           config_source=dict(path=str(config.relative_to(P)),sha256=digest(config)),
                           log=dict(path=str(log.relative_to(P)),sha256=digest(log)))
            item['execution']=execution
            binaries=list(build.glob('*/param_check-vcs/aixsilicon_ip_watchdog_1.0.0'))
            execution['binaries']=[dict(path=str(b.relative_to(P)),sha256=digest(b),
                                       runtime_artifacts=runtime_inventory(b)) for b in binaries if b.is_file()]
            for method in ['elab','sim']:
                if case['verify'].get(method):item['methods'][method]=dict(status='pass' if passed else 'fail',
                    scope='elaboration, capability and reset-default readback; not full functional regression')
            for method,required in case['verify'].items():
                if required and method not in item['methods']:
                    item['methods'][method]=dict(status='not_run',detail='requires independent configuration-bound tool signoff')
            item['status']='pass' if passed and all(x['status']=='pass' for x in item['methods'].values()) else 'fail'
        record['configurations'].append(item)
        (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
        print(case['id'],json.dumps(item['methods']),flush=True)
        if inputs()!=before:
            record.update(status='fail', inputs_after=inputs(), detail='source inputs changed; execution stopped')
            (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
            raise ValueError('source inputs changed during parameter execution')
    record['inputs_after']=inputs()
    record['complete_matrix']=len(cases)==len(model['support_matrix']['configs'])
    record['status']='pass' if record['complete_matrix'] and all(c['status']=='pass' for c in record['configurations']) else 'fail'
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(dict(status=record['status'],manifest=str((out/'manifest.json').relative_to(P)))))
    if record['status']=='pass':print('WATCHDOG_PARAMETER_VERIFICATION PASS')
    return 0 if record['status']=='pass' else 1


if __name__=='__main__':raise SystemExit(main())
