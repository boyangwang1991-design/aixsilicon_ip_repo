"""Build/run VCS UVM 1.2; fail closed on compile, assertions, UVM errors or missing PASS."""
from pathlib import Path
import argparse
import subprocess
import hashlib
import json
import os
import time
import xml.etree.ElementTree as ET

IP=Path(__file__).resolve().parents[1]
ROOT=IP.parents[5]
parser=argparse.ArgumentParser()
parser.add_argument('--config',choices=['small','default','max','asymmetric'],default='default')
parser.add_argument('--test',default='all')
parser.add_argument('--seed',type=int,default=1)
parser.add_argument('--no-build',action='store_true')
args=parser.parse_args()
params={'small':(1,4,4,2),'default':(4,32,32,4),'max':(8,256,256,16),'asymmetric':(3,8,16,4)}[args.config]
out=IP/'build/sim'/args.config;out.mkdir(parents=True,exist_ok=True)
files=[(IP/line.strip()).resolve() for line in (IP/'rtl/filelist.f').read_text().splitlines() if line.strip()]
files += [IP/'verification/th/spi_tb_if.sv',IP/'verification/env/spi_master_tests.sv']
files += sorted((IP/'verification/tc').glob('tc_*.sv'))
files += [IP/'verification/th/spi_master_tb.sv']
command=['vcs','-full64','-sverilog','-timescale=1ns/1ps','-ntb_opts','uvm-1.2','-debug_access+all',
         '-cm','line+cond+fsm+tgl+branch+assert','-cm_dir',str(out/'coverage.vdb'),'-top','spi_master_tb',
         '-o',str(out/'simv')]+[f'+define+{k}={v}' for k,v in zip(['SPI_NUM_CS','SPI_TX_DEPTH','SPI_RX_DEPTH','SPI_CMD_DEPTH'],params)]+list(map(str,files))
def execute(cmd,log,timeout):
    started=time.monotonic()
    with log.open('w') as f:
        f.write('COMMAND: '+str(cmd)+'\n');f.flush()
        try:r=subprocess.run(cmd,cwd=out,stdout=f,stderr=subprocess.STDOUT,timeout=timeout)
        except subprocess.TimeoutExpired:return {'exit_code':124,'seconds':time.monotonic()-started,'log':str(log.relative_to(IP)),'status':'fail'}
    return {'exit_code':r.returncode,'seconds':time.monotonic()-started,'log':str(log.relative_to(IP)),
            'sha256':hashlib.sha256(log.read_bytes()).hexdigest()}
fingerprint={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
manifest=out/'build-manifest.json'
identity={'sources':fingerprint,'command':command}
if args.no_build and (not manifest.exists() or json.loads(manifest.read_text())!=identity):
    raise SystemExit('Refusing stale --no-build: compile inputs changed; rebuild first')
if not args.no_build:
    build=execute(command,out/'compile.log',180)
    if build['exit_code'] or not (out/'simv').exists():
        print((out/'compile.log').read_text()[-8000:]);raise SystemExit(1)
    manifest.write_text(json.dumps(identity,indent=2)+'\n')
groups=['apb','modes','commands','fifo_stall','recovery','irq','extended','random','races'] if args.test=='all' else [args.test]
results=[]
for group in groups:
    log=out/f'{group}_{args.seed}.log'
    run=execute([str(out/'simv'),f'+UVM_TESTNAME=tc_spi_{group}',f'+ntb_random_seed={args.seed}',
                 '-cm','line+cond+fsm+tgl+branch+assert','-cm_name',f'{group}_{args.seed}'],log,180)
    content=log.read_text()
    ok=run['exit_code']==0 and f'{group} PASS' in content and 'UVM_ERROR :    0' in content and 'UVM_FATAL :    0' in content
    ok &= not any(token in content for token in ['Error:', 'Fatal:', 'Assertion failed', 'CHECK '])
    run.update(test='tc_spi_'+group,seed=args.seed,config=args.config,status='pass' if ok else 'fail')
    results.append(run);print(group,run['status'],flush=True)
    if not ok: print(content[-8000:],flush=True)
report=IP/'reports/quality'/f'regression-{args.config}-{args.seed}.json'
report.write_text(json.dumps({'config':params,'results':results,'source_hashes':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}},indent=2)+'\n')
suite=ET.Element('testsuite',name='spi_master',tests=str(len(results)),failures=str(sum(r['status']!='pass' for r in results)))
for r in results:
    tc=ET.SubElement(suite,'testcase',name=r['test'],classname=args.config,time=str(r['seconds']))
    if r['status']!='pass':ET.SubElement(tc,'failure',message='See '+r['log'])
ET.ElementTree(suite).write(IP/'reports/quality'/f'junit-{args.config}-{args.seed}.xml',encoding='utf-8',xml_declaration=True)
raise SystemExit(any(r['status']!='pass' for r in results))
