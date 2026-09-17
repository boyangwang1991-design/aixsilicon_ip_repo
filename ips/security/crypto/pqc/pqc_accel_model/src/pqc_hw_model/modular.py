from dataclasses import dataclass


@dataclass(frozen=True)
class ModularConfig:
    q: int
    coeff_width: int
    product_width: int
    montgomery_bits: int = 32


class ModularALU:
    def __init__(self, cfg: ModularConfig):
        self.cfg = cfg
        r = 1 << cfg.montgomery_bits
        if r <= cfg.q:
            raise ValueError("Montgomery radix must exceed modulus")
        self.r_mask = r - 1
        self.q_inv = (-pow(cfg.q, -1, r)) & self.r_mask
        self.r_mod_q = r % cfg.q

    def canonical(self, value: int) -> int:
        return value % self.cfg.q

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.cfg.q

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.cfg.q

    def mul(self, a: int, b: int) -> int:
        product = int(a) * int(b)
        if product.bit_length() > self.cfg.product_width:
            raise OverflowError("configured product width is insufficient")
        return product % self.cfg.q

    def to_montgomery(self, value: int) -> int:
        return (value % self.cfg.q) * self.r_mod_q % self.cfg.q

    def montgomery_reduce(self, value: int) -> int:
        m = ((value & self.r_mask) * self.q_inv) & self.r_mask
        t = (value + m * self.cfg.q) >> self.cfg.montgomery_bits
        return t - self.cfg.q if t >= self.cfg.q else t

    def from_montgomery(self, value: int) -> int:
        return self.montgomery_reduce(value)

    def montgomery_mul(self, a_mont: int, b_mont: int) -> int:
        return self.montgomery_reduce(a_mont * b_mont)


def negacyclic_schoolbook(a: list[int], b: list[int], q: int) -> list[int]:
    if len(a) != len(b):
        raise ValueError("polynomial sizes differ")
    n = len(a)
    out = [0] * n
    for i, av in enumerate(a):
        for j, bv in enumerate(b):
            d = i + j
            if d < n:
                out[d] += av * bv
            else:
                out[d - n] -= av * bv
    return [v % q for v in out]

