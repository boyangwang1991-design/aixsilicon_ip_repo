from dataclasses import dataclass
from enum import IntEnum


class ParameterSet(IntEnum):
    ML_KEM_512 = 1
    ML_KEM_768 = 2
    ML_KEM_1024 = 3
    ML_DSA_44 = 4
    ML_DSA_65 = 5
    ML_DSA_87 = 6


@dataclass(frozen=True)
class Params:
    name: str
    family: str
    n: int
    q: int
    rank_a: int
    rank_b: int
    public_key_bytes: int
    secret_key_bytes: int
    output_bytes: int
    primitive_root: int
    root_order: int


PARAMS = {
    ParameterSet.ML_KEM_512: Params("ML-KEM-512", "kem", 256, 3329, 2, 2, 800, 1632, 768, 17, 256),
    ParameterSet.ML_KEM_768: Params("ML-KEM-768", "kem", 256, 3329, 3, 3, 1184, 2400, 1088, 17, 256),
    ParameterSet.ML_KEM_1024: Params("ML-KEM-1024", "kem", 256, 3329, 4, 4, 1568, 3168, 1568, 17, 256),
    ParameterSet.ML_DSA_44: Params("ML-DSA-44", "dsa", 256, 8380417, 4, 4, 1312, 2560, 2420, 1753, 512),
    ParameterSet.ML_DSA_65: Params("ML-DSA-65", "dsa", 256, 8380417, 6, 5, 1952, 4032, 3309, 1753, 512),
    ParameterSet.ML_DSA_87: Params("ML-DSA-87", "dsa", 256, 8380417, 8, 7, 2592, 4896, 4627, 1753, 512),
}


def get_params(parameter_set: ParameterSet) -> Params:
    return PARAMS[ParameterSet(parameter_set)]

