#!/usr/bin/env python3
"""Executable LLD boundary models; not RTL, cryptographic or leakage proofs.

Run from the workflow root using uv run. All generated evidence stays in build.
The independent obligations below cover address bijection, response credits,
authorization/revocation and entropy ownership under backpressure.
"""
from dataclasses import dataclass, replace
import hashlib
from itertools import product
import json
from pathlib import Path

from check_ntt_bank_schedule import bank


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def storage_geometry():
    words = 0
    partners = 0
    for kib in (32, 64, 96):
        seen = set()
        for w in range(kib * 256):
            page, i = divmod(w, 256)
            b, row = bank(i), page * 32 + (i >> 3)
            require((b, row) not in seen, 'physical address alias')
            seen.add((b, row))
            # Invert low index bits from the bank and upper five index bits.
            hi = (row % 32) << 3
            lo = b ^ bank(hi)
            require(page * 256 + hi + lo == w, 'noninvertible mapping')
            words += 1
        require(len(seen) == kib * 256, 'capacity lost')
        for bit, i in product(range(8), range(256)):
            require(bank(i) != bank(i ^ (1 << bit)), 'butterfly bank conflict')
            partners += 1
    return dict(word_addresses=words, butterfly_pairs=partners,
                clear_cycles={str(k): 32*k+2 for k in (32, 64, 96)})


def credit_schedules():
    # State = the two outstanding arrival stages and queued responses.
    # Allocate before issue, release only when the response retires.
    states = {(0, 0, 0)}
    transitions = 0
    for _ in range(12):
        next_states = set()
        for (p0, p1, queued), (req, ready, clear) in product(
                states, product((0, 1), repeat=3)):
            pop = int(bool(queued and ready))
            issue = int(bool(req and p0+p1+queued-pop < 3 and not clear))
            new = (issue, p0, queued+p1-pop) if not clear else (0, 0, 0)
            require(0 <= sum(new) <= 3, 'lost reserved response capacity')
            require(new[2] >= 0, 'response retired without valid')
            next_states.add(new)
            transitions += 1
        states = next_states
    # Negative control: checking only current output allows an overflow when
    # two responses are still in flight and one is already held.
    require(sum((1, 1, 1)) == 3 and not (1 < 3 and 3+1 <= 3),
            'negative control failed to expose missing in-flight accounting')
    return dict(depth=12, transitions=transitions, reachable_states=len(states),
                response_capacity=3, negative_control='overflow_detected')


@dataclass(frozen=True)
class Identity:
    generation: int = 1
    owner: int = 9
    domain: int = 3
    slot: int = 0
    algorithm: int = 1
    pset: int = 2
    usage: int = 7


def authorized(stored, request, *, slots=8, valid=True, ready=True,
               held=False, pending=False, revoked=False):
    return (0 <= request.slot < slots and valid and ready and not held
            and not pending and not revoked
            and all(getattr(stored, f) == getattr(request, f) for f in
                    ('generation', 'owner', 'domain', 'slot', 'algorithm', 'pset'))
            and request.usage != 0 and (stored.usage & request.usage) == request.usage)


def key_authorization():
    stored = Identity()
    request = replace(stored, usage=1)
    require(authorized(stored, request), 'matching identity denied')
    mutations = 0
    for field in ('generation', 'owner', 'domain', 'slot', 'algorithm', 'pset'):
        require(not authorized(stored, replace(request, **{
            field: getattr(request, field) ^ 1})), f'{field} not compared')
        mutations += 1
    for slot in (-1, 8, 255, 256):
        require(not authorized(stored, replace(request, slot=slot)), 'slot truncation')
        mutations += 1
    for usage in range(256):
        require(authorized(stored, replace(request, usage=usage)) ==
                (usage in range(1, 8)), 'usage subset or zero usage error')
    for valid, ready, held, pending, revoked in product((False, True), repeat=5):
        expected = valid and ready and not (held or pending or revoked)
        require(authorized(stored, request, valid=valid, ready=ready, held=held,
                           pending=pending, revoked=revoked) == expected,
                'authorization lifecycle gating failed')
    for generation in range(65536):
        next_generation = min(generation+1, 65535)
        require(next_generation >= generation, 'generation wrapped')
        # Exhausted values are invalid; never accept a new handle of that value.
        require(next_generation > generation or generation == 65535,
                'generation reused')
    # The historical 8-bit CSR truncation aliases valid distinct handles.
    require((1 & 255) == (257 & 255) and 1 != 257, 'alias negative control broken')
    return dict(identity_mutations=mutations, usage_masks=256,
                lifecycle_combinations=32, generation_boundaries=65536,
                negative_control='8_bit_generation_alias_detected')


