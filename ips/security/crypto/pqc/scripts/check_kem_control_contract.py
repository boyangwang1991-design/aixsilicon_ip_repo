#!/usr/bin/env python3
"""Bounded KEM control design checks; no cryptographic/RTL/security signoff."""
from dataclasses import dataclass, replace
import hashlib
import json
from pathlib import Path


def require(ok, message):
    if not ok:
        raise AssertionError(message)


PARAMS = ((2, 3, 10, 4, 800, 1632, 768),
          (3, 2, 10, 4, 1184, 2400, 1088),
          (4, 2, 11, 5, 1568, 3168, 1568))


def parameter_and_loop_checks():
    pairs = nonces = 0
    for k, eta1, du, dv, ek, dk, ct in PARAMS:
        require((384*k+32, 768*k+96, 32*(du*k+dv)) == (ek, dk, ct),
                'parameter length mismatch')
        require(ct < 2**11 and 2*k < 2**8, 'counter capacity')
        # Independent nonce domains for KeyGen and Encrypt. CBD produces 256
        # coefficients from exactly 64*eta bytes; eta2 is always 2 here.
        kg = [('s', i, eta1) for i in range(k)]
        kg += [('e', k+i, eta1) for i in range(k)]
        enc = [('y', i, eta1) for i in range(k)]
        enc += [('e1', k+i, 2) for i in range(k)] + [('e2', 2*k, 2)]
        for stream in (kg, enc):
            require([n for _, n, _ in stream] == list(range(len(stream))),
                    'nonce reuse or skipped nonce')
            require(all(64*eta*8 == 256*2*eta for _, _, eta in stream),
                    'CBD consumption mismatch')
            nonces += len(stream)
        # Reference matrix entries carry coordinate labels, not random values.
        matrix = {(i, j): (j, i) for i in range(k) for j in range(k)}
        for i in range(k):
            for j in range(k):
                require(matrix[i, j] == (j, i), 'KeyGen matrix orientation')
                require(matrix[j, i] == (i, j), 'Encrypt matrix transpose')
                pairs += 1
        require(matrix[1, 0] != matrix[0, 1], 'transpose negative control')
    return dict(parameter_sets=3, matrix_pairs=pairs, nonce_instances=nonces,
                negative_control='untransposed_encrypt_suffix_detected')


@dataclass(frozen=True)
class Token:
    epoch: int = 7
    primitive: int = 11
    engine: int = 2
    allocation: int = 5
    count: int = 256


@dataclass
class Dispatch:
    state: str = 'ISSUE'
    token: Token = Token()
    issued: int = 0
    retired: int = 0

    def tick(self, ready=False, response=None, cancel=False, ok=True):
        if cancel:
            self.state = 'CLEAR'
            return
        if self.state in ('CLEAR', 'LOCKED', 'FAIL'):
            return  # draining cannot restore a cancelled or failed command
        if self.state == 'ISSUE':
            if response is not None and response.epoch == self.token.epoch:
                self.state = 'FAIL'
            elif ready:
                self.issued += 1
                self.state = 'WAIT'
        elif response is not None:
            if response.epoch != self.token.epoch:
                return  # revoked epoch is drained, never retired
            if self.state != 'WAIT' or response != self.token or not ok:
                self.state = 'FAIL'
            else:
                self.retired += 1
                self.state = 'ADVANCE'


def dispatch_checks():
    cases = 0
    for stalls in range(17):
        d = Dispatch()
        for _ in range(stalls):
            old = d.token
            d.tick()
            require(d.state == 'ISSUE' and d.token == old and d.issued == 0,
                    'request changed or issued under backpressure')
        d.tick(ready=True)
        d.tick(response=replace(d.token, epoch=6))
        require(d.state == 'WAIT' and d.retired == 0, 'stale result retired')
        d.tick(response=d.token)
        require((d.state, d.issued, d.retired) == ('ADVANCE', 1, 1),
                'matching response not retired exactly once')
        d.tick(response=d.token)
        require(d.state == 'FAIL' and d.retired == 1, 'duplicate response accepted')
        cases += 1
    for field in ('primitive', 'engine', 'allocation', 'count'):
        d = Dispatch()
        d.tick(ready=True)
        d.tick(response=replace(d.token, **{field: getattr(d.token, field)+1}))
        require(d.state == 'FAIL' and d.retired == 0, 'identity mismatch ignored')
        cases += 1
    for state in ('ISSUE', 'WAIT', 'ADVANCE'):
        d = Dispatch(state=state)
        d.tick(ready=True, response=d.token, cancel=True)
        require(d.state == 'CLEAR' and d.retired == 0 and d.issued == 0,
                'cancel lost to simultaneous handshake')
        d.tick(ready=True, response=d.token)
        require(d.state == 'CLEAR' and d.retired == 0,
                'late response revived cancelled command')
        cases += 1
    d = Dispatch()
    d.tick(ready=True, response=d.token)
    require(d.state == 'FAIL', 'same-edge combinational completion accepted')
    return dict(scenarios=cases+1, exclusions=['engine latency', 'RTL scoreboard'])


