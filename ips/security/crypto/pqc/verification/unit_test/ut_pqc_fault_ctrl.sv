// =============================================================================
// ut_pqc_fault_ctrl - module UT for alert aggregation and bounded zeroize
//
// Checks that every fatal source converges on the same safe-shutdown path, that
// the zeroize completes within the configured bound regardless of the main FSM
// state, and that recoverable events never lock the IP.
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_fault_ctrl;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  localparam int unsigned ZMAX = 64;

  logic tamper, ecc_ued, ecc_ded, selftest_fail, lifecycle_change;
  logic dma_error, timeout, rng_health_fail, zeroize_req_ext;
  logic [9:0] fsm_state;
  logic counter_parity_err;
  logic dft_enable, fault_inject_ecc_ue;
  logic sram_zeroize_done, keccak_zeroize_done, keys_zeroize_done;
  logic [9:0] fsm_state_o;
  logic zeroize_req, zeroize_done, locked, alert_recoverable, alert_fatal, integrity_fault;

  pqc_fault_ctrl #(.ZEROIZE_MAX_CYCLES(ZMAX)) dut (
    .clk(clk), .rst_n(rst_n),
    .tamper(tamper), .ecc_ued(ecc_ued), .ecc_ded(ecc_ded), .selftest_fail(selftest_fail),
    .lifecycle_change(lifecycle_change), .dma_error(dma_error), .timeout(timeout),
    .rng_health_fail(rng_health_fail), .zeroize_req_ext(zeroize_req_ext),
    .fsm_state(fsm_state), .counter_parity_err(counter_parity_err),
    .dft_enable(dft_enable), .fault_inject_ecc_ue(fault_inject_ecc_ue),
    .sram_zeroize_done(sram_zeroize_done), .keccak_zeroize_done(keccak_zeroize_done),
    .keys_zeroize_done(keys_zeroize_done),
    .work_key_zeroize_done(1'b1), .dma_zeroize_done(1'b1), .desc_zeroize_done(1'b1),
    .zeroize_req(zeroize_req), .zeroize_done(zeroize_done), .locked(locked),
    .alert_recoverable(alert_recoverable), .alert_fatal(alert_fatal),
    .integrity_fault(integrity_fault), .fsm_state_o(fsm_state_o)
  );

  int errors = 0;
  int guard;

  task automatic chk(input logic got, input logic exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0b exp %0b)", msg, got, exp);
      errors++;
    end
  endtask

  task automatic clear_faults();
    tamper = 0; ecc_ued = 0; ecc_ded = 0; selftest_fail = 0; lifecycle_change = 0;
    dma_error = 0; timeout = 0; rng_health_fail = 0; zeroize_req_ext = 0;
    counter_parity_err = 0; dft_enable = 0; fault_inject_ecc_ue = 0;
    sram_zeroize_done = 0; keccak_zeroize_done = 0; keys_zeroize_done = 0;
    @(negedge clk);
  endtask

  task automatic wait_zeroize_done();
    guard = 0;
    while (!zeroize_done && guard < 1000) begin @(negedge clk); guard++; end
    if (guard >= 1000) begin
      $display("FAIL: zeroize_done did not assert");
      errors++;
    end
  endtask

  initial begin
    clear_faults();
    fsm_state = 10'b0000000100;   // IDLE
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // ------------------------------------------------------------------
    // no faults: neither alert nor lock
    // ------------------------------------------------------------------
    @(negedge clk);
    chk(zeroize_req, 1'b0, "no zeroize request without a fault");
    chk(locked, 1'b0, "not locked without a fault");
    chk(alert_fatal, 1'b0, "no fatal alert without a fault");

    // ------------------------------------------------------------------
    // recoverable event: alert raised, no lock, no zeroize
    // ------------------------------------------------------------------
    ecc_ded = 1'b1;
    @(negedge clk);
    ecc_ded = 1'b0;
    @(negedge clk);
    chk(alert_recoverable, 1'b1, "recoverable alert raised for ECC DED");
    chk(locked, 1'b0, "recoverable event must not lock");
    chk(zeroize_req, 1'b0, "recoverable event must not trigger zeroize");

    // ------------------------------------------------------------------
    // fatal event: full safe shutdown and lock
    // ------------------------------------------------------------------
    @(negedge clk);
    tamper = 1'b1;
    @(negedge clk);
    chk(zeroize_req, 1'b1, "fatal event raises zeroize_req");
    sram_zeroize_done=1; keccak_zeroize_done=1; keys_zeroize_done=1;
    wait_zeroize_done();
    chk(locked, 1'b1, "fatal event locks the IP");
    chk(alert_fatal, 1'b1, "fatal alert raised");
    chk(integrity_fault, 1'b1, "integrity fault flagged");
    tamper = 1'b0;
    sram_zeroize_done=0; keccak_zeroize_done=0; keys_zeroize_done=0;
    repeat(3) @(negedge clk);
    chk(locked, 1'b1, "fatal lock persists after completion");

    // ------------------------------------------------------------------
    // system-closed handshake: completion waits for every subsystem to report
    // its own sweep, and no subsystem is left behind
    // ------------------------------------------------------------------
    fsm_state = 10'b0000000100;   // legal IDLE again
    @(negedge clk);
    zeroize_req_ext = 1'b1;
    @(negedge clk);
    zeroize_req_ext = 1'b0;
    @(negedge clk);
    chk(zeroize_req, 1'b1, "zeroize_req stays held while the sweep is active");
    // only two of three subsystems done: completion must NOT be reported
    sram_zeroize_done   = 1'b1;
    keccak_zeroize_done = 1'b1;
    keys_zeroize_done   = 1'b0;
    repeat (5) @(negedge clk);
    chk(zeroize_done, 1'b0, "completion waits for the last subsystem");
    keys_zeroize_done = 1'b1;
    wait_zeroize_done();
    chk(zeroize_req, 1'b0, "zeroize_req released after system-closed completion");
    sram_zeroize_done = 0; keccak_zeroize_done = 0; keys_zeroize_done = 0;
    @(negedge clk);

    // ------------------------------------------------------------------
    // illegal FSM encoding is detected locally and forces the fault path
    // ------------------------------------------------------------------
    @(negedge clk);
    fsm_state = 10'b1111111111;      // deliberately illegal encoding
    @(negedge clk);
    chk(zeroize_req, 1'b1, "illegal FSM encoding triggers the zeroize path");
    fsm_state = 10'b0000000100;
    repeat(ZMAX+5) @(negedge clk);
    chk(zeroize_done, 0, "timeout must not claim successful zeroize");
    chk(zeroize_req, 1, "timeout keeps shutdown active");
    chk(locked, 1, "timeout locks the IP");
    sram_zeroize_done=1; @(negedge clk); sram_zeroize_done=0;
    keccak_zeroize_done=1; @(negedge clk); keccak_zeroize_done=0;
    keys_zeroize_done=1;
    wait_zeroize_done();
    keys_zeroize_done=0;

    // A known asserted fault must dominate another unknown simulation source.
    // This also guards against reintroducing X-filtering into hardware logic.
    @(negedge clk);tamper=1'bx;ecc_ued=1'b1;
    #1;chk(dut.fatal_event,1'b1,"known ECC fault dominates unknown tamper");
    @(negedge clk);tamper=0;ecc_ued=0;
    #40;
    if (errors == 0) $display("UT_pqc_fault_ctrl: PASS (errors=0)");
    else             $display("UT_pqc_fault_ctrl: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #1_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_fault_ctrl: FAIL (errors=1)");
    $finish;
  end

endmodule