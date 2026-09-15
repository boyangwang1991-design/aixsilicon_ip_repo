"""Reproducible FuseSoC/VCS module/integration regression, with bound input hashes."""
from pathlib import Path
import os,sys,subprocess,json,hashlib,time,shutil,yaml
p=Path(__file__).resolve().parents[1];os.chdir(p)
workflow=Path(os.environ['UV_PROJECT'])
cbb=workflow/'repos/aixsilicon_cbb_repo/components/arbitration_scheduling/round_robin_arbiter'
runid=time.strftime('%Y%m%d_%H%M%S');out=p/'build/reports'/runid;out.mkdir(parents=True)
# The asset's legacy core lacks CAPI2 paramtype. Adapt build metadata only;
# source remains read-only in its owning repository, never copied into the IP.
adapter=p/'build/dependency_adapter';adapter.mkdir(parents=True,exist_ok=True)
(adapter/'round_robin.core').write_text('CAPI=2:\n'+yaml.safe_dump(dict(name='aixsilicon:cbb:round_robin_arbiter:0.1.0',filesets={'rtl':{'files':[str(cbb/'rtl/round_robin_arbiter.sv')],'file_type':'systemVerilogSource'}},targets={'default':{'filesets':['rtl']}})))
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
def local_inputs():
 return sorted({f for folder in ['docs','model','rtl','verification','scripts','regs','constraints','configs'] for f in (p/folder).rglob('*') if f.is_file() and '__pycache__' not in f.parts and f.name!='quality.yaml'} | set(p.glob('*.core')) | {p/'watchdog_contract.md'})
def inventory():
 inputs=local_inputs()+sorted(cbb.glob('rtl/*.sv'))+sorted(cbb.glob('fusesoc/*.core'))
 return {str(f.relative_to(p)) if f.is_relative_to(p) else str(f):sha(f) for f in inputs}
base=inventory();results=[]
(out/'inputs.before.sha256').write_text(''.join(f'{base[str(f.relative_to(p))]}  {f.relative_to(p)}\n' for f in local_inputs()))
configs=[('channel32','ut_channel',['--W=32']),('channel48','ut_channel',['--W=48']),('channel64','ut_channel',['--W=64']),('top_async','ut_top',['--PS=7','--WS=5']),('top_fast_apb','ut_top',['--PS=3','--WS=7'])]
if len(sys.argv)>1:configs=[c for c in configs if c[0] in sys.argv[1:]]
if not configs:raise SystemExit('Unknown configuration')
for name,target,args in configs:
 build=p/'build'/'regression'/runid/name
 cmd=['fusesoc','--cores-root',str(p),'--cores-root',str(adapter),'run','--target',target,'--build-root',str(build),'aixsilicon:ip:watchdog:1.0.0',*args]
 log=out/(name+'.log')
 started=time.time()
 with log.open('w') as stream:
  try:proc=subprocess.run(cmd,stdout=stream,stderr=subprocess.STDOUT,timeout=600);rc=proc.returncode
  except subprocess.TimeoutExpired:rc=124
 text=log.read_text(errors='replace');want='UT_WATCHDOG_CHANNEL: PASS' if target=='ut_channel' else 'UT_WATCHDOG_TOP: PASS'
 passed=rc==0 and want in text and 'Fatal:' not in text and inventory()==base
 results.append(dict(configuration=name,command=cmd,exit_code=rc,status='pass' if passed else 'fail',elapsed_s=round(time.time()-started,2),log=str(log.relative_to(p)),log_sha256=sha(log),binaries={str(f.relative_to(p)):sha(f) for f in build.rglob('aixsilicon_ip_watchdog_1.0.0') if f.is_file()}))
 print(name,results[-1]['status'],flush=True)
 (out/'manifest.json').write_text(json.dumps(dict(schema='watchdog-execution/1',inputs=base,results=results),indent=2)+'\n')
 if not passed:
  print(text[-5000:]);raise SystemExit(1)
print('WATCHDOG_REGRESSION PASS',flush=True)
if len(results)==5:
 (out/'inputs.after.sha256').write_text(''.join(f'{sha(f)}  {f.relative_to(p)}\n' for f in local_inputs()))
 artifacts=[out/'inputs.before.sha256',out/'inputs.after.sha256',out/'manifest.json']
 checks={}
 for name in ['channel','top']:
  log=out/f'ut_watchdog_{name}.log'
  selected=[r for r in results if r['configuration'].startswith(name)]
  log.write_text('\n'.join((p/r['log']).read_text() for r in selected))
  artifacts.append(log)
  checks[f'ut_watchdog_{name}']=dict(status='pass',compile_log=str(log.relative_to(p)),run_log=str(log.relative_to(p)))
 def record(f):return dict(path=str(f.relative_to(p)),sha256=sha(f))
 data=dict(schema_version='2.0',ip_name='watchdog',report_type='module_ut',status='pass',eda_profile='commercial-systemverilog',tool='vcs',tool_version='W-2024.09-SP1_Full64',command='bash verification/unit_test/run_ut.sh',test_count=2,checks=checks,artifacts=[record(f) for f in artifacts],inputs_manifest=record(artifacts[0]),inputs_after_manifest=record(artifacts[1]),module_coverage={'watchdog_channel':['ut_watchdog_channel','ut_watchdog_top'],'watchdog_top':['ut_watchdog_top'],'watchdog_reg_adapter':['ut_watchdog_top'],'watchdog_csr':['ut_watchdog_top']})
 report=p/'build/reports/quality/module_ut_summary.md';report.parent.mkdir(parents=True,exist_ok=True)
 report.write_text('# Watchdog Module UT\n\n<!-- REPORT_META\n'+yaml.safe_dump(data,sort_keys=False)+'END_REPORT_META -->\n')
