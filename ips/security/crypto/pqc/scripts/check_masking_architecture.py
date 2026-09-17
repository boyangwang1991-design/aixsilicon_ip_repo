#!/usr/bin/env python3
"""Check planned masking SRAM intervals and an optional pinned reference audit.

This checks architecture allocations, not RTL accesses, cryptographic correctness,
probing security, or physical leakage. Output belongs in the ignored build tree.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--reference', type=Path)
    args = parser.parse_args()
    root = args.workspace.resolve()
    doc = root / 'docs/hld/09_masking_execution.md'
    rows = re.findall(r'^\| (sign_matrix|sign_check) \| (\w+) \| (\d+) \| (\d+) \|$',
                      doc.read_text(), re.M)
    if not rows:
        raise ValueError('no allocation table found')
    phases = {}
    for phase, role, first, count in rows:
        slots = phases.setdefault(phase, {})
        for page in range(int(first), int(first) + int(count)):
            if page >= 32 or page in slots:
                raise ValueError(f'{phase}: out-of-range/overlapping page {page}')
            slots[page] = role
    if set(phases) != {'sign_matrix', 'sign_check'}:
        raise ValueError('missing Sign phase')
    # Check the documented forward move with symbolic data, including overlap.
    memory = [f'old{i}' for i in range(32)]
    for i in range(8):
        memory[7+i] = f'w{i}'
    for i in range(8):
        memory[i] = memory[7+i]
    if memory[:8] != [f'w{i}' for i in range(8)]:
        raise ValueError('planned w move overwrites live source')
    result = dict(kind='masking-architecture-check/1.0',
                  scope='Planned intervals and symbolic page move only; no RTL/security proof.',
                  rtl_verified=False, security_verified=False,
                  phases={k: dict(used_pages=len(v), highest_page=max(v),
                                  free_pages=32-len(v)) for k, v in phases.items()},
                  symbolic_move='pass',
                  inputs={str(doc.relative_to(root)): sha(doc),
                          str(Path(__file__).resolve().relative_to(root)): sha(Path(__file__))})
    if args.reference:
        ref = args.reference.resolve()
        commit = subprocess.check_output(['git', '-C', str(ref), 'rev-parse', 'HEAD'], text=True).strip()
        if commit != '7057a7c34f0b23d4c8969a92a89563185fda04d4':
            raise ValueError('reference version changed; repeat review')
        paths = [ref/'src'/name for name in ('MaskConversion_HALFCYCLE_STREAM.sv',
                 'MaskConversion_2SHARE_HALFCYCLE_STREAM.sv', 'SecAdd_HALFCYCLE_STREAM.sv')]
        wrapper, converter, adder = [x.read_text() for x in paths]
        override = re.search(r'MaskConversion_2SHARE_HALFCYCLE_STREAM\s*#\((.*?)\)\s*MaskConv',
                             wrapper, re.S)
        if not override:
            raise ValueError('reference instance no longer matches audited structure')
        # Narrow source observations, deliberately not a generic Verilog checker.
        result['reference_audit'] = dict(commit=commit,
            q_forwarded=bool(re.search(r'\.(?:q|KYBER_q)\s*\(', override[1])),
            ready_result_occurrences=len(re.findall(r'\bready_result\b', converter)),
            fixed_13bit_adder_connection='output_p_triangle[j][12]' in adder,
            production_dependency=False,
            inputs={str(x.relative_to(ref)): sha(x) for x in paths})
    out = root/'build/design/masking_architecture/check.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
