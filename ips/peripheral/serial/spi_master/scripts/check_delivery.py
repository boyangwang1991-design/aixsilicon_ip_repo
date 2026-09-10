"""Executable static/software delivery proof; evidence assertions fail closed."""
from pathlib import Path
import subprocess,json,hashlib,xml.etree.ElementTree as ET
import yaml
IP=Path(__file__).resolve().parents[1];out=IP/'build/delivery';out.mkdir(parents=True,exist_ok=True)
checks=[]
executions=[]
def check(name,condition):
 checks.append({'name':name,'status':'pass' if condition else 'fail'})
required=['scripts/check_delivery.py','sw/tests/test_driver.c','rtl/spi_master_top.sv','rtl/spi_master_engine.sv','rtl/spi_master_queues.sv','regs/spi_master.rdl','aixsilicon_ip_spi_master.core','sw/include/spi_master_regs.h','sw/include/spi_master.h','sw/src/spi_master.c','sw/examples/transactions.c','docs/integration.md','docs/verification/index.md','reports/skill-improvement-report.md']
for path in required:check('artifact '+path,(IP/path).is_file())
model=yaml.safe_load((IP/'model/parameter_space.yaml').read_text());check('four extracted parameters',len(model['parameters'])==4)
for config in ['small','default','max','asymmetric']:
 p=IP/f'reports/quality/regression-{config}-1.json'
 check('full regression '+config,p.is_file() and len(json.loads(p.read_text())['results'])==9 and all(r['status']=='pass' for r in json.loads(p.read_text())['results']))
for config in ['small','default','max']:
 p=IP/f'reports/synth/{config}/summary.json';d=json.loads(p.read_text()) if p.exists() else {}
 check('real PDK synthesis '+config,d.get('status')=='pass' and d.get('worst_slack_ns',-1)>=0 and (IP/d.get('netlist','missing')).is_file())
for report,count in [('negative-parameters.json',11),('unit-tests.json',2)]:
 p=IP/'reports/quality'/report;d=json.loads(p.read_text()) if p.exists() else []
 check(report,len(d)==count and all(r['status']=='pass' for r in d))
commands=[['cc','-std=c11','-Wall','-Wextra','-Werror','-pedantic','-I',str(IP/'sw/include'),str(IP/'sw/src/spi_master.c'),str(IP/'sw/tests/test_driver.c'),'-o',str(out/'driver-test')],[str(out/'driver-test')],['cc','-std=c11','-Wall','-Wextra','-Werror','-pedantic','-I',str(IP/'sw/include'),'-fsyntax-only',str(IP/'sw/examples/transactions.c')]]
for i,command in enumerate(commands):
 r=subprocess.run(command,cwd=out,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30)
 executions.append({'command':command,'exit_code':r.returncode})
 (out/f'driver-{i}.log').write_text(str(command)+'\n'+r.stdout)
 check('driver '+str(i),r.returncode==0 and (i!=1 or 'DRIVER_TEST PASS' in r.stdout))
# There is one PCLK domain and no combinational/generated clock in hand RTL.
rtl='\n'.join((IP/'rtl'/p).read_text() for p in ['spi_master_top.sv','spi_master_engine.sv','spi_master_queues.sv'])
check('single PCLK sequential domain','posedge spi_' not in rtl and 'posedge sclk' not in rtl and 'negedge pclk' not in rtl)
check('MISO is not false-pathed','spi_miso' not in '\n'.join(l for l in (IP/'constraints/characterization.sdc').read_text().splitlines() if 'set_false_path' in l))
report={'executions':executions,'status':'pass' if all(c['status']=='pass' for c in checks) else 'fail','checks':checks,'hashes':{str(p.relative_to(IP)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [*map(lambda x:IP/x,required),*out.glob('*.log')] if p.is_file()}}
(IP/'reports/quality/delivery-check.json').write_text(json.dumps(report,indent=2)+'\n')
for c in checks:print(c['status'],c['name'])
raise SystemExit(report['status']!='pass')
