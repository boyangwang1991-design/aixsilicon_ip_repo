from dataclasses import dataclass


@dataclass
class PageTag:
    valid: bool = False
    secret: bool = False
    representation: str = "bytes"
    owner: int = 0


class SecureBankedSRAM:
    def __init__(self, size_bytes: int = 64 * 1024, banks: int = 8, page_bytes: int = 1024):
        if size_bytes % page_bytes or banks & (banks - 1):
            raise ValueError("invalid SRAM geometry")
        self.data = bytearray(size_bytes)
        self.banks = banks
        self.page_bytes = page_bytes
        self.tags = [PageTag() for _ in range(size_bytes // page_bytes)]

    def bank(self, address: int) -> int:
        self._bounds(address, 1)
        return (address // 4) % self.banks

    def allocate_page(self, page: int, *, secret: bool, representation: str, owner: int) -> None:
        self.tags[page] = PageTag(True, secret, representation, owner)

    def write(self, address: int, value: bytes, owner: int) -> None:
        self._bounds(address, len(value))
        self._authorize(address, len(value), owner)
        self.data[address:address + len(value)] = value

    def read(self, address: int, length: int, owner: int, *, debug: bool = False) -> bytes:
        self._bounds(address, length)
        self._authorize(address, length, owner)
        first, last = address // self.page_bytes, (address + length - 1) // self.page_bytes
        if debug and any(self.tags[p].secret for p in range(first, last + 1)):
            raise PermissionError("debug cannot read secret page")
        return bytes(self.data[address:address + length])

    def zeroize(self, secret_only: bool = True) -> None:
        for page, tag in enumerate(self.tags):
            if tag.valid and (tag.secret or not secret_only):
                start = page * self.page_bytes
                self.data[start:start + self.page_bytes] = bytes(self.page_bytes)
                self.tags[page] = PageTag()

    def _bounds(self, address: int, length: int) -> None:
        if address < 0 or length < 0 or address + length > len(self.data):
            raise IndexError("SRAM access out of range")

    def _authorize(self, address: int, length: int, owner: int) -> None:
        if length == 0:
            return
        first, last = address // self.page_bytes, (address + length - 1) // self.page_bytes
        for page in range(first, last + 1):
            tag = self.tags[page]
            if not tag.valid or tag.owner != owner:
                raise PermissionError("invalid page or owner")

