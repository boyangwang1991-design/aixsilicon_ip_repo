"""Generate an ABI-valid ML-KEM-768 KeyGen descriptor using independent zlib CRC."""
from pathlib import Path
import struct
import zlib


def main():
    descriptor = bytearray(128)
    struct.pack_into('<I', descriptor, 0x00, 0x10000200)
    struct.pack_into('<I', descriptor, 0x04, 0xDDCCBBAA)
    struct.pack_into('<I', descriptor, 0x3C, 2)
    struct.pack_into('<QQ', descriptor, 0x40, 0x40000, 1184)
    struct.pack_into('<QQ', descriptor, 0x50, 0x50000, 4)
    struct.pack_into('<Q', descriptor, 0x60, 0x60000)
    struct.pack_into('<I', descriptor, 0x7C, zlib.crc32(descriptor[:124]))
    target = Path(__file__).resolve().parents[1] / 'verification/unit_test/golden/review_fix/descriptor_zlib.hex'
    target.write_text(''.join(f'{value:02x}\n' for value in descriptor))


if __name__ == '__main__':
    main()
