import hashlib

import pytest
from hypothesis import given, settings, strategies as st

from pqc_hw_model.codec import pack_lsb, unpack_lsb
from pqc_hw_model.descriptor import CommandDescriptor
from pqc_hw_model.keccak import KeccakEngine
from pqc_hw_model.memory import SecureBankedSRAM
from pqc_hw_model.modular import ModularALU, ModularConfig, negacyclic_schoolbook
from pqc_hw_model.ntt import HardwareNTT
from pqc_hw_model.params import ParameterSet, get_params
from pqc_hw_model.trace import Trace


@pytest.mark.parametrize("ps", list(ParameterSet))
def test_ntt_roundtrip(ps):
    p = get_params(ps)
    poly = [(i * i + 17 * i + 3) % p.q for i in range(256)]
    trace = Trace()
    transformed = HardwareNTT(p).forward(poly, trace)
    restored = HardwareNTT(p).inverse(transformed, trace)
    assert restored == poly
    assert trace.cycles > 0


@pytest.mark.parametrize("q,width", [(3329, 16), (8380417, 32)])
def test_montgomery_roundtrip(q, width):
    alu = ModularALU(ModularConfig(q, width, 64, 32))
    for value in [0, 1, 2, q // 2, q - 1]:
        assert alu.from_montgomery(alu.to_montgomery(value)) == value
        am = alu.to_montgomery(value)
        bm = alu.to_montgomery(q - 1)
        assert alu.from_montgomery(alu.montgomery_mul(am, bm)) == value * (q - 1) % q


@given(st.lists(st.integers(min_value=0, max_value=4095), min_size=32, max_size=32))
@settings(max_examples=50)
def test_codec_roundtrip(values):
    packed = pack_lsb(values, 12)
    restored, canonical = unpack_lsb(packed, len(values), 12, 4096)
    assert canonical and restored == values


def test_keccak_matches_stdlib():
    data = bytes(range(251)) * 3
    engine = KeccakEngine("shake_256")
    for offset in range(0, len(data), 37):
        engine.absorb(data[offset:offset + 37])
    assert engine.digest(97) == hashlib.shake_256(data).digest(97)


def test_descriptor_roundtrip_and_crc():
    d = CommandDescriptor(2, ParameterSet.ML_KEM_768, command_id=19,
                          src0_addr=0x1000, src0_len=1184, context_len=0)
    raw = d.encode()
    assert len(raw) == 128 and CommandDescriptor.decode(raw) == d
    damaged = bytearray(raw); damaged[23] ^= 1
    with pytest.raises(ValueError):
        CommandDescriptor.decode(bytes(damaged))


def test_secure_sram_permissions_and_zeroize():
    ram = SecureBankedSRAM(size_bytes=4096, page_bytes=1024)
    ram.allocate_page(0, secret=True, representation="poly", owner=7)
    ram.write(0, b"secret", owner=7)
    assert ram.read(0, 6, owner=7) == b"secret"
    with pytest.raises(PermissionError):
        ram.read(0, 6, owner=7, debug=True)
    ram.zeroize()
    assert ram.data[:1024] == bytes(1024)


def test_negacyclic_wrap_sign():
    a, b = [0] * 8, [0] * 8
    a[7] = b[1] = 1
    assert negacyclic_schoolbook(a, b, 17)[0] == 16

