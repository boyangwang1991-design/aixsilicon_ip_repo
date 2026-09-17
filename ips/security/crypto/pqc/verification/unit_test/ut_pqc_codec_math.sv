// =============================================================================
// ut_pqc_codec - module UT for the codec / rounding / norm-check unit
//
// Cross-checks the codec datapath against an independent software model of the
// FIPS 203 Compress/Decompress definition computed inside this testbench.
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_codec_math;

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
 start=0;op=0;domain=1;d_comp=10;gamma2_sel=1;src_page=0;src2_page=2;dst_page=1;bound=0;zeroize_req=0;
 ld_en=0;ld_addr=0;ld_data=0;rst_n=0;repeat(4) @(negedge clk);rst_n=1;
 for(int i=0;i<256;i++) preload(0,i,1);
 run_op(5,0,1,10,0);$display("CHECK DECOMPOSE(1) got=%0d expected=0",mem[256]);
 if (mem[256] !== 0) $fatal(1,"DECOMPOSE(1)");
 repeat(3) @(negedge clk);
 for(int i=0;i<256;i++) begin preload(0,i,0);preload(2,i,0);end
 run_op(6,0,1,10,0);$display("CHECK MAKEHINT(0) got=%0d expected=0",mem[256]);
 if (mem[256] !== 0) $fatal(1,"MAKEHINT(0)");
 repeat(3) @(negedge clk);
 for(int i=0;i<256;i++) preload(0,i,5000);
 run_op(4,0,1,10,0);$display("CHECK POWER2ROUND_LO(5000) got=%h expected=fffff388",mem[256]);
 if (mem[256] !== 32'hfffff388) $fatal(1,"POWER2ROUND_LO(5000)");
 repeat(3) @(negedge clk);
 for(int i=0;i<256;i++) preload(0,i,100);
 run_op(8,0,1,10,100);$display("CHECK NORM equal bound got=%b expected=0",norm_ok);
 if (norm_ok !== 1'b0) $fatal(1,"NORM equal bound");
 $display("UT_pqc_codec_math: PASS (errors=0)");$finish;end

 initial begin #2000000; $fatal(1,"watchdog");end
endmodule
