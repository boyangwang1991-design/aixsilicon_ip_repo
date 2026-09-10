"""Negative parameter elaboration must fail for the intended assertion, never a missing source."""
from pathlib import Path
import subprocess,json,hashlib
IP=Path(__file__).resolve().parents[1];out=IP/'build/parameter-checks';out.mkdir(parents=True,exist_ok=True)
files=[str((IP/x).resolve()) for x in (IP/'rtl/filelist.f').read_text().splitlines() if x.strip()]
results=[]
for parameter,values in {'NUM_CS':[0,9],'TX_FIFO_DEPTH':[3,5,512],'RX_FIFO_DEPTH':[3,5,512],'CMD_FIFO_DEPTH':[1,3,32]}.items():
 for value in values:
    name=f'{parameter}_{value}';d=out/name;d.mkdir(exist_ok=True)
    top=d/'parameter_tb.sv';top.write_text(f'module parameter_tb; spi_master_top #(.{parameter}({value})) dut(); initial begin #1; $display("ILLEGAL_ACCEPTED"); $finish; end endmodule\n')
    command=['vcs','-full64','-sverilog','-top','parameter_tb','-o',str(d/'simv'),*files,str(top)]
    r=subprocess.run(command,cwd=d,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=180);content=r.stdout
    if r.returncode==0:
      r=subprocess.run([str(d/'simv')],cwd=d,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30);content+='\n'+r.stdout
    (d/'run.log').write_text(str(command)+'\n'+content)
    ok=parameter in content and ('Error-' in content or 'Error:' in content or 'Fatal:' in content) and 'ILLEGAL_ACCEPTED' not in content
    results.append(dict(parameter=parameter,value=value,status='pass' if ok else 'fail',log=str((d/'run.log').relative_to(IP)),sha256=hashlib.sha256((d/'run.log').read_bytes()).hexdigest()))
    print(name,results[-1]['status'],flush=True)
    if not ok:print(content[-2000:])
(IP/'reports/quality/negative-parameters.json').write_text(json.dumps(results,indent=2)+'\n')
raise SystemExit(any(r['status']!='pass' for r in results))
