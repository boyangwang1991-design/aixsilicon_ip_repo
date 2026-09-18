#!/usr/bin/env python3
"""Offline fixture generation for ML-KEM Decaps (FIPS 203).

Generates frozen KAT vectors consumed by the UVM Decaps testcase:
  dk (private key, imported through the KM sideload),
  ct (ciphertext, staged in AXI memory by the testbench),
  ss (expected 32-byte shared secret).

This script is OFFLINE-ONLY: it runs the reference oracle during vector
preparation, never during UVM simulation. The UVM testbench consumes the
frozen hex files and compares the RTL output against them byte-by-byte.

The descriptor layout follows the PQC command contract (see
rtl/pqc_desc_validate.sv): OP_KEM_DECAPS with command key_handle at byte offset 8 and
src0 = ciphertext at 0x2000, dst0 = shared secret at 0x4000, completion at
0x6000. The private key is imported through the KM sideload, so it is NOT
placed in AXI memory and never travels on a public bus.
"""
from __future__ import annotations

import hashlib
import importlib.metadata
import json
import zlib
from pathlib import Path

from kyber_py.ml_kem import ML_KEM_512, ML_KEM_768, ML_KEM_1024

ROOT = Path(__file__).resolve().parents[1] / "verification" / "vectors" / "decaps"
ROOT.mkdir(parents=True, exist_ok=True)

ALGS = (ML_KEM_512, ML_KEM_768, ML_KEM_1024)
PSETS = (1, 2, 3)  # ML-KEM-512 / 768 / 1024

# KM sideload identity for Decaps (algo=1 KEM, pset 1..3, usage bit 2 = Decaps)
KM_ALGO = 1
KM_USAGE = 1 << 2  # operation=2 (Decaps)

# The command key handle that gates private-key access is carried in descriptor
# bytes 8..11 (offset 8..11); rtl/pqc_cmd_frontend.sv reads exactly these bytes
# for command_key_handle and passes it to the work-key check port. (The
# decoded.key_handle field at offset 64 overlaps dst0_addr and is NOT used for
# private-key authorization in the current frontend.)
KEY_HANDLE_OFFSET = 8


def put(desc: bytearray, off: int, x: int, size: int = 4) -> None:
    desc[off:off + size] = x.to_bytes(size, "little")


def make_descriptor(case: int, pset: int, ct_len: int, key_handle: int) -> bytes:
    desc = bytearray(128)
    put(desc, 0x00, 0x10000002 + (pset << 8))   # opcode=Decaps, pset, ABI
    put(desc, 0x04, 0x12340000 + case)          # command_id
    put(desc, 0x08, 0)                          # flags
    put(desc, KEY_HANDLE_OFFSET, key_handle)    # command key_handle (byte offset 8)
    put(desc, 0x10, 0x2000, 8)                  # src0_addr = ct in AXI mem
    put(desc, 0x18, ct_len, 8)                  # src0_len = ct length
    put(desc, 0x40, 0x4000, 8)                  # dst0_addr = ss in AXI mem
    put(desc, 0x48, 32, 8)                      # dst0_capacity
    put(desc, 0x60, 0x6000, 8)                  # completion_addr
    put(desc, 0x3c, 2)                          # entropy_policy
    put(desc, 0x7c, zlib.crc32(desc[:124]))     # descriptor CRC (offset 124)
    return bytes(desc)


def main() -> None:
    manifest = {
        "schema": "pqc-decaps-kat/1",
        "source": "https://github.com/GiacomoPope/kyber-py",
        "oracle": "kyber-py",
        "version": importlib.metadata.version("kyber-py"),
        "cases": [],
    }
    for n, (alg, pset) in enumerate(zip(ALGS, PSETS)):
        for sample in range(3):
            # Keep the six existing frozen vector identities unchanged.
            case = 2 * n + sample if sample < 2 else 6 + n
            seed = f"PQC RTL Decaps KAT {case}".encode()
            d = hashlib.sha256(seed + b"d").digest()
            z = hashlib.sha256(seed + b"z").digest()
            m = hashlib.sha256(seed + b"m").digest()
            ek, dk = alg._keygen_internal(d, z)
            ss, ct = alg._encaps_internal(ek, m)
            # The oracle's own decapsulation must round-trip.
            assert alg._decaps_internal(dk, ct) == ss
            # Fixed key handle for the KM sideload check path.
            key_handle = 0xDECA_0000 + case
            desc = make_descriptor(case, pset, len(ct), key_handle)
            files = {}
            for name, data in (
                ("dk", dk),
                ("ct", ct),
                ("ss", ss),
                ("desc", desc),
            ):
                path = ROOT / f"{case}_{name}.hex"
                serialized = "".join(f"{b:02x}\n" for b in data)
                if path.exists() and path.read_text() != serialized:
                    raise ValueError(f"frozen vector changed: {path}")
                path.write_text(serialized)
                files[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
            for variant, offset in enumerate((0, len(ct)//2, len(ct)-1), start=1):
                corrupted = bytearray(ct)
                corrupted[offset] ^= 1
                # Independent FIPS rejection oracle: J(z || original received c).
                rejected = hashlib.shake_256(z + corrupted).digest(32)
                assert alg._decaps_internal(dk, bytes(corrupted)) == rejected
                path = ROOT / f"{case}_reject_{variant}_ss.hex"
                serialized = "".join(f"{b:02x}\n" for b in rejected)
                if path.exists() and path.read_text() != serialized:
                    raise ValueError(f"frozen rejection vector changed: {path}")
                path.write_text(serialized)
                files[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
            manifest["cases"].append({
                "case": case,
                "parameter_set": (512, 768, 1024)[n],
                "ct_bytes": len(ct),
                "dk_bytes": len(dk),
                "key_handle": hex(key_handle),
                "d": d.hex(),
                "z": z.hex(),
                "m": m.hex(),
                "files": files,
            })
    (ROOT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Generated {len(manifest['cases'])} independent Decaps fixtures in {ROOT}")


if __name__ == "__main__":
    main()
