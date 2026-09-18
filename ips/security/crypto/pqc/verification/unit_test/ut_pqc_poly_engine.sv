// =============================================================================
// ut_pqc_poly_engine - module UT for the dual-modulus polynomial engine
//
// Drives the engine against an in-test memory model and compares the resulting
// coefficient pages with the reference model golden NTT / INTT vectors produced
// by scripts/gen_pqc_golden.py. Additionally checks the elementwise primitives
// (ADD / SUB / PW_MAC accumulate) which must use distinct operand pages and a
// separate accumulator page (F06 regression).
// =============================================================================
`timescale 1ns/1ps

`include "pqc_golden_vectors.svh"

module ut_pqc_poly_engine;

  logic clk, rst_n;
  function automatic logic [31:0] kem_pair_product(input int i);
    int rev, j, gamma, base;
    longint a0,a1,b0,b1;
    rev=0; j=i/2;
    for(int k=0;k<7;k++) rev=(rev<<1)|((j>>k)&1);
    gamma=1;
    for(int k=0;k<2*rev+1;k++) gamma=(gamma*17)%3329;
    base=i & ~1;
    a0=base; a1=base+1; b0=base*7+3; b1=(base+1)*7+3;
    if(i%2) return (a0*b1+a1*b0)%3329;
    return (a0*b0+a1*b1*gamma)%3329;
  endfunction

  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  // 16 pages x 256 coefficients = 4096 words; page 5 starts at word 1280.
  localparam int unsigned MEM_WORDS = 4096;

  logic [31:0] mem [0:MEM_WORDS-1];

  logic        start;
  logic [3:0]  prim;
  logic        domain;
  logic [7:0]  src_page, src2_page, dst_page;
  logic        busy, done;
  logic        mem_req, mem_we, mem_ready;
  logic [15:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata;
  logic        zeroize_req;

  pqc_poly_engine #(.NTT_LANES(2)) dut (
    .clk         (clk),
    .rst_n       (rst_n),
    .start       (start),
    .prim        (prim),
    .domain      (domain),
    .src_page    (src_page),
    .src2_page   (src2_page),
    .dst_page    (dst_page),
    .busy        (busy),
    .done        (done),
    .mem_req     (mem_req),
    .mem_we      (mem_we),
    .mem_addr    (mem_addr),
    .mem_wdata   (mem_wdata),
    .mem_rdata   (mem_rdata),
    .mem_ready   (mem_ready),
    .zeroize_req (zeroize_req)
  );

  int errors = 0;

  logic        ld_en;
  logic [15:0] ld_addr;
  logic [31:0] ld_data;

  always_comb begin
    mem_rdata = mem[mem_addr];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_ready <= 1'b0;
    end else begin
      mem_ready <= mem_req;
      if (ld_en) begin
        mem[ld_addr] <= ld_data;
      end else if (mem_req && mem_we) begin
        mem[mem_addr] <= mem_wdata;
      end
    end
  end

  task automatic preload(input logic [7:0] page, input logic [8:0] idx, input logic [31:0] val);
    @(negedge clk);
    ld_en   = 1'b1;
    ld_addr = {page, 8'(idx)};
    ld_data = val;
    @(negedge clk);
    ld_en   = 1'b0;
  endtask

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  task automatic run_prim(
    input logic [3:0] p,
    input logic        dom,
    input logic [7:0]  sp,
    input logic [7:0]  s2,
    input logic [7:0]  dp
  );
    int guard;
    start     <= 1'b1;
    prim      <= p;
    domain    <= dom;
    src_page  <= sp;
    src2_page <= s2;
    dst_page  <= dp;
    @(posedge clk);
    start <= 1'b0;
    guard = 0;
    while (!done && guard < 50000) begin @(posedge clk); guard++; end
    if (guard >= 50000) begin
      $display("FAIL: poly primitive timeout (prim=%0d)", p);
      errors++;
    end
    @(posedge clk);
  endtask

  // modular reference helpers for the elementwise checks
  function automatic logic [31:0] kem_add(input logic [31:0] a, input logic [31:0] b);
    logic [31:0] s;
    s = a + b;
    return (s >= 32'd3329) ? (s - 32'd3329) : s;
  endfunction

  function automatic logic [31:0] kem_sub(input logic [31:0] a, input logic [31:0] b);
    return (a >= b) ? (a - b) : (a + 32'd3329 - b);
  endfunction

  function automatic logic [31:0] kem_mul(input logic [31:0] a, input logic [31:0] b);
    return (a * b) % 32'd3329;
  endfunction

  initial begin
    // Exact RTL reduction versus independent mathematical remainder, including
    // the entire 46-bit input range (not just products of canonical operands).
    for(int n=0;n<200000;n++) begin
      logic[45:0] v;
      if(n<64) v=46'(n);
      else if(n<128) v=46'h3fffffffffff-46'(n-64);
      else if(n<256) v=46'd8380417*46'(n-128)+46'(n%3)-1'b1;
      else v={$urandom,$urandom};
      if(dut.dsa_reduce(v)!==32'(v%46'd8380417))
        $fatal(1,"DSA fold mismatch x=%h actual=%h expected=%h",v,dut.dsa_reduce(v),v%46'd8380417);
    end
    start = 1'b0; prim = 4'h0; domain = 1'b0;
    src_page = 8'h0; src2_page = 8'h0; dst_page = 8'h4;
    zeroize_req = 1'b0;
    ld_en = 1'b0; ld_addr = 16'h0; ld_data = 32'h0;

    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    @(negedge clk);

    // ------------------------------------------------------------------
    // Forward NTT in the KEM domain (in place on page 0)
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) preload(8'h0, 9'(i), {16'h0, GOLDEN_KEM_NTT_IN(i)});
    run_prim(4'h1, 1'b0, 8'h0, 8'h0, 8'h0);
    @(negedge clk);
    for (int i = 0; i < 256; i++) begin
      chk(mem[{8'h0, 8'(i)}] & 32'hFFFF, {16'h0, GOLDEN_KEM_NTT_FWD(i)},
          $sformatf("kem fwd ntt coeff %0d", i));
      if (errors > 8) break;
    end

    // ------------------------------------------------------------------
    // Inverse NTT restores the input
    // ------------------------------------------------------------------
    run_prim(4'h2, 1'b0, 8'h0, 8'h0, 8'h0);
    @(negedge clk);
    for (int i = 0; i < 256; i++) begin
      chk(mem[{8'h0, 8'(i)}] & 32'hFFFF, {16'h0, GOLDEN_KEM_INTT_OUT(i)},
          $sformatf("kem inv ntt coeff %0d", i));
      if (errors > 16) break;
    end

    // ------------------------------------------------------------------
    // Forward NTT in the DSA domain (in place)
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) preload(8'h5, 9'(i), GOLDEN_DSA_NTT_IN(i));
    run_prim(4'h1, 1'b1, 8'h5, 8'h5, 8'h5);
    @(negedge clk);
    for (int i = 0; i < 256; i++) begin
      chk(mem[{8'h5, 8'(i)}], GOLDEN_DSA_NTT_FWD(i),
          $sformatf("dsa fwd ntt coeff %0d", i));
      if (errors > 24) break;
    end

    // ------------------------------------------------------------------
    // Inverse NTT in the DSA domain (in place)
    // ------------------------------------------------------------------
    run_prim(4'h2, 1'b1, 8'h5, 8'h5, 8'h5);
    @(negedge clk);
    for (int i = 0; i < 256; i++) begin
      chk(mem[{8'h5, 8'(i)}], GOLDEN_DSA_INTT_OUT(i),
          $sformatf("dsa inv ntt coeff %0d", i));
      if (errors > 32) break;
    end

    // ------------------------------------------------------------------
    // ADD / SUB on distinct operand pages (F06 regression)
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) begin
      preload(8'h6, 9'(i), 32'(i % 3329));
      preload(8'h7, 9'(i), 32'((i * 7 + 3) % 3329));
    end
    run_prim(4'h4, 1'b0, 8'h6, 8'h7, 8'h4);    // ADD -> page 4
    @(negedge clk);
    for (int i = 0; i < 256; i++) begin
      chk(mem[{8'h4, 8'(i)}], kem_add(32'(i % 3329), 32'((i * 7 + 3) % 3329)),
          $sformatf("kem add coeff %0d", i));
      if (errors > 40) break;
    end
    run_prim(4'h5, 1'b0, 8'h6, 8'h7, 8'h4);    // SUB -> page 4
    @(negedge clk);
    for (int i = 0; i < 256; i++) begin
      chk(mem[{8'h4, 8'(i)}], kem_sub(32'(i % 3329), 32'((i * 7 + 3) % 3329)),
          $sformatf("kem sub coeff %0d", i));
      if (errors > 48) break;
    end

    // ------------------------------------------------------------------
    // PW_MAC accumulates into dst without aliasing the operands (F06)
    //   dst = dst + src0 * src1
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) begin
      preload(8'h6, 9'(i), 32'(i % 3329));
      preload(8'h7, 9'(i), 32'((i * 7 + 3) % 3329));
      preload(8'h4, 9'(i), 32'((i + 5) % 3329));
    end
    run_prim(4'h3, 1'b0, 8'h6, 8'h7, 8'h4);    // PW_MAC -> page 4
    @(negedge clk);
    for (int i = 0; i < 256; i++) begin
      chk(mem[{8'h4, 8'(i)}],
          kem_add(32'((i + 5) % 3329), kem_pair_product(i)),
          $sformatf("kem mac accumulate coeff %0d", i));
      if (errors > 56) break;
    end
    // run again: the accumulator must add a second product, not overwrite
    run_prim(4'h3, 1'b0, 8'h6, 8'h7, 8'h4);
    @(negedge clk);
    for (int i = 0; i < 4; i++) begin
      chk(mem[{8'h4, 8'(i)}],
          kem_add(kem_add(32'((i + 5) % 3329),
                          kem_pair_product(i)),
                  kem_pair_product(i)),
          $sformatf("kem mac double accumulate coeff %0d", i));
    end

    // ------------------------------------------------------------------
    // Zeroize clears internal accumulators
    // ------------------------------------------------------------------
    zeroize_req <= 1'b1;
    @(posedge clk);
    zeroize_req <= 1'b0;
    @(posedge clk);
    chk(dut.a_val, 32'h0, "zeroize clears a_val");
    chk(dut.acc_val, 32'h0, "zeroize clears acc_val");

    #50;
    if (errors == 0) $display("UT_pqc_poly_engine: PASS (errors=0)");
    else             $display("UT_pqc_poly_engine: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #40_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_poly_engine: FAIL (errors=1)");
    $finish;
  end

endmodule