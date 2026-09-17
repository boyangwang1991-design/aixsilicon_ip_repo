import pytest

from pqc_hw_model.accelerator import PqcAccelerator
from pqc_hw_model.oracle import oracle
from pqc_hw_model.params import ParameterSet, get_params


KEMS = [ParameterSet.ML_KEM_512, ParameterSet.ML_KEM_768, ParameterSet.ML_KEM_1024]
DSAS = [ParameterSet.ML_DSA_44, ParameterSet.ML_DSA_65, ParameterSet.ML_DSA_87]


@pytest.mark.parametrize("ps", KEMS)
def test_mlkem_model_roundtrip_and_invalid_ciphertext(ps):
    accel = PqcAccelerator()
    pk, handle, _ = accel.keygen(ps)
    ct, ss1, _ = accel.kem_encaps(ps, pk)
    ss2, valid_trace = accel.kem_decaps(ps, handle, ct)
    assert ss1 == ss2 and len(ct) == get_params(ps).output_bytes
    bad = bytearray(ct); bad[len(bad) // 2] ^= 1
    rejected_ss, invalid_trace = accel.kem_decaps(ps, handle, bytes(bad))
    assert len(rejected_ss) == 32 and rejected_ss != ss1
    assert valid_trace.public_shape() == invalid_trace.public_shape()


@pytest.mark.parametrize("ps", KEMS)
def test_mlkem_bidirectional_interop_with_independent_oracle(ps):
    accel, ref = PqcAccelerator(), oracle(ps)
    pk, handle, _ = accel.keygen(ps)
    ref_ct, ref_ss = ref.encaps(pk)
    model_ss, _ = accel.kem_decaps(ps, handle, ref_ct)
    assert model_ss == ref_ss

    ref_pk, ref_sk = ref.keygen()
    model_ct, model_ss, _ = accel.kem_encaps(ps, ref_pk)
    assert ref.decaps(ref_sk, model_ct) == model_ss


@pytest.mark.parametrize("ps", DSAS)
def test_mldsa_model_roundtrip_and_tamper(ps):
    accel = PqcAccelerator()
    pk, handle, _ = accel.keygen(ps)
    message, context = b"PQC hardware model", b"aixsilicon"
    sig, _ = accel.dsa_sign(ps, handle, message, context, deterministic=True)
    valid, _ = accel.dsa_verify(ps, pk, message, sig, context)
    invalid, _ = accel.dsa_verify(ps, pk, message + b"!", sig, context)
    assert valid and not invalid and len(sig) == get_params(ps).output_bytes


@pytest.mark.parametrize("ps", DSAS)
def test_mldsa_bidirectional_interop_with_independent_oracle(ps):
    accel, ref = PqcAccelerator(), oracle(ps)
    message, context = b"interoperability", b"hw-model"
    pk, handle, _ = accel.keygen(ps)
    sig, _ = accel.dsa_sign(ps, handle, message, context)
    # pqcrypto follows the exception-on-failure API: success returns None.
    assert ref.verify(pk, message, sig, context=context) is None

    ref_pk, ref_sk = ref.keygen()
    ref_sig = ref.sign(ref_sk, message, context=context)
    valid, _ = accel.dsa_verify(ps, ref_pk, message, ref_sig, context)
    assert valid


def test_stale_or_wrong_key_handle_rejected():
    accel = PqcAccelerator()
    _, handle, _ = accel.keygen(ParameterSet.ML_KEM_512)
    with pytest.raises(PermissionError):
        accel.kem_decaps(ParameterSet.ML_KEM_768, handle, bytes(1088))
    accel.destroy(handle)
    with pytest.raises(PermissionError):
        accel.kem_decaps(ParameterSet.ML_KEM_512, handle, bytes(768))
