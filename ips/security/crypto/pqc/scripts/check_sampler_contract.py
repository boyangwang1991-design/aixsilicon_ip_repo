#!/usr/bin/env python3
"""Sampler mathematics/stream design checks, never RTL or masking signoff."""
import hashlib
import json
from math import comb
from pathlib import Path
import random


def require(ok, why):
    if not ok:
        raise AssertionError(why)


def tail_bound(n, need, numerator, denominator):
    # Exact rational P[Binomial(n,p) < need]; no floating-point tail underflow.
    top = sum(comb(n, j)*numerator**j*(denominator-numerator)**(n-j)
              for j in range(need))
    bottom = denominator**n
    bits = max(0, bottom.bit_length()-top.bit_length()-1)
    require((top << bits) < bottom, 'tail certificate failed')
    return dict(candidates=n, required=need, p=[numerator, denominator],
                probability_less_than_power_of_two=-bits,
                numerator=str(top), denominator=str(bottom))


def mapped_nibble(v, eta):
    if eta == 2:
        return 2-v % 5 if v < 15 else None
    return 4-v if v < 9 else None


def compact_scan(values, eta):
    # Unmasked mathematical abstraction of the protected count/select path.
    scratch = [0]*256
    count = 0
    visits = 0
    for v in values:
        x = mapped_nibble(v, eta)
        take = x is not None and count < 256
        for address in range(256):
            if take and address == count:
                scratch[address] = x
            visits += 1
        count += int(take)
    return scratch, count, visits


def ball_reference(candidates, signs, tau):
    c = [0]*256
    accepted = 0
    for b in candidates:
        i = 256-tau+accepted
        if accepted < tau and b <= i:
            c[i] = c[b]
            c[b] = -1 if (signs >> accepted) & 1 else 1
            accepted += 1
    return c, accepted


def ball_scan(candidates, signs, tau):
    c = [0]*256
    accepted = 0
    visits = 0
    for b in candidates:
        i = 256-tau+accepted
        take = accepted < tau and b <= i
        selected = 0
        for address in range(256):
            if address == b:
                selected = c[address]
            visits += 1
        # b==i must receive sign, matching sequential assignment semantics.
        sign = -1 if signs & 1 else 1
        for address in range(256):
            old = c[address]
            c[address] = (sign if take and address == b else
                          selected if take and address == i else old)
            visits += 1
        if take:
            signs >>= 1
        accepted += int(take)
    return c, accepted, visits


def ordering_checks():
    rng = random.Random(204203)
    compact_cases = ball_cases = 0
    for eta, n in ((2, 512), (4, 1024)):
        streams = [[15]*n, [0]*n, [j % 16 for j in range(n)]]
        streams += [[rng.randrange(16) for _ in range(n)] for _ in range(8)]
        # Required samples only become available at the budget boundary.
        streams.append([15]*(n-256)+[0]*256)
        for values in streams:
            expected = [x for v in values if (x := mapped_nibble(v, eta)) is not None][:256]
            got, count, visits = compact_scan(values, eta)
            require(got[:count] == expected and count == len(expected), 'sample order changed')
            require(visits == n*256, 'secret acceptance changed scratch address count')
            compact_cases += 1
    for tau in (39, 49, 60):
        # All-zero stream also exercises b==i at the first accepted position
        # via the separate boundary stream, including the last i=255 case.
        streams = [[255]*256, [0]*256, list(range(256))]
        streams += [[rng.randrange(256) for _ in range(256)] for _ in range(8)]
        streams.append(list(range(256-tau, 256))+[255]*(256-tau))
        for values in streams:
            signs = rng.getrandbits(64)
            expected, count = ball_reference(values, signs, tau)
            actual, actual_count, visits = ball_scan(values, signs, tau)
            require((actual, actual_count) == (expected, count), 'ball permutation/sign changed')
            require(visits == 256*512, 'secret rejection changed ball address count')
            require(sum(x != 0 for x in actual) == count, 'challenge weight mismatch')
            ball_cases += 1
    # Per-output sampling slots discard valid candidates and change determinism.
    stream = [0, 1, 2, 3]
    reference = [mapped_nibble(v, 2) for v in stream][:2]
    wrong_slots = [mapped_nibble(stream[i], 2) for i in (0, 2)]
    require(reference != wrong_slots, 'per-output slot negative control ineffective')
    return dict(compaction_cases=compact_cases, ball_cases=ball_cases,
                negative_control='per_output_candidate_slots_change_sequence',
                exclusions=['masked implementation', 'cycle latency', 'random gadget budget'])


def reservoir(data, width, stall):
    acc = bits = pos = cycle = 0
    out = []
    while len(out) < 256:
        cycle += 1
        if bits < width:
            if stall and cycle % 5 in (0, 1):
                continue
            require(pos < len(data), 'underflow')
            acc |= data[pos] << bits
            bits += 8
            pos += 1
            require(bits <= 31, 'reservoir overflow')
        elif not stall or cycle % 3 != 0:
            out.append(acc & ((1 << width)-1))
            acc >>= width
            bits -= width
    return out, pos


def stream_checks():
    rng = random.Random(3329)
    cases = 0
    for width in (4, 6, 18, 20, 24):
        size = 256*width//8
        data = bytes(rng.randrange(256) for _ in range(size))
        raw = int.from_bytes(data, 'little')
        expected = [(raw >> (j*width)) & ((1 << width)-1) for j in range(256)]
        for stall in (False, True):
            actual, consumed = reservoir(data, width, stall)
            require(actual == expected and consumed == size, 'bitstream loss under backpressure')
            cases += 1
    cbd_cases = 0
    for eta in (2, 3):
        counts = {}
        for bits in range(1 << (2*eta)):
            a = (bits & ((1 << eta)-1)).bit_count()
            b = (bits >> eta).bit_count()
            residue = (a-b) % 3329
            require(0 <= residue < 3329, 'CBD residue range')
            counts[a-b] = counts.get(a-b, 0)+1
            cbd_cases += 1
        require(counts == {d: comb(2*eta, eta+d) for d in range(-eta, eta+1)},
                'CBD multiplicity not binomial')
    return dict(reservoir_cases=cases, cbd_exhaustive_cases=cbd_cases)


def main():
    root = Path(__file__).resolve().parents[1]
    paths = [Path(__file__).resolve(), root/'docs/lld/03_sampler.md',
             root/'docs/lld/03_sampler_secret.md']
    inputs = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in paths}
    bounds = {'eta2': tail_bound(512, 256, 15, 16),
              'eta4': tail_bound(1024, 256, 9, 16)}
    for tau in (39, 49, 60):
        # Each trial before completion has acceptance >= (257-tau)/256.
        bounds[f'ball{tau}'] = tail_bound(256, tau, 257-tau, 256)
    require(all(b['probability_less_than_power_of_two'] <= -128
                for b in bounds.values()), 'candidate tail exceeds analysis target')
    result = dict(schema='pqc-sampler-design-check/1.0', status='pass',
                  rtl_verified=False, security_verified=False,
                  probability_assumption='independent uniform XOF candidates, per invocation',
                  bounds=bounds, ordering=ordering_checks(), stream=stream_checks(), inputs=inputs)
    require(all(hashlib.sha256((root/p).read_bytes()).hexdigest() == h
                for p, h in inputs.items()), 'input changed during check')
    out = root/'build/design/g2_continue/sampler_check.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('bounds', 'inputs')}, indent=2))
    print({name: b['probability_less_than_power_of_two'] for name, b in bounds.items()})


if __name__ == '__main__':
    main()
