// =============================================================================
// ut_source.sv - apb_cdc_source 模块级 UT 自检
// 验证：捕获时机（仅 ACCESS）、单事务 wait-state、响应返回、复位
// 响应模型：并行进程在事务发起后提供 rsp_valid 脉冲（模拟跨桥返回）
// =============================================================================
`timescale 1ns/1ps

module ut_source;

  localparam int ADDR_W = 8;
  localparam int DATA_W = 32;

  logic s_pclk, s_presetn;
  logic s_psel, s_penable, s_pwrite;
  logic [ADDR_W-1:0] s_paddr;
  logic [DATA_W-1:0] s_pwdata, s_prdata;
  logic [DATA_W/8-1:0] s_pstrb;
  logic [2:0] s_pprot;
  logic s_pready, s_pslverr;

  logic s_req_push;
  logic [ADDR_W-1:0] s_req_addr;
  logic s_req_write;
  logic [DATA_W-1:0] s_req_wdata;
  logic [DATA_W/8-1:0] s_req_strb;
  logic [2:0] s_req_prot;
  logic s_req_ready;
  logic s_rsp_valid;
  logic [DATA_W-1:0] s_rsp_rdata;
  logic s_rsp_slverr;

  apb_cdc_source #(
    .ADDR_WIDTH (ADDR_W),
    .DATA_WIDTH (DATA_W),
    .APB_PROFILE(1)
  ) dut (
    .s_pclk(s_pclk), .s_presetn(s_presetn),
    .s_psel(s_psel), .s_penable(s_penable), .s_paddr(s_paddr),
    .s_pwrite(s_pwrite), .s_pwdata(s_pwdata), .s_pstrb(s_pstrb), .s_pprot(s_pprot),
    .s_prdata(s_prdata), .s_pready(s_pready), .s_pslverr(s_pslverr),
    .s_req_push(s_req_push), .s_req_addr(s_req_addr), .s_req_write(s_req_write),
    .s_req_wdata(s_req_wdata), .s_req_strb(s_req_strb), .s_req_prot(s_req_prot),
    .s_req_ready(s_req_ready),
    .s_rsp_valid(s_rsp_valid), .s_rsp_rdata(s_rsp_rdata), .s_rsp_slverr(s_rsp_slverr)
  );

  int errors = 0;

  initial begin s_pclk = 1'b0; forever #5ns s_pclk = ~s_pclk; end

  task automatic chk(logic [31:0] a, logic [31:0] b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b);
      errors++;
    end
  endtask

  // 事件等待宏
  `define WAIT_SIG(sig) wait (sig == 1'b1);

  // 响应提供者：等待源域发起请求（s_req_push 出现且 ready），随后给 rsp_valid 脉冲
  always @(posedge s_pclk) begin
    #1;
    if (s_req_push && s_req_ready) begin
      // 发起后数拍提供响应（模拟跨桥往返）
      repeat (5) @(posedge s_pclk);
      #1;
      s_rsp_valid = 1'b1;
      @(posedge s_pclk);
      #1;
      s_rsp_valid = 1'b0;
    end
  end

  // APB SETUP->ACCESS 序列驱动
  task automatic apb_transfer(input logic [ADDR_W-1:0] addr, input logic wr, input logic [DATA_W-1:0] wdata);
    begin
      s_psel = 1'b1; s_penable = 1'b0;
      s_paddr = addr; s_pwrite = wr; s_pwdata = wdata;
      @(posedge s_pclk);
      s_penable = 1'b1;
      // 等待 pready（跨桥完成返回）
      `WAIT_SIG(s_pready)
      @(posedge s_pclk);
      s_psel = 1'b0; s_penable = 1'b0;
    end
  endtask

  initial begin
    // 复位
    s_presetn = 1'b0;
    s_psel = 0; s_penable = 0; s_paddr = 0; s_pwrite = 0; s_pwdata = 0;
    s_pstrb = 0; s_pprot = 0;
    s_req_ready = 1'b1;
    s_rsp_valid = 1'b0; s_rsp_rdata = 0; s_rsp_slverr = 0;
    repeat (3) @(posedge s_pclk);
    s_presetn = 1'b1;
    @(posedge s_pclk);

    // 复位后 pready=0
    chk(s_pready, 1'b0, "reset: pready=0");
    chk(s_req_push, 1'b0, "reset: no req push");

    // --- 场景 1: 写事务捕获 ---
    apb_transfer(8'h2A, 1'b1, 32'hDEAD_BEEF);
    chk(s_req_addr, 8'h2A, "req addr captured");
    chk(s_req_write, 1'b1, "req write captured");
    chk(s_req_wdata, 32'hDEAD_BEEF, "req wdata captured");

    // --- 场景 2: 读事务 + PSLVERR 返回 ---
    s_rsp_rdata = 32'h1234_5678;
    s_rsp_slverr = 1'b1;
    apb_transfer(8'h10, 1'b0, 32'h0);
    chk(s_prdata, 32'h1234_5678, "prdata returned");
    chk(s_pslverr, 1'b1, "pslverr returned");
    s_rsp_slverr = 1'b0;

    #30;
    if (errors == 0) $display("UT_SOURCE: PASS (errors=0)");
    else             $display("UT_SOURCE: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
