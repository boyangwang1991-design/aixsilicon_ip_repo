// =============================================================================
// ut_handshake.sv - apb_cdc_handshake 模块级 UT 自检（双时钟域）
// 验证：请求握手往返（req push -> dest valid -> ack -> ready 释放）、
//       响应握手往返（rsp push -> src valid）、payload 保真
// 等待纪律：一律内联 `wait (sig == 1'b1)` 事件语句（避免 task 值传递假挂死）
// 挂死保护：run_ut.sh 的 `timeout` 兜底
// =============================================================================
`timescale 1ns/1ps

module ut_handshake;

  localparam int ADDR_W = 8;
  localparam int DATA_W = 32;

  logic s_clk, m_clk;
  logic s_rst_n, m_rst_n;

  // req 通道（源）
  logic                     s_req_push;
  logic [ADDR_W-1:0]        s_req_addr;
  logic                     s_req_write;
  logic [DATA_W-1:0]        s_req_wdata;
  logic [DATA_W/8-1:0]      s_req_strb;
  logic [2:0]               s_req_prot;
  logic                     s_req_ready;
  // rsp 通道（源）
  logic                     s_rsp_valid;
  logic [DATA_W-1:0]        s_rsp_rdata;
  logic                     s_rsp_slverr;
  // req 通道（目的）
  logic                     m_req_valid;
  logic [ADDR_W-1:0]        m_req_addr;
  logic                     m_req_write;
  logic [DATA_W-1:0]        m_req_wdata;
  logic [DATA_W/8-1:0]      m_req_strb;
  logic [2:0]               m_req_prot;
  logic                     m_req_ack;
  // rsp 通道（目的）
  logic                     m_rsp_push;
  logic [DATA_W-1:0]        m_rsp_rdata;
  logic                     m_rsp_slverr;
  logic                     m_rsp_ready;

  apb_cdc_handshake #(
    .ADDR_WIDTH (ADDR_W),
    .DATA_WIDTH (DATA_W),
    .SYNC_STAGES(2),
    .APB_PROFILE(1)
  ) dut (
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

  int errors = 0;

  // 时钟（源 10ns，目的 20ns -> 异步）
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
    s_req_addr = 0; s_req_write = 0; s_req_wdata = 0;
    s_req_strb = 0; s_req_prot = 0;
    m_rsp_rdata = 0; m_rsp_slverr = 0;
    m_req_ack = 0;
    repeat (3) @(posedge s_clk); #1;
    repeat (3) @(posedge m_clk); #1;
    s_rst_n = 1'b1; m_rst_n = 1'b1;
    @(posedge s_clk); #1;

    // --- 场景 1: 请求握手（写）---
    @(posedge s_clk); #1;
    s_req_push = 1'b1;
    s_req_addr = 8'h2A;
    s_req_write = 1'b1;
    s_req_wdata = 32'hDEAD_BEEF;
    s_req_strb = 4'hF;
    s_req_prot = 3'b010;
    @(posedge s_clk); #1;
    s_req_push = 1'b0;

    // 等待目的域 valid
    wait (m_req_valid == 1'b1);
    #1;
    chk(m_req_valid, 1'b1, "dest sees req valid");
    chk(m_req_addr, 8'h2A, "dest req addr");
    chk(m_req_write, 1'b1, "dest req write");
    chk(m_req_wdata, 32'hDEAD_BEEF, "dest req wdata");
    chk(m_req_strb, 4'hF, "dest req strb");

    // 目的域 ack（沿后设置）
    @(posedge m_clk); #1;
    m_req_ack = 1'b1;
    @(posedge m_clk); #1;
    m_req_ack = 1'b0;

    // 源域 ready 应被释放
    wait (s_req_ready == 1'b1);
    #1;
    chk(s_req_ready, 1'b1, "src req ready released after ack");

    // --- 场景 2: 响应握手 ---
    @(posedge m_clk); #1;
    m_rsp_push = 1'b1;
    m_rsp_rdata = 32'h1234_5678;
    m_rsp_slverr = 1'b0;
    @(posedge m_clk); #1;
    m_rsp_push = 1'b0;

    // 源域应收到响应
    wait (s_rsp_valid == 1'b1);
    #1;
    chk(s_rsp_valid, 1'b1, "src sees rsp valid");
    chk(s_rsp_rdata, 32'h1234_5678, "src rsp rdata");

    // 目的域 rsp_ready 释放（ack 回）
    wait (m_rsp_ready == 1'b1);
    #1;
    chk(m_rsp_ready, 1'b1, "dest rsp ready released");

    // --- 场景 3: 第二个请求 + PSLVERR 传播 ---
    @(posedge s_clk); #1;
    s_req_push = 1'b1;
    s_req_addr = 8'h10;
    s_req_write = 1'b0;   // read
    @(posedge s_clk); #1;
    s_req_push = 1'b0;

    wait (m_req_valid == 1'b1);
    #1;
    @(posedge m_clk); #1; m_req_ack = 1'b1;
    @(posedge m_clk); #1; m_req_ack = 1'b0;

    @(posedge m_clk); #1;
    m_rsp_push = 1'b1;
    m_rsp_rdata = 32'h0;
    m_rsp_slverr = 1'b1;  // error
    @(posedge m_clk); #1;
    m_rsp_push = 1'b0;

    wait (s_rsp_valid == 1'b1);
    #1;
    chk(s_rsp_slverr, 1'b1, "src sees pslverr");

    #50;
    if (errors == 0) $display("UT_HANDSHAKE: PASS (errors=0)");
    else             $display("UT_HANDSHAKE: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
