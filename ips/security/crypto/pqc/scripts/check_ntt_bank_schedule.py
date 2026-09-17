#!/usr/bin/env python3
"""Exhaust the planned 256-coefficient NTT bank schedule, without simulating RTL."""
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path


def bank(index):
    b0 = ((index >> 0) ^ (index >> 3) ^ (index >> 6)) & 1
    b1 = ((index >> 1) ^ (index >> 4) ^ (index >> 7)) & 1
    b2 = ((index >> 2) ^ (index >> 5)) & 1
    return b0 | (b1 << 1) | (b2 << 2)


def stage(length, lanes):
    pairs = [(i, i+length) for start in range(0, 256, 2*length)
             for i in range(start, start+length)]
    assert len(pairs) == 128 and len({i for pair in pairs for i in pair}) == 256
    requests = defaultdict(lambda: Counter())
    writes = defaultdict(lambda: Counter())
    live = Counter()
    for batch, pos in enumerate(range(0, len(pairs), lanes)):
        by_bank = defaultdict(list)
        for a, b in pairs[pos:pos+lanes]:
            assert bank(a) != bank(b)
            by_bank[bank(a)].append(a)
            by_bank[bank(b)].append(b)
        assert max(map(len, by_bank.values())) <= 2
        start_cycle = 2*batch
        for b, indices in by_bank.items():
            for beat, index in enumerate(indices):
                requests[start_cycle+beat][b] += 1
                writes[start_cycle+10+beat][b] += 1
        # A slot is conservatively held through the second write beat, even
        # for batches which use only one physical memory beat.
        for cycle in range(start_cycle, start_cycle+12):
            live[cycle] += 1
    assert all(max(v.values()) <= 1 for v in requests.values())
    assert all(max(v.values()) <= 1 for v in writes.values())
    assert max(live.values()) <= 6
    return dict(length=length, lanes=lanes, batches=128//lanes,
                cycles=2*(128//lanes)+10, max_live_slots=max(live.values()))


def main():
    root = Path(__file__).resolve().parents[1]
    assert len({(bank(i), i >> 3) for i in range(256)}) == 256
    rows = [stage(length, lanes) for lanes in (1, 2, 4)
            for length in (1, 2, 4, 8, 16, 32, 64, 128)]
    result = dict(kind='ntt-bank-schedule/1.0', rtl_verified=False,
                  assumptions=['8 banks per share, each 1R1W',
                               'Two-cycle batch issue interval; six slots',
                               'Read requests at issue+0/+1; writes at issue+10/+11',
                               'No other consumer steals a reserved bank port',
                               'Stage barrier after all writebacks; canonical residues'],
                  rows=rows,
                  ntt_cycles_without_command_overhead={
                      str(lanes): dict(dsa=8*(2*(128//lanes)+10),
                                       kem=7*(2*(128//lanes)+10)) for lanes in (1,2,4)},
                  inputs={str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest()
                          for f in (Path(__file__).resolve(), root/'docs/lld/03_poly.md')})
    out = root/'build/design/lld_resume/ntt_bank_schedule.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2)+'\n')
    print('24 stage/lane schedules checked; bijective mapping; max six in-flight batches.')
    print(json.dumps(result['ntt_cycles_without_command_overhead'], indent=2))


if __name__ == '__main__':
    main()
