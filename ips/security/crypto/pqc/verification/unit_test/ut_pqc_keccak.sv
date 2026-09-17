// =============================================================================
// ut_pqc_keccak - module UT for the Keccak / SHA3 / SHAKE engine
//
// Compares the RTL byte stream against Python hashlib golden vectors produced
// by scripts/gen_pqc_golden.py (message = 0x00..0x3F).
// =============================================================================
`timescale 1ns/1ps

`include "pqc_golden_vectors.svh"

module ut_pqc_keccak;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic        start;
  logic [2:0]  function_id;
  logic        ctx_sel;
  logic [31:0] out_len;
  logic        in_valid;
  logic        in_ready;
  logic [7:0]  in_data;
  logic        in_last;
  logic        out_valid;
  logic        out_ready;
  logic [7:0]  out_data;
  logic        out_last;
  logic        busy, done;
  logic        zeroize_req, zeroize_done;

  pqc_keccak #(.ROUNDS_PER_CYCLE(2)) dut (
    .clk         (clk),
    .rst_n       (rst_n),
    .start       (start),
    .function_id (function_id),
    .ctx_sel     (ctx_sel),
    .out_len     (out_len),
    .in_valid    (in_valid),
    .in_ready    (in_ready),
    .in_data     (in_data),
    .in_last     (in_last),
    .out_valid   (out_valid),
    .out_ready   (out_ready),
    .out_data    (out_data),
    .out_last    (out_last),
    .busy        (busy),
    .done        (done),
    .zeroize_req (zeroize_req),
    .zeroize_done(zeroize_done)
  );

  int errors = 0;
  logic [7:0] captured [0:255];
  int unsigned captured_len;

  task automatic chk_byte(input logic [7:0] got, input logic [7:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got 0x%02x exp 0x%02x)", msg, got, exp);
      errors++;
    end
  endtask

  // Absorb GOLDEN_KECCAK_MSG[0:63] then squeeze `olen` bytes into `captured`.
  // All stimulus is driven on the falling edge so signals are stable at the
  // rising edge where the DUT samples them.
  task automatic run_hash(input logic [2:0] fid, input int unsigned olen);
    int guard;
    captured_len = olen;

    @(negedge clk);
    start       = 1'b1;
    function_id = fid;
    ctx_sel     = 1'b1;
    out_len     = olen;
    @(negedge clk);
    start = 1'b0;

    for (int i = 0; i < 64; i++) begin
      guard = 0;
      while (!in_ready && guard < 1000) begin @(negedge clk); guard++; end
      in_valid = 1'b1;
      in_data  = GOLDEN_KECCAK_MSG(i);
      in_last  = (i == 63);
      @(negedge clk);
      in_valid = 1'b0;
      in_last  = 1'b0;
    end

    // Standard valid/ready consumption: hold ready high, and capture the byte
    // on the edge at which `out_valid && out_ready` is observed (out_data is
    // already stable for that beat). This is the handshake a real consumer uses
    // and it exercises the "data must be valid with valid" contract.
    out_ready = 1'b1;
    for (int i = 0; i < olen; i++) begin
      guard = 0;
      while (!(out_valid && out_ready) && guard < 4000) begin @(negedge clk); guard++; end
      if (guard >= 4000) begin
        $display("FAIL: squeeze timeout at byte %0d", i);
        errors++;
        return;
      end
      captured[i] = out_data;
      @(negedge clk);
    end
    out_ready = 1'b0;
    // let the engine return to IDLE before the next command
    guard = 0;
    while (busy && guard < 1000) begin @(negedge clk); guard++; end
  endtask

  initial begin
    start = 1'b0; function_id = 3'd0; ctx_sel = 1'b0; out_len = 32'd0;
    in_valid = 1'b0; in_data = 8'h0; in_last = 1'b0; out_ready = 1'b0;
    zeroize_req = 1'b0;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    run_hash(3'd0, 32);
    for (int i = 0; i < 32; i++) chk_byte(captured[i], GOLDEN_SHA3_256(i), "sha3_256");

    run_hash(3'd1, 64);
    for (int i = 0; i < 64; i++) chk_byte(captured[i], GOLDEN_SHA3_512(i), "sha3_512");

    run_hash(3'd2, 32);
    for (int i = 0; i < 32; i++) chk_byte(captured[i], GOLDEN_SHAKE128_32(i), "shake128");

    run_hash(3'd3, 32);
    for (int i = 0; i < 32; i++) chk_byte(captured[i], GOLDEN_SHAKE256_32(i), "shake256");

    #30;
    if (errors == 0) $display("UT_pqc_keccak: PASS (errors=0)");
    else             $display("UT_pqc_keccak: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #5_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_keccak: FAIL (errors=1)");
    $finish;
  end

endmodule