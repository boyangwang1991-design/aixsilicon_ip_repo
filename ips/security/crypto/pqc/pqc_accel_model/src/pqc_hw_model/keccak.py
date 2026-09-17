import hashlib

from .trace import Trace


class KeccakEngine:
    def __init__(self, function: str, trace: Trace | None = None):
        constructors = {
            "sha3_256": hashlib.sha3_256,
            "sha3_512": hashlib.sha3_512,
            "shake_128": hashlib.shake_128,
            "shake_256": hashlib.shake_256,
        }
        if function not in constructors:
            raise ValueError("unsupported Keccak function")
        self.function = function
        self._hash = constructors[function]()
        self.trace = trace

    def absorb(self, data: bytes) -> None:
        self._hash.update(data)
        if self.trace:
            self.trace.emit("keccak_absorb", count=len(data))

    def digest(self, length: int | None = None) -> bytes:
        if self.function.startswith("shake"):
            if length is None:
                raise ValueError("SHAKE output length is required")
            result = self._hash.digest(length)
        else:
            result = self._hash.digest()
            if length is not None and length != len(result):
                raise ValueError("fixed-output SHA3 length mismatch")
        if self.trace:
            self.trace.emit("keccak_squeeze", count=len(result))
        return result

