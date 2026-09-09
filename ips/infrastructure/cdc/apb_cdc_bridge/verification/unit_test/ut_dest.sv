// =============================================================================
// ut_dest.sv - apb_cdc_dest 模块级 UT 自检
// 验证：IDLE->SETUP->ACCESS->COMPLETE 状态流、wait-state 输出稳定、响应发起
// =============================================================================
`timescale 1ns/1ps

module ut_dest;

  localparam int ADDR_W = 8;
  localparam int DATA_W = 32;

  logic m_pclk, m_presetn;
  logic m_psel, m_penable, m_pwrite;
  logic [ADDR_W-1:0] m_paddr;
  logic [DATA_W-1:0] m_pwdata, m_prdata;
  logic [DATA_W/8-1:0] m_pstrb;
  logic [2:0] m_pprot;
  logic m_pready, m_pslverr;

  logic m_req_valid;
  logic [ADDR_W-1:0] m_req_addr;
  logic m_req_write;
  logic [DATA_W-1:0] m_req_wdata;
  logic [DATA_W/8-1:0] m_req_strb;
  logic [2:0] m_req_prot;
  logic m_req_ack;
  logic m_rsp_push;
  logic [DATA_W-1:0] m_rsp_rdata;
  logic m_rsp_slverr;
  logic m_rsp_ready;

  apb_cdc_dest #(
    .ADDR_WIDTH (ADDR_W),
    .DATA_WIDTH (DATA_W),
    .APB_PROFILE(1)
  ) dut (
    .m_pclk(m_pclk), .m_presetn(m_presetn),
    .m_psel(m_psel), .m_penable(m_penable), .m_paddr(m_paddr),
    .m_pwrite(m_pwrite), .m_pwdata(m_pwdata), .m_pstrb(m_pstrb), .m_pprot(m_pprot),
    .m_prdata(m_prdata), .m_pready(m_pready), .m_pslverr(m_pslverr),
    .m_req_valid(m_req_valid), .m_req_addr(m_req_addr), .m_req_write(m_req_write),
    .m_req_wdata(m_req_wdata), .m_req_strb(m_req_strb), .m_req_prot(m_req_prot),
    .m_req_ack(m_req_ack),
    .m_rsp_push(m_rsp_push), .m_rsp_rdata(m_rsp_rdata), .m_rsp_slverr(m_rsp_slverr),
    .m_rsp_ready(m_rsp_ready)
  );

  int errors = 0;

  initial begin m_pclk = 1'b0; forever #5ns m_pclk = ~m_pclk; end

  task automatic chk(logic [31:0] a, logic [31:0] b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b);
      errors++;
    end
  endtask

  task automatic wait_sig(string name, input logic c, input int limit_ns);
    fork
      begin wait (c == 1'b1); end
      begin #(limit_ns * 1ns); $display("TIMEOUT wait %s", name); end
    join_any
    disable fork;
  endtask

  initial begin
    // 复位
    m_presetn = 1'b0;
    m_req_valid = 0; m_req_addr = 0; m_req_write = 0; m_req_wdata = 0;
    m_req_strb = 0; m_req_prot = 0;
    m_prdata = 0; m_pready = 0; m_pslverr = 0;
    m_rsp_ready = 1'b1;
    repeat (3) @(posedge m_pclk);
    m_presetn = 1'b1;
    @(posedge m_pclk); #1;

    // 复位后 IDLE：psel=0, penable=0
    chk(m_psel, 1'b0, "reset: psel=0");
    chk(m_penable, 1'b0, "reset: penable=0");

    // --- 场景 1: 写事务（2 wait-state）---
    m_req_valid = 1'b1;
    m_req_addr = 8'h2A; m_req_write = 1'b1; m_req_wdata = 32'hDEAD_BEEF;
    m_req_strb = 4'hF; m_req_prot = 3'b010;
    @(posedge m_pclk); #1;

    // SETUP 阶段：psel=1, penable=0
    chk(m_psel, 1'b1, "SETUP: psel=1");
    chk(m_penable, 1'b0, "SETUP: penable=0");
    chk(m_paddr, 8'h2A, "SETUP: addr");
    @(posedge m_pclk); #1;

    // ACCESS 阶段：penable=1, wait pready
    chk(m_penable, 1'b1, "ACCESS: penable=1");
    m_pready = 1'b0;
    @(posedge m_pclk); #1;
    chk(m_paddr, 8'h2A, "ACCESS: addr stable");
    chk(m_pwdata, 32'hDEAD_BEEF, "ACCESS: wdata stable");
    m_pready = 1'b1;
    m_prdata = 32'h0;
    @(posedge m_pclk); #1;

    // COMPLETE: rsp push
    chk(m_rsp_push, 1'b1, "COMPLETE: rsp push");
    chk(m_rsp_slverr, 1'b0, "COMPLETE: no error");
    @(posedge m_pclk); #1;
    chk(m_psel, 1'b0, "back to IDLE: psel=0");

    // --- 场景 2: 读 + PSLVERR ---
    m_req_valid = 1'b1;
    m_req_addr = 8'h10; m_req_write = 1'b0;
    @(posedge m_pclk); #1;
    @(posedge m_pclk); #1;
    m_pready = 1'b1;
    m_prdata = 32'h1234_5678;
    m_pslverr = 1'b1;
    @(posedge m_pclk); #1;
    chk(m_rsp_push, 1'b1, "read COMPLETE: rsp push");
    chk(m_rsp_rdata, 32'h1234_5678, "read data captured");
    chk(m_rsp_slverr, 1'b1, "read slverr captured");

    #30;
    if (errors == 0) $display("UT_DEST: PASS (errors=0)");
    else             $display("UT_DEST: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
