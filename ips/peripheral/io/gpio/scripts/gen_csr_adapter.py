"""Generate structural GPIO CSR descriptors and external-register wiring from RDL only."""
from pathlib import Path
import hashlib
import json
import re
from collections import defaultdict
from systemrdl import RDLCompiler
from systemrdl.node import RegNode


def main():
    root=Path(__file__).resolve().parents[1]
    src=root/'regs/gpio.rdl'
    compiler=RDLCompiler();compiler.compile_file(str(src));top=compiler.elaborate().top
    regs=[n for n in top.descendants(unroll=True) if isinstance(n,RegNode)]
    families=defaultdict(list)
    for index,reg in enumerate(regs):
        path=reg.get_path().split('.',1)[1]
        key=re.sub(r'\[\d+\]','',path).replace('.','_').upper()
        families[key].append((index,reg,path))
    keys=list(families)
    pkg=['// Generated from gpio.rdl by gen_csr_adapter.py; do not edit.',
         'package gpio_reg_desc_pkg;', f'  localparam int GPIO_REG_COUNT={len(regs)};',
         '  typedef enum logic [6:0] {OP_INVALID=7\'d0,\n'+',\n'.join(f"    OP_{key}=7'd{i+1}" for i,key in enumerate(keys))+'\n  } gpio_reg_op_t;',
         '  typedef struct packed {logic hit; gpio_reg_op_t op; logic [1:0] group_id; logic [6:0] instance_id; logic [9:0] index; logic readable; logic writable; logic [31:0] read_mask; logic [31:0] write_mask;} gpio_reg_desc_t;']
    def masks(reg):
        rd=wr=reset=0
        for field in reg.fields():
            mask=((1<<field.width)-1)<<field.low
            access=field.get_property('sw').name
            if access in ('r','rw','rw1'):rd|=mask
            if access in ('w','rw','w1','rw1'):wr|=mask
            value=field.get_property('reset')
            if isinstance(value,int):reset|=value<<field.low
        return rd,wr,reset
    for key,items in families.items():
        indices=[item[0] for item in items]
        if len(indices)==1:
            pkg.append(f'  localparam int IDX_{key}={indices[0]};')
        else:
            stride=indices[1]-indices[0]
            assert all(value==indices[0]+i*stride for i,value in enumerate(indices))
            pkg.append(f'  function automatic int idx_{key}(input int instance_id); return {indices[0]}+instance_id*{stride}; endfunction')
    pkg+=['  function automatic gpio_reg_desc_t gpio_decode(input logic [13:0] address);',"    gpio_reg_desc_t d; d='0;",'    case (address)']
    for index,reg in enumerate(regs):
        path=reg.get_path().split('.',1)[1]
        key=re.sub(r'\[\d+\]','',path).replace('.','_').upper()
        group=0 if '.' not in path else {'bank':1,'pin':2,'aon':3}[path.split('[')[0]]
        match=re.search(r'\[(\d+)\]',path);instance=int(match[1]) if match else 0
        rd,wr,_=masks(reg)
        pkg.append(f"      14'h{reg.absolute_address:04x}: d='{{1'b1,OP_{key},2'd{group},7'd{instance},10'd{index},1'b{int(bool(rd))},1'b{int(bool(wr))},32'h{rd:08x},32'h{wr:08x}}};")
    pkg+=['      default: d=\'0;', '    endcase', '    return d;', '  endfunction', 'endpackage']
    glue=['// Generated external-register structural connections; behavior belongs to gpio_regfile.',
          'module gpio_csr_adapter (',
          '  input logic commit_i, write_i,',
          '  input logic [31:0] read_words_i [gpio_reg_desc_pkg::GPIO_REG_COUNT],',
          '  input gpio_csr_pkg::gpio_regs__out_t hwif_out_i,',
          '  output gpio_csr_pkg::gpio_regs__in_t hwif_in_o,',
          '  output logic [gpio_reg_desc_pkg::GPIO_REG_COUNT-1:0] write_strobe_o, read_strobe_o',
          ');']
    for index,reg in enumerate(regs):
        path=reg.get_path().split('.',1)[1];rd,wr,_=masks(reg)
        # External registers return raw words; explicitly mask reserved bits in this view.
        if rd:
            glue += [f"  assign hwif_in_o.{path}.rd_data=read_words_i[{index}] & 32'h{rd:08x};",
                     f'  assign hwif_in_o.{path}.rd_ack=hwif_out_i.{path}.req && !write_i;',
                     f'  assign read_strobe_o[{index}]=commit_i && !write_i && hwif_out_i.{path}.req;']
        else:glue.append(f"  assign read_strobe_o[{index}]=1'b0;")
        if wr:
            glue += [f'  assign hwif_in_o.{path}.wr_ack=hwif_out_i.{path}.req && write_i;',
                     f'  assign write_strobe_o[{index}]=commit_i && write_i && hwif_out_i.{path}.req;']
        else:glue.append(f"  assign write_strobe_o[{index}]=1'b0;")
    glue.append('endmodule')
    out=root/'rtl/generated';out.mkdir(exist_ok=True)
    outputs=[]
    for name,lines in [('gpio_reg_desc_pkg.sv',pkg),('gpio_csr_adapter.sv',glue)]:
        target=out/name;target.write_text('\n'.join(lines)+'\n');outputs.append(target)
    manifest={'generator':'scripts/gen_csr_adapter.py','scope':'RDL structure only; not behavioral RTL','inputs':{},'outputs':{}}
    for path in [Path(__file__),src]:manifest['inputs'][str(path.relative_to(root))]=hashlib.sha256(path.read_bytes()).hexdigest()
    for path in outputs:manifest['outputs'][str(path.relative_to(root))]=hashlib.sha256(path.read_bytes()).hexdigest()
    (out/'gpio_adapter.manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(f'Generated descriptors and external wiring for {len(regs)} register instances, {len(keys)} operation families')


if __name__=='__main__':main()
