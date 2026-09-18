#!/usr/bin/env python3
"""Offline ML-KEM KeyGen fixtures; UVM never runs a software algorithm."""
from pathlib import Path
import hashlib
import importlib.metadata
import json
import zlib
from kyber_py.ml_kem import ML_KEM_512, ML_KEM_768, ML_KEM_1024

ROOT = Path(__file__).resolve().parents[1] / 'verification/vectors/keygen'


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    manifest = {'schema': 'pqc-keygen-kat/1', 'oracle': 'kyber-py',
                'version': importlib.metadata.version('kyber-py'), 'cases': []}
    for family, alg in enumerate((ML_KEM_512, ML_KEM_768, ML_KEM_1024)):
        for n in range(3):
            case = 3 * family + n
            pset = family + 1
            seed = f'PQC KeyGen KAT {case}'.encode()
            d = hashlib.sha256(seed + b'd').digest()
            z = hashlib.sha256(seed + b'z').digest()
            ek, dk = alg._keygen_internal(d, z)
            desc = bytearray(128)
            def put(offset, value, size=4):
                desc[offset:offset + size] = value.to_bytes(size, 'little')
            put(0, 0x10000000 + (pset << 8))
            put(4, 0x4B470000 + case)
            put(0x3c, 2)
            put(0x40, 0x2000, 8)
            put(0x48, len(ek), 8)
            put(0x50, 0x4000, 8)
            put(0x58, 4, 8)
            put(0x60, 0x6000, 8)
            put(0x7c, zlib.crc32(desc[:124]))
            files = {}
            for kind, data in dict(entropy=d+z, ek=ek, dk=dk, desc=desc).items():
                name = f'{case}_{kind}.hex'
                content = ''.join(f'{v:02x}\n' for v in data)
                path = ROOT / name
                if path.exists() and path.read_text() != content:
                    raise ValueError(f'refusing to change frozen fixture: {path}')
                path.write_text(content)
                files[name] = dict(bytes=len(data), sha256=hashlib.sha256(path.read_bytes()).hexdigest())
            manifest['cases'].append(dict(id=case, pset=pset, files=files))
    (ROOT / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')


if __name__ == '__main__':
    main()
