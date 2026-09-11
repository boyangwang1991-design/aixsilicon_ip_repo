// Included in watchdog_harness; assertions observe RTL, they do not drive it.
// Each VPLAN assertion ID has executable checks plus antecedent cover properties.
`ifndef WATCHDOG_ASSERTIONS__SV
`define WATCHDOG_ASSERTIONS__SV
// ASSERT.WATCHDOG.BUS.001
apb_access_bound: assert property(@(posedge control.pclk) disable iff(!dut.apb_rst_n)
 apb.psel[0] && apb.penable && !apb.pready |=> apb.pready) else $error("ASSERT.WATCHDOG.BUS.001 ACCESS latency");
apb_accept_equivalence: assert property(@(posedge control.pclk) disable iff(!dut.apb_rst_n)
 dut.apb_fire == (apb.psel[0] && apb.penable && apb.pready)) else $error("ASSERT.WATCHDOG.BUS.001 accept event");
bus_attempt: cover property(@(posedge control.pclk) dut.apb_rst_n && dut.apb_fire);
// ASSERT.WATCHDOG.CDC.001
mailbox_payload_stable: assert property(@(posedge control.pclk) disable iff(!dut.prst_n)
 dut.busy |=> $stable({dut.mailbox_cmd,dut.mailbox_config})) else $error("ASSERT.WATCHDOG.CDC.001 payload changed while owned");
mailbox_no_reexecute: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
 dut.execute_mailbox |=> !dut.execute_mailbox) else $error("ASSERT.WATCHDOG.CDC.001 duplicate execution");
mailbox_ack: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
 dut.execute_mailbox |=> dut.ack_toggle==$past(dut.req_sync[SYNC_STAGES-1])) else $error("ASSERT.WATCHDOG.CDC.001 acknowledgement");
mailbox_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && dut.execute_mailbox);
// ASSERT.WATCHDOG.HW_EVENT.001
one_request: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
 $onehot0(dut.cmd_v) && !(dut.execute_mailbox && control.hw_valid && control.hw_ready)) else $error("ASSERT.WATCHDOG.HW_EVENT.001 two requests consumed");
mailbox_fairness: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
 dut.mailbox_available |-> ##[0:2] dut.execute_mailbox) else $error("ASSERT.WATCHDOG.HW_EVENT.001 mailbox starved");
cancel_blocks_hw: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
 dut.cancel_mailbox |-> !control.hw_ready) else $error("ASSERT.WATCHDOG.HW_EVENT.001 cancel consumed hardware");
arbitration_attempt: cover property(@(posedge control.wdt_clk) dut.mailbox_available && control.hw_valid);
// ASSERT.WATCHDOG.RESET.001: every request toggle transition has a retained bus acceptance.
request_change_cause: assert property(@(posedge control.pclk) disable iff(!dut.prst_n)
 $changed(dut.req_toggle) |-> $past(dut.apb_fire && apb.pwrite && !apb.pslverr && dut.is_command)) else $error("ASSERT.WATCHDOG.RESET.001 spurious reset request");
reset_attempt: cover property(@(posedge control.pclk) control.por_n && !control.preset_n && dut.busy);
for(genvar c=0;c<NUM_CHANNELS;c++) begin : g_contract_assertions
 `define CH dut.g_channel[c].u_channel
 // ASSERT.WATCHDOG.TIMING.001
 legal_refresh: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n || !`CH.initialized)
  `CH.do_refresh |-> (`CH.accepted && `CH.completed && `CH.cmd_valid && `CH.cmd.opcode==SERVICE) ||
   (`CH.running && `CH.sup==2 && `CH.timed_out && `CH.missing==0)) else $error("ASSERT.WATCHDOG.TIMING.001 illegal refresh");
 timing_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && `CH.do_refresh);
 // ASSERT.WATCHDOG.COMMIT.001
 atomic_activation: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n || !`CH.initialized)
  $changed(`CH.q.cfg) |-> $past((`CH.q.state==DISABLED && `CH.cmd_valid && `CH.cmd.opcode==COMMIT && `CH.result==OK) ||
   (`CH.q.state==RUN && `CH.q.cfg_pending && `CH.do_refresh))) else $error("ASSERT.WATCHDOG.COMMIT.001 activation without validated boundary");
 commit_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && $changed(`CH.q.version));
 // ASSERT.WATCHDOG.LOCK.001
 monotonic_locks: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n || !`CH.initialized)
  (`CH.q.locks & $past(`CH.q.locks))==$past(`CH.q.locks)) else $error("ASSERT.WATCHDOG.LOCK.001 cleared lock");
 credit_consumed: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
  `CH.cmd_valid && `CH.sensitive |=> !`CH.q.credit) else $error("ASSERT.WATCHDOG.LOCK.001 reusable credit");
 lock_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && |`CH.q.locks);
 // ASSERT.WATCHDOG.SNAPSHOT.001: all bits are one retained snapshot object.
 retained_snapshot: assert property(@(posedge control.pclk) disable iff(!dut.prst_n)
  !(dut.busy && dut.ack_sync[SYNC_STAGES-1]==dut.req_toggle && dut.mailbox_cmd.opcode==SNAPSHOT &&
    dut.reply_result==OK && dut.mailbox_cmd.channel==c) |=> $stable(dut.snapshots[c])) else $error("ASSERT.WATCHDOG.SNAPSHOT.001 mirror changed without successful snapshot");
 snapshot_attempt: cover property(@(posedge control.pclk) dut.prst_n && dut.snap_valid[c]);
 // ASSERT.WATCHDOG.FAULT.001
 final_request_holds: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
  `CH.system_reset_req && !control.warm |=> `CH.system_reset_req) else $error("ASSERT.WATCHDOG.FAULT.001 final request dropped");
 fault_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && `CH.system_reset_req);
 // ASSERT.WATCHDOG.RECOVERY.001
 recovery_once: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
  $rose(`CH.q.ack) |-> $past(control.recovery_done[c] && `CH.q.recovery_armed && !`CH.q.ack)) else $error("ASSERT.WATCHDOG.RECOVERY.001 stale completion reused");
 recovery_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && $rose(`CH.q.ack));
 // ASSERT.WATCHDOG.PAUSE.001; explicit diagnostic writes can perturb the protected state.
 paused_time: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
  `CH.q.state==PAUSED_STATE && !control.warm && !(`CH.cmd_valid && `CH.cmd.opcode==INJECT)
  |=> $stable({`CH.q.count,`CH.q.divider})) else $error("ASSERT.WATCHDOG.PAUSE.001 ordinary time advanced during pause");
 pause_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && `CH.q.state==PAUSED_STATE);
 // ASSERT.WATCHDOG.SAFETY.001
 if(SAFETY_EN) begin
  diagnosed_fault_bounded: assert property(@(posedge control.wdt_clk) disable iff(!dut.wrst_n)
   `CH.initialized && (|(`CH.events & FATAL_MASK) || `CH.qualification_mismatch)
    |=> `CH.system_reset_req && `CH.safety_alert) else $error("ASSERT.WATCHDOG.SAFETY.001 diagnostic deadline");
  safety_attempt: cover property(@(posedge control.wdt_clk) dut.wrst_n && |(`CH.events & FATAL_MASK));
 end
 `undef CH
end
`endif
