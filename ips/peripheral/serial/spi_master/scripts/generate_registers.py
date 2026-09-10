"""Deterministically generate native PeakRDL views and access metadata from RDL.

The address/access function is a generated policy view, not a hand-maintained decoder.
"""
from pathlib import Path
import hashlib
import json
import subprocess
import importlib.metadata
from systemrdl import RDLCompiler
from systemrdl.node import RegNode

IP=Path(__file__).resolve().parents[1]
rdl=IP/'regs/spi_master.rdl'
def run(*args):
    subprocess.run(['peakrdl',*map(str,args)],cwd=IP,check=True)

run('regblock',rdl,'-o','rtl/generated','--cpuif','passthrough','--module-name','spi_master_csr',
    '--package-name','spi_master_csr_pkg','--default-reset','arst_n','--addr-width','12','--err-if-bad-addr','--err-if-bad-rw')
run('c-header',rdl,'-o','sw/include/spi_master_regs.h')
run('uvm',rdl,'-o','verification/ral/spi_master_ral.sv')
run('ip-xact',rdl,'-o','verification/ral/spi_master.xml')
run('html',rdl,'-o','docs/generated/spi_master_regs')
compiler=RDLCompiler(); compiler.compile_file(str(rdl)); top=compiler.elaborate().top
lines=['// Generated from regs/spi_master.rdl; do not edit.', 'package spi_master_addr_pkg;']
regs=[]
for node in top.descendants(unroll=True):
    if not isinstance(node,RegNode): continue
    fields=list(node.fields())
    readable=any(f.is_sw_readable for f in fields)
    writable=any(f.is_sw_writable for f in fields)
    path=node.get_path().removeprefix('spi_master.')
    name=path.upper().replace('.','_').replace('[','').replace(']','')
    addr=node.absolute_address
    regs.append((addr,readable,writable,path))
    lines.append(f"  localparam logic [11:0] A_{name}=12'h{addr:03x};")
lines+=['  function automatic logic access_ok(input logic [11:0] addr, input logic wr);',
        "    access_ok=1'b0;", '    case(addr)']
for addr,readable,writable,_ in regs:
    expr="1'b1" if readable and writable else ('wr' if writable else '~wr')
    lines.append(f"      12'h{addr:03x}: access_ok={expr};")
lines+=['      default: access_ok=1\'b0;', '    endcase', '  endfunction', 'endpackage']
(IP/'rtl/generated/spi_master_addr_pkg.sv').write_text('\n'.join(lines)+'\n')
files=[rdl,*sorted((IP/'rtl/generated').glob('*.sv')),IP/'sw/include/spi_master_regs.h',IP/'verification/ral/spi_master_ral.sv']
(IP/'reports/quality/register-generation.json').write_text(json.dumps({
    'tool': 'PeakRDL', 'versions':{p:importlib.metadata.version(p) for p in ['peakrdl','peakrdl-regblock','systemrdl-compiler']},
    'cpuif':'passthrough with zero-wait APB wrapper',
    'files':{str(p.relative_to(IP)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}},indent=2)+'\n')
print(f'Generated {len(regs)} register access entries')
# Native CSR provenance expected by the suite; emitted only after successful generation.
import yaml
manifest={'schema_version':'2.0','generator':'peakrdl-regblock',
 'generator_version':importlib.metadata.version('peakrdl-regblock'),
 'rdl_source':str(rdl),'rdl_source_sha256':hashlib.sha256(rdl.read_bytes()).hexdigest(),
 'outputs':[{'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted((IP/'rtl/generated').glob('*_csr*.sv'))]}
(IP/'rtl/generated/spi_master_csr.manifest.yaml').write_text(yaml.safe_dump(manifest,sort_keys=False))
