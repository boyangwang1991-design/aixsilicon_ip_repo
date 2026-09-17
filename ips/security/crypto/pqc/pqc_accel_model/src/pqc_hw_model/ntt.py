from dataclasses import dataclass

from .params import Params
from .trace import Trace


def _bit_reverse(value: int, width: int) -> int:
    return int(f"{value:0{width}b}"[::-1], 2)


@dataclass(frozen=True)
class NttConfig:
    lanes: int = 2
    banks: int = 8


class HardwareNTT:
    """Reversible radix-2 butterfly network with hardware address tracing.

    The transform models the proposed stage schedule. It deliberately keeps
    standard-domain coefficients; a later RTL freeze can replace multiplication
    with the selected Montgomery representation without changing the interface.
    """

    def __init__(self, params: Params, cfg: NttConfig = NttConfig()):
        if cfg.lanes not in (1, 2, 4):
            raise ValueError("lanes must be 1, 2, or 4")
        self.p = params
        self.cfg = cfg
        if pow(params.primitive_root, params.root_order, params.q) != 1:
            raise ValueError("invalid root order")

    def _zeta(self, index: int, width: int) -> int:
        exponent = _bit_reverse(index, width) % self.p.root_order
        return pow(self.p.primitive_root, exponent, self.p.q)

    def forward(self, poly: list[int], trace: Trace | None = None) -> list[int]:
        if len(poly) != 256:
            raise ValueError("NTT requires 256 coefficients")
        r = [x % self.p.q for x in poly]
        stop = 2 if self.p.family == "kem" else 1
        length, k, stage = 128, 1, 0
        width = 7 if self.p.family == "kem" else 8
        while length >= stop:
            ops = []
            start = 0
            while start < 256:
                zeta = self._zeta(k, width)
                k += 1
                for j in range(start, start + length):
                    a, b = r[j], r[j + length]
                    t = zeta * b % self.p.q
                    r[j] = (a + t) % self.p.q
                    r[j + length] = (a - t) % self.p.q
                    ops.append((j, j + length))
                start += 2 * length
            conflicts = sum(1 for a, b in ops if a % self.cfg.banks == b % self.cfg.banks)
            if trace:
                trace.emit("ntt_stage", (len(ops) + self.cfg.lanes - 1) // self.cfg.lanes,
                           stage=stage, count=len(ops), bank_conflicts=conflicts)
            length //= 2
            stage += 1
        return r

    def inverse(self, transformed: list[int], trace: Trace | None = None) -> list[int]:
        if len(transformed) != 256:
            raise ValueError("NTT requires 256 coefficients")
        r = [x % self.p.q for x in transformed]
        lengths = []
        length = 128
        stop = 2 if self.p.family == "kem" else 1
        while length >= stop:
            lengths.append(length)
            length //= 2
        # Reconstruct forward twiddle assignment, then undo butterflies in reverse.
        width = 7 if self.p.family == "kem" else 8
        schedule, k = [], 1
        for length in lengths:
            groups = []
            for start in range(0, 256, 2 * length):
                groups.append((start, self._zeta(k, width)))
                k += 1
            schedule.append((length, groups))
        inv2 = pow(2, -1, self.p.q)
        for stage, (length, groups) in enumerate(reversed(schedule)):
            ops = 0
            for start, zeta in groups:
                zeta_inv = pow(zeta, -1, self.p.q)
                for j in range(start, start + length):
                    x, y = r[j], r[j + length]
                    r[j] = (x + y) * inv2 % self.p.q
                    r[j + length] = (x - y) * inv2 * zeta_inv % self.p.q
                    ops += 1
            if trace:
                trace.emit("intt_stage", (ops + self.cfg.lanes - 1) // self.cfg.lanes,
                           stage=stage, count=ops)
        return r

