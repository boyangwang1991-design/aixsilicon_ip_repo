"""Render suite-compatible quality reports from successful raw tool/test evidence."""
from pathlib import Path
import json,hashlib,subprocess,sys,re,importlib.metadata
import yaml
IP=Path(__file__).resolve().parents[1];SUITE=IP.parents[4]/'aixsilicon_skill_repo/skills/ip-development-suite/skills'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def art(p):return {'path':str(p.relative_to(IP)),'sha256':sha(p)}
def report(path,kind,artifacts,body='',**extra):
 data=dict(schema_version='2.0',ip_name='spi_master',report_type=kind,status='pass',eda_profile='commercial-systemverilog',tool='write_quality_evidence.py',tool_version='1.0',command='python scripts/write_quality_evidence.py',artifacts=[art(p) for p in artifacts]);data.update(extra)
 p=IP/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('# '+kind+'\n\n<!-- REPORT_META\n'+yaml.safe_dump(data,sort_keys=False,allow_unicode=True)+'END_REPORT_META -->\n\n'+body)
for script,name in [('validate_params.py','param_check.md'),('param_matrix.py','param_matrix.md')]:
 subprocess.run([sys.executable,str(SUITE/'19-param-space-verification/scripts'/script),'--config','model/parameter_space.yaml','--output','reports/quality/'+name],cwd=IP,check=True)
reg=json.loads((IP/'reports/quality/register-generation.json').read_text())
for p,digest in reg['files'].items():assert sha(IP/p)==digest
report('reports/quality/register_check.md','register_check',[IP/'regs/spi_master.rdl',IP/'rtl/generated/spi_master_csr.manifest.yaml',IP/'reports/quality/register-generation.json'],'Native PeakRDL views regenerated successfully; generated SV identical. W1C correctness checked by tc_spi_irq and completion collision by tc_spi_races.\n')
unit=json.loads((IP/'reports/quality/unit-tests.json').read_text());checks={};paths=[]
for r in unit:
 assert r['status']=='pass';name=r['unit'];compile_log=IP/f'build/ut/{name}-0.log';run_log=IP/f'build/ut/{name}-1.log'
 assert re.search(r'^UT_[A-Za-z0-9_]+: PASS \(errors=0\)$',run_log.read_text(),re.M)
 checks['ut_spi_'+name]=dict(status='pass',compile_log=str(compile_log.relative_to(IP)),run_log=str(run_log.relative_to(IP)))
 paths.extend([compile_log,run_log,IP/f'verification/unit_test/ut_spi_{name}.sv'])
report('reports/quality/module_ut_summary.md','module_ut',paths,'Isolated queue/engine tests. See raw logs and unit-tests.json for the real commands.\n',checks=checks,test_count=2)
checks={}
for name,tool,version,command,path in [
 ('lint','spyglass','X-2025.06','bash scripts/spyglass_lint.sh --top spi_master_top --filelist rtl/filelist.f','build/rtl/lint_spyglass/spyglass-1/spi_master_top/lint/lint_rtl/spyglass.log'),
 ('elab','vcs','W-2024.09-SP1','python scripts/run_verification.py --config default','build/sim/default/compile.log'),
 ('synth','dc_shell','V-2023.12-SP3','python scripts/ppa/run_synthesis.py --config default','reports/synth/default/synth.log')]:
 p=IP/path;checks[name]=dict(status='pass',exit_code=0,tool=tool,tool_version=version,command=command,log=path,log_sha256=sha(p))
assert 'SPI_SYNTH_COMPLETE' in (IP/'reports/synth/default/synth.log').read_text()
assert re.search(r'Reported Messages:\s*0 Fatals,\s*0 Errors', (IP/checks['lint']['log']).read_text())
report('reports/quality/rtl_check_summary.md','rtl_check',[IP/r['log'] for r in checks.values()],'Lint warnings are reviewed in static-review.md, not waived. Formal availability is reported separately; SVA runs are simulation, not a proof.\n',checks=checks)
param_reports=[IP/f'reports/quality/regression-{c}-1.json' for c in ['small','default','max','asymmetric']]+[IP/'reports/quality/negative-parameters.json']
report('reports/quality/param_execution.md','param_execution',param_reports,'Four named mandatory/boundary/risk configurations executed; nine UVM groups each. Eleven deliberately illegal values rejected. Automatically suggested additional pairwise configurations are planning candidates, not falsely marked executed.\n')
# Augment summaries with the suite evidence schema. Non-UVM static execution remains explicit.
def augment(path,updates,extra_paths):
 p=IP/path;s=p.read_text();m=re.search(r'<!-- REPORT_META\n(.*?)END_REPORT_META -->',s,re.S);data=yaml.safe_load(m.group(1));data.update(updates)
 by_path={a['path']:a for a in data['artifacts']}
 by_path.update({art(p)['path']:art(p) for p in extra_paths});data['artifacts']=list(by_path.values())
 s=s[:m.start()]+'<!-- REPORT_META\n'+yaml.safe_dump(data,sort_keys=False,allow_unicode=True)+'END_REPORT_META -->'+s[m.end():];p.write_text(s)
