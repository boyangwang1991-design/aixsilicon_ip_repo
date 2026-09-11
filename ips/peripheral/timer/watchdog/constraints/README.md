# Integration constraints (candidate)

The SDC gives characterization clock assumptions, not device ratings. Inputs named
sleep/debug/recovery/warm/test/hw_evt are synchronous to wdt_clk at the IP boundary.
Only POR and preset are asynchronous reset inputs. Review reset recovery/removal
and release synchronizers with actual reset-tree implementation.

Mark por_p/por_w/pre_p, req_sync/ack_sync, error and output synchronizers as CDC
chains. Mailbox data stays stable until ack returns; reply data stays stable until
the next command. Apply max-delay/datapath-only and skew constraints to bundled
payloads after selecting clock periods; never synchronize their individual bits.
The cancellation tag follows the request synchronizer pipeline on warm reset.

For SAFETY, preserve independent count_bar/divider_bar/config/lock/state/esc_age
and request control protection cones. Inspect mapped registers and fan-in, inject
faults into mapped state, and prove final requests survive a single control upset.
`set_dont_touch` intent and RTL presence alone do not prove physical independence.
CDC/RDC signoff, formal closure, physical placement and PPA are separate evidence.
