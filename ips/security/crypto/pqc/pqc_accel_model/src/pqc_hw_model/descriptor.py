import struct
import zlib
from dataclasses import dataclass

from .params import ParameterSet


@dataclass(frozen=True)
class CommandDescriptor:
    opcode: int
    parameter_set: ParameterSet
    flags: int = 0
    abi: int = 0x10
    command_id: int = 0
    key_handle: int = 0
    src0_addr: int = 0
    src0_len: int = 0
    src1_addr: int = 0
    src1_len: int = 0
    context_addr: int = 0
    context_len: int = 0
    entropy_policy: int = 0
    dst0_addr: int = 0
    dst0_capacity: int = 0
    dst1_addr: int = 0
    dst1_capacity: int = 0
    completion_addr: int = 0
    timeout_hint: int = 0

    def encode(self) -> bytes:
        if not 0 <= self.context_len <= 255:
            raise ValueError("context length must be 0..255")
        header = self.opcode | (int(self.parameter_set) << 8) | (self.flags << 12) | (self.abi << 24)
        raw = bytearray(128)
        struct.pack_into("<IIII", raw, 0x00, header, self.command_id, self.key_handle, 0)
        struct.pack_into("<QQQQ", raw, 0x10, self.src0_addr, self.src0_len, self.src1_addr, self.src1_len)
        struct.pack_into("<QII", raw, 0x30, self.context_addr, self.context_len, self.entropy_policy)
        struct.pack_into("<QQQQ", raw, 0x40, self.dst0_addr, self.dst0_capacity,
                         self.dst1_addr, self.dst1_capacity)
        struct.pack_into("<QI", raw, 0x60, self.completion_addr, self.timeout_hint)
        struct.pack_into("<I", raw, 0x7C, zlib.crc32(raw[:0x7C]))
        return bytes(raw)

    @classmethod
    def decode(cls, raw: bytes) -> "CommandDescriptor":
        if len(raw) != 128 or zlib.crc32(raw[:0x7C]) != struct.unpack_from("<I", raw, 0x7C)[0]:
            raise ValueError("descriptor length or CRC error")
        if any(raw[0x6C:0x7C]):
            raise ValueError("reserved descriptor bytes are nonzero")
        header, command_id, key_handle, reserved = struct.unpack_from("<IIII", raw, 0x00)
        if reserved:
            raise ValueError("reserved word is nonzero")
        src0_addr, src0_len, src1_addr, src1_len = struct.unpack_from("<QQQQ", raw, 0x10)
        context_addr, context_len, entropy_policy = struct.unpack_from("<QII", raw, 0x30)
        dst0_addr, dst0_capacity, dst1_addr, dst1_capacity = struct.unpack_from("<QQQQ", raw, 0x40)
        completion_addr, timeout_hint = struct.unpack_from("<QI", raw, 0x60)
        return cls(header & 0xFF, ParameterSet((header >> 8) & 0xF), (header >> 12) & 0xFFF,
                   (header >> 24) & 0xFF, command_id, key_handle, src0_addr, src0_len,
                   src1_addr, src1_len, context_addr, context_len, entropy_policy,
                   dst0_addr, dst0_capacity, dst1_addr, dst1_capacity,
                   completion_addr, timeout_hint)

