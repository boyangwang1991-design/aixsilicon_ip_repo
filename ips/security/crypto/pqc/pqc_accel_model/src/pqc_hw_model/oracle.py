from importlib import import_module

from .params import ParameterSet


MODULES = {
    ParameterSet.ML_KEM_512: "pqcrypto.kem.ml_kem_512",
    ParameterSet.ML_KEM_768: "pqcrypto.kem.ml_kem_768",
    ParameterSet.ML_KEM_1024: "pqcrypto.kem.ml_kem_1024",
    ParameterSet.ML_DSA_44: "pqcrypto.sign.ml_dsa_44",
    ParameterSet.ML_DSA_65: "pqcrypto.sign.ml_dsa_65",
    ParameterSet.ML_DSA_87: "pqcrypto.sign.ml_dsa_87",
}


def oracle(ps: ParameterSet):
    return import_module(MODULES[ps])

