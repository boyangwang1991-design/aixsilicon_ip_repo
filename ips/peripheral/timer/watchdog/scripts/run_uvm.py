"""Reproducible UVM entry: input identity, explicit selectors, fail-closed logs."""
from pathlib import Path
import argparse,hashlib,json,os,re,signal,subprocess,sys,time
P=Path(__file__).resolve().parents[1]
R=Path(os.environ.get('UV_PROJECT',Path(__file__).resolve().parents[7]))
def digest(f):return hashlib.sha256(f.read_bytes()).hexdigest()
def inputs():
    files=[]
    for folder in ['rtl','regs','verification','scripts']:
        files += [f for f in (P/folder).rglob('*') if f.is_file() and '__pycache__' not in f.parts and f.suffix not in ['.pyc','.log']]
    files += [P/'aixsilicon_ip_watchdog.core',R/'uv.lock']
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
    a=parser.parse_args()
    if not re.fullmatch(r'tc_[a-z_]+',a.test) or not (P/'verification/tc'/f'{a.test}.sv').is_file():parser.error('unknown testcase')
    stamp=time.strftime('%Y%m%d_%H%M%S')+f'_{time.time_ns()%1000000:06d}'
    out=P/'reports/uvm'/stamp;out.mkdir(parents=True)
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
        record['parent_build']=dict(path=str(a.reuse),sha256=digest(a.reuse));record['build_exit_code']=0
    else:
        cmd=['fusesoc','--cores-root','.', '--cores-root','build/dependency_adapter','run','--target','sim','--setup','--build','--build-root',str(build),'aixsilicon:ip:watchdog:1.0.0',*['--'+x for x in a.parameter]]
        record['build_command']=cmd;record['build_exit_code']=run(cmd,P,out/'build.log',1800)
        candidates=list(build.glob('*/sim-vcs/aixsilicon_ip_watchdog_1.0.0'))
        if len(candidates)==1:binary=candidates[0]
    if record['build_exit_code']==0 and binary and inputs()==before:
        record['binary']=dict(path=str(binary.relative_to(P)),sha256=digest(binary))
        cov=P/'build/cov'/stamp/'coverage.vdb';cov.parent.mkdir(parents=True)
        cmd=[str(binary),f'+UVM_TESTNAME={a.test}',f'+ntb_random_seed={a.seed}','-cm','line+cond+branch+fsm+tgl','-cm_dir',str(cov)]
        record['run_command']=cmd;record['run_exit_code']=run(cmd,binary.parent,out/'run.log',600)
        text=(out/'run.log').read_text(errors='replace')
        selected=re.findall(r'\[RNTST\] Running test (\w+)',text)
        good=(record['run_exit_code']==0 and selected==[a.test] and f'[WATCHDOG_TEST_PASS] {a.test} ' in text
          and re.search(r'UVM_ERROR\s*:\s*0\b',text) and re.search(r'UVM_FATAL\s*:\s*0\b',text)
          and not re.search(r'(?m)^(?:Error:|Fatal:)|assertion.*fail|WATCHDOG_RUNNER TIMEOUT',text,re.I))
        record['coverage_database']=str(cov.relative_to(P));record['selected_tests']=selected
        record['checks']=re.findall(r'\[WATCHDOG_CHECKS\] checks=(\d+) mismatches=(\d+) pending=(\d+)',text)
        if good and inputs()==before and digest(binary)==record['binary']['sha256']:record['status']='pass'
    record['inputs_after']=inputs();record['ended']=time.time()
    record['logs']=[dict(path=str(f.relative_to(P)),sha256=digest(f)) for f in out.glob('*.log')]
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(dict(status=record['status'],manifest=str((out/'manifest.json').relative_to(P)),checks=record.get('checks'))))
    return 0 if record['status']=='pass' else 1
if __name__=='__main__':sys.exit(main())
