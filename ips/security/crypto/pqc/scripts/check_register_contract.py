#!/usr/bin/env python3
"""Audit elaborated RDL against selected frozen HLD and LLD obligations.

This is an input-readiness check, not CSR generation or an APB simulation.
Nonzero exit is required while semantic conflicts remain.
"""
import argparse
import hashlib
from importlib.metadata import version
import json
from pathlib import Path

from systemrdl import RDLCompiler
from systemrdl.node import RegNode
from systemrdl.rdltypes import AccessType


def audit(rdl):
    compiler = RDLCompiler()
    compiler.compile_file(str(rdl))
    top = compiler.elaborate().top
    regs = {r.inst_name: r for r in top.children() if isinstance(r, RegNode)}
    findings = []

    def problem(ident, register, detail, source):
        findings.append(dict(id=ident, register=register, detail=detail,
                             source=source, severity='major', status='open'))

    def field(reg, name):
        node = regs.get(reg)
        return next((f for f in node.fields() if f.inst_name == name), None) if node else None

    # HLD 07_register_arch.md defines the full 32-bit handle layout explicitly.
    expected = {'slot_id': (0, 7), 'owner': (8, 15), 'generation': (16, 31)}
    actual = {f.inst_name: (f.low, f.high) for f in regs['KEY_HANDLE'].fields()}
    if actual != expected:
        problem('REG-HANDLE-001', 'KEY_HANDLE',
                f'Expected {expected}, elaborated {actual}', 'docs/hld/07_register_arch.md')
    generation = field('KEY_SLOT_GEN', 'generation')
    if generation is None or generation.width != 16:
        problem('REG-HANDLE-002', 'KEY_SLOT_GEN',
                'Full 16-bit generation readback is required; current width is '
                f'{generation.width if generation else None}', 'docs/lld/03_keyslot.md')

    for reg, names in [('CTRL', ['abort', 'zeroize', 'self_test']),
                       ('DOORBELL', ['doorbell']),
                       ('KEY_SLOT_CTRL', ['import_req', 'destroy_req', 'export_req', 'lock_req']),
                       ('INTR_TEST', [f.inst_name for f in regs['INTR_TEST'].fields()])]:
        missing = [name for name in names if not field(reg, name).get_property('singlepulse')
                   and not field(reg, name).get_property('hwclr')]
        if missing:
            problem(f'REG-PULSE-{reg}', reg,
                    'Request bits have neither singlepulse nor hardware clear: '+', '.join(missing),
                    'docs/lld/03_register_behavior_1.md' if reg != 'INTR_TEST'
                    else 'docs/lld/03_register_behavior_2.md')

    # All fields within a captured command group must obey BUSY protection.
    busy_regs = ['COMMAND', 'KEY_HANDLE', 'CONTEXT_LEN', 'DESC_ADDR_LO', 'DESC_ADDR_HI']
    busy_regs += [name for name, r in regs.items() if 0x020 <= r.raw_address_offset <= 0x078]
    for name in busy_regs:
        missing = [f.inst_name for f in regs[name].fields()
                   if f.get_property('sw') in (AccessType.rw, AccessType.w)
                   and not f.get_property('swwe')]
        if missing:
            problem(f'REG-BUSY-{name}', name, 'No swwe on: '+', '.join(missing),
                    'docs/lld/03_register_behavior_1.md')
    for name, reg in regs.items():
        if name.startswith('PERF_'):
            missing = [f.inst_name for f in reg.fields()
                       if f.get_property('hw') not in (AccessType.w, AccessType.rw)
                       and not f.get_property('counter')]
            if missing:
                problem(f'REG-COUNT-{name}', name,
                        'No hardware update/counter path: '+', '.join(missing),
                        'docs/lld/03_register_behavior_2.md')
        reserved = [f.inst_name for f in reg.fields()
                    if any(s in f.inst_name.lower() for s in ('reserved', 'rsvd'))]
        if reserved:
            problem(f'REG-RESERVED-{name}', name,
                    'Explicit hardware-driven reserved fields must be gaps: '+', '.join(reserved),
                    'docs/lrs/04_register.md')
    if not any('domain' in f.inst_name.lower() for name, reg in regs.items()
               if name.startswith('KEY_SLOT') for f in reg.fields()):
        problem('REG-META-DOMAIN', 'KEY_SLOT_META', 'No domain metadata readback field',
                'docs/lrs/04_register.md')
    # Validate the working W1C behavior too, rather than returning only failures.
    w1c_checks = 0
    for name in ('INTR_STATE', 'ALERT_RECOVERABLE', 'ALERT_FATAL'):
        for f in regs[name].fields():
            good = (str(f.get_property('onwrite')).endswith('.woclr')
                    and f.get_property('hwset') is True
                    and str(f.get_property('precedence')).endswith('.hw'))
            if not good:
                problem(f'REG-W1C-{name}-{f.inst_name}', name,
                        'Expected per-bit W1C, hardware set and hardware priority',
                        'docs/lld/03_register_behavior_2.md')
            w1c_checks += 1
    return dict(register_definitions=len(regs),
                field_definitions=sum(len(list(r.fields())) for r in regs.values()),
                w1c_fields_checked=w1c_checks, findings=findings)


def main():
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--rdl', type=Path, default=root/'regs/pqc.rdl')
    parser.add_argument('--output', type=Path,
                        default=root/'build/design/g2_continue/register_contract_check.json')
    args = parser.parse_args()
    paths = [Path(__file__).resolve(), args.rdl.resolve()]
    paths += [root/p for p in ('docs/hld/07_register_arch.md', 'docs/lrs/04_register.md',
              'docs/lld/03_keyslot.md', 'docs/lld/03_register_behavior_1.md',
              'docs/lld/03_register_behavior_2.md')]
    inputs = {str(p.relative_to(root)) if p.is_relative_to(root) else str(p):
              hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    result = audit(args.rdl)
    result.update(schema='pqc-register-contract-audit/1.0',
                  status='fail' if result['findings'] else 'pass',
                  scope='Selected elaborated register obligations; not exhaustive field signoff.',
                  tool='systemrdl-compiler', tool_version=version('systemrdl-compiler'),
                  rtl_verified=False, inputs=inputs)
    if any(hashlib.sha256(p.read_bytes()).hexdigest() != inputs[
            str(p.relative_to(root)) if p.is_relative_to(root) else str(p)] for p in paths):
        raise RuntimeError('input changed during audit')
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))
    return 1 if result['findings'] else 0


if __name__ == '__main__':
    raise SystemExit(main())
