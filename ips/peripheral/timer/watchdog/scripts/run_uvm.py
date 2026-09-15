"""Reproducible UVM entry: input identity, explicit selectors, fail-closed logs."""
from pathlib import Path
import argparse,hashlib,json,os,re,signal,subprocess,sys,time
import yaml
P=Path(__file__).resolve().parents[1]
R=Path(os.environ.get('UV_PROJECT',Path(__file__).resolve().parents[7]))
SUITE=Path(os.environ.get('SUITE_DIR',R/'.roo/skills/ip-development-suite'))
sys.path.insert(0,str(SUITE/'scripts'))
from parse_uvm_log import parse_uvm_log
def digest(f):return hashlib.sha256(f.read_bytes()).hexdigest()
def runtime_inventory(binary):
    directory=Path(str(binary)+'.daidir')
    if not directory.is_dir():raise ValueError('missing compiled VCS runtime directory')
    files=[binary,*[f for f in directory.rglob('*') if f.is_file()]]
    return {str(f.relative_to(P)):digest(f) for f in sorted(files)}
BUILD_SCRIPTS=('run_uvm.py','run_regression.py','prepare_dependencies.py',
               'generate_package.py','generate_register_views.py','generate_verification_views.py')
def inputs(extra_files=()):
    files=[]
    for folder in ['rtl','regs','verification','docs','constraints','configs']:
        files += [f for f in (P/folder).rglob('*') if f.is_file() and '__pycache__' not in f.parts and f.suffix not in ['.pyc','.log']]
    # Bind the actual simulation/generation drivers. Postprocessing and unrelated
    # EDA drivers bind themselves in their own result; they cannot change simv.
    files += [P/'scripts'/name for name in BUILD_SCRIPTS]
    files += list(extra_files)
    files += [P/'aixsilicon_ip_watchdog.core',P/'watchdog_contract.md',R/'uv.lock']
    files += [f for f in (P/'model').glob('*.yaml') if f.name!='quality.yaml']
    files += [SUITE/'scripts/parse_uvm_log.py']
    files += [R/'repos/aixsilicon_cbb_repo/components/arbitration_scheduling/round_robin_arbiter/rtl/round_robin_arbiter.sv']
    files += list((R/'repos/aixsilicon_vip_repo/vip/amba/apb/src').rglob('*.sv'))
    return {str(f.relative_to(R)):digest(f) for f in sorted(set(files))}
