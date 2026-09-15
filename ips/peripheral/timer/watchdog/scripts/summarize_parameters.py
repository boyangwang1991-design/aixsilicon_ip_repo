"""Produce a local, fail-closed summary of the actually attempted PV matrix."""
from pathlib import Path
import argparse,collections,json,sys,yaml
P=Path(__file__).resolve().parents[1];sys.path.insert(0,str(P/'scripts'))
from run_parameter_verification import inputs
from run_uvm import digest
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--manifest',type=Path,required=True)
source=parser.parse_args().manifest.resolve()
if not source.is_relative_to(P/'build'):raise ValueError('PV manifest must be local build evidence')
data=json.loads(source.read_text())
if data['inputs']!=inputs() or data.get('inputs_after')!=inputs():raise ValueError('stale PV execution identity')
counts=collections.Counter();artifacts=[dict(path=str(source.relative_to(P)),sha256=digest(source)),dict(path=str(Path(__file__).resolve().relative_to(P)),sha256=digest(Path(__file__)))]
for case in data['configurations']:
 counts['configurations']+=1
 for name,result in case['methods'].items():counts[name+':'+result['status']]+=1
 if case.get('execution'):
  e=case['execution'];counts['exit:'+str(e['exit_code'])]+=1
  for key in ['log','config_source']:
   item=e[key]
   if digest(P/item['path'])!=item['sha256']:raise ValueError('PV raw evidence changed')
   artifacts.append(item)
status='pass' if data['status']=='pass' and data['complete_matrix'] else 'fail'
meta=dict(schema_version='2.0',ip_name='watchdog',report_type='param_execution',status=status,eda_profile='commercial-systemverilog',tool='VCS and independent LRS semantic checker',tool_version='W-2024.09-SP1_Full64',command='python scripts/summarize_parameters.py --manifest '+str(source.relative_to(P)),artifacts=artifacts,complete_matrix=data['complete_matrix'],counts=dict(counts),scope='elaboration/capability/reset-default readback and schema negatives; planned independent lint/formal/synth and functional matrix closure remain required')
out=P/'build/reports/quality/param_execution.md';out.write_text('# Parameter execution summary\n\n<!-- REPORT_META\n'+yaml.safe_dump(meta,allow_unicode=True,sort_keys=False)+'END_REPORT_META -->\n')
print(json.dumps(dict(status=status,counts=dict(counts))))
raise SystemExit(0 if status=='pass' else 1)
