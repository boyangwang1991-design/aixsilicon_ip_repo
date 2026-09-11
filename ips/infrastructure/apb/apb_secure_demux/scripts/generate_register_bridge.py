"""Generate only RDL-derived constants and external-register wiring (no state behavior)."""
import argparse
import hashlib
import json
import re
from pathlib import Path

from systemrdl import RDLCompiler
from systemrdl.node import RegNode

KINDS = '''IP_ID VERSION CAP0 CAP1 STATUS POLICY_VERSION GLOBAL_LOCK COMMIT_MASK COMMIT_STATUS
SHADOW_RELOAD MGMT_MASK_LO MGMT_MASK_HI INTR_RAW INTR_ENABLE INTR_MASKED ALERT_ENABLE INTR_TEST
FAULT_CLEAR FIFO_STATUS FIFO_POP ACCESS_DENY_COUNT CFG_DENY_COUNT EVENT_LOST_COUNT DOWNSTREAM_ERR_COUNT
COUNTER_CLEAR INTEGRITY_STATUS FIRST_FAULT LAST_FAULT FIFO_HEAD DFX_STATUS WAIT_THRESHOLD DFX_CLEAR
INJECT_TARGET INJECT_CMD MAP_BASE MAP_LIMIT PORT_LOCK CFG_SHADOW CFG_ACTIVE SUCCESS_COUNT DENY_COUNT
SLVERR_COUNT WAIT_TOTAL WAIT_MAX DFX_COUNTER_CLEAR PERM_SHADOW PERM_ACTIVE'''.split()


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--rdl', type=Path, required=True)
    parser.add_argument('--config-manifest', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    compiler = RDLCompiler()
    compiler.compile_file(str(args.rdl))
    top = compiler.elaborate().top
    values = json.loads(args.config_manifest.read_text())['values']
    regs = [n for n in top.descendants(unroll=True) if isinstance(n, RegNode)]
    records = []
    for reg in regs:
        path = reg.get_path().split('.', 1)[1]
        kind = re.sub(r'_\d+$', '', reg.inst_name)
        if kind not in KINDS:
            raise ValueError(f'No behavior binding declared for {kind}')
        port = re.search(r'port_(\d+)', path)
        master = re.search(r'PERM_(?:ACTIVE|SHADOW)_(\d+)', path)
        word = reg.current_idx[0] if reg.is_array else 0
        mask = sum(((1 << f.width) - 1) << f.low for f in reg.fields())
        reset = sum(f.get_property('reset') << f.low for f in reg.fields())
        records.append(dict(path=path, kind=kind, port=int(port[1]) if port else 0,
                            master=int(master[1]) if master else 0, word=word,
                            address=reg.absolute_address, mask=mask, reset=reset,
                            readable=reg.has_sw_readable, writable=reg.has_sw_writable))
    package = ['// RDL-derived structure and validated instance constants. DO NOT EDIT.',
               'package apb_secure_demux_instance_pkg;',
               'typedef enum int unsigned {' + ','.join('K_' + k for k in KINDS) + '} register_kind_t;',
               f'localparam int unsigned REG_COUNT={len(records)};']
    for key, value in values.items():
        if isinstance(value, list):
            if key == 'RESET_PERM':
                rows = [value[p*values['NUM_MASTERS']:(p+1)*values['NUM_MASTERS']] for p in range(values['NUM_PORTS'])]
                literal = "'{" + ','.join("'{" + ','.join(f"8'h{x:02x}" for x in row) + '}' for row in rows) + '}'
                package.append(f'localparam logic [7:0] C_{key}[{values["NUM_PORTS"]}][{values["NUM_MASTERS"]}]={literal};')
            else:
                width = 2 if key == 'RESET_PORT_CFG' else values['ADDR_WIDTH'] + (key == 'PORT_SIZE')
                literal = "'{" + ','.join(f"{width}'h{x:x}" for x in value) + '}'
                package.append(f'localparam logic [{width-1}:0] C_{key}[{len(value)}]={literal};')
        else:
            package.append(f"localparam logic [63:0] C_{key}=64'h{int(value):x};")
    for name, field, sv_type in [('REG_KIND', 'kind', 'register_kind_t'), ('REG_PORT', 'port', 'int unsigned'),
                                  ('REG_MASTER', 'master', 'int unsigned'), ('REG_WORD', 'word', 'int unsigned'),
                                  ('REG_ADDR', 'address', 'logic [31:0]'), ('REG_MASK', 'mask', 'logic [31:0]'),
                                  ('REG_RESET', 'reset', 'logic [31:0]'), ('REG_READABLE', 'readable', 'bit'),
                                  ('REG_WRITABLE', 'writable', 'bit')]:
        entries = [('K_' + r[field]) if field == 'kind' else ("32'h%x" % int(r[field])) for r in records]
        package.append(f"localparam {sv_type} {name}[REG_COUNT]='{{" + ','.join(entries) + '};')
    for function, prop in [('public_address', 'asd_public_windows'), ('dfx_address', 'asd_dfx_windows')]:
        windows = json.loads(top.get_property(prop))
        terms = [f"((address>=32'h{lo:x}) && (address<32'h{hi:x}))" for lo, hi in windows]
        package += [f'function automatic logic {function}(input logic [31:0] address);',
                    'return ' + ' || '.join(terms) + ';', 'endfunction']
    package.append('endpackage')
    bridge = ['// RDL-derived native external-register wiring. DO NOT EDIT.',
              'module apb_secure_demux_register_bridge (',
              'input logic pclk,preset_n,psel,penable,pwrite,',
              'input logic [31:0] address,write_data,',
              'input logic [3:0] strb, input logic [2:0] prot,',
              'input logic [31:0] read_data_i [apb_secure_demux_instance_pkg::REG_COUNT],',
              'output logic [apb_secure_demux_instance_pkg::REG_COUNT-1:0] read_select_o,write_select_o,',
              'output logic ready,error,output logic [31:0] read_data);',
              'import apb_secure_demux_csr_pkg::*;',
              'apb_secure_demux__in_t hwif_in;', 'apb_secure_demux__out_t hwif_out;',
              'apb_secure_demux_csr_regblock u_native(.clk(pclk),.arst_n(preset_n),',
              '.s_apb_psel(psel),.s_apb_penable(penable),.s_apb_pwrite(pwrite),.s_apb_pprot(prot),',
              '.s_apb_paddr(address[APB_SECURE_DEMUX_CSR_REGBLOCK_MIN_ADDR_WIDTH-1:0]),',
              '.s_apb_pwdata(write_data),.s_apb_pstrb(strb),.s_apb_pready(ready),',
              '.s_apb_prdata(read_data),.s_apb_pslverr(error),.hwif_in(hwif_in),.hwif_out(hwif_out));',
              '// Every field/selection bit has one explicit structural driver.']
    for i, reg in enumerate(records):
        path = reg['path']
        if reg['readable']:
            bridge += [f'assign hwif_in.{path}.rd_ack=(hwif_out.{path}.req && !hwif_out.{path}.req_is_wr);',
                       f"assign hwif_in.{path}.rd_data=read_data_i[{i}] & 32'h{reg['mask']:08x};",
                       f'assign read_select_o[{i}]=(hwif_out.{path}.req && !hwif_out.{path}.req_is_wr);']
        else:
            bridge.append(f"assign read_select_o[{i}]=1'b0;")
        if reg['writable']:
            bridge += [f'assign hwif_in.{path}.wr_ack=(hwif_out.{path}.req && hwif_out.{path}.req_is_wr);',
                       f'assign write_select_o[{i}]=(hwif_out.{path}.req && hwif_out.{path}.req_is_wr);']
        else:
            bridge.append(f"assign write_select_o[{i}]=1'b0;")
    bridge += ['endmodule']
    args.output.mkdir(parents=True, exist_ok=True)
    outputs = []
    for name, lines in [('apb_secure_demux_instance_pkg.sv', package), ('apb_secure_demux_register_bridge.sv', bridge)]:
        path = args.output / name
        path.write_text('\n'.join(lines) + '\n')
        outputs.append(dict(path=name, sha256=sha(path)))
    manifest = dict(scope='RDL structural constants and external-register wiring only; no behavioral state generation',
                    inputs=[dict(path=str(p), sha256=sha(p)) for p in [args.rdl, args.config_manifest, Path(__file__)]],
                    outputs=outputs, registers=records)
    (args.output / 'register_bridge.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('Generated RDL bridge:', len(regs), 'registers')


if __name__ == '__main__':
    main()