def compare_stream(left, right, stall=False, early_exit=False, old_last=False):
    """Two response slots; each side independently held until paired."""
    idx = cycle = diff = 0
    a = b = None
    addresses = []
    while idx < len(left):
        cycle += 1
        if a is None and (not stall or cycle % 3 != 0):
            a = (idx, left[idx])
        if b is None and (not stall or cycle % 5 in (0, 2)):
            b = (idx, right[idx])
        if a is None or b is None:
            continue
        require(a[0] == b[0] == idx, 'unpaired comparison')
        addresses.append(idx)
        updated = diff | (a[1] ^ b[1])
        if not (old_last and idx == len(left)-1):
            diff = updated
        idx += 1
        a = b = None
        if early_exit and diff:
            break
    return diff == 0, addresses, cycle


def compare_checks():
    cases = 0
    for _, _, _, _, _, _, length in PARAMS:
        original = bytes((17*i+3) % 256 for i in range(length))
        # Exhaust every single mismatching byte position plus exact equality.
        for mismatch in range(-1, length):
            calculated = bytearray(original)
            if mismatch >= 0:
                calculated[mismatch] ^= 0x80
            equal, addresses, cycles = compare_stream(original, calculated)
            require(equal == (mismatch == -1), 'wrong equality decision')
            require(addresses == list(range(length)) and cycles == length,
                    'mismatch changed full traversal')
            cases += 1
        for mismatch in (-1, 0, length//2, length-1):
            calculated = bytearray(original)
            if mismatch >= 0:
                calculated[mismatch] ^= 1
            equal, addresses, cycles = compare_stream(original, calculated, stall=True)
            require(equal == (mismatch == -1) and addresses == list(range(length)),
                    'backpressure lost bytes or changed comparison')
            reference_cycles = compare_stream(original, original, stall=True)[2]
            require(cycles == reference_cycles, 'mismatch affected stalled timing')
            # This arithmetic selector is only the Level 0/1 functional contract.
            candidate = bytes(range(32))
            fallback = bytes(range(255, 223, -1))
            mask = 255 if equal else 0
            selected = bytes((a & mask) | (b & (255 ^ mask))
                             for a, b in zip(candidate, fallback))
            require(selected == (candidate if mismatch == -1 else fallback),
                    'secret candidate select incorrect')
            cases += 1
        last = bytearray(original)
        last[-1] ^= 1
        require(compare_stream(original, last, old_last=True)[0],
                'negative control did not expose stale last-byte accumulator')
        first = bytearray(original)
        first[0] ^= 1
        require(len(compare_stream(original, first, early_exit=True)[1]) != length,
                'negative control did not expose early exit')
    return dict(cases=cases, mismatch_positions=3424,
                negative_controls=['old_last_accumulator', 'early_exit'],
                exclusions=['masked comparison/select', 'cryptographic K/J',
                            'RTL AXI/SRAM timing', 'physical leakage'])


def main():
    root = Path(__file__).resolve().parents[1]
    paths = [Path(__file__).resolve(), root/'docs/lld/03_kemseq.md',
             root/'docs/lld/04_safety_mechanisms.md', root/'docs/hld/05_flows.md',
             root/'docs/hld/05_flows_algorithms.md']
    hashes = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in paths}
    result = dict(schema='pqc-kem-control-design-check/1.0', status='pass',
                  rtl_verified=False, cryptography_verified=False,
                  security_verified=False, parameters=parameter_and_loop_checks(),
                  dispatch=dispatch_checks(), compare_select=compare_checks(), inputs=hashes)
    require(all(hashlib.sha256((root/p).read_bytes()).hexdigest() == h
                for p, h in hashes.items()), 'input changed during checks')
    out = root/'build/design/g2_continue/kem_control_check.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