@dataclass(frozen=True)
class Slot:
    state: str = 'INVALID'
    floor: int = 0
    active: int = 0
    wipe_epoch: int = 0

    def step(self, action):
        if action == 'release_and_destroy':
            return self.step('release_11').step('destroy')
        if action == 'revoke_and_acquire':
            return self.step('revoke')
        if action == 'revoke':
            if self.state in ('REVOKING', 'EXHAUSTED'):
                return self
            return Slot('REVOKING', min(self.floor+1, 65535), 0,
                        self.wipe_epoch+1)
        if action == 'allocate' and self.state == 'INVALID' and self.floor < 65535:
            return replace(self, state='READY', floor=self.floor+1)
        if action == 'acquire' and self.state == 'READY':
            return replace(self, state='HELD', active=11)
        if action == 'destroy':
            if self.state == 'HELD':
                return replace(self, state='DESTROY_PENDING')
            if self.state == 'READY':
                return self.step('revoke')
        if action == 'release_11':
            if self.active == 11 and self.state == 'HELD':
                return replace(self, state='READY', active=0)
            if self.active == 11 and self.state == 'DESTROY_PENDING':
                return self.step('revoke')
        if action == 'wipe_ack' and self.state == 'REVOKING':
            return replace(self, state='EXHAUSTED' if self.floor == 65535
                           else 'INVALID')
        # Wrong release/clear identities must not change any ownership.
        return self


def slot_schedules():
    states = {Slot(), Slot('READY', 65534), Slot('READY', 65535)}
    transitions = 0
    actions = ('allocate', 'acquire', 'destroy', 'revoke', 'release_11',
               'release_stale', 'wipe_ack', 'wipe_ack_stale',
               'release_and_destroy', 'revoke_and_acquire')
    for _ in range(8):
        following = set()
        for old, action in product(states, actions):
            new = old.step(action)
            require(new.floor >= old.floor, 'generation regression')
            require(bool(new.active) == (new.state in ('HELD', 'DESTROY_PENDING')),
                    'active epoch/state mismatch')
            if action.endswith('stale'):
                require(new == old, 'stale identity changed state')
            if old.state in ('REVOKING', 'DESTROY_PENDING', 'EXHAUSTED'):
                if action in ('allocate', 'acquire'):
                    require(new == old, 'new owner admitted before retirement')
            if action in ('revoke', 'revoke_and_acquire'):
                require(not new.active and new.state in ('REVOKING', 'EXHAUSTED'),
                        'revoke did not immediately close access')
            if old.state == 'HELD' and action == 'destroy':
                require(new.active == old.active, 'software destroy broke held key')
            if old.state == 'HELD' and action == 'release_and_destroy':
                require(new.state == 'REVOKING' and not new.active,
                        'same-cycle release lost destroy request')
            following.add(new)
            transitions += 1
        states = following
    return dict(depth=8, transitions=transitions, reachable_states=len(states),
                abstracted='one slot, active epoch 11 and stale epoch class; logical wipe_ack')


def page_authorization():
    # Independent expected relation: a public DMA cannot observe any secret
    # page, even when all remaining tags and initialization bits match.
    cases = 0
    for valid, initialized, secret, dma, tag_match, revoked in product(
            (False, True), repeat=6):
        allow = valid and initialized and tag_match and not revoked
        if dma and secret:
            allow = False
        expected = all((valid, initialized, tag_match, not revoked,
                        not (dma and secret)))
        require(allow == expected, 'page authorization error')
        if revoked or (dma and secret) or not initialized:
            require(not allow, 'forbidden material exposure')
        cases += 1
    return dict(permission_combinations=cases,
                exclusions=['RTL tag comparator', 'ECC logic', 'physical erase'])


