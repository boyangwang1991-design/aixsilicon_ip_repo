"""Cross-layer learning experiments; standard library plus repository models.

Reads public frozen test fixtures. Does not write fixtures or execute RTL.
"""

import hashlib
import json
import sys
from pathlib import Path

PQC_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PQC_ROOT / "scripts"))
sys.path.insert(0, str(PQC_ROOT / "pqc_accel_model" / "src"))

from encaps_algebra_oracle import encaps  # noqa: E402
from pqc_hw_model.codec import pack_lsb, unpack_lsb  # noqa: E402


def representations():
    q = 3329
    packed = pack_lsb([1, 2], 12)
    assert packed.hex() == "012000"
    restored, canonical = unpack_lsb(packed, 2, 12, q)
    assert restored == [1, 2] and canonical
    print("12-bit pack [1, 2]:", packed.hex())
    for bits, expected_bound in ((4, 104), (10, 2)):
        errors = []
        for coefficient in range(q):
            compressed = ((coefficient * (1 << bits) + q // 2) // q) % (1 << bits)
            recovered = (q * compressed + (1 << (bits - 1))) >> bits
            difference = (coefficient - recovered) % q
            errors.append(min(difference, q - difference))
        assert max(errors) == expected_bound
        print(f"Compress/decompress d={bits}: max circular error={max(errors)}")
    assert (q - 1).bit_length() == 12
    assert ((q - 1) ** 2).bit_length() <= 24


def handshakes_and_budget():
    samples = [(1, 0, "A"), (1, 0, "A"), (1, 1, "A"), (1, 1, "B"), (0, 1, None)]
    accepted = [data for valid, ready, data in samples if valid and ready]
    assert accepted == ["A", "B"]
    print("Stream handshake accepted:", accepted)
    assert 0 % 8 == 8 % 8 and 0 % 8 != 1 % 8
    print("Toy bank mapping: words 0/8 conflict; 0/1 do not")
    print("Ideal KEM forward NTT, 2 lanes:", 7 * 128 // 2, "cycles (not RTL latency)")
    assert 3 * 256 * 10 // 8 + 256 * 4 // 8 == 1088
    print("Encaps-768: pk=1184 B, ct=1088 B, K=32 B; payload=2304 B")


def frozen_encaps():
    directory = PQC_ROOT / "verification" / "vectors" / "encaps"
    manifest = json.loads((directory / "manifest.json").read_text())
    case = next(item for item in manifest["cases"] if item["case"] == 2)
    assert case["parameter_set"] == 768
    for filename, expected_hash in case["files"].items():
        assert hashlib.sha256((directory / filename).read_bytes()).hexdigest() == expected_hash

    def read_fixture(name):
        return bytes.fromhex((directory / f"2_{name}.hex").read_text())

    public_key, message = read_fixture("pk"), read_fixture("m")
    assert len(public_key) == 1184 and len(message) == 32
    shared_secret, ciphertext = encaps(public_key, message, 3)
    assert len(ciphertext) == 1088 and len(shared_secret) == 32
    assert ciphertext == read_fixture("ct")
    assert shared_secret == read_fixture("ss")
    print("Frozen ML-KEM-768 case 2: manifest hashes, full ciphertext and K match")
    print("Oracle uses inverse Vandermonde and ring convolution; this is not an RTL test")


if __name__ == "__main__":
    representations()
    handshakes_and_budget()
    frozen_encaps()
