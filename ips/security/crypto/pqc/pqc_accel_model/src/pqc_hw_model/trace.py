from dataclasses import dataclass, field


@dataclass
class Trace:
    events: list[dict] = field(default_factory=list)
    cycles: int = 0

    def emit(self, kind: str, cycles: int = 0, **fields) -> None:
        self.events.append({"kind": kind, **fields})
        self.cycles += cycles

    def public_shape(self) -> tuple:
        return tuple((e["kind"], e.get("stage"), e.get("count")) for e in self.events)

