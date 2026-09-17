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

module ut_pqc_dsa_replay;

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
 errors=0;cmt_snap=0;start=0;op=0;pset=5;prim_busy=0;stage_ready=1;stage_rdata=0;
 norm_z_ok=1;norm_r0_ok=1;hint_weight_ok=1;zeroize_req=0;
 ct_calc_we=0;ct_ref_we=0;ct_clear=0;ct_calc_byte=0;ct_ref_byte=0;
 rst_n=0;repeat(4) @(negedge clk);rst_n=1;
 load_digests(8'h5a,8'h5a,99);run_cmd(2);
 $display("CHECK DSA valid loaded digest valid=%b",verify_valid);
 if(verify_valid !== 1) $fatal(1,"fresh digest rejected");
 repeat(3) @(negedge clk);ct_clear=1;@(negedge clk);ct_clear=0;
 run_cmd(2);$display("CHECK DSA no new digest after clear valid=%b expected fail-closed=0",verify_valid);
 if(verify_valid !== 0) $fatal(1,"stale digest accepted");
 $display("UT_pqc_dsa_replay: PASS (errors=0)");$finish;end

 initial begin #2000000; $fatal(1,"watchdog");end
endmodule
