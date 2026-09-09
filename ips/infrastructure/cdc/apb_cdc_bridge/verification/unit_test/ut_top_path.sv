// =============================================================================
// ut_top_path.sv - apb_cdc_bridge_top 顶层集成 UT（读/写数据通路）
// 验证：双时钟异步下写事务与读事务经完整 Bridge 通路往返
// 分别例化 CDC_IMPL=0（HANDSHAKE）与 CDC_IMPL=1（ASYNC_FIFO depth=2）
// 等待纪律：内联 `wait (sig == 1'b1)`；挂死由 run_ut.sh 的 timeout 兜底
// =============================================================================
`timescale 1ns/1ps

module ut_top_path;

  localparam int ADDR_W = 8;
  localparam int DATA_W = 32;

  logic s_clk, m_clk;
  logic s_rst_n, m_rst_n;

  // DUT-H（HANDSHAKE）
  logic s_psel_h, s_penable_h, s_pwrite_h, s_pready_h, s_pslverr_h;
  logic [ADDR_W-1:0] s_paddr_h;
  logic [DATA_W-1:0] s_pwdata_h, s_prdata_h;
  logic [DATA_W/8-1:0] s_pstrb_h;
  logic [2:0] s_pprot_h;
  logic m_psel_h, m_penable_h, m_pwrite_h, m_pready_h, m_pslverr_h;
  logic [ADDR_W-1:0] m_paddr_h;
  logic [DATA_W-1:0] m_pwdata_h, m_prdata_h;
  logic [DATA_W/8-1:0] m_pstrb_h;
  logic [2:0] m_pprot_h;

  apb_cdc_bridge_top #(
    .ADDR_WIDTH (ADDR_W), .DATA_WIDTH (DATA_W),
    .CDC_IMPL (0), .SYNC_STAGES (2), .APB_PROFILE (1)
  ) dut_h (
    .s_pclk(s_clk), .s_presetn(s_rst_n),
    .s_psel(s_psel_h), .s_penable(s_penable_h), .s_paddr(s_paddr_h),
    .s_pwrite(s_pwrite_h), .s_pwdata(s_pwdata_h), .s_pstrb(s_pstrb_h), .s_pprot(s_pprot_h),
    .s_prdata(s_prdata_h), .s_pready(s_pready_h), .s_pslverr(s_pslverr_h),
    .m_pclk(m_clk), .m_presetn(m_rst_n),
    .m_psel(m_psel_h), .m_penable(m_penable_h), .m_paddr(m_paddr_h),
    .m_pwrite(m_pwrite_h), .m_pwdata(m_pwdata_h), .m_pstrb(m_pstrb_h), .m_pprot(m_pprot_h),
    .m_prdata(m_prdata_h), .m_pready(m_pready_h), .m_pslverr(m_pslverr_h)
  );

  // DUT-F（ASYNC_FIFO depth=2）
  logic s_psel_f, s_penable_f, s_pwrite_f, s_pready_f, s_pslverr_f;
  logic [ADDR_W-1:0] s_paddr_f;
  logic [DATA_W-1:0] s_pwdata_f, s_prdata_f;
  logic [DATA_W/8-1:0] s_pstrb_f;
  logic [2:0] s_pprot_f;
  logic m_psel_f, m_penable_f, m_pwrite_f, m_pready_f, m_pslverr_f;
  logic [ADDR_W-1:0] m_paddr_f;
  logic [DATA_W-1:0] m_pwdata_f, m_prdata_f;
  logic [DATA_W/8-1:0] m_pstrb_f;
  logic [2:0] m_pprot_f;

  apb_cdc_bridge_top #(
    .ADDR_WIDTH (ADDR_W), .DATA_WIDTH (DATA_W),
    .CDC_IMPL (1), .REQ_DEPTH (2), .RSP_DEPTH (2), .APB_PROFILE (1)
  ) dut_f (
    .s_pclk(s_clk), .s_presetn(s_rst_n),
    .s_psel(s_psel_f), .s_penable(s_penable_f), .s_paddr(s_paddr_f),
    .s_pwrite(s_pwrite_f), .s_pwdata(s_pwdata_f), .s_pstrb(s_pstrb_f), .s_pprot(s_pprot_f),
    .s_prdata(s_prdata_f), .s_pready(s_pready_f), .s_pslverr(s_pslverr_f),
    .m_pclk(m_clk), .m_presetn(m_rst_n),
    .m_psel(m_psel_f), .m_penable(m_penable_f), .m_paddr(m_paddr_f),
    .m_pwrite(m_pwrite_f), .m_pwdata(m_pwdata_f), .m_pstrb(m_pstrb_f), .m_pprot(m_pprot_f),
    .m_prdata(m_prdata_f), .m_pready(m_pready_f), .m_pslverr(m_pslverr_f)
  );

  int errors = 0;

  initial begin s_clk = 1'b0; forever #5ns s_clk = ~s_clk; end
  initial begin m_clk = 1'b0; forever #20ns m_clk = ~m_clk; end  // 1:4 慢快

  task automatic chk(logic [31:0] a, logic [31:0] b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b);
      errors++;
    end
  endtask

  // 完成一次 APB 传输（SETUP->ACCESS，等待 pready 脉冲后一拍采样）
  // pready 是单周期脉冲，wait 返回后立即采样记录
  logic pready_seen_h, pready_seen_f;
  `define DO_TRANSFER(sel, ena, pready, seen) \
    begin \
      @(posedge s_clk); #1; \
      sel = 1'b1; ena = 1'b0; \
      @(posedge s_clk); #1; \
      ena = 1'b1; \
      wait (pready == 1'b1); \
      seen = 1'b1; \
      @(posedge s_clk); #1; \
      sel = 1'b0; ena = 1'b0; \
    end

  initial begin
    // 复位
    s_rst_n = 1'b0; m_rst_n = 1'b0;
    s_psel_h = 0; s_penable_h = 0; s_psel_f = 0; s_penable_f = 0;
    s_paddr_h = 0; s_pwrite_h = 0; s_pwdata_h = 0;
    s_paddr_f = 0; s_pwrite_f = 0; s_pwdata_f = 0;
    repeat (3) @(posedge s_clk); #1;
    repeat (3) @(posedge m_clk); #1;
    s_rst_n = 1'b1; m_rst_n = 1'b1;
    @(posedge s_clk); #1;

    // 目的侧 PREADY 默认 1（零等待）
    m_pready_h = 1'b1; m_pready_f = 1'b1;

    // ===== HANDSHAKE 实现 =====
    // 写事务
    @(posedge s_clk); #1;
    s_paddr_h = 8'h2A; s_pwrite_h = 1'b1; s_pwdata_h = 32'hDEAD_BEEF;
    s_pstrb_h = 4'hF; s_pprot_h = 3'b010;
    pready_seen_h = 1'b0;
    `DO_TRANSFER(s_psel_h, s_penable_h, s_pready_h, pready_seen_h)
    chk(pready_seen_h, 1'b1, "HS: write completed (pready seen)");

    // 读事务（目的侧返回数据）
    @(posedge s_clk); #1;
    m_prdata_h = 32'h1234_5678; m_pslverr_h = 1'b0;
    s_paddr_h = 8'h10; s_pwrite_h = 1'b0; s_pwdata_h = 32'h0;
    pready_seen_h = 1'b0;
    `DO_TRANSFER(s_psel_h, s_penable_h, s_pready_h, pready_seen_h)
    chk(s_prdata_h, 32'h1234_5678, "HS: read data returned");

    // ===== ASYNC_FIFO 实现 =====
    // 写事务
    @(posedge s_clk); #1;
    s_paddr_f = 8'h3B; s_pwrite_f = 1'b1; s_pwdata_f = 32'h0F0F_0F0F;
    pready_seen_f = 1'b0;
    `DO_TRANSFER(s_psel_f, s_penable_f, s_pready_f, pready_seen_f)
    chk(pready_seen_f, 1'b1, "FIFO: write completed (pready seen)");

    // 读事务 + PSLVERR
    @(posedge s_clk); #1;
    m_prdata_f = 32'hABCD_EF01; m_pslverr_f = 1'b1;
    s_paddr_f = 8'h20; s_pwrite_f = 1'b0; s_pwdata_f = 32'h0;
    pready_seen_f = 1'b0;
    `DO_TRANSFER(s_psel_f, s_penable_f, s_pready_f, pready_seen_f)
    chk(s_prdata_f, 32'hABCD_EF01, "FIFO: read data returned");
    chk(s_pslverr_f, 1'b1, "FIFO: slverr returned");

    #50;
    if (errors == 0) $display("UT_TOP_PATH: PASS (errors=0)");
    else             $display("UT_TOP_PATH: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
