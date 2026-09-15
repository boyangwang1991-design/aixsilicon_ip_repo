"""Check software, generated views and actual technical delivery prerequisites."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess
import sys
import yaml
from run_uvm import P, SUITE, inputs as simulation_inputs

def inputs():
    return simulation_inputs([Path(__file__),P/'scripts/test_driver.sh',
                             *[f for f in (P/'sw').rglob('*') if f.is_file()]])


def main():
    stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%f')
    out=P/'build/reports/delivery'/stamp;out.mkdir(parents=True)
    before=inputs();checks=[]
    with (out/'driver.log').open('w') as log:
        result=subprocess.run(['bash','scripts/test_driver.sh'],cwd=P,stdout=log,stderr=subprocess.STDOUT)
    checks.append(dict(id='driver',status='pass' if result.returncode==0 and
                       'WATCHDOG_DRIVER_TEST PASS' in (out/'driver.log').read_text() else 'fail',exit_code=result.returncode))
    manifest=json.loads((P/'rtl/generated/register_manifest.json').read_text())
    mismatch=[name for name,sha in manifest.items() if not (P/name).is_file() or hashlib.sha256((P/name).read_bytes()).hexdigest()!=sha]
    checks.append(dict(id='register_views',status='fail' if mismatch else 'pass',mismatches=mismatch))
    for name in ['docs/user_guide.md','docs/safety_manual.md','regs/watchdog.rdl','rtl/filelist.f','aixsilicon_ip_watchdog.core']:
        checks.append(dict(id=name,status='pass' if (P/name).is_file() else 'fail'))
    with (out/'quality.log').open('w') as log:
        result=subprocess.run([sys.executable,str(SUITE/'skills/15-regression-quality-review/scripts/evaluate_quality.py'),
                               '--workspace',str(P),'--ip-name','watchdog'],cwd=P,stdout=log,stderr=subprocess.STDOUT)
    quality=P/'build/reports/quality/quality.yaml'
    if result.returncode==0 and quality.is_file():
        data=yaml.safe_load(quality.read_text());g3=next(g for g in data['gates'] if g['id']=='G3')
        checks.append(dict(id='static_technical_signoff',status='pass' if g3['status']=='pass' and
                           g3.get('technical_signoff_complete',True) else 'fail',detail=g3['status']))
        g5=next(g for g in data['gates'] if g['id']=='G5')
        ppa=[c for c in g5['checks'] if 'ppa' in c['id']]
        checks.append(dict(id='ppa',status='pass' if ppa and all(c['status']=='pass' for c in ppa) else 'fail',checks=ppa))
    else:checks.append(dict(id='quality',status='fail',exit_code=result.returncode))
    after=inputs();passed=before==after and all(c['status']=='pass' for c in checks)
    (out/'manifest.json').write_text(json.dumps(dict(schema='watchdog-delivery-check/1.0',
        inputs=before,inputs_after=after,checks=checks,status='pass' if passed else 'fail'),indent=2)+'\n')
    print(json.dumps(checks,indent=2))
    print('WATCHDOG_DELIVERY_CHECK '+('PASS' if passed else 'FAIL'))
    return 0 if passed else 1


if __name__=='__main__':raise SystemExit(main())
