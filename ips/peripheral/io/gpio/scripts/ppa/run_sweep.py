"""Run declared GPIO DC characterization points with native PPA manifest/reader."""
from pathlib import Path
import hashlib,json,os,shutil,subprocess,tempfile,time
import yaml
ROOT=Path(__file__).resolve().parents[2]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 lock=json.loads((ROOT/'scripts/ppa/core.lock.json').read_text());core=ROOT/'scripts/ppa/core'/lock['core_id']
 points=[(8,100),(32,100),(128,100)]
 summary_dir=ROOT/'reports/ppa';summary_dir.mkdir(parents=True,exist_ok=True)
 def invoke(cmd,log=None,env=None,timeout=3600):
  if log:
   with log.open('w') as f:return subprocess.run(cmd,cwd=ROOT,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=timeout).returncode
  return subprocess.run(cmd,cwd=ROOT,env=env,timeout=timeout).returncode
 outcomes=[]
 for width,freq in points:
  out=ROOT/'build/ppa'/f'n{width}_{freq}mhz_{time.time_ns()}';out.mkdir(parents=True)
  manifest=out/'manifest.yaml'
  cmd=['uv','run','--locked','--no-sync','python',str(core/'gen_sweep_manifest.py'),'--pdk','model/pdk.yaml','--ip-name','gpio','--config-id',f'CFG_WIDTH_{width}','--freq-mhz',str(freq),'--params',f'N_GPIO={width}','--rtl-dir','rtl','--constraints','constraints/gpio_characterization.sdc','--constraint-profile','GPIO_CHARACTERIZATION_100MHZ','--evaluator-script',str(core/'extract_ppa_summary.py'),'--tool-version','V-2023.12-SP3','--compile-option','compile_ultra','--input','build/cbb_adapter/rtl/parity_gen_check.sv','--input','build/rtl/pdk_setup.tcl','--output',str(manifest)]
  if invoke(cmd):raise RuntimeError('PPA manifest failed')
  frozen=yaml.safe_load(manifest.read_text())['inputs']
  scratch=Path(tempfile.mkdtemp(prefix=f'gpio_ppa_n{width}_',dir='/tmp'))
  env=os.environ.copy();env.update(IP_ROOT=str(ROOT),GPIO_PDK_SETUP=str(ROOT/'build/rtl/pdk_setup.tcl'),GPIO_SYNTH_SDC=str(ROOT/'constraints/gpio_characterization.sdc'),GPIO_SYNTH_PARAMETERS=f'N_GPIO={width}')
  command=['uv','run','--locked','--no-sync','fusesoc','--cores-root=.','--cores-root=build/cbb_adapter','run','--target=synth','--build-root='+str(scratch),'aixsilicon:ip:gpio:0.1.0']
  rc=invoke(command,out/'console.log',env)
  reports=list(scratch.rglob('reports/area.rpt'))
  if len(reports)==1:
   for name in ('area.rpt','timing.rpt','power.rpt','design_check.rpt','constraints.rpt','synth.log'):
    source=reports[0].parent/name
    if source.exists():shutil.copy2(source,out/name)
  unchanged=all((ROOT/x['path']).is_file() and digest(ROOT/x['path'])==x['sha256'] for x in frozen)
  result={'command':command,'exit_code':rc,'inputs_unchanged':unchanged,'scratch':str(scratch),'reports':{f.name:digest(f) for f in out.glob('*.rpt')}}
  (out/'execution.json').write_text(json.dumps(result,indent=2)+'\n')
  ok=rc==0 and unchanged and len(reports)==1 and 'GPIO_SYNTHESIS_COMPLETE' in (out/'synth.log').read_text()
  if ok:
   cmd=['uv','run','--locked','--no-sync','python',str(core/'extract_ppa_summary.py'),'--manifest',str(manifest),'--area-report',str(out/'area.rpt'),'--timing-report',str(out/'timing.rpt'),'--power-report',str(out/'power.rpt'),'--evidence-level','E1','--output',str(summary_dir/f'summary_n{width}.yaml')]
   ok=invoke(cmd)==0
  outcomes.append({'width':width,'freq_mhz':freq,'status':'pass' if ok else 'fail','directory':str(out.relative_to(ROOT))})
  (summary_dir/'sweep_execution.json').write_text(json.dumps(outcomes,indent=2)+'\n')
  print('PPA',outcomes[-1],flush=True)
 return 0 if all(x['status']=='pass' for x in outcomes) else 1
if __name__=='__main__':raise SystemExit(main())
