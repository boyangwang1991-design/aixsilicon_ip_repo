def pack_lsb(values: list[int], bits: int) -> bytes:
    if not 1 <= bits <= 32:
        raise ValueError("unsupported width")
    limit = 1 << bits
    accumulator = used = 0
    out = bytearray()
    for value in values:
        if not 0 <= value < limit:
            raise ValueError("value is not canonical for width")
        accumulator |= value << used
        used += bits
        while used >= 8:
            out.append(accumulator & 0xFF)
            accumulator >>= 8
            used -= 8
    if used:
        out.append(accumulator & 0xFF)
    return bytes(out)


def unpack_lsb(data: bytes, count: int, bits: int, modulus: int | None = None) -> tuple[list[int], bool]:
    accumulator = used = cursor = 0
    mask = (1 << bits) - 1
    out, canonical = [], True
    for _ in range(count):
        while used < bits:
            if cursor >= len(data):
                raise ValueError("truncated packed input")
            accumulator |= data[cursor] << used
            cursor += 1
            used += 8
        value = accumulator & mask
        accumulator >>= bits
        used -= bits
        if modulus is not None and value >= modulus:
            canonical = False
        out.append(value)
    if accumulator != 0 or any(data[cursor:]):
        canonical = False
    return out, canonical

