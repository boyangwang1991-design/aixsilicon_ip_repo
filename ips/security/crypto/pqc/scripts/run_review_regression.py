#!/usr/bin/env python3
"""Run current-source PQC unit regressions with source hashes and strict verdicts.
No synthesis/PPA tools are invoked. Output defaults to a fresh /tmp directory.
"""
import argparse, hashlib, json, re, subprocess, tempfile
from pathlib import Path
p=Path(__file__).resolve().parents[1]
a=argparse.ArgumentParser(description=__doc__)
a.add_argument('--tests',nargs='*',help='Optional UT stem filters')
a.add_argument('--output',type=Path)
args=a.parse_args();work=args.output or Path(tempfile.mkdtemp(prefix='pqc_review_fix_'));work.mkdir(parents=True,exist_ok=True)
sources=[p/s.strip() for s in (p/'rtl/filelist.f').read_text().splitlines() if s.strip()]
tests=sorted((p/'verification/unit_test').glob('ut_*.sv'))
if args.tests: tests=[t for t in tests if any(n in t.stem for n in args.tests)]
if not tests: raise SystemExit('No tests selected')
def hashes():
 files=[*sources,*tests,*sorted((p/'verification/unit_test/golden').rglob('*')),*sorted((p/'rtl/include').glob('*'))]
 return {str(f.relative_to(p)):hashlib.sha256(f.read_bytes()).hexdigest() for f in files if f.is_file()}
before=hashes(); records=[]
print('Output:',work,flush=True)
for tb in tests:
 out=work/tb.stem;out.mkdir(exist_ok=True)
 content=tb.read_text();selected=sources if tb.stem.startswith('ut_pqc_top') else [s for s in sources if s.name=='pqc_pkg.sv' or s.stem in content]
 cmd=['vcs','-full64','-sverilog','-timescale=1ns/1ps','-top',tb.stem,
 '+incdir+'+str(p/'rtl/include'),'+incdir+'+str(p/'verification/unit_test/golden'),
 *map(str,selected),str(tb),'-o',str(out/'simv')]
 compile_code=run_code=None; verdict=False; reason=''
 try:
  with (out/'compile.log').open('w') as log:
   compile_code=subprocess.run(cmd,cwd=out,stdout=log,stderr=subprocess.STDOUT,timeout=240).returncode
  if compile_code==0:
   with (out/'run.log').open('w') as log:
    run_code=subprocess.run([str(out/'simv'),'+VECTORS='+str(p/'verification/unit_test/golden/review_fix')],cwd=out,stdout=log,stderr=subprocess.STDOUT,timeout=90).returncode
   logtext=(out/'run.log').read_text()
   verdict=run_code==0 and ': PASS' in logtext and not re.search(r'FAIL|Fatal|Error|TIMEOUT',logtext)
   reason='; '.join(l for l in logtext.splitlines() if re.search(r'PASS|FAIL|Fatal|Error|TIMEOUT',l))
  else: reason='compile error; see compile.log'
 except subprocess.TimeoutExpired: reason='tool timeout'
 records.append({'test':tb.stem,'passed':verdict,'compile_exit':compile_code,'run_exit':run_code,'command':cmd,'reason':reason})
 print(tb.stem, 'PASS' if verdict else 'FAIL',reason,flush=True)
 (work/'results.json').write_text(json.dumps({'source_hashes':before,'results':records},indent=2))
if hashes()!=before: raise SystemExit('Sources changed during regression: results are not a final-version proof')
failed=sum(not r['passed'] for r in records)
print(f'PQC_REVIEW_REGRESSION: {len(records)-failed}/{len(records)} PASS',flush=True)
raise SystemExit(bool(failed))
