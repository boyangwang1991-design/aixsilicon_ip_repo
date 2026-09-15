"""Run the canonical VPLAN UVM matrix, preserving every seed and build identity."""
from pathlib import Path
import argparse
import datetime
import json
import re
import shutil
import subprocess
import sys
import yaml
from run_uvm import P, R, SUITE, digest, inputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--phase', choices=['smoke', 'regress'], default='regress')
    args = parser.parse_args()
    subprocess.run([sys.executable, str(SUITE/'skills/15-regression-quality-review/scripts/gen_regression_list.py'),
                    '--workspace', str(P), '--ip-name', 'watchdog'], check=True)
    plan = yaml.safe_load((P/'model/verification.yaml').read_text())
    tests = [t for f in plan['features'] for t in f.get('testcases', [])]
    for t in tests:
        if not (P/t['implementation']).is_file():
            raise ValueError(f"missing planned implementation: {t['implementation']}")
    dynamic = [t for t in tests if t.get('proof_kind', 'static' if t['type']=='static' else 'uvm')=='uvm']
    source = (P/'docs/verification/verification_plan.md').read_text()
    seeds = [int(x) for x in re.search(r'运行seed=([\d,]+)', source)[1].split(',')]
    extra_seeds = [int(x) for x in re.search(r'extended加seed=([\d,]+)', source)[1].split(',')]
    profiles = [(c['config_ref'], c['parameters']) for c in plan['config_sets'] if 'parameters' in c]
    pc = yaml.safe_load((P/'model/parameter_space.yaml').read_text())
    # The named diagnostic risk point supplies the explicitly planned enabled scenario.
    diagnostic = next(c for c in pc['support_matrix']['configs'] if c['id']=='CFG_RISK_DIAG')
    allowed = yaml.safe_load((P/'aixsilicon_ip_watchdog.core').read_text().split('\n',1)[1])['targets']['sim']['parameters']
    profiles.append((diagnostic['id'], {k:v for k,v in diagnostic['params'].items() if k in allowed}))
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%f')
    out = P/'build/reports/regression'/stamp; out.mkdir(parents=True)
    before = inputs()
    result = dict(schema='watchdog-regression/1.0', phase=args.phase, inputs=before,
                  plan_sha256=digest(P/'model/verification.yaml'), jobs=[],
                  static_testcases=[t['id'] for t in tests if t not in dynamic], status='running')
    builds = {}

    def execute(t, config, params, seed, tier):
        index = len(result['jobs'])
        manifest = out/f'job_{index:04d}.json'
        job = dict(testcase_id=t['id'], implementation=t['implementation'], config_id=config,
                   seed=seed, tier=tier, parameters=params, status='fail')
        command = [sys.executable, str(P/'scripts/run_uvm.py'), '--test', Path(t['implementation']).stem,
                   '--seed', str(seed), '--manifest-output', str(manifest)]
        for k,v in sorted(params.items()): command += ['--parameter', f'{k}={v}']
        key = json.dumps(params, sort_keys=True)
        if key in builds: command += ['--reuse', str(builds[key])]
        job['command'] = command
        if inputs()!=before:
            result.update(status='fail', inputs_after=inputs(), detail='source inputs changed; execution stopped')
            (out/'manifest.json').write_text(json.dumps(result,indent=2)+'\n')
            raise ValueError('regression inputs changed; rebuild required')
        if shutil.disk_usage(P).free < 500*1024*1024:
            job['detail']='insufficient local disk: less than 500 MiB free'
            job['exit_code']=125
        else:
            with (out/f'job_{index:04d}.log').open('w') as log:
                completed = subprocess.run(command, cwd=P, stdout=log, stderr=subprocess.STDOUT)
            job['exit_code']=completed.returncode
            if manifest.exists():
                data=json.loads(manifest.read_text())
                job['manifest']={'path':str(manifest.relative_to(P)), 'sha256':digest(manifest)}
                if data.get('binary') and data['inputs']==data['inputs_after']:
                    builds[key]=manifest
                if completed.returncode==0 and data['status']=='pass': job['status']='pass'
        result['jobs'].append(job)
        (out/'manifest.json').write_text(json.dumps(result, indent=2)+'\n')
        print(f"{tier} {config} {t['id']} seed={seed}: {job['status']}", flush=True)
        return job['status']=='pass'

    smoke=[t for t in dynamic if t['tier']=='smoke']
    good=True
    for t in smoke:
        good=execute(t, *profiles[0], 1, 'smoke') and good
    if good and args.phase=='regress':
        for config,params in profiles:
            for t in sorted(dynamic, key=lambda t:(t['tier']!='smoke',t['id'])):
                for seed in seeds+(extra_seeds if t['tier']=='extended' else []):
                    good=execute(t,config,params,seed,'regression') and good
    result['inputs_after']=inputs()
    result['status']='pass' if good and result['inputs_after']==before else 'fail'
    result['scope']='UVM matrix only; static CONFIG/DELIVERY proofs and PV are separate required results'
    (out/'manifest.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(status=result['status'], manifest=str((out/'manifest.json').relative_to(P)))))
    return 0 if result['status']=='pass' else 1


if __name__=='__main__':
    raise SystemExit(main())
