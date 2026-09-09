// harness.sv - APB CDC Bridge UVM 顶层（双时钟域）
// 例化 DUT + 两个 apb_if（上游 Requester 侧 / 下游 Completer 侧）
// 时钟生成：s_pclk / m_pclk 独立，支持频率比/相位/暂停（由 test 配置）
module harness #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int CDC_IMPL   = 0,
  parameter int SYNC_STAGES = 2
) (
  input logic tb_s_pclk,
  input logic tb_m_pclk
);

  // ---------------------------------------------------------------------------
  // 复位（async assert / sync deassert 由 tb 顶层时钟域控制）
  // ---------------------------------------------------------------------------
  logic s_presetn, m_presetn;
  logic s_psel, s_penable, s_pwrite;
  logic [ADDR_WIDTH-1:0] s_paddr;
  logic [DATA_WIDTH-1:0] s_pwdata, s_prdata;
  logic [DATA_WIDTH/8-1:0] s_pstrb;
  logic [2:0] s_pprot;
  logic s_pready, s_pslverr;

  logic m_psel, m_penable, m_pwrite;
  logic [ADDR_WIDTH-1:0] m_paddr;
  logic [DATA_WIDTH-1:0] m_pwdata, m_prdata;
  logic [DATA_WIDTH/8-1:0] m_pstrb;
  logic [2:0] m_pprot;
  logic m_pready, m_pslverr;

  // ---------------------------------------------------------------------------
  // APB 接口实例（上游 Requester / 下游 Completer）
  // ---------------------------------------------------------------------------
  apb_if #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .HAS_PSTRB  (1),
    .HAS_PPROT  (1)
  ) s_apb (
    .pclk     (tb_s_pclk),
    .presetn  (s_presetn),
    .check_enable (1'b0)
  );

  apb_if #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .HAS_PSTRB  (1),
    .HAS_PPROT  (1)
  ) m_apb (
    .pclk     (tb_m_pclk),
    .presetn  (m_presetn),
    .check_enable (1'b0)
  );

  // ---------------------------------------------------------------------------
  // DUT 例化
  // ---------------------------------------------------------------------------
  apb_cdc_bridge_top #(
    .ADDR_WIDTH  (ADDR_WIDTH),
    .DATA_WIDTH  (DATA_WIDTH),
    .CDC_IMPL    (CDC_IMPL),
    .SYNC_STAGES (SYNC_STAGES),
    .APB_PROFILE (1)   // APB4（含 PSTRB/PPROT）
  ) u_dut (
    .s_pclk    (tb_s_pclk),
    .s_presetn (s_presetn),
    .s_psel    (s_psel),
    .s_penable (s_penable),
    .s_paddr   (s_paddr),
    .s_pwrite  (s_pwrite),
    .s_pwdata  (s_pwdata),
    .s_pstrb   (s_pstrb),
    .s_pprot   (s_pprot),
    .s_prdata  (s_prdata),
    .s_pready  (s_pready),
    .s_pslverr (s_pslverr),
    .m_pclk    (tb_m_pclk),
    .m_presetn (m_presetn),
    .m_psel    (m_psel),
    .m_penable (m_penable),
    .m_paddr   (m_paddr),
    .m_pwrite  (m_pwrite),
    .m_pwdata  (m_pwdata),
    .m_pstrb   (m_pstrb),
    .m_pprot   (m_pprot),
    .m_prdata  (m_prdata),
    .m_pready  (m_pready),
    .m_pslverr (m_pslverr)
  );

  // ---------------------------------------------------------------------------
  // 接口 <-> 顶层连线（DUT 上游 = slave 视角；VIP 上游 agent 为 master 驱动）
  // 注意：VIP apb_if 的 psel/penable 等为双向驱动线；DUT 是 slave，故上游
  // agent（master）驱动 s_apb，DUT 采样并返回。下游 DUT 是 master，VIP slave
  // agent 驱动 m_apb 响应。
  // 通过 assign 将 apb_if 信号与 DUT 端口连接。
  // ---------------------------------------------------------------------------

  // 上游：VIP master agent 驱动 s_apb.paddr/pwrite/pwdata/pstrb/pprot/psel/penable
  //       DUT 返回 s_prdata/s_pready/s_pslverr
  assign s_psel         = s_apb.psel[0];
  assign s_penable      = s_apb.penable;
  assign s_paddr        = s_apb.paddr;
  assign s_pwrite       = s_apb.pwrite;
  assign s_pwdata       = s_apb.pwdata;
  assign s_pstrb        = s_apb.pstrb_w;
  assign s_pprot        = s_apb.pprot_w;
  assign s_apb.prdata   = s_prdata;
  assign s_apb.pready   = s_pready;
  assign s_apb.pslverr  = s_pslverr;

  // 下游：DUT 驱动 m_apb 输出，VIP slave agent 采样并响应
  assign m_apb.psel[0]  = m_psel;
  assign m_apb.penable  = m_penable;
  assign m_apb.paddr    = m_paddr;
  assign m_apb.pwrite   = m_pwrite;
  assign m_apb.pwdata   = m_pwdata;
  assign m_apb.pstrb_w  = m_pstrb;
  assign m_apb.pprot_w  = m_pprot;
  assign m_prdata       = m_apb.prdata;
  assign m_pready       = m_apb.pready;
  assign m_pslverr      = m_apb.pslverr;

endmodule : harness
