// =============================================================================
// ut_pqc_codec - module UT for the codec / rounding / norm-check unit
//
// Cross-checks the codec datapath against an independent software model of the
// FIPS 203 Compress/Decompress definition computed inside this testbench.
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_codec;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  localparam int unsigned MEM_WORDS = 4096;
  localparam logic [31:0] Q_KEM = 32'd3329;

  logic [31:0] mem [0:MEM_WORDS-1];

  logic        start;
  logic [3:0]  op;
  logic        domain;
  logic [3:0]  d_comp;
  logic [1:0]  gamma2_sel;
  logic [7:0]  src_page, src2_page, dst_page;
  logic [31:0] bound;
  logic        busy, done, canonical_ok, norm_ok;
  logic        mem_req, mem_we, mem_ready;
  logic [15:0] mem_addr;
  logic [31:0] mem_wdata, mem_rdata;
  logic        zeroize_req;

  pqc_codec dut (
    .clk(clk), .rst_n(rst_n), .start(start), .op(op), .domain(domain),
    .d_comp(d_comp), .gamma2_sel(gamma2_sel), .src_page(src_page),
    .src2_page(src2_page), .dst_page(dst_page),
    .bound(bound), .busy(busy), .done(done), .canonical_ok(canonical_ok), .norm_ok(norm_ok),
    .mem_req(mem_req), .mem_we(mem_we), .mem_addr(mem_addr), .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata), .mem_ready(mem_ready), .zeroize_req(zeroize_req)
  );

  int errors = 0;

  always_comb mem_rdata = mem[mem_addr];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) mem_ready <= 1'b0;
    else        mem_ready <= mem_req;
  end

  // Single writer keeps the array free of multiple procedural drivers.
  logic        ld_en;
  logic [15:0] ld_addr;
  logic [31:0] ld_data;
  always_ff @(posedge clk) begin
    if (ld_en)                 mem[ld_addr] <= ld_data;
    else if (mem_req && mem_we) mem[mem_addr] <= mem_wdata;
  end

  task automatic preload(input logic [7:0] page, input int unsigned idx, input logic [31:0] v);
    @(negedge clk);
    ld_en = 1'b1; ld_addr = {page, 8'(idx)}; ld_data = v;
    @(negedge clk);
    ld_en = 1'b0;
  endtask

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  // FIPS 203 Compress_d: round(2^d / q * x) mod 2^d
  function automatic logic [31:0] sw_compress(input logic [31:0] x, input int unsigned d);
    logic [63:0] t;
    t = (64'(x) << d) + 64'(Q_KEM >> 1);
    sw_compress = 32'((t / 64'(Q_KEM)) & ((64'h1 << d) - 64'h1));
  endfunction

  // FIPS 203 Decompress_d: round(q / 2^d * y)
  function automatic logic [31:0] sw_decompress(input logic [31:0] y, input int unsigned d);
    sw_decompress = ((y * Q_KEM) + (32'h1 << (d - 1))) >> d;
  endfunction

  task automatic run_op(
    input logic [3:0]  o,
    input logic [7:0]  sp,
    input logic [7:0]  dp,
    input logic [3:0]  dc,
    input logic [31:0] bnd
  );
    int guard;
    op = o; src_page = sp; dst_page = dp; d_comp = dc; bound = bnd;
    start <= 1'b1; @(posedge clk); start <= 1'b0;
    guard = 0;
    while (!done && guard < 20000) begin @(posedge clk); guard++; end
    if (guard >= 20000) begin
      $display("FAIL: codec timeout op=%0d", o);
      errors++;
    end
    @(negedge clk);
  endtask

  logic [15:0] caddr;

  initial begin
    start = 1'b0; op = 4'h0; domain = 1'b0; d_comp = 4'hA; gamma2_sel = 2'h1;
    src_page = 8'h0; src2_page = 8'h1; dst_page = 8'h1; bound = 32'h0; zeroize_req = 1'b0;
    ld_en = 1'b0; ld_addr = 16'h0; ld_data = 32'h0;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // ------------------------------------------------------------------
    // Compress with d = 10 over in-range coefficients
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) preload(8'h0, i, 32'((i * 13) % 3329));
    run_op(4'h2, 8'h0, 8'h1, 4'hA, 32'h0);
    for (int i = 0; i < 256; i++) begin
      caddr = {8'h1, 8'(i)};
      chk(mem[caddr] & 32'h3FF, sw_compress(32'((i * 13) % 3329), 10),
          $sformatf("compress d10 coeff %0d", i));
      if (errors > 8) break;
    end
    if (canonical_ok !== 1'b1) begin
      $display("FAIL: canonical_ok should be 1 for in-range input");
      errors++;
    end

    // ------------------------------------------------------------------
    // Decompress the compressed values
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) preload(8'h2, i, mem[{8'h1, 8'(i)}]);
    run_op(4'h3, 8'h2, 8'h3, 4'hA, 32'h0);
    for (int i = 0; i < 256; i++) begin
      caddr = {8'h3, 8'(i)};
      chk(mem[caddr], sw_decompress(mem[{8'h2, 8'(i)}] & 32'h3FF, 10),
          $sformatf("decompress d10 coeff %0d", i));
      if (errors > 16) break;
    end

    // ------------------------------------------------------------------
    // Canonical check must flag an out-of-range coefficient
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) preload(8'h4, i, 32'(i % 3329));
    preload(8'h4, 7, 32'd4000);          // >= q, non-canonical
    run_op(4'h0, 8'h4, 8'h5, 4'hA, 32'h0);
    if (canonical_ok !== 1'b0) begin
      $display("FAIL: canonical_ok should be 0 for coefficient 4000 >= q");
      errors++;
    end

    // ------------------------------------------------------------------
    // Norm check OR-reduces across all coefficients (not first-violation stop)
    // ------------------------------------------------------------------
    for (int i = 0; i < 256; i++) preload(8'h6, i, 32'd100);
    preload(8'h6, 200, 32'd5000);        // single late violation
    run_op(4'h8, 8'h6, 8'h7, 4'hA, 32'd1000);
    if (norm_ok !== 1'b0) begin
      $display("FAIL: norm_ok should be 0 when a late coefficient exceeds bound");
      errors++;
    end

    for (int i = 0; i < 256; i++) preload(8'h8, i, 32'd100);
    run_op(4'h8, 8'h8, 8'h9, 4'hA, 32'd1000);
    if (norm_ok !== 1'b1) begin
      $display("FAIL: norm_ok should be 1 when all coefficients are within bound");
      errors++;
    end

    #40;
    if (errors == 0) $display("UT_pqc_codec: PASS (errors=0)");
    else             $display("UT_pqc_codec: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #2_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_codec: FAIL (errors=1)");
    $finish;
  end

endmodule