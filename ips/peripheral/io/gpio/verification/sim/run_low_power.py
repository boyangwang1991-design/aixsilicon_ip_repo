from pathlib import Path
import argparse,re,subprocess,shutil
ROOT=Path(__file__).resolve().parents[2]
a=argparse.ArgumentParser();a.add_argument('--build',required=True);a.add_argument('--out',type=Path,required=True);args=a.parse_args();args.out.mkdir(parents=True,exist_ok=True)
cmd=['make','-C','verification/sim','run-existing','BUILD='+args.build,'TESTS=lowpower aon','SEEDS=1']
r=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True);print(r.stdout,end='');print(r.stderr,end='')
for name in ('lowpower','aon'):
 matches=re.findall(r'^'+name+r' 1 (?:pass|fail) (.+/run.log)$',r.stdout,re.M)
 if len(matches)!=1:raise RuntimeError('Missing unique '+name+' raw log')
 source=(ROOT/matches[0]).resolve()
 if not source.is_relative_to(ROOT):raise RuntimeError('Escaping raw log')
 shutil.copy2(source,args.out/(name+'.log'))
 print(source.read_text())
raise SystemExit(r.returncode)
