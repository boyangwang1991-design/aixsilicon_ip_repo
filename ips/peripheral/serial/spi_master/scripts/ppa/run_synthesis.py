"""IP-specific FuseSoC/DC characterization runner; uses scanner-rendered PDK binding."""
from pathlib import Path
import argparse
import os
import subprocess
import hashlib
import json
import re
import shutil
IP=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser();parser.add_argument('--config',choices=['small','default','max','asymmetric'],default='small')
args=parser.parse_args()
params={'small':(1,4,4,2),'default':(4,32,32,4),'max':(8,256,256,16),'asymmetric':(3,8,16,4)}[args.config]
env=dict(os.environ,SPI_IP_ROOT=str(IP),**dict(zip(['SPI_NUM_CS','SPI_TX_DEPTH','SPI_RX_DEPTH','SPI_CMD_DEPTH'],map(str,params))))
out=IP/'build/rtl'/f'synth-{args.config}';out.mkdir(parents=True,exist_ok=True)
cmd=['fusesoc','--cores-root=.','--cores-root=build/dependencies','run','--target=synth','--setup','--build',
     '--build-root='+str(out),'aixsilicon:ip:spi_master:1.0.0']
with (out/'run.log').open('w') as f:
    f.write('COMMAND: '+str(cmd)+'\n');f.flush()
    r=subprocess.run(cmd,cwd=IP,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=1200)
content=(out/'run.log').read_text()
work=out/'aixsilicon_ip_spi_master_1.0.0/synth-design_compiler'
logs=list(work.glob('reports/*'))
combined=content+'\n'+'\n'.join(p.read_text(errors='replace') for p in logs if p.is_file())
ok=r.returncode==0 and 'SPI_SYNTH_COMPLETE' in combined and not re.search(r'(^|\n)Error:',combined)
dest=IP/'reports/synth'/args.config;dest.mkdir(parents=True,exist_ok=True)
for p in logs:
    if p.is_file():shutil.copy2(p,dest/p.name)
shutil.copy2(out/'run.log',dest/'tool-output.txt')
netlist=work/'outputs/spi_master_top_synth.v'
ok &= netlist.is_file()
timing=(dest/'timing.rpt').read_text() if (dest/'timing.rpt').exists() else ''
area=(dest/'area.rpt').read_text() if (dest/'area.rpt').exists() else ''
slacks=re.findall(r'slack\s+\([^)]*\)\s+(-?[\d.]+)',timing)
areas=re.findall(r'Total cell area:\s+([\d.]+)',area)
summary={'status':'pass' if ok else 'fail','config':args.config,'parameters':params,'tool':'Design Compiler',
    'exit_code':r.returncode,'area_um2':float(areas[-1]) if areas else None,'worst_slack_ns':min(map(float,slacks)) if slacks else None,
    'period_ns':10,'activity':'default vectorless probability propagation; not measured workload power',
    'netlist':str(netlist.relative_to(IP)),'hashes':{str(p.relative_to(IP)):hashlib.sha256(p.read_bytes()).hexdigest()
        for p in [IP/'model/pdk.yaml',IP/'constraints/characterization.sdc',Path(__file__),IP/'scripts/ppa/synth.tcl',*dest.glob('*.rpt')]}}
(dest/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2)[:1500],flush=True)
if not ok:print(combined[-8000:]);raise SystemExit(1)
