# Safety integration notes — candidate, no ASIL claim

Implemented diagnostics compare independently evolving complemented counters and
dividers, active/pending configuration copies, lock/state/request controls,
escalation age, client/sequence parity and service comparison. Six injection
commands exercise actual state/compare detection and sticky response. A test
injection does not mask system reset. Fault outputs are independent of pclk.

Digital mismatches are observed on WDT edges. Simulation exercises single injected
faults; it does not establish diagnostic coverage percentages. Shared oscillator,
power, reset, combinational common causes, multiple errors, malicious software and
analog failure remain outside this proof. Token/QA is deterministic replay/error
detection, not cryptographic authentication. Client identity requires trustworthy
source/auth signals and actual task isolation outside the IP.

The system must monitor WDT clock stoppage using an independent timebase, preserve
requests through reset sequencing, and budget reset-manager/actuator latency.
Pause can remove supervision indefinitely and therefore requires system-level
policy. Synchronize power/debug/test/recovery/event inputs before the IP boundary.

See constraints/README.md for mapped-netlist preservation and CDC/RDC obligations.
FIRST_FAULT survives warm/interface reset, but not POR. Persist records externally
if power-loss retention is needed. Do not deploy as a qualified safety component
until the open verification and physical implementation evidence is closed.
