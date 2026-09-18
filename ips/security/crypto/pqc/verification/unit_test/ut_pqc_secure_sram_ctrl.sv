// =============================================================================
// ut_pqc_secure_sram_ctrl - module UT for the secure banked working memory
//
// Checks three-port arbitration, read/write fidelity, page tag gating,
// response/port ownership binding, denied-access rejection, SECDED ECC
// reporting and the independent bounded zeroize.
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_secure_sram_ctrl;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic        c0_req, c0_we, c0_ready;
  logic [15:0] c0_addr;
  logic [31:0] c0_wdata, c0_rdata;
  logic        c1_req, c1_we, c1_ready;
  logic [15:0] c1_addr;
  logic [31:0] c1_wdata, c1_rdata;
  logic        d_req, d_we, d_ready;
  logic [15:0] d_addr;
  logic [31:0] d_wdata, d_rdata;

  logic        tag_we, tag_secret, tag_valid, tag_check_req, tag_check_ok;
  logic [7:0]  tag_page, tag_check_page;
  logic [3:0]  tag_rep, tag_algo, tag_pset;

  logic        access_denied;
  logic        ecc_ded, ecc_ued, zeroize_req, zeroize_done;
  logic        ecc_inject_en;
  logic [15:0] ecc_inject_idx;
  logic [38:0] ecc_inject_mask;

  pqc_secure_sram_ctrl #(.LOCAL_SRAM_KIB(64), .NUM_PAGES(96)) dut (
    .clk(clk), .rst_n(rst_n),
    .c0_req(c0_req), .c0_we(c0_we), .c0_addr(c0_addr), .c0_wdata(c0_wdata),
    .c0_rdata(c0_rdata), .c0_ready(c0_ready),
    .c1_req(c1_req), .c1_we(c1_we), .c1_addr(c1_addr), .c1_wdata(c1_wdata),
    .c1_rdata(c1_rdata), .c1_ready(c1_ready),
    .d_req(d_req), .d_we(d_we), .d_addr(d_addr), .d_wdata(d_wdata),.d_wstrb(4'hf),
    .d_rdata(d_rdata), .d_ready(d_ready),
    .tag_we(tag_we), .tag_page(tag_page), .tag_rep(tag_rep), .tag_algo(tag_algo),
    .tag_pset(tag_pset), .tag_secret(tag_secret), .tag_valid(tag_valid),
    .tag_check_req(tag_check_req), .tag_check_page(tag_check_page),
    .tag_check_ok(tag_check_ok),
    .access_denied(access_denied),
    .ecc_ded(ecc_ded), .ecc_ued(ecc_ued),
    .ecc_inject_en(ecc_inject_en), .ecc_inject_idx(ecc_inject_idx),
    .ecc_inject_mask(ecc_inject_mask),
    .zeroize_req(zeroize_req), .zeroize_done(zeroize_done)
  );

  int errors = 0;

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  logic saved_ded, saved_ued;
  task automatic port0_write(input logic [15:0] a, input logic [31:0] v);
    int guard;
    @(negedge clk);
    c0_req = 1'b1; c0_we = 1'b1; c0_addr = a; c0_wdata = v;
    guard = 0;
    while (!c0_ready && guard < 100) begin @(negedge clk); guard++; end
    @(negedge clk);
    c0_req = 1'b0; c0_we = 1'b0;
  endtask

  task automatic port0_read(input logic [15:0] a, output logic [31:0] v);
    int guard;
    @(negedge clk);
    c0_req = 1'b1; c0_we = 1'b0; c0_addr = a;
    guard = 0;
    while (!c0_ready && guard < 100) begin @(negedge clk); guard++; end
    v = c0_rdata; saved_ded=ecc_ded; saved_ued=ecc_ued;
    @(negedge clk);
    c0_req = 1'b0;
  endtask

  logic [31:0] rv;
  int          zero_guard;
  int          deny_guard;

  initial begin
    c0_req = 0; c0_we = 0; c0_addr = 0; c0_wdata = 0;
    c1_req = 0; c1_we = 0; c1_addr = 0; c1_wdata = 0;
    d_req = 0;  d_we = 0;  d_addr = 0;  d_wdata = 0;
    tag_we = 0; tag_page = 0; tag_rep = 0; tag_algo = 0; tag_pset = 0;
    tag_secret = 0; tag_valid = 0; tag_check_req = 0; tag_check_page = 0;
    zeroize_req = 0;
    ecc_inject_en = 0; ecc_inject_idx = 0; ecc_inject_mask = '0;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // ------------------------------------------------------------------
    // read/write fidelity on compute port 0 (auto page tagging on first write)
    // ------------------------------------------------------------------
    port0_write(16'h0010, 32'hDEAD_BEEF);
    port0_write(16'h0100, 32'h1234_5678);
    port0_read(16'h0010, rv);
    chk(rv, 32'hDEAD_BEEF, "port0 readback at 0x0010");
    port0_read(16'h0100, rv);
    chk(rv, 32'h1234_5678, "port0 readback at 0x0100");

    port0_write(16'h0010, 32'h0000_0001);
    port0_read(16'h0010, rv);
    chk(rv, 32'h0000_0001, "port0 overwrite");

    // ------------------------------------------------------------------
    // continuous back-to-back reads: the response must belong to the request
    // that produced it (no stale previous-address data) - F09 regression
    // ------------------------------------------------------------------
    port0_write(16'h0011, 32'hAAAA_AAAA);
    port0_write(16'h0012, 32'hBBBB_BBBB);
    @(negedge clk);
    c0_req = 1'b1; c0_we = 1'b0; c0_addr = 16'h0011;
    // hold req and change the address every cycle
    @(negedge clk); c0_addr = 16'h0012;
    deny_guard = 0;
    while (!c0_ready && deny_guard < 20) begin @(negedge clk); deny_guard++; end
    chk(c0_rdata, 32'hAAAA_AAAA, "response bound to the accepted request (0x0011)");
    @(negedge clk);
    c0_req = 1'b0;
    @(negedge clk);
    @(negedge clk);

    // Competing held requests each receive exactly their own response.
    begin bit got0,got1,gotd; int cycles;
      got0=0;got1=0;gotd=0;cycles=0;
      c0_req=1;c0_we=0;c0_addr=16'h0010;
      c1_req=1;c1_we=0;c1_addr=16'h0100;
      d_req=1;d_we=0;d_addr=16'h0012;
      while(!(got0&&got1&&gotd) && cycles<10) begin
        @(negedge clk);cycles++;
        if(c0_ready) begin chk(c0_rdata,1,"round-robin c0 ownership");got0=1;c0_req=0;end
        if(c1_ready) begin chk(c1_rdata,32'h12345678,"round-robin c1 ownership");got1=1;c1_req=0;end
        if(d_ready) begin chk(d_rdata,32'hbbbbbbbb,"round-robin DMA ownership");gotd=1;d_req=0;end
      end
      if(!(got0&&got1&&gotd)) $fatal(1,"arbiter starved a client");
    end
    repeat(2) @(negedge clk);
    c0_req=1;c0_we=0;c0_addr=16'h0013;
    repeat(3) @(negedge clk);
    chk(c0_ready,0,"unwritten neighbour must not be exposed");
    chk(access_denied,1,"per-word validity denies unwritten neighbour");
    c0_req=0;@(negedge clk);
    port0_write(16'd16383,32'h87654321);
    port0_read(16'd16383,rv);
    chk(rv,32'h87654321,"64 KiB last word exists");

    // ------------------------------------------------------------------
    // page tag gating: an untouched page is never readable
    // ------------------------------------------------------------------
    @(negedge clk);
    tag_we = 1'b1; tag_page = 8'h01; tag_rep = 4'h2; tag_algo = 4'h0;
    tag_pset = 4'h2; tag_secret = 1'b1; tag_valid = 1'b1;
    @(negedge clk);
    tag_we = 1'b0;
    @(negedge clk);

    tag_check_page = 8'h01;
    @(negedge clk);
    chk(tag_check_ok, 32'h1, "tag valid for programmed page");

    tag_check_page = 8'h02;   // never programmed
    @(negedge clk);
    chk(tag_check_ok, 32'h0, "tag invalid for unprogrammed page");

    // denied read on the untouched page: no ready, access_denied asserted
    @(negedge clk);
    c0_req = 1'b1; c0_we = 1'b0; c0_addr = 16'h0230;   // page 2, untouched
    @(negedge clk);
    @(negedge clk);
    chk(c0_ready, 32'h0, "denied read does not assert ready");
    chk(access_denied, 32'h1, "denied read raises access_denied");
    c0_req = 1'b0;
    @(negedge clk);

    // ------------------------------------------------------------------
    // SECDED: inject a single-bit error and confirm DED + corrected read
    // ------------------------------------------------------------------
    port0_write(16'h0010, 32'h0000_0001);
    @(negedge clk);
    // flip one stored code-word bit (code position 3 carries data bit 1)
    ecc_inject_en = 1'b1; ecc_inject_idx = 16'h0010; ecc_inject_mask = 39'h1 << 2;
    @(negedge clk);
    ecc_inject_en = 1'b0; ecc_inject_mask = '0;
    @(negedge clk);
    port0_read(16'h0010, rv);
    // ded/ued are registered with the read data: sample them in the same cycle
    chk(rv, 32'h0000_0001,
        "single-bit error corrected by SECDED (data bit recovered)");
    chk(saved_ded, 32'h1, "SECDED reports a single-bit (DED) error");
    @(negedge clk);

    // double-bit error: not correctable, must be flagged as UED.
    // rewrite first: the correction above is read-path only, so the stored code
    // word must be regenerated before a fresh injection.
    port0_write(16'h0010, 32'h0000_0001);
    @(negedge clk);
    ecc_inject_en = 1'b1; ecc_inject_idx = 16'h0010;
    ecc_inject_mask = (39'h1 << 1) | (39'h1 << 20);
    @(negedge clk);
    ecc_inject_en = 1'b0; ecc_inject_mask = '0;
    @(negedge clk);
    port0_read(16'h0010, rv);
    chk(saved_ued, 32'h1, "SECDED reports a double-bit (UED) error");
    chk(saved_ded, 32'h0, "double-bit error is not reported as DED");
    @(negedge clk);

    // ------------------------------------------------------------------
    // independent bounded zeroize clears the whole array and blocks reads
    // ------------------------------------------------------------------
    @(negedge clk);
    zeroize_req = 1'b1;
    @(negedge clk);
    // during zeroize a read must not be served
    c0_req = 1'b1; c0_we = 1'b0; c0_addr = 16'h0010;
    @(negedge clk);
    @(negedge clk);
    chk(c0_ready, 32'h0, "read is refused while zeroize is active");
    c0_req = 1'b0;
    zeroize_req = 1'b0;
    zero_guard = 0;
    while (!zeroize_done && zero_guard < 4000000) begin @(negedge clk); zero_guard++; end
    if (zero_guard >= 4000000) begin
      $display("FAIL: zeroize did not complete");
      errors++;
    end
    @(negedge clk);
    chk(dut.secded_data(dut.u_store.mem[16'h0010]), 32'h0, "zeroize cleared word 0x0010");
    chk(dut.secded_data(dut.u_store.mem[16'h0100]), 32'h0, "zeroize cleared word 0x0100");

    // Populate a marker in every physical page, then invalidate every tag.
    // Invalid metadata-only pages must not alias valid physical pages.
    begin
      logic [16383:0] expected_valid;
      expected_valid='0;
      for(int p=0;p<64;p++) begin
        port0_write(16'(p*256),32'h12340000+32'(p));
        expected_valid[p*256]=1'b1;
      end
      if(dut.word_valid!==expected_valid) $fatal(1,"word validity publication mismatch");
      for(int n=0;n<96;n++) begin
        int pg;pg=n<32 ? 64+n : ((n-32)*17)%64;
        @(negedge clk);tag_we=1;tag_valid=0;tag_page=8'(pg);
        @(negedge clk);tag_we=0;
        // Independent per-word reference, retaining explicit capacity guard.
        for(int w=0;w<256;w++) if(pg*256+w<16384) expected_valid[pg*256+w]=0;
        #1;if(dut.word_valid!==expected_valid) $fatal(1,"page invalidation mismatch pg=%0d",pg);
      end
    end
    #40;
    if (errors == 0) $display("UT_pqc_secure_sram_ctrl: PASS (errors=0)");
    else             $display("UT_pqc_secure_sram_ctrl: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #4_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_secure_sram_ctrl: FAIL (errors=1)");
    $finish;
  end

endmodule