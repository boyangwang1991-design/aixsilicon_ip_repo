`timescale 1ns/1ps
// ============================================================================
// ut_pqc_ecc_sram - self-checking unit test for the working-memory macro
//
// Checks the storage contract that pqc_secure_sram_ctrl relies on:
//   * a write is visible on the read port with no extra latency
//     (combinational read) and only on the addressed location
//   * holding we low never modifies the array
//   * back-to-back writes to different addresses stay independent
//   * the last write wins for the same address
//   * no array location is readable as anything other than what was written
//     (the module deliberately has no reset term; unwritten locations are
//     "unknown" and must never be consumed - the controller guards this with
//     page_valid/word_valid, which is checked by ut_pqc_secure_sram_ctrl)
// ============================================================================
module ut_pqc_ecc_sram;
  logic clk = 0;
  always #5 clk = ~clk;

  localparam int unsigned DEPTH = 64;
  localparam int unsigned WIDTH = 39;

  logic                    we;
  logic [$clog2(DEPTH)-1:0] waddr, raddr;
  logic [WIDTH-1:0]         wdata, rdata;

  pqc_ecc_sram #(.DEPTH(DEPTH), .WIDTH(WIDTH)) dut (
    .clk   (clk),
    .rst_n (1'b1),
    .we    (we),
    .waddr (waddr),
    .wdata (wdata),
    .raddr (raddr),
    .rdata (rdata)
  );

  int errors = 0;

  task automatic chk(input logic [WIDTH-1:0] got, input logic [WIDTH-1:0] exp,
                     input string what);
    if (got !== exp) begin
      errors++;
      $display("FAIL: %s (got %h exp %h)", what, got, exp);
    end
  endtask

  task automatic write_word(input int unsigned a, input logic [WIDTH-1:0] d);
    @(negedge clk); we = 1'b1; waddr = a[$clog2(DEPTH)-1:0]; wdata = d;
    @(negedge clk); we = 1'b0;
  endtask

  task automatic read_word(input int unsigned a, input logic [WIDTH-1:0] exp,
                           input string what);
    raddr = a[$clog2(DEPTH)-1:0];
    #1; chk(rdata, exp, what);
    @(negedge clk);
  endtask

  initial begin
    we = 1'b0; waddr = '0; raddr = '0; wdata = '0;
    repeat(2) @(negedge clk);

    // A held write enable with no explicit write must not modify anything:
    // read a written location repeatedly while we stays low.
    write_word(0, 39'h0A5A5_A5A5A);
    read_word(0, 39'h0A5A5_A5A5A, "first write visible without extra latency");

    // we low over several cycles keeps the content stable.
    for (int i = 0; i < 3; i++) begin
      we = 1'b0;
      @(negedge clk);
      raddr = '0;
      #1; chk(rdata, 39'h0A5A5_A5A5A, "we low must not modify the array");
    end

    // Address isolation: writing one word leaves its neighbours untouched.
    write_word(1, 39'h1_FFFF_FFFF);
    write_word(DEPTH-1, 39'h2_0000_0001);
    read_word(0, 39'h0A5A5_A5A5A, "word 0 unaffected by other writes");
    read_word(1, 39'h1_FFFF_FFFF, "word 1 written");
    read_word(DEPTH-1, 39'h2_0000_0001, "last word written");

    // Last write wins for the same address.
    write_word(1, 39'h3_1234_5678);
    read_word(1, 39'h3_1234_5678, "last write wins");

    // Back-to-back writes to different addresses stay independent.
    @(negedge clk); we = 1'b1; waddr = 6'd2;  wdata = 39'h4_1111_1111;
    @(negedge clk); we = 1'b1; waddr = 6'd3;  wdata = 39'h5_2222_2222;
    @(negedge clk); we = 1'b0;
    read_word(2, 39'h4_1111_1111, "back-to-back write addr 2");
    read_word(3, 39'h5_2222_2222, "back-to-back write addr 3");

    // Read while a write is presented to the same address: the read data is the
    // pre-write content (the macro updates on the clock edge).
    raddr = 6'd2; we = 1'b1; waddr = 6'd2; wdata = 39'h6_3333_3333;
    #1; chk(rdata, 39'h4_1111_1111, "read-before-write returns current content");
    @(negedge clk); we = 1'b0;
    read_word(2, 39'h6_3333_3333, "write applied on the clock edge");

    if (errors == 0) $display("UT_pqc_ecc_sram: PASS (errors=0)");
    else             $display("UT_pqc_ecc_sram: FAIL (errors=%0d)", errors);
    $finish;
  end
endmodule