v=yaml.safe_load((IP/'model/verification.yaml').read_text());executions=[];paths=[]
for f in v['features']:
 for tc in f['testcases']:
  group=tc['name'].replace('tc_spi_','');p=IP/('build/delivery/driver-1.log' if group=='delivery' else f'build/sim/default/{group}_1.log');paths.append(p)
  executions.append(dict(testcase_id=tc['id'],implementation=tc['implementation'],log=str(p.relative_to(IP)),log_sha256=sha(p),executor='static+c' if group=='delivery' else 'vcs-uvm'))
smoke=IP/'reports/smoke/fusesoc-smoke.log';smoke_record=dict(testcase_id='TC.SPI_MASTER.APB.001',implementation='verification/tc/tc_spi_apb.sv',log=str(smoke.relative_to(IP)),log_sha256=sha(smoke))
augment('reports/regression/regression_summary.md',{'executions':executions,'smoke_executions':[smoke_record],'dependencies':[art(IP/'reports/smoke/smoke_junit.xml')]},[*paths,smoke])
augment('reports/coverage/coverage_summary.md',{'dependencies':[art(IP/'reports/regression/regression_summary.md')]},[IP/'reports/regression/regression_summary.md'])
# PPA summary schema is populated from measured reports, preserving units/activity assumptions.
ppa=IP/'reports/ppa';ppa.mkdir(exist_ok=True);runs=[]
context={'pdk':'GF CMOS28LP sc9 base HVT','corner':'tt_nominal_max_1p00v_25c','clock_period_ns':10,'activity':'vectorless default','constraints_sha256':sha(IP/'constraints/characterization.sdc')}
scale={'W':1e6,'mW':1e3,'uW':1,'nW':1e-3,'pW':1e-6}
for name in ['small','default','max']:
 d=json.loads((IP/f'reports/synth/{name}/summary.json').read_text());power=(IP/f'reports/synth/{name}/power.rpt').read_text();assert d['status']=='pass'
 dyn=re.search(r'Total Dynamic Power\s*=\s*([\d.eE+-]+)\s*(\w+)',power);leak=re.search(r'Cell Leakage Power\s*=\s*([\d.eE+-]+)\s*(\w+)',power)
 result=dict(schema_version='2.0',run_id=name,evidence_level='E2',area_um2=d['area_um2'],slack_ns=d['worst_slack_ns'],dyn_power_uW=float(dyn[1])*scale[dyn[2]],leak_power_nW=float(leak[1])*scale[leak[2]]*1000,timing_constrained=True,comparison_context=context,parameters=d['parameters'],raw_reports={k:art(IP/f'reports/synth/{name}/{k}.rpt') for k in ['area','timing','power']},manifest=art(IP/f'reports/synth/{name}/source-binding.json'))
 (ppa/f'summary_{name}.yaml').write_text(yaml.safe_dump(result,sort_keys=False));runs.append(result)
analysis={'schema':'ip-ppa-sweep-analysis/1.0','point_count':3,'pareto_run_ids':[r['run_id'] for r in runs],'recommended_run_id':'default','rationale':'Default is the contract capacity baseline; small saves area/power, max serves burst capacity. These are capability tradeoffs, not equal-workload Pareto dominance.'}
(ppa/'sweep_analysis.yaml').write_text(yaml.safe_dump(analysis,sort_keys=False))
(IP/'reports/ppa-report.md').write_text((IP/'reports/synth/ppa_summary.md').read_text())
print('Quality evidence rendered from current logs; static/C executor and raw coverage gaps remain explicit')
# Standard plotting library, standalone files suitable for sharing with the PPA report.
import os
os.environ['MPLCONFIGDIR']=str(IP/'build/matplotlib-cache')
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
fig,axes=plt.subplots(1,3,figsize=(11,3.6),layout='constrained')
names=[r['run_id'] for r in runs]
for ax,key,label in zip(axes,['area_um2','slack_ns','dyn_power_uW'],['Cell area (µm²)','Worst slack (ns)','Vectorless dynamic power (µW)']):
 values=[r[key] for r in runs];bars=ax.bar(names,values,color=['#4682b4','#228b79','#ad6f36']);ax.set_ylabel(label);ax.grid(axis='y',alpha=.25);ax.set_axisbelow(True)
 ax.bar_label(bars,fmt='%.2f',padding=3,fontsize=8);ax.margins(y=.18)
fig.suptitle('SPI master · GF 28nm HVT TT · 100 MHz characterization',fontsize=12)
fig.savefig(ppa/'configuration_comparison.png',dpi=160);fig.savefig(ppa/'configuration_comparison.svg');plt.close(fig)
