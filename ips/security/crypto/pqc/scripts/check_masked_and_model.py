#!/usr/bin/env python3
"""Exhaustive single-execution bit-gadget checks; not RTL/compositional signoff."""
from collections import Counter
from itertools import product
import hashlib
import json
from pathlib import Path


def circuit(values):
    nodes = {k: ('input', (), v) for k, v in values.items()}
    def make(name, op, *parents):
        data = [nodes[x][2] for x in parents]
        value = data[0] if op == 'reg' else data[0] ^ data[1] if op == 'xor' else data[0] & data[1]
        nodes[name] = (op, parents, value)
        return name
    for i in (0, 1):
        make(f'A{i}', 'reg', f'a{i}')
        make(f'br{i}', 'xor', f'b{1-i}', 'r')
        make(f'B{i}', 'reg', f'br{i}')
        make(f'ar{i}', 'and', f'a{i}', 'r')
        make(f'ur{i}', 'xor', f'ar{i}', 's')
        make(f'U{i}', 'reg', f'ur{i}')
        make(f'dr{i}', 'and', f'a{i}', f'b{i}')
        make(f'D{i}', 'reg', f'dr{i}')
    make('M', 'reg', 'm')
    for i in (0, 1):
        make(f'cross{i}', 'and', f'A{i}', f'B{i}')
        make(f'partial{i}', 'xor', f'D{i}', f'cross{i}')
        make(f'w{i}', 'xor', f'partial{i}', f'U{i}')
        make(f'out{i}', 'xor', f'w{i}', 'M')
        make(f'c{i}', 'reg', f'out{i}')
    # Incorrect, unregistered mixing of both b shares: the checker must detect it.
    make('bad_cross', 'and', 'a0', 'b1')
    make('bad', 'xor', 'dr0', 'bad_cross')
    return nodes


def cone(nodes, name):
    op, parents, _ = nodes[name]
    if op in ('reg', 'input'):
        return {name}
    return set().union(*(cone(nodes, x) for x in parents))


def main():
    hist = {}
    count = 0
    for a, b in product((0, 1), repeat=2):
        counters = {}
        for ma, mb, r, s, m in product((0, 1), repeat=5):
            nodes = circuit(dict(a0=ma, a1=a^ma, b0=mb, b1=b^mb, r=r, s=s, m=m))
            assert nodes['c0'][2] ^ nodes['c1'][2] == a & b
            for name in nodes:
                observation = tuple(nodes[x][2] for x in sorted(cone(nodes, name)))
                counters.setdefault(name, Counter())[observation] += 1
            count += 1
        hist[a, b] = counters
    baseline = hist[0, 0]
    differing = [name for name in baseline
                 if any(case[name] != baseline[name] for case in hist.values())]
    assert set(differing) == {'bad'}, differing
    root = Path(__file__).resolve().parents[1]
    result = dict(kind='masked-and-bit-model/1.0', functional_cases=count,
                  good_glitch_cones=len(baseline)-2,
                  negative_control_detected=differing,
                  rtl_verified=False, composition_verified=False,
                  transition_verified=False, physical_leakage_verified=False,
                  scope='One execution, independent uniformly shared two-bit inputs, one glitch-extended probe; no feedback or stalls.',
                  inputs={str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest()
                          for f in (Path(__file__).resolve(), root/'docs/lld/03_masked_and.md')})
    out = root/'build/design/lld_resume/masked_and_model.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
