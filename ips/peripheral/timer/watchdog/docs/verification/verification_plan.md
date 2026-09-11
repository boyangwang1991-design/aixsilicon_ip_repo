# Watchdog verification plan (candidate)

Input: watchdog_contract.md §19. No human freeze or G4 approval is asserted.

## Features and test entry points

| Requirement families | Executable proof | Checks |
|---|---|---|
| TIM, SRV, STA | ut_watchdog_channel | Independent TIMEOUT*(P+1) reference; minimum/late/early service; dual key inclusive expiry; TOKEN replay, QA known vector |
| SUP | ut_watchdog_channel | GROUP partial/last/duplicate, ALIVE fixed boundary/missing/overflow, FLOW START/STEP/END/deadline |
| CFG, REG | channel/top UT | Atomic pending apply, lock and one-shot credit, staging isolation, capability and fixed address access |
| ESC, REC, PWR | ut_watchdog_channel | Delay-zero local reset, final deadline priority, stale done, recovery budget, exact pause phase |
| SAF, TST, DIA | ut_watchdog_channel | All six diagnostic injection targets, real checker/real sticky response, test-context first capture, warm history |
| BUS, CDC, RST, SNP, IF | ut_watchdog_top | Async clocks; stopped WDT busy, partial/reserved/RO/unauthorized access, preset in flight, no replay, warm cancellation inside synchronizer, held snapshots, stopped pclk/AUTO_START |
| PAR | W=32/48/64 and two pclk/WDT ratios | Explicit parameter configurations; not exhaustive parameter-space closure |
| Software SRV/CDC | sw/tests/test_watchdog.c | Timeout retains pending sequence, old DONE rejected, no blind reissue, write failure, sequence wrap |

## Environment and checking

Module UT directly drives channel commands at negative edges and checks expected
pre-edge completion plus post-edge architectural state. Top UT uses actual APB
transactions, no backdoor initialization, independent clocks, and bounded waits.
The timer randomized reference computes elapsed cycles from the contract formula,
not by reading the RTL divider state. Fatal assertions stop the simulation.

Tests are bare SV Module UT, compiled with VCS and UVM 1.2 available. They are
not a completed UVM environment or a replacement for full protocol qualification.
VCS line/condition/branch/FSM/toggle coverage is collected per elaboration. Different
widths must not be merged into one misleading denominator. No coverage percentage
or waiver is invented. The runner binds the source set, command and original log.

## Open verification work

Full functional cross coverage, all possible reset alignments, formal properties,
CDC/RDC tool signoff, maximum channel/client implementation, saturated 64-bit long
periods, mapped-gate fault injection, physical redundancy and three-profile PPA
need additional qualification. Directed tests do not establish all §19.3 criteria.
These remain explicit open items, not waived or marked pass.
