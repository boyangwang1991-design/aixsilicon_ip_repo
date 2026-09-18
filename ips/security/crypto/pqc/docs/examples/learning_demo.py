"""Small, executable reading exercises for pqc_accel_model.

Run from any directory with the workspace Python environment. The primitive
mode requires only the standard library; algorithms uses the model's pinned
third-party dependencies. This is an educational demo, not an RTL testbench.
"""

import argparse
import hashlib
import sys
from pathlib import Path

PQC_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PQC_ROOT / "pqc_accel_model" / "src"))

from pqc_hw_model.codec import pack_lsb, unpack_lsb  # noqa: E402
from pqc_hw_model.descriptor import CommandDescriptor  # noqa: E402
from pqc_hw_model.keccak import KeccakEngine  # noqa: E402
from pqc_hw_model.memory import SecureBankedSRAM  # noqa: E402
from pqc_hw_model.modular import ModularALU, ModularConfig, negacyclic_schoolbook  # noqa: E402
from pqc_hw_model.ntt import HardwareNTT, NttConfig  # noqa: E402
from pqc_hw_model.params import ParameterSet, get_params  # noqa: E402
from pqc_hw_model.trace import Trace  # noqa: E402


def primitives():
    product = negacyclic_schoolbook([1, 2, 0, 0], [3, 0, 0, 1], 17)
    assert product == [1, 6, 0, 1]
    print("negacyclic:", product)

    alu = ModularALU(ModularConfig(3329, 16, 64, 32))
    result = alu.from_montgomery(alu.montgomery_mul(alu.to_montgomery(123), alu.to_montgomery(456)))
    assert result == 123 * 456 % 3329
    print("Montgomery product:", result)

    for ps in (ParameterSet.ML_KEM_768, ParameterSet.ML_DSA_65):
        params = get_params(ps)
        poly = [(i * i + 17 * i + 3) % params.q for i in range(256)]
        engine = HardwareNTT(params, NttConfig(lanes=2, banks=8))
        forward_trace = Trace()
        transformed = engine.forward(poly, forward_trace)
        assert engine.inverse(transformed) == poly
        print(params.name, "NTT roundtrip: OK; ideal forward cycles:", forward_trace.cycles)

    packed = pack_lsb([1, 2, 3], 3)
    restored, canonical = unpack_lsb(packed, 3, 3)
    assert packed == bytes.fromhex("d100")
    assert restored == [1, 2, 3] and canonical
    _, noncanonical = unpack_lsb(pack_lsb([3329], 12), 1, 12, 3329)
    assert not noncanonical
    print("LSB packing:", packed.hex(), "; noncanonical coefficient rejected")

    engine = KeccakEngine("shake_256")
    engine.absorb(b"PQC ")
    engine.absorb(b"learning")
    digest = engine.digest(32)
    assert digest == hashlib.shake_256(b"PQC learning").digest(32)
    assert engine.digest(32) == digest  # This API returns a repeated prefix.
    print("SHAKE chunking and repeated-prefix semantics: OK")

    descriptor = CommandDescriptor(
        opcode=0x01,
        parameter_set=ParameterSet.ML_KEM_768,
        command_id=19,
        src0_addr=0x1000,
        src0_len=1184,
        entropy_policy=2,
        dst0_addr=0x2000,
        dst0_capacity=1088,
        dst1_addr=0x3000,
        dst1_capacity=32,
        completion_addr=0x4000,
    )
    raw = descriptor.encode()
    assert len(raw) == 128 and raw[:4].hex() == "01020010"
    assert CommandDescriptor.decode(raw) == descriptor
    damaged = bytearray(raw)
    damaged[23] ^= 1
    try:
        CommandDescriptor.decode(bytes(damaged))
    except ValueError:
        print("descriptor: 128 B; header:", raw[:4].hex(), "; CRC corruption caught")
    else:
        raise AssertionError("Corrupted descriptor was accepted")

    ram = SecureBankedSRAM(size_bytes=4096)
    ram.allocate_page(0, secret=True, representation="poly", owner=7)
    ram.write(0, b"training-data", owner=7)
    for owner, debug in ((8, False), (7, True)):
        try:
            ram.read(0, 13, owner=owner, debug=debug)
        except PermissionError:
            pass
        else:
            raise AssertionError("Unauthorized SRAM read was accepted")
    ram.zeroize()
    assert ram.data[:1024] == bytes(1024) and not ram.tags[0].valid
    print("SRAM owner/debug denial and secret-page zeroize: OK")
    print("Primitive learning checks: PASS (not an RTL or security certification)")


def algorithms():
    from pqc_hw_model.accelerator import PqcAccelerator

    try:
        accelerator = PqcAccelerator()
    except ModuleNotFoundError as exc:
        raise SystemExit(
            f"Missing dependency: {exc.name}. See docs/learning/11-labs.md "
            "and pqc_accel_model/pyproject.toml."
        ) from exc

    ps = ParameterSet.ML_KEM_768
    public_key, handle, _ = accelerator.keygen(ps)
    ciphertext, shared, _ = accelerator.kem_encaps(ps, public_key)
    recovered, valid_trace = accelerator.kem_decaps(ps, handle, ciphertext)
    assert shared == recovered and len(shared) == 32
    corrupted = bytearray(ciphertext)
    corrupted[len(corrupted) // 2] ^= 1
    rejected, invalid_trace = accelerator.kem_decaps(ps, handle, bytes(corrupted))
    assert len(rejected) == 32
    assert rejected != shared  # Negligible cryptographic collision probability.
    assert valid_trace.public_shape() == invalid_trace.public_shape()
    print("ML-KEM-768: pk/ct/ss lengths:", len(public_key), len(ciphertext), len(shared))
    print("KEM valid/invalid trace shapes equal:", valid_trace.public_shape())
    accelerator.destroy(handle)

    ps = ParameterSet.ML_DSA_65
    public_key, handle, _ = accelerator.keygen(ps)
    message, context = b"PQC learning", b"tutorial"
    signature, _ = accelerator.dsa_sign(ps, handle, message, context, deterministic=True)
    valid, _ = accelerator.dsa_verify(ps, public_key, message, signature, context)
    invalid, _ = accelerator.dsa_verify(ps, public_key, message + b"!", signature, context)
    wrong_context, _ = accelerator.dsa_verify(ps, public_key, message, signature, b"other")
    assert valid and not invalid and not wrong_context
    print("ML-DSA-65: pk/sig lengths:", len(public_key), len(signature))
    print("DSA message/context tampering: rejected")
    accelerator.destroy(handle)
    print("Algorithm learning checks: PASS (external algorithm libraries)")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "mode", choices=("primitives", "algorithms"), default="primitives", nargs="?"
    )
    args = parser.parse_args()
    if args.mode == "primitives":
        primitives()
    else:
        algorithms()


if __name__ == "__main__":
    main()
