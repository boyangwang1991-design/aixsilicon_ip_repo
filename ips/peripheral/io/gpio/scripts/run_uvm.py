"""Build/run GPIO UVM through FuseSoC; preserve immutable inputs and actual results."""
from pathlib import Path
import argparse, hashlib, json, os, re, subprocess, tempfile
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def snapshot():
 files=[]
 for d in ('rtl','regs','verification/env','verification/th','verification/tc','verification/ral','verification/assertions','build/cbb_adapter'):
  files.extend(p for p in (ROOT/d).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
 files += [ROOT/'aixsilicon_ip_gpio.core',ROOT/'scripts/run_uvm.py',ROOT/'scripts/generate_core.py',ROOT/'verification/sim/Makefile']
 return {str(p.relative_to(ROOT)):sha(p) for p in sorted(set(files))}
def run(cmd,cwd,log,timeout):
 with log.open('w') as f:
  try:return subprocess.run(cmd,cwd=cwd,stdout=f,stderr=subprocess.STDOUT,timeout=timeout).returncode
  except subprocess.TimeoutExpired:f.write('\nTIMEOUT\n');return 124

def main():
 a=argparse.ArgumentParser();a.add_argument('--tests',nargs='+',default=['apb']);a.add_argument('--seeds',nargs='+',type=int,default=[1]);a.add_argument('--width',type=int,default=32);a.add_argument('--parity',type=int,default=0);a.add_argument('--build-only',action='store_true');a.add_argument('--reuse',type=Path)
 args=a.parse_args();base=ROOT/'build/sim/uvm';base.mkdir(parents=True,exist_ok=True)
 if args.reuse:
  build=args.reuse.resolve();manifest=json.loads((build/'build.json').read_text())
  if manifest['inputs']!=snapshot() or manifest['width']!=args.width or manifest['parity']!=args.parity:raise RuntimeError('Cannot reuse stale or different configuration build')
  binary=ROOT/manifest['binary']['path']
  if sha(binary)!=manifest['binary']['sha256']:raise RuntimeError('Binary changed')
 else:
  build=Path(tempfile.mkdtemp(prefix=f'n{args.width}_p{args.parity}_',dir=base));before=snapshot()
  cmd=['uv','run','--locked','--no-sync','fusesoc','--cores-root=.','--cores-root=build/cbb_adapter','run','--target=uvm','--setup','--build','--build-root='+str(build/'fusesoc'),'aixsilicon:ip:gpio:0.1.0','--N_GPIO='+str(args.width),'--CFG_PARITY_EN='+str(args.parity)]
  rc=run(cmd,ROOT,build/'compile.console.log',600)
  print('BUILD',build,'exit',rc,flush=True)
  if rc:return rc
  binaries=[p for p in (build/'fusesoc').rglob('aixsilicon_ip_gpio_0.1.0') if p.is_file() and os.access(p,os.X_OK)]
  if len(binaries)!=1:raise RuntimeError(f'Expected one simv: {binaries}')
  binary=binaries[0]
  if before!=snapshot():raise RuntimeError('Build inputs changed')
  manifest={'schema':'gpio-uvm-build/1.0','command':cmd,'exit_code':rc,'tool':'VCS','tool_version':'W-2024.09-SP1','width':args.width,'parity':args.parity,'inputs':before,'inputs_after':snapshot(),'binary':{'path':str(binary.relative_to(ROOT)),'sha256':sha(binary)}}
  (build/'build.json').write_text(json.dumps(manifest,indent=2)+'\n')
 if args.build_only:return 0
 results=[]
 for test in args.tests:
  for seed in args.seeds:
   if snapshot()!=manifest['inputs']:raise RuntimeError('Sources changed during regression')
   work=Path(tempfile.mkdtemp(prefix=f'{test}_{seed}_',dir=build));log=work/'run.log'
   cmd=[str(binary),'+UVM_TESTNAME=tc_gpio_'+test,'+ntb_random_seed='+str(seed),'-cm','line+cond+branch+tgl+fsm+assert','-cm_dir',str(work/'coverage.vdb'),'-cm_name',f'{test}_{seed}']
   rc=run(cmd,work,log,180);text=log.read_text(errors='replace')
   ok=rc==0 and f'tc_gpio_{test} PASS' in text and re.search(r'UVM_ERROR\s*:\s*0\b',text) and re.search(r'UVM_FATAL\s*:\s*0\b',text) and not re.search(r'Error-\[|Fatal:|TIMEOUT',text)
   results.append({'testcase_id':f'TC.GPIO.{test.upper()}.001','class':f'tc_gpio_{test}','seed':seed,'status':'pass' if ok else 'fail','command':cmd,'exit_code':rc,'log':{'path':str(log.relative_to(ROOT)),'sha256':sha(log)}})
   print(test,seed,results[-1]['status'],str(log.relative_to(ROOT)),flush=True)
 if snapshot()!=manifest['inputs']:raise RuntimeError('Inputs changed after regression')
 out=build/'results.json'
 if out.exists():out=build/f'results_{len(list(build.glob("results*.json")))}.json'
 out.write_text(json.dumps({'schema':'gpio-uvm-results/1.0','build':{'path':str((build/'build.json').relative_to(ROOT)),'sha256':sha(build/'build.json')},'inputs_after':snapshot(),'executions':results},indent=2)+'\n')
 return 0 if all(r['status']=='pass' for r in results) else 1
if __name__=='__main__':raise SystemExit(main())
