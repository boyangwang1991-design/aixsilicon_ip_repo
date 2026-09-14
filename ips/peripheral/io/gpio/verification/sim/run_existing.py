"""Run an identity-checked GPIO UVM build, with explicit wall-clock budget."""
from pathlib import Path
import argparse,json,sys,tempfile,re
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from scripts.run_uvm import snapshot,sha,run

def main():
 a=argparse.ArgumentParser();a.add_argument('--build',type=Path,required=True);a.add_argument('--tests',nargs='+',required=True);a.add_argument('--seeds',nargs='+',type=int,default=[1]);a.add_argument('--timeout',type=int,default=1200);args=a.parse_args()
 build=args.build.resolve();manifest=json.loads((build/'build.json').read_text());binary=ROOT/manifest['binary']['path'];runner_hash=sha(Path(__file__))
 if snapshot()!=manifest['inputs'] or sha(binary)!=manifest['binary']['sha256']:raise RuntimeError('Refuse stale build')
 results=[];batch=Path(tempfile.mkdtemp(prefix='batch_',dir=build))
 for test in args.tests:
  for seed in args.seeds:
   if snapshot()!=manifest['inputs'] or sha(Path(__file__))!=runner_hash:raise RuntimeError('Inputs changed')
   work=batch/f'{test}_{seed}';work.mkdir();log=work/'run.log'
   cmd=[str(binary),'+UVM_TESTNAME=tc_gpio_'+test,'+ntb_random_seed='+str(seed),'-cm','line+cond+branch+tgl+fsm+assert','-cm_dir',str(work/'coverage.vdb'),'-cm_name',f'{test}_{seed}']
   rc=run(cmd,work,log,args.timeout);text=log.read_text(errors='replace')
   ok=rc==0 and f'tc_gpio_{test} PASS' in text and re.search(r'UVM_ERROR\s*:\s*0\b',text) and re.search(r'UVM_FATAL\s*:\s*0\b',text) and not re.search(r'Error-\[|Fatal:|TIMEOUT',text)
   results.append({'testcase_id':f'TC.GPIO.{test.upper()}.001','class':f'tc_gpio_{test}','seed':seed,'status':'pass' if ok else 'fail','command':cmd,'exit_code':rc,'log':{'path':str(log.relative_to(ROOT)),'sha256':sha(log)}})
   data={'schema':'gpio-uvm-results/1.0','build':{'path':str((build/'build.json').relative_to(ROOT)),'sha256':sha(build/'build.json')},'runner':{'path':str(Path(__file__).relative_to(ROOT)),'sha256':runner_hash},'timeout_seconds':args.timeout,'inputs_after':snapshot(),'executions':results}
   (batch/'results.json').write_text(json.dumps(data,indent=2)+'\n');print(test,seed,results[-1]['status'],str(log.relative_to(ROOT)),flush=True)
 if snapshot()!=manifest['inputs']:raise RuntimeError('Inputs changed after execution')
 return 0 if all(x['status']=='pass' for x in results) else 1
if __name__=='__main__':raise SystemExit(main())
