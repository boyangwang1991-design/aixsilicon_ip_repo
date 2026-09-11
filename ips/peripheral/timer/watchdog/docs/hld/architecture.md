# Watchdog architecture (candidate, draft)

Input: ../../watchdog_contract.md 1.0.0-draft. Execution mode: partial-task;
implementation and executable evidence are authorized, technical gates remain open.
No user approval, qualification or release signoff is asserted.

The APB domain owns staging and selectors. A POR-retained, single-entry bundled-data
mailbox transports commands and the complete configuration to the independent WDT
clock. Request/acknowledge toggles cross SYNC_STAGES flip-flops; payload remains
stable until completion. Interface reset never resets these toggles or completion
records. A separate four-phase, coalescing handshake carries access errors.

Each channel independently owns counting, client supervision, configuration, locks,
escalation and diagnostic state. A shared two-request round-robin arbiter selects
mailbox versus hardware service. Snapshot captures the complete post-update state
and client table in one edge. Reply data remains stable through acknowledgement.

Both domains use asynchronously asserted, synchronously released POR. Interface
reset affects only staging, APB readiness and APB output synchronizers. Warm reset
is a trusted WDT-domain event, cancels visible unexecuted mailbox commands, and
restarts active channels without erasing first-fault history or locks.

APB accesses complete in one ACCESS edge. A command becomes visible after at most
SYNC_STAGES+1 destination edges, executes within two further edges under arbitration,
and completion returns within SYNC_STAGES+1 pclk edges. Bounds assume both clocks
continue running; stopped WDT never blocks APB reads or BUSY rejection.

Register architecture uses SystemRDL external registers and PeakRDL passthrough
CPU interface behind an APB4 policy wrapper. Generated decode/metadata are reused
for all configurations; channel addresses stay fixed when channels are trimmed.
Runtime state is never read live across clock domains.

Safety uses independently evolving complemented counter/divider paths, protected
configuration/control state and sticky final-request state. Physical independence,
CDC/RDC closure and post-synthesis preservation require separate tool evidence.
