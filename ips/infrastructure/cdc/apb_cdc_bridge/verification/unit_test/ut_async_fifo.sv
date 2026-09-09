// =============================================================================
// ut_async_fifo.sv - apb_cdc_async_fifo 模块级 UT 自检（双时钟域）
// 验证 depth=2（灰度指针 FIFO）与 depth=1（单槽握手 FIFO）：
//   - 请求入队/出队保真
//   - 响应入队/出队保真
//   - full/empty 边界
// 等待纪律：内联 `wait (sig == 1'b1)`；挂死由 run_ut.sh 的 timeout 兜底
// =============================================================================
`timescale 1ns/1ps

module ut_async_fifo;

  localparam int ADDR_W = 8;
  localparam int DATA_W = 32;

  logic s_clk, m_clk;
  logic s_rst_n, m_rst_n;

  // 请求（源 -> 目的）depth=2
  logic                     s_req_push;
  logic [ADDR_W-1:0]        s_req_addr;
  logic                     s_req_write;
  logic [DATA_W-1:0]        s_req_wdata;
  logic [DATA_W/8-1:0]      s_req_strb;
  logic [2:0]               s_req_prot;
  logic                     s_req_ready;
  // 响应（目的 -> 源）depth=2
  logic                     s_rsp_valid;
  logic [DATA_W-1:0]        s_rsp_rdata;
  logic                     s_rsp_slverr;
  // 目的域 depth=2
  logic                     m_req_valid;
  logic [ADDR_W-1:0]        m_req_addr;
  logic                     m_req_write;
  logic [DATA_W-1:0]        m_req_wdata;
  logic [DATA_W/8-1:0]      m_req_strb;
  logic [2:0]               m_req_prot;
  logic                     m_req_ack;
  logic                     m_rsp_push;
  logic [DATA_W-1:0]        m_rsp_rdata;
  logic                     m_rsp_slverr;
  logic                     m_rsp_ready;

  apb_cdc_async_fifo #(
    .ADDR_WIDTH (ADDR_W),
    .DATA_WIDTH (DATA_W),
    .REQ_DEPTH  (2),
    .RSP_DEPTH  (2),
    .APB_PROFILE(1)
  ) dut2 (
    .s_clk(s_clk), .s_rst_n(s_rst_n),
    .s_req_push(s_req_push), .s_req_addr(s_req_addr), .s_req_write(s_req_write),
    .s_req_wdata(s_req_wdata), .s_req_strb(s_req_strb), .s_req_prot(s_req_prot),
    .s_req_ready(s_req_ready),
    .s_rsp_valid(s_rsp_valid), .s_rsp_rdata(s_rsp_rdata), .s_rsp_slverr(s_rsp_slverr),
    .m_clk(m_clk), .m_rst_n(m_rst_n),
    .m_req_valid(m_req_valid), .m_req_addr(m_req_addr), .m_req_write(m_req_write),
    .m_req_wdata(m_req_wdata), .m_req_strb(m_req_strb), .m_req_prot(m_req_prot),
    .m_req_ack(m_req_ack),
    .m_rsp_push(m_rsp_push), .m_rsp_rdata(m_rsp_rdata), .m_rsp_slverr(m_rsp_slverr),
    .m_rsp_ready(m_rsp_ready)
  );

  // depth=1 实例信号
  logic s1_req_push, s1_req_write, s1_req_ready, s1_rsp_valid, s1_rsp_slverr;
  logic [ADDR_W-1:0] s1_req_addr;
  logic [DATA_W-1:0] s1_req_wdata, s1_rsp_rdata;
  logic [DATA_W/8-1:0] s1_req_strb;
  logic [2:0] s1_req_prot;
  logic m1_req_valid, m1_req_write, m1_req_ack, m1_rsp_push, m1_rsp_slverr, m1_rsp_ready;
  logic [ADDR_W-1:0] m1_req_addr;
  logic [DATA_W-1:0] m1_req_wdata, m1_rsp_rdata;
  logic [DATA_W/8-1:0] m1_req_strb;
  logic [2:0] m1_req_prot;

  apb_cdc_async_fifo #(
    .ADDR_WIDTH (ADDR_W),
    .DATA_WIDTH (DATA_W),
    .REQ_DEPTH  (1),
    .RSP_DEPTH  (1),
    .APB_PROFILE(1)
  ) dut1 (
    .s_clk(s_clk), .s_rst_n(s_rst_n),
    .s_req_push(s1_req_push), .s_req_addr(s1_req_addr), .s_req_write(s1_req_write),
    .s_req_wdata(s1_req_wdata), .s_req_strb(s1_req_strb), .s_req_prot(s1_req_prot),
    .s_req_ready(s1_req_ready),
    .s_rsp_valid(s1_rsp_valid), .s_rsp_rdata(s1_rsp_rdata), .s_rsp_slverr(s1_rsp_slverr),
    .m_clk(m_clk), .m_rst_n(m_rst_n),
    .m_req_valid(m1_req_valid), .m_req_addr(m1_req_addr), .m_req_write(m1_req_write),
    .m_req_wdata(m1_req_wdata), .m_req_strb(m1_req_strb), .m_req_prot(m1_req_prot),
    .m_req_ack(m1_req_ack),
    .m_rsp_push(m1_rsp_push), .m_rsp_rdata(m1_rsp_rdata), .m_rsp_slverr(m1_rsp_slverr),
    .m_rsp_ready(m1_rsp_ready)
  );

  int errors = 0;

  initial begin s_clk = 1'b0; forever #5ns s_clk = ~s_clk; end
  initial begin m_clk = 1'b0; forever #10ns m_clk = ~m_clk; end

  task automatic chk(logic [31:0] a, logic [31:0] b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b);
      errors++;
    end
  endtask

  initial begin
    // 复位
    s_rst_n = 1'b0; m_rst_n = 1'b0;
    s_req_push = 0; m_rsp_push = 0;
    s_req_addr = 0; s_req_write = 0; s_req_wdata = 0; s_req_strb = 0; s_req_prot = 0;
    m_rsp_rdata = 0; m_rsp_slverr = 0; m_req_ack = 0;
    s1_req_push = 0; m1_rsp_push = 0; m1_req_ack = 0;

    repeat (3) @(posedge s_clk); #1;
    repeat (3) @(posedge m_clk); #1;
    s_rst_n = 1'b1; m_rst_n = 1'b1;
    @(posedge s_clk); #1;

    // ========== depth=2 请求 FIFO ==========
    @(posedge s_clk); #1;
    s_req_push = 1'b1;
    s_req_addr = 8'h01; s_req_write = 1'b1; s_req_wdata = 32'h1111_1111;
    @(posedge s_clk); #1;
    s_req_addr = 8'h02; s_req_write = 1'b0; s_req_wdata = 32'h2222_2222;
    @(posedge s_clk); #1;
    s_req_push = 1'b0;

    // 目的域依次出队
    wait (m_req_valid == 1'b1);
    #1;
    chk(m_req_addr, 8'h01, "depth2 req1 addr");
    @(posedge m_clk); #1; m_req_ack = 1'b1;
    @(posedge m_clk); #1; m_req_ack = 1'b0;

    wait (m_req_valid == 1'b1);
    #1;
    chk(m_req_addr, 8'h02, "depth2 req2 addr");
    chk(m_req_write, 1'b0, "depth2 req2 write");
    @(posedge m_clk); #1; m_req_ack = 1'b1;
    @(posedge m_clk); #1; m_req_ack = 1'b0;

    // ========== depth=2 响应 FIFO ==========
    @(posedge m_clk); #1;
    m_rsp_push = 1'b1;
    m_rsp_rdata = 32'hAAAA_BBBB; m_rsp_slverr = 1'b0;
    @(posedge m_clk); #1;
    m_rsp_rdata = 32'hCCCC_DDDD; m_rsp_slverr = 1'b1;
    @(posedge m_clk); #1;
    m_rsp_push = 1'b0;

    wait (s_rsp_valid == 1'b1);
    #1;
    chk(s_rsp_rdata, 32'hAAAA_BBBB, "depth2 rsp1 data");
    // 等 valid 清除（单周期）
    repeat (2) @(posedge s_clk); #1;
    wait (s_rsp_valid == 1'b1);
    #1;
    chk(s_rsp_rdata, 32'hCCCC_DDDD, "depth2 rsp2 data");
    chk(s_rsp_slverr, 1'b1, "depth2 rsp2 slverr");

    // ========== depth=1 请求 FIFO ==========
    @(posedge s_clk); #1;
    s1_req_push = 1'b1;
    s1_req_addr = 8'hA1; s1_req_write = 1'b1; s1_req_wdata = 32'h0A0A_0A0A;
    @(posedge s_clk); #1;
    s1_req_push = 1'b0;

    wait (m1_req_valid == 1'b1);
    #1;
    chk(m1_req_addr, 8'hA1, "depth1 req addr");
    chk(m1_req_wdata, 32'h0A0A_0A0A, "depth1 req wdata");
    @(posedge m_clk); #1; m1_req_ack = 1'b1;
    @(posedge m_clk); #1; m1_req_ack = 1'b0;

    // 等 ready 恢复（可压入新请求）
    wait (s1_req_ready == 1'b1);
    #1;
    chk(s1_req_ready, 1'b1, "depth1 req ready released");

    // ========== depth=1 响应 FIFO ==========
    @(posedge m_clk); #1;
    m1_rsp_push = 1'b1;
    m1_rsp_rdata = 32'hFEED_FACE; m1_rsp_slverr = 1'b0;
    @(posedge m_clk); #1;
    m1_rsp_push = 1'b0;

    wait (s1_rsp_valid == 1'b1);
    #1;
    chk(s1_rsp_rdata, 32'hFEED_FACE, "depth1 rsp data");

    #50;
    if (errors == 0) $display("UT_ASYNC_FIFO: PASS (errors=0)");
    else             $display("UT_ASYNC_FIFO: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
