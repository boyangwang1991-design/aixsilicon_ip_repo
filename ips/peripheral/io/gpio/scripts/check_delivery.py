"""Executable delivery inventory/port/constraint check; never substitutes for EDA results."""
from pathlib import Path
import hashlib,json,re,subprocess,tempfile
import yaml
ROOT=Path(__file__).resolve().parents[1]
def main():
 checks=[]
 def check(name,ok,detail):checks.append({'id':name,'status':'pass' if ok else 'fail','detail':detail})
 required=['docs/integration/gpio_integration_guide.md','docs/integration/gpio_integration_checklist.xlsx','docs/user_manual/gpio_user_guide.md','docs/user_manual/gpio_register_programming_guide.md','sw/include/gpio_regs.h','constraints/gpio_characterization.sdc','constraints/gpio.sgdc','aixsilicon_ip_gpio.core','reports/signoff/cdc.yaml','reports/signoff/rdc.yaml']
 for name in required:check('FILE.'+name,(ROOT/name).is_file(),name)
 rtl=(ROOT/'rtl/gpio.sv').read_text().split('  import gpio_pkg')[0]
 ports=set(re.findall(r'\b([a-z][a-z0-9_]*_[io])\b',rtl))
 docs=(ROOT/'docs/integration/gpio_integration_guide.md').read_text()
 for port in sorted(ports):check('PORT.'+port,port in docs,port)
 for d in (ROOT/'docs/integration',ROOT/'docs/user_manual'):
  for f in d.glob('*.md'):
   for target in re.findall(r'\]\(([^)]+)\)',f.read_text()):
    if not re.match(r'https?://',target):check('LINK.'+f.name+':'+target,(f.parent/target.split('#')[0]).exists(),target)
 for f in ['gpio_input.sv','gpio_aon_wake.sv','gpio_aon_mailbox.sv']:
  check('SYNC.'+f,'ASYNC_REG' in (ROOT/'rtl'/f).read_text(),f)
 for kind in ('cdc','rdc'):
  f=ROOT/f'reports/signoff/{kind}.yaml'
  if f.exists():
   data=yaml.safe_load(f.read_text());check('SIGNOFF.'+kind,data.get('status') in ('pass','skipped'),'Conditional exception remains disclosed; see signoff record')
 with tempfile.TemporaryDirectory(prefix='gpio_header_') as work:
  src=Path(work)/'header.c';src.write_text('#include "gpio_regs.h"\nint main(void){return 0;}\n')
  result=subprocess.run(['cc','-std=c11','-Wall','-Werror','-fsyntax-only','-I',str(ROOT/'sw/include'),str(src)],capture_output=True,text=True)
  check('C_HEADER',result.returncode==0,result.stdout+result.stderr)
 report={'schema':'gpio-delivery-check/1.0','ip_name':'gpio','checks':checks,'inputs':{n:hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in required if (ROOT/n).is_file()}}
 out=ROOT/'reports/quality/delivery_check.json';out.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 failures=[c for c in checks if c['status']!='pass']
 for c in failures:print(c['id'],c['detail'])
 print('GPIO_DELIVERY PASS' if not failures else 'GPIO_DELIVERY FAIL')
 return bool(failures)
if __name__=='__main__':raise SystemExit(main())
