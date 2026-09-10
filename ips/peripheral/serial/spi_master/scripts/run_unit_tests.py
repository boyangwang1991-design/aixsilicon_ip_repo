"""Isolated queue and engine tests, including race boundaries inaccessible to slow APB polling."""
from pathlib import Path
import subprocess,json,hashlib
IP=Path(__file__).resolve().parents[1]
out=IP/'build/ut';out.mkdir(parents=True,exist_ok=True)
files=[(IP/x).resolve() for x in (IP/'rtl/filelist.f').read_text().splitlines() if x.strip()]
results=[]
for unit in ['queues','engine']:
    top=f'spi_{unit}_ut';src=IP/f'verification/unit_test/ut_spi_{unit}.sv'
    cmd=['vcs','-full64','-sverilog','-timescale=1ns/1ps','-top',top,'-o',str(out/top),*map(str,files),str(src)]
    commands=[cmd,[str(out/top),'+ntb_random_seed=917']]
    ok=True
    for index,command in enumerate(commands):
        log=out/f'{unit}-{index}.log'
        with log.open('w') as f:
            f.write(str(command)+'\n');f.flush();r=subprocess.run(command,cwd=out,stdout=f,stderr=subprocess.STDOUT,timeout=180)
        content=log.read_text()
        ok &= r.returncode==0 and 'Error:' not in content and 'Fatal:' not in content
        if index:ok &= unit.upper()+'_UT PASS' in content
        if not ok:print(content[-8000:]);break
    results.append(dict(unit=unit,status='pass' if ok else 'fail',commands=commands,source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),log=str(log.relative_to(IP)),log_sha256=hashlib.sha256(log.read_bytes()).hexdigest()))
    print(unit,results[-1]['status'],flush=True)
(IP/'reports/quality/unit-tests.json').write_text(json.dumps(results,indent=2)+'\n')
raise SystemExit(any(x['status']!='pass' for x in results))
