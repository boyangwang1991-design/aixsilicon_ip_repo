#!/usr/bin/env python3
"""Integer range certificate for planned reducers; not an RTL equivalence proof."""
import hashlib
import json
from pathlib import Path
import random


def main():
    root = Path(__file__).resolve().parents[1]
    base, q = 1 << 23, 8380417
    fold_factor = (1 << 13) - 1
    assert base - fold_factor == q
    # For any 0<=x<=upper, F(x) = low23(x)+8191*high23(x).
    # F(x)-x = -q*high23(x), and the following is a conservative bound.
    upper = (1 << 46) - 1
    bounds = []
    for _ in range(3):
        upper = base - 1 + fold_factor * (upper // base)
        bounds.append(upper)
    assert upper < 2*q

    def dsa_reduce(value):
        for _ in range(3):
            value = (value & (base-1)) + fold_factor*(value >> 23)
        return value-q if value >= q else value

    kq, reciprocal_base = 3329, 1 << 24
    reciprocal = reciprocal_base // kq
    assert reciprocal == 5039
    delta = reciprocal_base - kq*reciprocal
    assert 0 <= delta < kq
    # floor(x*mu/B) underestimates floor(x/q) by at most one for x<B.
    # Therefore x-q*estimate is nonnegative and <2*q.
    def kem_reduce(value):
        estimate = (value*reciprocal) >> 24
        residue = value-estimate*kq
        return residue-kq if residue >= kq else residue

    rng = random.Random(0x505143)
    dsa_cases = {0, 1, q-1, q, q+1, (q-1)**2, (1 << 46)-1}
    for bit in range(46):
        dsa_cases.update(x for x in ((1 << bit)-1, 1 << bit, (1 << bit)+1) if x < 1 << 46)
    dsa_cases.update(rng.randrange(1 << 46) for _ in range(10000))
    for value in dsa_cases:
        assert dsa_reduce(value) == value % q, value
    # Exhaust every possible quotient boundary, including the full 24-bit domain.
    kem_cases = {0, (kq-1)**2, reciprocal_base-1}
    for quotient in range(reciprocal_base // kq + 1):
        kem_cases.update(x for x in (quotient*kq-1, quotient*kq, quotient*kq+1)
                         if 0 <= x < reciprocal_base)
    for value in kem_cases:
        assert kem_reduce(value) == value % kq, value
    doc = root/'docs/lld/03_poly.md'
    result = dict(kind='integer-reduction-certificate/1.0', rtl_verified=False,
        scope='Algebraic congruence and conservative interval bounds, plus boundary/random arithmetic checks.',
        dsa=dict(input_bits=46, fold_factor=fold_factor, bounds=bounds,
                 widths=[x.bit_length() for x in bounds], final_subtractions=1,
                 checked_cases=len(dsa_cases)),
        kem=dict(input_bits=24, reciprocal=reciprocal, reciprocal_error=delta,
                 final_subtractions=1, checked_cases=len(kem_cases)),
        inputs={str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest()
                for f in (Path(__file__).resolve(), doc)})
    out = root/'build/design/lld_resume/reduction_certificate.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
