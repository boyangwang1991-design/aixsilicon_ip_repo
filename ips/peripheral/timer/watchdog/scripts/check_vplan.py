"""Check watchdog verification source, proof planning, links and baseline identity."""
from pathlib import Path
import argparse,hashlib,json,re
import yaml

def check(p):
 errors=[]; hashes={}; blocks={}; docs=[]
 def require(ok,msg):
  if not ok:errors.append(msg)
 def bind(f):
  hashes[str(f.relative_to(p))]=hashlib.sha256(f.read_bytes()).hexdigest()
 def model(name):
  f=p/'model'/name;bind(f);return yaml.safe_load(f.read_text())
 req=model('requirements.yaml'); hld=model('architecture.yaml'); lld=model('micro_design.yaml'); pc=model('parameter_space.yaml'); v=model('verification.yaml')
 require(any(g.get('status')=='pass' and g.get('microarchitecture_freeze') and g.get('register_freeze') for g in lld['gates']),'LLD not frozen')
 for f in sorted((p/'docs/verification').glob('*.md')):
  bind(f);t=f.read_text();b=re.findall(r'<!-- (\w+)_META\s*(.*?)END_\1_META -->',t,re.S)
  docs.append(dict(path=str(f.relative_to(p)),lines=len(t.splitlines()),meta=len(b)))
  require(len(t.splitlines())<=300,f'{f.name}: exceeds 300-line review limit')
  require(len(b)<=12,f'{f.name}: exceeds 12 META review limit')
  for kind,raw in b:blocks.setdefault(kind,[]).append(yaml.safe_load(raw))
  for target in re.findall(r'\]\(([^)]+)\)',t):
   if not re.match(r'\w+://',target) and not target.startswith('#'):
    require((f.parent/target.split('#')[0]).exists(),f'{f.name}: broken link {target}')
 require(len(blocks.get('VPLAN',[]))==1,'expected one VPLAN header')
 require(len(blocks.get('VPLAN_GATE',[]))==1,'expected one VP0 gate')
 features=blocks.get('FEATURE',[]); tests=blocks.get('TESTCASE',[]); assertions=blocks.get('ASSERTION',[])
 ids={r['id'] for r in req['requirements']}; fids={f['id'] for f in features}; aids=[]
 design_ids={o['id'] for value in lld.values() if isinstance(value,list) for o in value if isinstance(o,dict) and 'id' in o}
 cfgids={c['id'] for c in blocks.get('CONFIG_SET',[])}
 covered=set()
 for f in features:
  require(set(f['req_ref'])<=ids,f'{f["id"]}: unknown requirements')
  require(bool(f.get('proof_methods')),f'{f["id"]}: missing correctness method')
  proof=[x for x in tests+assertions if x.get('feature_ref')==[f['id']]]
  require(bool(proof),f'{f["id"]}: coverage-only or missing proof')
  for x in proof:
   require(set(f['req_ref'])<=set(x.get('req_ref',[])),f'{x["id"]}: missing explicit requirement mapping')
  if proof:covered.update(f['req_ref'])
 for kind in ('FEATURE','TESTCASE','ASSERTION','COVERAGE','CONFIG_SET','CONFIG_COVERAGE'):
  for obj in blocks.get(kind,[]):
   aids.append(obj['id']); require(set(obj.get('design_ref',[]))<=design_ids,f'{obj["id"]}: unknown LLD object')
   if kind in ('TESTCASE','ASSERTION'):require(len(obj.get('feature_ref',[]))==1 and obj['feature_ref'][0] in fids,f'{obj["id"]}: bad single feature')
   if kind=='TESTCASE':
    for key in ('stimulus','expected_result','implementation','timeout_policy','tier','config_ref'):require(bool(obj.get(key)),f'{obj["id"]}: missing {key}')
    require(set(obj['config_ref'])<=cfgids,f'{obj["id"]}: unknown config set')
 require(len(aids)==len(set(aids)),'duplicate verification ID')
 require(covered==ids,f'requirement gap: {sorted(ids-covered)}')
 require(any(t['tier']=='smoke' for t in tests),'no smoke')
 expected={f['id']:f for f in features}; actual={f['id']:f for f in v['features']}
 require(set(actual)==set(expected),'stale feature projection')
 for fid,f in expected.items():
  for key in f:require(actual.get(fid,{}).get(key)==f[key],f'{fid}: source/model mismatch {key}')
  for kind,key in [('TESTCASE','testcases'),('ASSERTION','assertions'),('COVERAGE','coverage')]:
   source={o['id']:o for o in blocks.get(kind,[]) if fid in o.get('feature_ref',[])}
   output={o['id']:o for o in actual.get(fid,{}).get(key,[])}
   require(source==output,f'{fid}: stale {key} projection')
 matrix=next(c for c in blocks['CONFIG_SET'] if c['id']=='CFGSET.WATCHDOG.PC_MATRIX')
 require(set(matrix['configuration_ids'])=={c['id'] for c in pc['support_matrix']['configs']},'PC matrix not complete')
 for name in ('verification_plan.md','feature_list.md','test_matrix.md','checker_plan.md','coverage_plan.md','agent_plan.md','99_quality_gate.md','index.md'):require((p/'docs/verification'/name).exists(),f'missing {name}')
 bind(p/'scripts/check_vplan.py')
 return dict(schema='watchdog-vplan-check/1.0',passed=not errors,role='plan_check_not_execution',counts=dict(requirements=len(ids),covered=len(covered),features=len(features),testcases=len(tests),assertions=len(assertions),configurations=len(pc['support_matrix']['configs']),documents=len(docs)),errors=errors,documents=docs,source_sha256=hashes)

def main():
 a=argparse.ArgumentParser();a.add_argument('--workspace',type=Path,default=Path('.'));p=a.parse_args().workspace.resolve();r=check(p)
 (p/'reports/quality/vplan_check.json').write_text(json.dumps(r,ensure_ascii=False,indent=2)+'\n')
 (p/'reports/quality/vplan_check.md').write_text('# Watchdog VPLAN检查\n\n'+('PASS' if r['passed'] else 'FAIL')+'；此检查证明计划结构与追踪，不证明用例执行或覆盖率达标。\n\n'+json.dumps(r['counts'],ensure_ascii=False)+'\n\n'+'\n'.join('- '+e for e in r['errors'])+'\n')
 print(json.dumps({k:r[k] for k in ('passed','counts','errors')},ensure_ascii=False));return int(not r['passed'])
if __name__=='__main__':raise SystemExit(main())
