from dataclasses import dataclass

from .params import ParameterSet, get_params
from .trace import Trace


def _implementations():
    from kyber_py.ml_kem import ML_KEM_512, ML_KEM_768, ML_KEM_1024
    from dilithium_py.ml_dsa import ML_DSA_44, ML_DSA_65, ML_DSA_87
    return {
        ParameterSet.ML_KEM_512: ML_KEM_512,
        ParameterSet.ML_KEM_768: ML_KEM_768,
        ParameterSet.ML_KEM_1024: ML_KEM_1024,
        ParameterSet.ML_DSA_44: ML_DSA_44,
        ParameterSet.ML_DSA_65: ML_DSA_65,
        ParameterSet.ML_DSA_87: ML_DSA_87,
    }


@dataclass
class Slot:
    parameter_set: ParameterSet
    secret_key: bytes
    generation: int


class PqcAccelerator:
    """Complete-algorithm functional model with hardware-visible behavior."""

    def __init__(self):
        self.impl = _implementations()
        self.slots: dict[int, Slot] = {}
        self.next_slot = 0

    def _store(self, ps: ParameterSet, secret_key: bytes) -> int:
        slot = self.next_slot
        self.next_slot += 1
        generation = 1
        self.slots[slot] = Slot(ps, secret_key, generation)
        return generation << 16 | slot

    def _load(self, handle: int, ps: ParameterSet) -> bytes:
        slot_id, generation = handle & 0xFFFF, handle >> 16
        slot = self.slots.get(slot_id)
        if slot is None or slot.generation != generation or slot.parameter_set != ps:
            raise PermissionError("invalid, stale, or wrong-type key handle")
        return slot.secret_key

    def keygen(self, ps: ParameterSet) -> tuple[bytes, int, Trace]:
        p, trace = get_params(ps), Trace()
        pk, sk = self.impl[ps].keygen()
        assert len(pk) == p.public_key_bytes and len(sk) == p.secret_key_bytes
        trace.emit("keygen", count=p.rank_a)
        return pk, self._store(ps, sk), trace

    def kem_encaps(self, ps: ParameterSet, public_key: bytes) -> tuple[bytes, bytes, Trace]:
        if get_params(ps).family != "kem":
            raise ValueError("not an ML-KEM parameter set")
        shared, ciphertext = self.impl[ps].encaps(public_key)
        trace = Trace(); trace.emit("kem_encaps", count=get_params(ps).rank_a)
        return ciphertext, shared, trace

    def kem_decaps(self, ps: ParameterSet, handle: int, ciphertext: bytes) -> tuple[bytes, Trace]:
        sk = self._load(handle, ps)
        shared = self.impl[ps].decaps(sk, ciphertext)
        trace = Trace()
        # Public trace shape deliberately does not encode ciphertext validity.
        trace.emit("kem_decrypt", count=get_params(ps).rank_a)
        trace.emit("kem_reencrypt", count=get_params(ps).rank_a)
        trace.emit("constant_time_select", count=32)
        return shared, trace

    def dsa_sign(self, ps: ParameterSet, handle: int, message: bytes,
                 context: bytes = b"", deterministic: bool = False) -> tuple[bytes, Trace]:
        if len(context) > 255:
            raise ValueError("context too long")
        sk = self._load(handle, ps)
        signature = self.impl[ps].sign(sk, message, ctx=context, deterministic=deterministic)
        trace = Trace(); trace.emit("dsa_sign_commit", count=len(signature))
        return signature, trace

    def dsa_verify(self, ps: ParameterSet, public_key: bytes, message: bytes,
                   signature: bytes, context: bytes = b"") -> tuple[bool, Trace]:
        valid = self.impl[ps].verify(public_key, message, signature, ctx=context)
        trace = Trace(); trace.emit("dsa_verify", count=get_params(ps).rank_a)
        return valid, trace

    def destroy(self, handle: int) -> None:
        slot_id = handle & 0xFFFF
        slot = self.slots.pop(slot_id, None)
        if slot is not None:
            # Python bytes cannot guarantee physical zeroization; remove reachability.
            del slot

