"""Produce raw URG reports for each elaborated design; never merge unlike parameter hierarchies."""
from pathlib import Path
import subprocess,os,json,hashlib
IP=Path(__file__).resolve().parents[1];records=[]
for config in ['default','small','max','asymmetric']:
 out=IP/'reports/coverage'/config;log=IP/'build'/f'urg-{config}.log'
 cmd=['urg','-full64','-dir',str(IP/'build/sim'/config/'coverage.vdb'),'-report',str(out),'-format','both','-show','ratios','-group','show_bin_values','-group','maxmissing','100']
 with log.open('w') as f:
  f.write(str(cmd)+'\n');f.flush();r=subprocess.run(cmd,cwd=IP,env=dict(os.environ,VCS_USE_MALLOC='1'),stdout=f,stderr=subprocess.STDOUT,timeout=180)
 ok=r.returncode==0 and (out/'dashboard.txt').is_file() and (out/'groups.txt').is_file()
 records.append(dict(config=config,status='pass' if ok else 'fail',command=cmd,environment={'VCS_USE_MALLOC':'1'},log=str(log.relative_to(IP)),sha256=hashlib.sha256(log.read_bytes()).hexdigest()))
 print(config,records[-1]['status'],flush=True)
 if not ok:print(log.read_text()[-3000:])
(IP/'reports/coverage/urg-runs.json').write_text(json.dumps(records,indent=2)+'\n')
raise SystemExit(any(r['status']!='pass' for r in records))
