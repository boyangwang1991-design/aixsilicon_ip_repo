"""Derive verification access metadata directly from SystemRDL, not DUT decode."""
from pathlib import Path
from systemrdl import RDLCompiler
from systemrdl.node import RegNode
p=Path(__file__).resolve().parents[1];c=RDLCompiler();c.compile_file(str(p/'regs/watchdog.rdl'));top=c.elaborate().top
lines=['// Generated from regs/watchdog.rdl; do not edit.','package watchdog_reg_views_pkg;',
 'typedef struct packed { bit valid,readable,writable; bit[31:0] read_mask,write_mask; } register_access_t;',
 'function automatic register_access_t access_at(bit[31:0] address);',"register_access_t a; a='0; case(address)"]
for r in top.descendants(unroll=True):
 if not isinstance(r,RegNode):continue
 rd=sum(((1<<f.width)-1)<<f.low for f in r.fields() if f.is_sw_readable)
 wr=sum(((1<<f.width)-1)<<f.low for f in r.fields() if f.is_sw_writable)
 lines.append(f"32'h{r.absolute_address:08x}: a='{{1'b1,1'b{int(rd!=0)},1'b{int(wr!=0)},32'h{rd:08x},32'h{wr:08x}}};")
lines+=['default: begin end','endcase return a; endfunction','endpackage']
f=p/'verification/ral/watchdog_reg_views_pkg.sv';f.write_text('\n'.join(lines)+'\n');print('VERIFICATION_REGISTER_VIEWS PASS')
