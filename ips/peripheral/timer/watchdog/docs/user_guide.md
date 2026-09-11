# Watchdog integration and software guide

Top: `watchdog_top`. Ports/parameters follow the supplied watchdog_contract.md.
STANDARD defaults to one channel, 32-bit counter, 16-bit prescaler, BOOT+DUAL_KEY,
timeout/boot timeout 65536 WDT ticks, no pause, no IRQ mask and NO_STOP enabled.
These are cycle counts, not a clock-independent wall-clock duration. Override
DEFAULT_CFG for actual system timing. SAFETY/SUPERVISOR features are elaboration
switches; production injection defaults off.

From this IP directory in the multi-repository workspace:

```bash
bash scripts/regenerate.sh
bash verification/unit_test/run_ut.sh
```

The runner uses the workflow's locked uv environment, FuseSoC, VCS and the existing
CBB repository. No second environment is created. Artifacts stay under build/;
reports contain exact commands, hashes and original logs. To repeat a subset:
`bash verification/unit_test/run_ut.sh channel64 top_fast_apb`.
For static checks set UV_PROJECT to the workflow root and WATCHDOG_IP_ROOT to this
IP root, then run FuseSoC `--target lint` or `--target synth` with a build-root under
build/. Run the regression entry once to materialize the legacy CBB core adapter.
Synthesis defaults to generic DC elaboration; a real library must be supplied in
WATCHDOG_TARGET_LIBRARY for mapping. SDC frequencies are characterization examples.

Software must serialize the **global** mailbox. Write staging and each selected
client's real indirect configuration, unlock with the two constants and wait for
each DONE_SEQ, commit, inspect result, then unlock again and START. One credit
expires after 64 WDT cycles; the two unlock writes must execute within 32 WDT
cycles. Very slow APB clocks require considering this budget in software.

`sw/watchdog.c` uses platform MMIO callbacks capable of reporting bus faults and
providing barriers. Polling timeout retains an outstanding operation: call
watchdog_poll later, do not reissue. `watchdog_snapshot` must complete before
reading the snapshot. Count high/low words are from that one held image.
`watchdog_service` sends one word; dual-key service requires KEY1 then KEY2,
each with checked completion, before SEQ_LIMIT and the watchdog deadline.

A service must follow real application health checks. No automatic unconditional
feed loop is supplied. IRQ clear never feeds or clears active reset requests.
Only trusted, already-synchronized warm/recovery inputs may restart supervision.
Hold recovery_done until recovery_ack and return both to zero before another
recovery. At FINAL_DELAY the final request wins even over simultaneous recovery.

SystemRDL/JSON/C constants/IP-XACT and UVM RAL are generated views. RAL describes
the fixed maximum register aperture and default reset profile; select only the
implemented channel blocks and configure non-default reset expectations for the
instantiated DEFAULT_CFG/capabilities before applying generic register sequences.
