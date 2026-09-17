// =============================================================================
// ut_pqc_dsa_seq - module UT for the ML-DSA sequencer attempt loop + verify
//
// Verifies:
//   * one rejected attempt produces no committed signature, the loop retries
//   * the attempt limit yields the retry-exhausted state with no output
//   * an all-pass attempt commits exactly once
//   * Verify scans the FULL challenge digest and is the conjunction of the
//     numeric rejection gates and the digest equality (F07 regression):
//       - all-pass + all-equal digest             -> verify_valid = 1
//       - norm_z failure although digest equal      -> verify_valid = 0
//       - hint failure although digest equal        -> verify_valid = 0
//       - mismatch only at the LAST digest byte     -> verify_valid = 0
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_dsa_seq;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  localparam int unsigned MAX_ATT = 8;
  localparam int unsigned CT_LEN  = 48;   // ML-DSA-65 challenge digest bytes

  logic        start;
  logic [1:0]  op;
  logic [2:0]  pset;
  logic        busy, done, verify_valid, retry_exhausted;

  logic        prim_start, prim_domain;
  logic [3:0]  prim_op;
  logic        prim_busy, prim_done;

  logic        norm_z_ok, norm_r0_ok, hint_weight_ok;

  logic        stage_req, stage_we, stage_ready, commit_valid;
  logic [15:0] stage_addr, sig_len;
  logic [7:0]  stage_wdata, stage_rdata;

  logic        ct_calc_we, ct_ref_we, ct_clear;
  logic [7:0]  ct_calc_byte, ct_ref_byte;

  logic        zeroize_req;

  pqc_dsa_seq #(.MAX_ATTEMPTS(MAX_ATT)) dut (
    .clk(clk), .rst_n(rst_n), .start(start), .op(op), .pset(pset),
    .busy(busy), .done(done), .verify_valid(verify_valid),
    .retry_exhausted(retry_exhausted),
    .prim_start(prim_start), .prim_op(prim_op), .prim_domain(prim_domain),
    .prim_busy(prim_busy), .prim_done(prim_done),
    .norm_z_ok(norm_z_ok), .norm_r0_ok(norm_r0_ok), .hint_weight_ok(hint_weight_ok),
    .stage_req(stage_req), .stage_we(stage_we), .stage_addr(stage_addr),
    .stage_wdata(stage_wdata), .stage_rdata(stage_rdata), .stage_ready(stage_ready),
    .commit_valid(commit_valid), .sig_len(sig_len),
    .ct_calc_we(ct_calc_we), .ct_calc_byte(ct_calc_byte),
    .ct_ref_we(ct_ref_we), .ct_ref_byte(ct_ref_byte), .ct_clear(ct_clear),
    .zeroize_req(zeroize_req)
  );

  int errors;
  int guard;
  int commit_count;
  int cmt_snap;

  logic [7:0] ct_ref_mem  [0:63];
  logic [7:0] ct_calc_mem [0:63];

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) commit_count <= 0;
    else if (commit_valid) commit_count <= commit_count + 1;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) prim_done <= 1'b0;
    else        prim_done <= dut.prim_start;   // primitive completes next cycle
  end

  // load the two digest byte arrays into the DUT RF before a verify command
  task automatic load_digests(input logic [7:0] calc, input logic [7:0] refv,
                              input int unsigned mismatch_idx);
    // rewind write pointers
    @(negedge clk); ct_clear = 1'b1; ct_calc_we = 0; ct_ref_we = 0;
    @(negedge clk); ct_clear = 1'b0; ct_calc_we = 1; ct_ref_we = 1;
    for (int i = 0; i < CT_LEN; i++) begin
      ct_calc_byte = calc;
      ct_ref_byte  = (i == mismatch_idx) ? ~refv : refv;
      @(negedge clk);
    end
    ct_calc_we = 0; ct_ref_we = 0;
    @(negedge clk);
  endtask

  // command run helper
  task automatic run_cmd(input logic [1:0] cmd);
    @(negedge clk);
    start = 1'b1; op = cmd;
    @(negedge clk);
    start = 1'b0;
    guard = 0;
    while (!done && guard < 40000) begin @(negedge clk); guard++; end
    if (guard >= 40000) begin
      $display("FAIL: DSA sequencer timeout");
      errors++;
    end
    @(negedge clk);
  endtask

  initial begin
    errors = 0; cmt_snap = 0;
    start = 0; op = 0; pset = 3'd5; prim_busy = 0;   // ML-DSA-65
    stage_ready = 1'b1; stage_rdata = 8'hA5;
    norm_z_ok = 1'b1; norm_r0_ok = 1'b1; hint_weight_ok = 1'b1;
    zeroize_req = 0;
    ct_calc_we = 0; ct_ref_we = 0; ct_clear = 0;
    ct_calc_byte = 8'h5A; ct_ref_byte = 8'h5A;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    chk(sig_len, 16'd3309, "ML-DSA-65 signature length");

    // ------------------------------------------------------------------
    // sign: all checks pass -> exactly one commit, no rejection
    // ------------------------------------------------------------------
    cmt_snap = commit_count;
    norm_z_ok = 1'b1; norm_r0_ok = 1'b1; hint_weight_ok = 1'b1;
    run_cmd(2'd1);
    if ((commit_count - cmt_snap) != 1) begin
      $display("FAIL: expected exactly 1 commit on a passing attempt, got %0d",
               commit_count - cmt_snap);
      errors++;
    end
    chk(retry_exhausted, 1'b0, "no retry exhaustion when the attempt passes");
    @(negedge clk);

    // ------------------------------------------------------------------
    // sign: permanent rejection -> attempt limit, no commit at all
    // ------------------------------------------------------------------
    cmt_snap = commit_count;
    norm_z_ok = 1'b0; norm_r0_ok = 1'b1; hint_weight_ok = 1'b1;
    run_cmd(2'd1);
    if ((commit_count - cmt_snap) != 0) begin
      $display("FAIL: retry-exhausted run must not commit a signature (got %0d)",
               commit_count - cmt_snap);
      errors++;
    end
    chk(retry_exhausted, 1'b1, "retry_exhausted asserted after the attempt limit");
    norm_z_ok = 1'b1;
    @(negedge clk);

    // ------------------------------------------------------------------
    // verify: all-pass + full digest equal -> valid
    // ------------------------------------------------------------------
    load_digests(8'h5A, 8'h5A, 64);
    norm_z_ok = 1'b1; norm_r0_ok = 1'b1; hint_weight_ok = 1'b1;
    run_cmd(2'd2);
    @(negedge clk);
    chk(verify_valid, 1'b1, "verify valid when all gates pass and digests agree");

    // ------------------------------------------------------------------
    // verify: norm_z fails although the digest is fully equal -> invalid
    // (the F07 bypass must be closed)
    // ------------------------------------------------------------------
    load_digests(8'h5A, 8'h5A, 64);
    norm_z_ok = 1'b0; norm_r0_ok = 1'b1; hint_weight_ok = 1'b1;
    run_cmd(2'd2);
    @(negedge clk);
    chk(verify_valid, 1'b0, "verify invalid when norm_z fails despite equal digest");

    // ------------------------------------------------------------------
    // verify: hint check fails although the digest is fully equal -> invalid
    // ------------------------------------------------------------------
    load_digests(8'h5A, 8'h5A, 64);
    norm_z_ok = 1'b1; norm_r0_ok = 1'b1; hint_weight_ok = 1'b0;
    run_cmd(2'd2);
    @(negedge clk);
    chk(verify_valid, 1'b0, "verify invalid when hint check fails despite equal digest");
    hint_weight_ok = 1'b1;

    // ------------------------------------------------------------------
    // verify: mismatch only at the LAST digest byte -> invalid
    // proves the whole digest is traversed, not a single byte
    // ------------------------------------------------------------------
    load_digests(8'h5A, 8'h5A, CT_LEN - 1);
    run_cmd(2'd2);
    @(negedge clk);
    chk(verify_valid, 1'b0, "verify invalid when a late digest byte differs");

    #40;
    if (errors == 0) $display("UT_pqc_dsa_seq: PASS (errors=0)");
    else             $display("UT_pqc_dsa_seq: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #40_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_dsa_seq: FAIL (errors=1)");
    $finish;
  end

endmodule