def run(argv,cwd,log,timeout):
    with log.open('w') as stream:
        process=subprocess.Popen(argv,cwd=cwd,stdout=stream,stderr=subprocess.STDOUT,start_new_session=True)
        try:return process.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid,signal.SIGTERM)
            try:process.wait(timeout=10)
            except subprocess.TimeoutExpired:os.killpg(process.pid,signal.SIGKILL);process.wait()
            stream.write('\nWATCHDOG_RUNNER TIMEOUT\n');return 124

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--test',default='tc_bus');parser.add_argument('--seed',type=int,default=1)
    parser.add_argument('--parameter',action='append',default=[]);parser.add_argument('--reuse',type=Path)
    parser.add_argument('--manifest-output',type=Path)
    a=parser.parse_args()
    allowed=yaml.safe_load((P/'aixsilicon_ip_watchdog.core').read_text().split('\n',1)[1])['targets']['sim']['parameters']
    if any(not re.fullmatch(r'[A-Z_]+=-?\d+',x) or x.split('=')[0] not in allowed for x in a.parameter):
        parser.error('unknown or non-integer simulation parameter')
    if len({x.split('=')[0] for x in a.parameter})!=len(a.parameter):parser.error('duplicate parameter')
    if a.manifest_output and (not a.manifest_output.resolve().is_relative_to(P/'build') or a.manifest_output.exists()):
        parser.error('manifest output must be a new build/ path')
    if not re.fullmatch(r'tc_[a-z_]+',a.test) or not (P/'verification/tc'/f'{a.test}.sv').is_file():parser.error('unknown testcase')
    stamp=time.strftime('%Y%m%d_%H%M%S')+f'_{time.time_ns()%1000000:06d}'
    out=P/'build/reports/uvm'/stamp;out.mkdir(parents=True)
    build=P/'build/sim'/stamp
    env_command=[sys.executable,str(P/'scripts/prepare_dependencies.py')]
    subprocess.run(env_command,cwd=P,check=True)
    before=inputs();(out/'inputs_before.json').write_text(json.dumps(before,indent=2)+'\n')
    record=dict(schema='watchdog-uvm-run/1.0',testcase=a.test,seed=a.seed,parameters=a.parameter,inputs=before,started=time.time(),status='fail')
    binary=None
    if a.reuse:
        parent=json.loads(a.reuse.read_text())
        if parent['inputs']!=before or parent['parameters']!=a.parameter:raise SystemExit('stale/incompatible build reuse refused')
        binary=P/parent['binary']['path']
        if digest(binary)!=parent['binary']['sha256']:raise SystemExit('binary changed')
        if runtime_inventory(binary)!=parent.get('runtime_artifacts'):raise SystemExit('compiled VCS runtime changed or unbound')
        record['parent_build']=dict(path=str(a.reuse),sha256=digest(a.reuse));record['build_exit_code']=0
    else:
        cmd=['fusesoc','--verbose','--cores-root','.', '--cores-root','build/dependency_adapter','run','--target','sim','--setup','--build','--build-root',str(build),'aixsilicon:ip:watchdog:1.0.0',*['--'+x for x in a.parameter]]
        record['build_command']=cmd;record['build_exit_code']=run(cmd,P,out/'build.log',1800)
        candidates=list(build.glob('*/sim-vcs/aixsilicon_ip_watchdog_1.0.0'))
        if len(candidates)==1:binary=candidates[0]
    if record['build_exit_code']==0 and binary and inputs()==before:
        record['binary']=dict(path=str(binary.relative_to(P)),sha256=digest(binary))
        record['runtime_artifacts']=runtime_inventory(binary)
        cov=P/'build/cov'/stamp/'coverage.vdb';cov.parent.mkdir(parents=True)
        cmd=[str(binary),f'+UVM_TESTNAME={a.test}',f'+ntb_random_seed={a.seed}','-cm','line+cond+branch+fsm+tgl','-cm_dir',str(cov)]
        record['run_command']=cmd;record['run_exit_code']=run(cmd,binary.parent,out/'run.log',600)
        text=(out/'run.log').read_text(errors='replace')
        version=re.search(r'Compiler version ([^;\s]+)',text)
        record['tool']='vcs';record['tool_version']=version[1] if version else 'unknown'
        selected=re.findall(r'\[RNTST\] Running test (\w+)',text)
        good=(record['run_exit_code']==0 and selected==[a.test] and f'[WATCHDOG_TEST_PASS] {a.test} ' in text
          and parse_uvm_log(text)['result']=='PASSED'
          and re.search(r'UVM_ERROR\s*:\s*0\b',text) and re.search(r'UVM_FATAL\s*:\s*0\b',text)
          and not re.search(r'(?m)^(?:Error:|Fatal:)|assertion.*fail|WATCHDOG_RUNNER TIMEOUT',text,re.I))
        record['coverage_database']=str(cov.relative_to(P));record['selected_tests']=selected
        record['checks']=re.findall(r'\[WATCHDOG_CHECKS\] checks=(\d+) mismatches=(\d+) pending=(\d+)',text)
        if good and inputs()==before and runtime_inventory(binary)==record['runtime_artifacts']:record['status']='pass'
    record['inputs_after']=inputs();record['ended']=time.time()
    record['logs']=[dict(path=str(f.relative_to(P)),sha256=digest(f)) for f in out.glob('*.log')]
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
    if a.manifest_output:
        a.manifest_output.parent.mkdir(parents=True,exist_ok=True)
        a.manifest_output.write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(dict(status=record['status'],manifest=str((out/'manifest.json').relative_to(P)),checks=record.get('checks'))))
    return 0 if record['status']=='pass' else 1
if __name__=='__main__':sys.exit(main())
