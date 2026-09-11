"""Run the complete GPIO module suite through FuseSoC with frozen input evidence."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import yaml

ROOT = Path(__file__).resolve().parents[1]
CORE = 'aixsilicon:ip:gpio:0.1.0'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def snapshot():
    files = set()
    for directory in ('rtl', 'regs', 'verification/unit_test', 'scripts', 'constraints', 'docs/lld', 'docs/hld', 'docs/lrs'):
        files.update(p.resolve() for p in (ROOT / directory).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
    files.update(ROOT.glob('*.core'))
    files.add(ROOT / 'ip-package.yaml')
    files.add(ROOT / 'build/cbb_adapter/provenance.json')
    files.update(Path(p) for p in json.loads((ROOT / 'build/cbb_adapter/provenance.json').read_text())['files'])
    return {str(p): digest(p) for p in sorted(files)}

def main():
    tests = sorted((ROOT / 'verification/unit_test').glob('ut_*.sv'))
    base = ROOT / 'build/sim/run/ut'
    base.mkdir(parents=True, exist_ok=True)
    run = Path(tempfile.mkdtemp(prefix='run.', dir=base))
    frozen = snapshot()
    (run / 'inputs.json').write_text(json.dumps(frozen, indent=2)+'\n')
    checks = {}
    artifacts = []
    evidence = ROOT / 'reports/module_ut' / run.name
    evidence.mkdir(parents=True)
    def record(path):
        artifacts.append({'path':str(path.relative_to(ROOT)), 'sha256':digest(path)})
    passed = True
    for test in tests:
        if snapshot() != frozen:
            raise RuntimeError('SOURCE_CHANGED: module UT batch invalidated')
        target = run / test.stem
        command = ['uv','run','--locked','--no-sync','fusesoc','--cores-root=.',
                   '--cores-root=build/cbb_adapter','run','--target='+test.stem,
                   '--build-root='+str(target),CORE]
        log = evidence / (test.stem+'.run.log')
        with log.open('w') as output:
            try:
                result = subprocess.run(command,cwd=ROOT,stdout=output,stderr=subprocess.STDOUT,timeout=180)
                rc = result.returncode
            except subprocess.TimeoutExpired:
                output.write('\nTIMEOUT: FuseSoC module UT\n')
                rc = 124
        text = log.read_text(errors='replace')
        compile_logs = list(target.rglob('compile.log'))
        compile_log = evidence / (test.stem+'.compile.log')
        if len(compile_logs)==1:
            shutil.copyfile(compile_logs[0],compile_log)
        else:
            compile_log.write_text('FAIL: no unique compiler log\n')
        ok = (rc==0 and len(compile_logs)==1 and snapshot()==frozen
              and re.search(r'^UT_[A-Z0-9_]+: PASS \(errors=0\)$',text,re.M)
              and not re.search(r'FAIL|TIMEOUT|Fatal:|Error-\[',text))
        passed = passed and bool(ok)
        checks[test.stem] = {'status':'pass' if ok else 'fail','exit_code':rc,
            'compile_log':str(compile_log.relative_to(ROOT)), 'run_log':str(log.relative_to(ROOT))}
        record(log);record(compile_log)
        print(test.stem,checks[test.stem]['status'],flush=True)
    if snapshot()!=frozen:
        raise RuntimeError('SOURCE_CHANGED: module UT batch invalidated')
    # Keep dependency identities local; report binds their immutable manifest by digest.
    record(run/'inputs.json')
    report = {'schema_version':'2.0','ip_name':'gpio','report_type':'module_ut',
              'status':'pass' if passed else 'fail','eda_profile':'commercial-systemverilog',
              'tool':'vcs','tool_version':'W-2024.09-SP1','test_count':len(tests),
              'command':'bash verification/unit_test/run_ut.sh','artifacts':artifacts,'checks':checks}
    text = '<!-- REPORT_META\n'+yaml.safe_dump(report,sort_keys=False)+'END_REPORT_META -->\n'
    (ROOT/'reports/quality/module_ut_summary.md').write_text(text)
    (run/'module_ut_summary.md').write_text(text)
    return 0 if passed else 1

if __name__=='__main__':
    sys.exit(main())