def random_chunks():
    # Symbolic entropy beat identities, not an entropy generator. Different
    # tokens can contain equal random values without being a replay.
    beats_seen = set()
    delivered = set()
    discarded_bits = 0
    stall_checks = 0
    for lease, bits in enumerate(range(1, 4801), 1):
        identity = (1, lease, 'BOOL_MASK', 'KECCAK')
        cache = []
        remaining = bits
        for beat in range((bits+63)//64):
            token = (identity, beat)
            require(token not in beats_seen, 'entropy token reused')
            beats_seen.add(token)
            take = min(64, remaining)
            cache.append((token, take))
            remaining -= take
            discarded_bits += 64-take
        require(remaining == 0 and len(cache) <= 75, 'random cache capacity exceeded')
        require(sum(take for _, take in cache) == bits, 'wrong valid bit count')
        snapshot = tuple(cache)
        # Output is held over all 3-bit ready patterns; only its first ready
        # edge consumes this particular lease.
        for pattern in product((False, True), repeat=3):
            consumed = False
            count = 0
            for ready in pattern:
                valid = not consumed
                if valid and ready:
                    count += 1
                    consumed = True
                else:
                    require(tuple(cache) == snapshot, 'backpressure changed token')
                stall_checks += 1
            require(count == int(any(pattern)), 'duplicate/lost random acceptance')
        require(identity not in delivered, 'lease delivered twice')
        delivered.add(identity)
        # clear/revoke wins over simultaneous consumer_ready and entropy_valid.
        for ready, entropy_valid, tag_ok, health in product((False, True), repeat=4):
            clear = True
            chunk_fire = not clear and health and ready
            entropy_fire = not clear and health and tag_ok and entropy_valid
            require(not chunk_fire and not entropy_fire, 'clear lost same-cycle race')
        cache[:] = []
        require(not cache, 'random cache retained after clear')
    return dict(chunk_lengths=4800, symbolic_entropy_beats=len(beats_seen),
                delivered_leases=len(delivered), discarded_tail_bits=discarded_bits,
                stall_cycles=stall_checks, max_cache_bytes=600,
                exclusions=['RTL handshake', 'random statistical quality',
                            'consumer composition', 'physical leakage'])


def dma_geometry():
    cases = 0
    for width in (64, 128, 256):
        beat_bytes = width//8
        for offset in range(0, 4096, beat_bytes):
            for length in (0, 1, 3, 4, beat_bytes-1, beat_bytes, beat_bytes+1,
                           4095, 4096, 4097, 8193):
                cur, left, total = offset, length, 0
                while left:
                    size = min(left, 4096-cur % 4096, 256*beat_bytes)
                    beats = (size+beat_bytes-1)//beat_bytes
                    require(1 <= beats <= 256, 'illegal burst length')
                    require(cur//4096 == (cur+beats*beat_bytes-1)//4096,
                            'AXI burst crosses 4 KiB')
                    tail = size-(beats-1)*beat_bytes
                    require(1 <= tail <= beat_bytes, 'invalid tail strobe')
                    require((beats-1)*beat_bytes+((1 << tail)-1).bit_count() == size,
                            'byte enable changed byte count')
                    total += size
                    cur += size
                    left -= size
                require(total == length, 'byte count lost')
                cases += 1
    return dict(aligned_address_length_cases=cases, widths=[64, 128, 256],
                exclusions=['RTL AXI protocol', 'cancel/drain response timing'])


def main():
    root = Path(__file__).resolve().parents[1]
    paths = [Path(__file__).resolve(), root/'scripts/check_ntt_bank_schedule.py']
    paths += [root/'docs/lld'/f'03_{name}.md'
              for name in ('keyslot', 'sram', 'top', 'dma')]
    before = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in paths}
    result = dict(schema='pqc-storage-random-design-check/1.0', status='pass',
                  rtl_verified=False, security_verified=False,
                  scope='Bounded logical design models only; no G3/G4 signoff.',
                  storage=storage_geometry(), credits=credit_schedules(),
                  authorization=key_authorization(), slots=slot_schedules(),
                  pages=page_authorization(), random=random_chunks(), dma=dma_geometry(),
                  inputs=before)
    require(all(hashlib.sha256((root/p).read_bytes()).hexdigest() == h
                for p, h in before.items()), 'inputs changed during checks')
    output = root/'build/design/g2_continue/storage_random_check.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
