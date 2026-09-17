#!/usr/bin/env python3
"""Functional design model only: independent hashlib oracle, no RTL/security claim."""
import hashlib
import json
from pathlib import Path
import random

MASK = (1 << 64) - 1
ROT = ((0, 36, 3, 41, 18), (1, 44, 10, 45, 2), (62, 6, 43, 15, 61),
       (28, 55, 25, 21, 56), (27, 20, 39, 8, 14))
RC = (0x0000000000000001, 0x0000000000008082, 0x800000000000808a,
      0x8000000080008000, 0x000000000000808b, 0x0000000080000001,
      0x8000000080008081, 0x8000000000008009, 0x000000000000008a,
      0x0000000000000088, 0x0000000080008009, 0x000000008000000a,
      0x000000008000808b, 0x800000000000008b, 0x8000000000008089,
      0x8000000000008003, 0x8000000000008002, 0x8000000000000080,
      0x000000000000800a, 0x800000008000000a, 0x8000000080008081,
      0x8000000000008080, 0x0000000080000001, 0x8000000080008008)


def rot(a, n):
    return ((a << n) | (a >> ((64 - n) % 64))) & MASK


def linear(a):
    c = [a[x] ^ a[x+5] ^ a[x+10] ^ a[x+15] ^ a[x+20] for x in range(5)]
    d = [c[(x-1) % 5] ^ rot(c[(x+1) % 5], 1) for x in range(5)]
    b = [0] * 25
    for x in range(5):
        for y in range(5):
            b[y + 5*((2*x + 3*y) % 5)] = rot(a[x+5*y] ^ d[x], ROT[x][y])
    return b


class Model:
    def __init__(self, seed):
        # Reproducible test masks only, explicitly not a production entropy source.
        self.rng = random.Random(seed)
        self.initial_bits = 1600
        self.chi_bits = 0
        self.permutations = 0
        mask = [self.rng.getrandbits(64) for _ in range(25)]
        self.a = [mask[:], mask[:]]

    def permute(self):
        for rc in RC:
            b0, b1 = map(linear, self.a)
            out = [[0]*25, [0]*25]
            for y in range(5):
                for x in range(5):
                    i, j, k = x+5*y, (x+1) % 5+5*y, (x+2) % 5+5*y
                    a0, a1, v0, v1 = b0[j] ^ MASK, b1[j], b0[k], b1[k]
                    r, s, m = [self.rng.getrandbits(64) for _ in range(3)]
                    # First register stage, followed by second register equations.
                    B0, B1 = v1 ^ r, v0 ^ r
                    U0, U1 = (a0 & r) ^ s, (a1 & r) ^ s
                    D0, D1 = a0 & v0, a1 & v1
                    c0 = D0 ^ (a0 & B0) ^ U0 ^ m
                    c1 = D1 ^ (a1 & B1) ^ U1 ^ m
                    out[0][i], out[1][i] = b0[i] ^ c0, b1[i] ^ c1
                    self.chi_bits += 192
            out[0][0] ^= rc
            self.a = out
        self.permutations += 1

    def absorb_public_block(self, block):
        for i in range(0, len(block), 8):
            self.a[0][i//8] ^= int.from_bytes(block[i:i+8], 'little')
        self.permute()

    def digest(self, message, rate, suffix, length):
        full = len(message)//rate
        for n in range(full):
            self.absorb_public_block(message[n*rate:(n+1)*rate])
        final = bytearray(rate)
        tail = message[full*rate:]
        final[:len(tail)] = tail
        final[len(tail)] ^= suffix
        final[-1] ^= 0x80
        self.absorb_public_block(final)
        output = bytearray()
        while len(output) < length:
            # Recombination is ONLY the model observation; no RTL readback contract.
            block = b''.join((u ^ v).to_bytes(8, 'little') for u, v in zip(*self.a))[:rate]
            output.extend(block[:length-len(output)])
            if len(output) < length:
                self.permute()
        assert self.chi_bits == self.permutations * 115200
        return bytes(output)


def main():
    root = Path(__file__).resolve().parents[1]
    rows = []
    for name, rate, suffix, size in [('sha3_256',136,6,32), ('sha3_512',72,6,64),
                                     ('shake_128',168,31,None), ('shake_256',136,31,None)]:
        for n in (0, 1, rate-1, rate, rate+1, 2*rate):
            msg = bytes((i*73+19) % 256 for i in range(n))
            for seed in (7, 901):
                size_out = size if size else 2*rate+9
                model = Model(seed)
                actual = model.digest(msg, rate, suffix, size_out)
                oracle = getattr(hashlib, name)(msg)
                expected = oracle.digest() if size else oracle.digest(size_out)
                assert actual == expected, (name, n, seed)
                rows.append(dict(function=name, input_bytes=n, output_bytes=size_out,
                                 test_mask_seed=seed, permutations=model.permutations,
                                 fresh_chi_bits=model.chi_bits, functional_match=True))
    sources = [Path(__file__).resolve(), root/'docs/lld/03_keccak.md',
               root/'docs/lld/03_masked_and.md']
    result = dict(kind='masked-keccak-functional-design-model/1.0', cases=len(rows),
                  oracle='Python hashlib/OpenSSL', rtl_verified=False,
                  security_verified=False, cycle_verified=False,
                  limitations=['Public message absorption only; secret import sharing not tested.',
                               'Atomic functional model; no stalls, glitches, transitions or netlist.',
                               'Pseudorandom deterministic test masks, not entropy validation.'],
                  sources={str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest()
                           for f in sources}, rows=rows)
    output = root/'build/design/lld_resume/masked_keccak_model.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2)+'\n')
    print(f'{len(rows)} masked functional cases match hashlib; RTL/security/cycles unverified')


if __name__ == '__main__':
    main()
