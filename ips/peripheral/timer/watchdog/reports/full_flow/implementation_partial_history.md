# Watchdog microarchitecture (candidate, draft)

The contract's WDT-* requirements remain authoritative. G2 is open; freeze=false.

## LLD.MOD.WDT.CHANNEL

`rtl/watchdog_channel.sv` uses current/next state. Each running edge computes both
independent candidate ages from its own counter and divider. It accumulates all
new reasons before resolving fatal/timeout, recovery, refresh, command and pause
priority. Saturating state never wraps into a valid service window. State values
0..5 have complemented protection; illegal values escalate, never silently disable.
Sequence and flow ages increment on unpaused WDT edges independently of prescaling.
ALIVE evaluates the old period before accepting any boundary service. A refresh
clears round progress, not tokens or historical diagnostics. Restart reseeds tokens.

Pending runtime configuration compares every field except prescale/window/timeout/
pretimeout against active, including the whole client table. It applies only on a
successful old-configuration refresh. Unlock ages never pause and sensitive commands
consume one source-bound credit even when rejected. New hardware events win W1C.
First-fault data uses old configuration, old state and candidate age, with priority
encoded from the contract. Repeated fault observations never restart escalation.
Local done is accepted only after observing low since reset/last handshake; ACK
stays high until DONE drops. At final deadline escalation wins over all recovery.

## LLD.MOD.WDT.TOP

`rtl/watchdog_top.sv` instantiates channels and a reused round-robin arbiter.
Staging uses per-channel arrays and genuinely independent per-client entries.
Mailbox capture locks selectors, authorization, source, data, entire configuration
and sequence. APB rejection never toggles the mailbox. Native PeakRDL external
register requests are acknowledged combinationally; all side effects occur only
on APB completion. Staging reads return local data; snapshot reads return a held
reply copied only after the synchronized acknowledge. Snapshot source is channel
next state, so counters, faults and configuration are from the same edge.

Register behavior: staging writes require cfg_auth; command permissions follow
contract. Unsupported fields are checked on commit without truncation. Partial,
reserved-bit, misaligned, RO and unauthorized writes are rejected before mutation.
WO reads return zero. Snapshot invalid reads are zero. Preset clears staging and
selectors to DEFAULT_CFG but preserves mailbox, completed snapshots and sequences.

## Safety and physical implementation

Complemented C/D evolve from their own previous values; they do not sample primary
next values. Explicit restart/refresh clears both paths. Config/lock/state integrity
checks run even paused. Injection changes the actual protected storage or one
comparison path for one check; it never directly asserts a diagnostic result.
Synthesis must preserve independent register cones; RTL simulation alone is not
physical redundancy evidence. Timing storage uses parameter widths; diagnostics
expose zero-extended 64-bit containers.
