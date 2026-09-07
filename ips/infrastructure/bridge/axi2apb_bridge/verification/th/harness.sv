// =============================================================================
// harness.sv - X2P VIP 集成验证顶层
//   - 拓扑：x2p_top 是 AXI slave + APB master
//     · AXI 侧：axi4_if（ID=4/ADDR=32/DATA=64）被 VIP axi4_master_agent 驱动
//     · APB 侧：apb_if（APB4）被 VIP apb_slave_agent 响应（completer/memory）
//   - 复用：aixsilicon:vip:axi4 / aixsilicon:vip:apb（FuseSoC depend，只读引用）
//   - 运行：+UVM_TESTNAME=tc_sanity|tc_burst|tc_timeout
//   超时专项：tc_timeout 需 +X2P_APB_TIMEOUT=1（env 禁用 APB responder）
// =============================================================================

`timescale 1ns/1ps

module harness;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi4_pkg::*;
  import axi4_types_pkg::*;
  import apb_pkg::*;
  import apb_types_pkg::*;

  // ---------------------------------------------------------------------------
  // FSDB（可选：+X2P_FSDB=1 打开，便于 Verdi 观察读写路径）
  // ---------------------------------------------------------------------------
  string fsdb_file;
  initial begin
    if ($test$plusargs("X2P_FSDB")) begin
      if ($value$plusargs("FSDB_FILE=%s", fsdb_file)) ;
      else fsdb_file = "x2p_vip.fsdb";
      $fsdbDumpfile(fsdb_file);
      $fsdbDumpvars(0, harness);
    end
  end

  // ---------------------------------------------------------------------------
  // Clock / Reset（默认 SYNC：pclk 跟随 aclk；+CLOCK_MODE=1 切 ASYNC 125MHz）
  // ---------------------------------------------------------------------------
  logic   aclk;
  logic   aresetn;
  logic   pclk;
  logic   presetn;
  integer SYNC_MODE;

  initial begin
    aclk = 1'b0;
    forever #5ns aclk = ~aclk;          // 100 MHz
  end

  initial begin
    SYNC_MODE = 0;
    if ($value$plusargs("CLOCK_MODE=%d", SYNC_MODE)) ;
    if (SYNC_MODE == 0) begin
      // SYNC：pclk 与 aclk 同源同相（DUT CLOCK_MODE=0，CDC generate-out 旁路）
      pclk = 1'b0;
      forever @(aclk) pclk = aclk;
    end else begin
      // ASYNC：独立 125MHz（经 CDC FIFO 跨域）
      pclk = 1'b0;
      forever #4ns pclk = ~pclk;
    end
  end

  initial begin
    aresetn = 1'b0;
    presetn = 1'b0;
    repeat (10) @(posedge aclk);
    aresetn = 1'b1;
    @(posedge aclk);
    presetn = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // VIP interfaces
  // ---------------------------------------------------------------------------
  axi4_if #(
    .ID_WIDTH     (4),
    .ADDRESS_WIDTH(32),
    .DATA_WIDTH   (64)
  ) u_axi (
    .aclk     (aclk),
    .areset_n (aresetn)
  );

  logic check_enable = 1'b1;
  apb_if #(
    .ADDR_WIDTH (32),
    .DATA_WIDTH (32),
    .HAS_PSTRB  (1'b1),
    .HAS_PPROT  (1'b1),
    .NUM_SLAVES (1)
  ) u_apb (
    .pclk         (pclk),
    .presetn      (presetn),
    .check_enable (check_enable)
  );

  // ---------------------------------------------------------------------------
  // AXI 枚举/结构信号 → 纯 logic 适配线（DUT 输入端口为 logic 向量）
  //   awlen/arlen 是 typedef logic[7:0]（axi4_burst_length），直接兼容，无需适配
  // ---------------------------------------------------------------------------
  logic [2:0] awsize_w;  logic [1:0] awburst_w; logic [2:0] awprot_w;
  logic [2:0] arsize_w;  logic [1:0] arburst_w; logic [2:0] arprot_w;
  assign awsize_w  = u_axi.awsize;
  assign awburst_w = u_axi.awburst;
  assign awprot_w  = u_axi.awprot;
  assign arsize_w  = u_axi.arsize;
  assign arburst_w = u_axi.arburst;
  assign arprot_w  = u_axi.arprot;

  // DUT pstrb/pprot 输出空接（不接入 apb_if，避免与其预置初值冲突）
  logic [3:0] pstrb_dummy;
  logic [2:0] pprot_dummy;

  // ---------------------------------------------------------------------------
  // DUT: X2P（AXI slave → APB master）
  // ---------------------------------------------------------------------------
  x2p_top #(
    .AXI_ADDR_WIDTH   (32),
    .AXI_DATA_WIDTH   (64),
    .AXI_ID_WIDTH     (4),
    .APB_ADDR_WIDTH   (32),
    .APB_DATA_WIDTH   (32),
    .AXI_PROFILE      (1),
    .APB_PROFILE      (1),
    .READ_REQUEST_DEPTH_LOG2 (2),
    .WRITE_REQUEST_DEPTH_LOG2(2),
    .ARB_POLICY       (0),
    .ARB_GRANULARITY  (0),
    .TIMEOUT_ENABLE   (1'b1),
    .TIMEOUT_CYCLES   (256),
    .CLOCK_MODE       (0),
    .CDC_REQ_DEPTH_LOG2 (2),
    .CDC_RSP_DEPTH_LOG2 (2),
    .AXI_INPUT_REG    (1'b0),
    .AXI_OUTPUT_REG   (1'b0),
    .APB_OUTPUT_REG   (1'b0)
  ) u_dut (
    .aclk     (aclk),
    .aresetn  (aresetn),
    .pclk     (pclk),
    .presetn  (presetn),
    // AW
    .awvalid  (u_axi.awvalid),   .awready (u_axi.awready),
    .awid     (u_axi.awid),      .awaddr  (u_axi.awaddr),
    .awlen    (u_axi.awlen),     .awsize  (awsize_w),
    .awburst  (awburst_w),       .awprot  (awprot_w),
    // W
    .wvalid   (u_axi.wvalid),    .wready  (u_axi.wready),
    .wdata    (u_axi.wdata),     .wstrb   (u_axi.wstrb),
    .wlast    (u_axi.wlast),
    // B
    .bvalid   (u_axi.bvalid),    .bresp   (u_axi.bresp),
    .bid      (u_axi.bid),       .bready  (u_axi.bready),
    // AR
    .arvalid  (u_axi.arvalid),   .arready (u_axi.arready),
    .arid     (u_axi.arid),      .araddr  (u_axi.araddr),
    .arlen    (u_axi.arlen),     .arsize  (arsize_w),
    .arburst  (arburst_w),       .arprot  (arprot_w),
    // R
    .rvalid   (u_axi.rvalid),    .rready  (u_axi.rready),
    .rdata    (u_axi.rdata),     .rresp   (u_axi.rresp),
    .rid      (u_axi.rid),       .rlast   (u_axi.rlast),
    // APB Master（DUT 驱动 psel/penable/paddr/pwrite/pwdata；prdata/pready/pslverr 由
    // VIP completer 驱动）。注：apb_if 预置复位初值的变量不允许被结构驱动，故
    // pstrb/pprot 不接入 apb_if（completer 全字读写，不需要 strb/prot 语义）。
    .paddr    (u_apb.paddr),
    .psel     (u_apb.psel[0]),
    .penable  (u_apb.penable),
    .pwrite   (u_apb.pwrite),
    .pwdata   (u_apb.pwdata),
    .pstrb    (pstrb_dummy),
    .pprot    (pprot_dummy),
    .prdata   (u_apb.prdata),
    .pready   (u_apb.pready),
    .pslverr  (u_apb.pslverr)
  );

  // ---------------------------------------------------------------------------
  // config_db 注入 + UVM 启动
  // ---------------------------------------------------------------------------
  initial begin
    // 超时专项（+X2P_APB_TIMEOUT）：保持 APB slave agent active，用 suppress_pready
    // 抑制 completer 的 completion 拍 PREADY（恒低）→ DUT APB 引擎挂起 → 内部超时。
    // 若 APB agent 被禁用，P3 修复后必选信号（pready）纯声明无驱动 → X → 永不超时。
    if ($test$plusargs("X2P_APB_TIMEOUT")) begin
      u_apb.suppress_pready = 1'b1;
      // 超时恢复是 DUT 主动放弃挂起事务的协议异常路径：超时后 psel/paddr 切换
      // 不满足 SVA RUL-003"wait 期请求字段稳定"的正常协议语义，属预期行为 →
      // 关闭 SVA（VIP runtime 门 sva_enable，见 apb_if.sv），避免误报。
      u_apb.sva_enable = 1'b0;
    end
    uvm_config_db#(virtual axi4_if)::set(null, "*", "axi_vif", u_axi);
    uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", u_apb);
    run_test();
  end

  // 全局 watchdog（防挂死）
  initial begin
    #20ms;
    `uvm_fatal("TB", "Global watchdog timeout (20ms)")
  end

endmodule : harness
