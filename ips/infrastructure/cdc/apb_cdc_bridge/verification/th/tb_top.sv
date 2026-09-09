// tb_top.sv - APB CDC Bridge UVM testbench 顶层
// 双时钟（s_pclk 10ns / m_pclk 20ns 异步）+ 独立复位 + DUT + 两个 apb_if
// 例化 harness 连接 DUT；向 UVM 提供 virtual interface
module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // 时钟（支持 plusarg 控制周期，供 clock_relation 回归矩阵覆盖 1:1/1:2/1:4/1:8/2:1/4:1/8:1）
  // 默认 s=10ns / m=20ns（异步 1:2）；回归用 +S_PERIOD_PS=.. +M_PERIOD_PS=.. 覆盖各关系
  logic s_pclk, m_pclk;
  int s_period_half, m_period_half;
  initial begin
    s_period_half = $value$plusargs("S_PERIOD_PS=%d", s_period_half) ? s_period_half/2 : 5000;
    s_pclk = 1'b0;
    forever #(s_period_half * 1ps) s_pclk = ~s_pclk;
  end
  initial begin
    m_period_half = $value$plusargs("M_PERIOD_PS=%d", m_period_half) ? m_period_half/2 : 10000;
    m_pclk = 1'b0;
    forever #(m_period_half * 1ps) m_pclk = ~m_pclk;
  end

  // 复位（源/目的独立，async assert / sync deassert）
  logic s_presetn, m_presetn;
  initial begin
    s_presetn = 1'b0;
    m_presetn = 1'b0;
    repeat (5) @(posedge s_pclk);
    s_presetn = 1'b1;
    repeat (5) @(posedge m_pclk);
    m_presetn = 1'b1;
  end

  // DUT 信号
  logic s_psel, s_penable, s_pwrite, s_pready, s_pslverr;
  logic [31:0] s_paddr, s_pwdata, s_prdata;
  logic [3:0] s_pstrb;
  logic [2:0] s_pprot;
  logic m_psel, m_penable, m_pwrite, m_pready, m_pslverr;
  logic [31:0] m_paddr, m_pwdata, m_prdata;
  logic [3:0] m_pstrb;
  logic [2:0] m_pprot;

  // APB 接口（源 Requester 侧 / 目的 Completer 侧）
  apb_if #(
    .ADDR_WIDTH (32),
    .DATA_WIDTH (32),
    .HAS_PSTRB  (1),
    .HAS_PPROT  (1)
  ) s_apb (
    .pclk (s_pclk), .presetn (s_presetn), .check_enable (1'b0)
  );
  apb_if #(
    .ADDR_WIDTH (32),
    .DATA_WIDTH (32),
    .HAS_PSTRB  (1),
    .HAS_PPROT  (1)
  ) m_apb (
    .pclk (m_pclk), .presetn (m_presetn), .check_enable (1'b0)
  );

  // DUT 例化
  apb_cdc_bridge_top #(
    .ADDR_WIDTH (32), .DATA_WIDTH (32),
    .CDC_IMPL (0), .SYNC_STAGES (2), .APB_PROFILE (1)
  ) u_dut (
    .s_pclk(s_pclk), .s_presetn(s_presetn),
    .s_psel(s_psel), .s_penable(s_penable), .s_paddr(s_paddr),
    .s_pwrite(s_pwrite), .s_pwdata(s_pwdata), .s_pstrb(s_pstrb), .s_pprot(s_pprot),
    .s_prdata(s_prdata), .s_pready(s_pready), .s_pslverr(s_pslverr),
    .m_pclk(m_pclk), .m_presetn(m_presetn),
    .m_psel(m_psel), .m_penable(m_penable), .m_paddr(m_paddr),
    .m_pwrite(m_pwrite), .m_pwdata(m_pwdata), .m_pstrb(m_pstrb), .m_pprot(m_pprot),
    .m_prdata(m_prdata), .m_pready(m_pready), .m_pslverr(m_pslverr)
  );

  // 源侧接口连线（DUT 是 slave 视角）
  // 写方向（psel/penable/paddr/pwrite/pwdata/pstrb/pprot）由 VIP master agent
  // 驱动 apb_if，tb 读取供 DUT 输入（避免与 VIP apb_if 内部驱动冲突）
  assign s_psel    = s_apb.psel[0];
  assign s_penable = s_apb.penable;
  assign s_paddr   = s_apb.paddr;
  assign s_pwrite  = s_apb.pwrite;
  assign s_pwdata  = s_apb.pwdata;
  // DUT 输出 -> apb_if 读回
  assign s_apb.prdata  = s_prdata;
  assign s_apb.pready  = s_pready;
  assign s_apb.pslverr = s_pslverr;

  // 目的侧接口连线（DUT 是 master 视角）
  // DUT 输出 -> apb_if 写方向（VIP slave agent 采样响应）
  assign m_apb.psel[0] = m_psel;
  assign m_apb.penable = m_penable;
  assign m_apb.paddr   = m_paddr;
  assign m_apb.pwrite  = m_pwrite;
  assign m_apb.pwdata  = m_pwdata;
  // 读回（PREADY/PRDATA/PSLVERR）由 VIP slave agent 驱动 apb_if，tb 读取供 DUT 输入
  assign m_prdata  = m_apb.prdata;
  assign m_pready  = m_apb.pready;
  assign m_pslverr = m_apb.pslverr;

  // UVM 启动 + virtual interface 注入
  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "s_vif", s_apb);
    uvm_config_db#(virtual apb_if)::set(null, "*", "m_vif", m_apb);
    run_test();
  end

endmodule : tb_top
