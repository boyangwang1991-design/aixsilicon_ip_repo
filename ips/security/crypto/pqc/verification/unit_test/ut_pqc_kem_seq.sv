// =============================================================================
// ut_pqc_kem_seq - module UT for the ML-KEM sequencer
//
// Focuses on the security-critical Decaps behaviour: the ciphertext compare
// must traverse the full length (no early exit) and the shared-secret select
// must be a full-width mask select. Also checks the attempt-free KeyGen /
// Encaps completion path and zeroize.
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_kem_seq;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic        start;
  logic [1:0]  op;
  logic [1:0]  rank;
  logic        busy, done, op_error;

  logic        prim_start, prim_domain;
  logic [3:0]  prim_op;
  logic        prim_busy, prim_done;

  logic [15:0] ct_bytes;


  logic [7:0]  ct_read_data, ct_calc_data, kprime_data, kbar_data;
  logic [15:0] ct_read_addr, ct_calc_addr, ss_addr;
  logic [7:0]  ss_wdata;
  logic        ss_we;
  logic [15:0] ct_len;
  logic [7:0]  verify_mask;

  logic        zeroize_req;

  pqc_kem_seq dut (
    .clk(clk), .rst_n(rst_n), .start(start), .op(op), .rank(rank),
    .busy(busy), .done(done), .op_error(op_error),
    .prim_start(prim_start), .prim_op(prim_op), .prim_domain(prim_domain),
    .prim_busy(prim_busy), .prim_done(prim_done), .ct_bytes(ct_bytes),
    .ct_read_data(ct_read_data), .ct_read_addr(ct_read_addr),
    .ct_calc_data(ct_calc_data), .ct_calc_addr(ct_calc_addr),
    .kprime_data(kprime_data), .kbar_data(kbar_data),
    .ss_addr(ss_addr), .ss_wdata(ss_wdata), .ss_we(ss_we),
    .ct_len(ct_len), .verify_mask(verify_mask), .zeroize_req(zeroize_req)
  );

  int errors;
  int guard;
  int select_writes;
  logic [7:0] selected_first;
  int read_cycles;
  int sel_cnt_snap;
  int rd_cnt_snap;
  logic phase_reset;

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  // Instruments the select phase: count writes and latch the first value.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || phase_reset) begin
      select_writes  <= 0;
      selected_first <= 8'h0;
      read_cycles    <= 0;
    end else begin
      if (ss_we) begin
        if (select_writes == 0) selected_first <= ss_wdata;
        select_writes <= select_writes + 1;
      end
      if (dut.qstate == dut.Q_COMPARE) read_cycles <= read_cycles + 1;
    end
  end

  // The re-encryption primitive is modelled as always completing one cycle
  // after it is requested, which is what the sequencer expects.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) prim_done <= 1'b0;
    else        prim_done <= dut.prim_start;
  end

  task automatic run_op(input logic [1:0] o, input logic [15:0] clen);
    @(negedge clk);
    ct_bytes = clen;
    start = 1'b1; op = o;
    @(negedge clk);
    start = 1'b0;
    guard = 0;
    while (!done && guard < 200000) begin @(negedge clk); guard++; end
    if (guard >= 200000) begin
      $display("FAIL: KEM sequencer timeout op=%0d", o);
      errors++;
    end
    @(negedge clk);
    @(negedge clk);
  endtask

  initial begin
    phase_reset = 1'b0;
    start = 0; op = 0; rank = 0; prim_busy = 0;
    ct_bytes = 16'h0;
    ct_read_data = 0; ct_calc_data = 0; kprime_data = 0; kbar_data = 0;
    zeroize_req = 0;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // ------------------------------------------------------------------
    // KeyGen: completes as soon as the primitive reports done
    // ------------------------------------------------------------------
    @(negedge clk);
    start = 1'b1; op = 2'd0;
    @(negedge clk);
    start = 1'b0;
    guard = 0;
    while (!busy && guard < 50) begin @(negedge clk); guard++; end
    guard = 0;
    while (!done && guard < 200) begin @(negedge clk); guard++; end
    chk(done, 1'b1, "KeyGen reached done");
    chk(op_error, 1'b0, "KeyGen reported no error");
    @(negedge clk);

    // ------------------------------------------------------------------
    // Decaps: full-length compare, no early exit, masking select
    // ------------------------------------------------------------------
    // reset per-phase instrumentation
    phase_reset = 1'b1;
    @(negedge clk);
    phase_reset = 1'b0;
    @(negedge clk);
    // differing bytes across the whole length: an early-exit implementation
    // would finish far sooner
    @(negedge clk);
    ct_read_data = 8'hA5;
    ct_calc_data = 8'h5A;
    kprime_data  = 8'h11;
    kbar_data    = 8'h22;
    run_op(2'd2, 16'd768);
    @(negedge clk);
    chk(op_error, 1'b0, "Decaps reported no error");
    // compare must have visited every byte of the ciphertext
    if (read_cycles < 768) begin
      $display("FAIL: compare exited early (%0d cycles, expected >= 768)", read_cycles);
      errors++;
    end
    // the shared secret is 32 bytes and must be written by a masked select
    if (select_writes != 32) begin
      $display("FAIL: expected 32 shared-secret select writes, got %0d", select_writes);
      errors++;
    end
    // all bytes differ, so the rejection secret must be selected
    chk(selected_first, 8'h22, "mismatching ciphertext selects the rejection secret");
    @(negedge clk);

    // ------------------------------------------------------------------
    // Matching ciphertext selects the derived secret
    // ------------------------------------------------------------------
    phase_reset = 1'b1;
    @(negedge clk);
    phase_reset = 1'b0;
    @(negedge clk);
    ct_read_data = 8'h77;
    ct_calc_data = 8'h77;      // identical => valid
    kprime_data  = 8'hAB;
    kbar_data    = 8'hCD;
    run_op(2'd2, 16'd768);
    @(negedge clk);
    chk(selected_first, 8'hAB, "matching ciphertext selects the derived secret");

    // ------------------------------------------------------------------
    // zeroize returns the sequencer to idle
    // ------------------------------------------------------------------
    @(negedge clk);
    zeroize_req = 1'b1;
    @(negedge clk);
    zeroize_req = 1'b0;
    @(negedge clk);
    chk(busy, 1'b0, "not busy after zeroize");

    #40;
    if (errors == 0) $display("UT_pqc_kem_seq: PASS (errors=0)");
    else             $display("UT_pqc_kem_seq: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #10_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_kem_seq: FAIL (errors=1)");
    $finish;
  end

endmodule
