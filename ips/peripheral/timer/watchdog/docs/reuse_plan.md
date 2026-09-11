# Watchdog reuse assessment — 2026-09-10

Source: current workspace CBB/VIP registry files, read before implementation.
No remote sync was performed; these decisions describe the local asset baseline.

| Asset | Registry status | Decision |
|---|---|---|
| aixsilicon:cbb:round_robin_arbiter:0.1.0 | implemented | Instantiate with NUM_REQ=2, PC_IMPL=0, default combinational grant; mailbox/hardware arbitration |
| incrementer_decrementer:0.1.0 | implemented | Not selected: this IP's independent saturated/complemented state update and fault-priority arbitration are channel-specific, not standalone modulo arithmetic |
| lockstep_comparator:1.0.0 | implemented | Not selected: complemented, per-field classification and immediate sticky fault response differ from generic vector lockstep comparison |
| APB VIP | developing, M1, PARTIAL_DEVELOPING; version '-' | Not qualified as a G4 dependency; local bounded APB bus tasks are temporary module/integration UT stimulus |

FuseSoC declares the arbiter dependency. Its existing core lacks `paramtype` and
is rejected by the installed FuseSoC schema. `run_validation.py` writes only build
metadata under `build/dependency_adapter`, referencing the original CBB SV path.
The CBB source is never edited. FuseSoC exports disposable compilation copies into
build/; they are not IP deliverables. The adaptation is recorded in raw logs.

Mailbox, reset/error handshakes and channel supervision have no implemented,
semantically matching asset in the inspected registry. They remain IP-specific.
Full UVM APB VIP integration and asset qualification are outside these UT results.
