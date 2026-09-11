"""Audit elaborated RDL against the contract's fixed slots and field behavior refs."""
import argparse
import hashlib
import json
import re
from pathlib import Path

import yaml
from systemrdl import RDLCompiler
from systemrdl.node import RegNode


def audit(rdl, values, micro):
    compiler = RDLCompiler()
    compiler.compile_file(str(rdl))
    top = compiler.elaborate().top
    nodes = [n for n in top.descendants(unroll=True) if isinstance(n, RegNode)]
    actual = {n.absolute_address: n for n in nodes}
    expected = set(range(0, 0x068, 4))
    expected.update(range(0x0a0, 0x0e0, 4))
    if values['EVENT_FIFO_DEPTH']:
        expected.update(range(0x0e0, 0x100, 4))
    else:
        expected.remove(0x04c)
    if values['DFX_EN']:
        expected.update(range(0x100, 0x114, 4))
    else:
        expected.remove(0x040)
    for port in range(values['NUM_PORTS']):
        base = 0x1000 + port * 0x400
        expected.update(base + off for off in range(0, 0x014, 4))
        if values['DFX_EN']:
            expected.update(base + off for off in range(0x014, 0x02c, 4))
        for master in range(values['NUM_MASTERS']):
            expected.add(base + 0x100 + 4 * master)
            expected.add(base + 0x200 + 4 * master)
    errors = []
    if set(actual) != expected or len(actual) != len(nodes):
        errors.append('slot set differs from contract or duplicate register address')
    refs = {r['register_ref'] for r in micro['registers']}
    covered = set()
    for node in nodes:
        used = 0
        for field in node.fields():
            mask = ((1 << field.width) - 1) << field.low
            if used & mask or field.high > 31:
                errors.append('invalid field layout: ' + field.get_path())
            used |= mask
            logical = re.sub(r'port_\d+', 'port[p]', field.get_path())
            logical = re.sub(r'PERM_(SHADOW|ACTIVE)_\d+', r'PERM_\1[m]', logical)
            logical = re.sub(r'(FIRST_FAULT|LAST_FAULT|FIFO_HEAD)\[\d+\]', r'\1[w]', logical)
            if logical not in refs:
                errors.append('field has no frozen LLD behavior: ' + logical)
            covered.add(logical)
            reset = field.get_property('reset')
            if not isinstance(reset, int) or not 0 <= reset < 2 ** field.width:
                errors.append('invalid reset: ' + logical)
        name = node.inst_name
        fs = list(node.fields())
        if name in ('GLOBAL_LOCK', 'PORT_LOCK'):
            if any(f.get_property('onwrite').name != 'woset' or f.get_property('sw').name != 'rw' for f in fs):
                errors.append('lock must be readable W1S')
        if name == 'INTR_RAW':
            if any(f.get_property('onwrite').name != 'woclr' or f.get_property('sw').name != 'rw' for f in fs):
                errors.append('RAW must be readable W1C')
    # Independently compute instance-visible reset words and policy reset placement.
    reset_words = {off: sum(f.get_property('reset') << f.low for f in n.fields()) for off, n in actual.items()}
    wanted = {0: 0x41534458, 4: 0x10000,
              8: values['NUM_PORTS'] | values['NUM_MASTERS'] << 8 | values['ADDR_WIDTH'] << 16 | values['MASTER_ID_WIDTH'] << 24,
              12: int(values['REGISTER_MODE']) | int(values['OUTPUT_ISOLATION_EN']) << 1 | int(values['POLICY_PARITY_EN']) << 2 | int(values['DFX_EN']) << 3 | int(values['PUBLIC_ID_EN']) << 4 | values['EVENT_FIFO_DEPTH'] << 8,
              0x28: values['MGMT_MASTER_MASK'] & 0xffffffff,
              0x2c: values['MGMT_MASTER_MASK'] >> 32, 0x3c: 0x9b, 0x48: 0x100}
    for p in range(values['NUM_PORTS']):
        base = 0x1000 + p * 0x400
        wanted.update({base: values['PORT_BASE'][p], base + 4: values['PORT_BASE'][p] + values['PORT_SIZE'][p] - 1,
                       base + 0xc: values['RESET_PORT_CFG'][p], base + 0x10: values['RESET_PORT_CFG'][p]})
        for m in range(values['NUM_MASTERS']):
            for bank in (0x100, 0x200):
                wanted[base + bank + 4 * m] = values['RESET_PERM'][p * values['NUM_MASTERS'] + m]
    for off, expected_value in wanted.items():
        if reset_words.get(off) != expected_value:
            errors.append(f'reset mismatch at {off:#x}')
    return {'scope': 'RDL structure/reset audit, not external state implementation or RTL proof',
            'register_count': len(nodes), 'logical_behaviors_covered': len(covered), 'errors': errors,
            'rdl_sha256': hashlib.sha256(rdl.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--rdl', type=Path, required=True)
    parser.add_argument('--config-manifest', type=Path, required=True)
    parser.add_argument('--micro-design', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads(args.config_manifest.read_text())
    if hashlib.sha256(args.rdl.read_bytes()).hexdigest() != manifest['rdl_sha256']:
        raise ValueError('RDL identity mismatch')
    result = audit(args.rdl, manifest['values'], yaml.safe_load(args.micro_design.read_text()))
    result['configuration'] = manifest['configuration']
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
    return bool(result['errors'])


if __name__ == '__main__':
    raise SystemExit(main())
