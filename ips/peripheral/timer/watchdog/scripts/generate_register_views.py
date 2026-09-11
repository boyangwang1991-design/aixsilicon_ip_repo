"""Derive native CSR wiring, masks, address constants and JSON from SystemRDL.
Run with the workflow uv environment. PeakRDL owns watchdog_csr*.sv separately.
"""
from pathlib import Path
import json
from systemrdl import RDLCompiler
from systemrdl.node import RegNode
p=Path(__file__).resolve().parents[1]
c=RDLCompiler(); c.compile_file(str(p/'regs/watchdog.rdl')); root=c.elaborate().top
regs=[n for n in root.descendants(unroll=True) if isinstance(n,RegNode)]
s=['// Generated from regs/watchdog.rdl. Do not edit.','module watchdog_reg_adapter(',
'input logic clk,rst_n,req,write, input logic [14:0] addr,',
'input logic [31:0] wdata,rdata, output logic ready,error,',
'output logic [31:0] read_data,write_mask, output logic writable,valid_addr);',
'watchdog_csr_pkg::watchdog_regs__in_t hin;',
'watchdog_csr_pkg::watchdog_regs__out_t hout;',
'logic ra,wa,re,we;','watchdog_csr u_csr(.clk(clk),.arst_n(rst_n),',
'.s_cpuif_req(req),.s_cpuif_req_is_wr(write),.s_cpuif_addr(addr),',
'.s_cpuif_wr_data(wdata),.s_cpuif_wr_biten(32\'hffffffff),',
'.s_cpuif_req_stall_wr(),.s_cpuif_req_stall_rd(),.s_cpuif_rd_ack(ra),',
'.s_cpuif_rd_err(re),.s_cpuif_rd_data(read_data),.s_cpuif_wr_ack(wa),',
'.s_cpuif_wr_err(we),.hwif_in(hin),.hwif_out(hout));',
'assign ready=write ? wa : ra; assign error=write ? we : re;']
meta=[]; h=['/* Generated from SystemRDL. Do not edit. */','#ifndef WATCHDOG_REGS_H','#define WATCHDOG_REGS_H','#include <stdint.h>','#define WDT_CHANNEL_BASE(ch) (0x1000u + (uint32_t)(ch)*0x400u)']
for r in regs:
 path=r.get_path().split('.',1)[1]; mask=sum(((1<<f.width)-1)<<f.low for f in r.fields()); rd=any(f.is_sw_readable for f in r.fields()); wr=any(f.is_sw_writable for f in r.fields())
 if rd:
  s.extend([f'assign hin.{path}.rd_ack=hout.{path}.req && !hout.{path}.req_is_wr;',f"assign hin.{path}.rd_data=rdata & 32'h{mask:08x};"])
 if wr: s.append(f'assign hin.{path}.wr_ack=hout.{path}.req && hout.{path}.req_is_wr;')
 meta.append(dict(name=path,address=r.absolute_address,mask=mask,readable=rd,writable=wr))
 if '[' not in path or path.startswith('ch[0]'):
  name=path.split('.')[-1]; address=r.absolute_address if '[' not in path else r.absolute_address-0x1000
  h.append(f'#define WDT_{name} 0x{address:03x}u')
s+=['always_comb begin','write_mask=0; writable=0; valid_addr=0;','case(addr)']
for r in meta: s.append(f"15'h{r['address']:04x}: begin valid_addr=1; writable=1'b{int(r['writable'])}; write_mask=32'h{r['mask']:08x}; end")
s+=['default: begin end','endcase','end','endmodule']
(p/'rtl/generated/watchdog_reg_adapter.sv').write_text('\n'.join(s)+'\n')
(p/'sw/include/watchdog_regs.h').write_text('\n'.join(h+['#endif'])+'\n')
(p/'regs/register.json').write_text(json.dumps(meta,indent=2)+'\n')
print(f'REGISTER_VIEWS PASS: {len(regs)} registers')
