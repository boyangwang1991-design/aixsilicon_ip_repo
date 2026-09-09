// tb_top.sv - APB Demux UVM testbench 顶层
// 单时钟（PCLK 10ns）+ 单一复位 + DUT + 1 上游 apb_if + N 下游 apb_if
// 复用 aixsilicon:vip:apb:1.0.0（只读引用，不复制）
module tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int NS = 4;   // 默认 NUM_SLAVES（testcase 可经 plusarg 覆盖）

  // 时钟
  logic pclk;
  int clk_period_half;
  initial begin
    clk_period_half = $value$plusargs("CLK_PERIOD_PS=%d", clk_period_half) ? clk_period_half/2 : 5000;
    pclk = 1'b0;
    forever #(clk_period_half * 1ps) pclk = ~pclk;
  end

  // 复位
  logic presetn;
  initial begin
    presetn = 1'b0;
    repeat (5) @(posedge pclk);
    presetn = 1'b1;
  end

  // DUT 信号
  logic [31:0] paddr;
  logic psel, penable, pwrite, pready, pslverr;
  logic [31:0] pwdata, prdata;
  logic [3:0] pstrb;
  logic [2:0] pprot;

  logic [31:0] m_paddr [NS];
  logic m_psel [NS], m_penable [NS], m_pwrite [NS], m_pready [NS], m_pslverr [NS];
  logic [31:0] m_pwdata [NS], m_prdata [NS];
  logic [3:0] m_pstrb [NS];
  logic [2:0] m_pprot [NS];

  // APB 接口：1 上游（slave 视角）+ N 下游（master 视角）
  apb_if #(.ADDR_WIDTH(32), .DATA_WIDTH(32), .HAS_PSTRB(1), .HAS_PPROT(1)) u_apb_s (
    .pclk(pclk), .presetn(presetn), .check_enable(1'b0)
  );
  apb_if #(.ADDR_WIDTH(32), .DATA_WIDTH(32), .HAS_PSTRB(1), .HAS_PPROT(1)) u_apb_m [NS] (
    .pclk(pclk), .presetn(presetn), .check_enable(1'b0)
  );

  // DUT 例化
  apb_demux_top #(
    .NUM_SLAVES(NS),
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .APB_PROFILE(1),
    .ADDR_REMAP_ENABLE(0),
    .TIMEOUT_ENABLE(0),
    .TIMEOUT_CYCLES(16),
    .OUTPUT_REGISTER(0),
    .BASE_ADDR('{32'h4000_0000, 32'h4000_1000, 32'h4000_2000, 32'h4000_3000}),
    .ADDR_MASK('{32'hFFFF_F000, 32'hFFFF_F000, 32'hFFFF_F000, 32'hFFFF_F000})
  ) u_dut (
    .pclk(pclk), .presetn(presetn),
    .paddr(paddr), .psel(psel), .penable(penable), .pwrite(pwrite),
    .pwdata(pwdata), .pstrb(pstrb), .pprot(pprot),
    .prdata(prdata), .pready(pready), .pslverr(pslverr),
    .m_paddr(m_paddr), .m_psel(m_psel), .m_penable(m_penable), .m_pwrite(m_pwrite),
    .m_pwdata(m_pwdata), .m_pstrb(m_pstrb), .m_pprot(m_pprot),
    .m_prdata(m_prdata), .m_pready(m_pready), .m_pslverr(m_pslverr)
  );

  // 上游接口连线（DUT 是 slave 视角；VIP master agent 驱动写方向）
  assign psel    = u_apb_s.psel[0];
  assign penable = u_apb_s.penable;
  assign paddr   = u_apb_s.paddr;
  assign pwrite  = u_apb_s.pwrite;
  assign pwdata  = u_apb_s.pwdata;
  assign pstrb   = u_apb_s.pstrb_w;
  assign pprot   = u_apb_s.pprot_w;
  assign u_apb_s.prdata  = prdata;
  assign u_apb_s.pready  = pready;
  assign u_apb_s.pslverr = pslverr;

  // 下游接口连线（DUT 是 master 视角；VIP slave agent 驱动响应）
  for (genvar i = 0; i < NS; i++) begin : gen_m_conn
    // 必选信号由 tb 结构驱动（与参考 IP 一致）
    assign u_apb_m[i].psel[0] = m_psel[i];
    assign u_apb_m[i].penable = m_penable[i];
    assign u_apb_m[i].paddr   = m_paddr[i];
    assign u_apb_m[i].pwrite  = m_pwrite[i];
    assign u_apb_m[i].pwdata  = m_pwdata[i];
    // 可选信号（pstrb_w/pprot_w）由 VIP 内部 initial 清零驱动，
    // 不在此 assign（避免 ICPSD 混合驱动）；PSTRB/PPROT 透传经
    // 上游 apb_if 观察 + RTL 端口检查覆盖。
    assign m_prdata[i]  = u_apb_m[i].prdata;
    assign m_pready[i]  = u_apb_m[i].pready;
    assign m_pslverr[i] = u_apb_m[i].pslverr;
  end

  // UVM 启动 + virtual interface 注入（下游 vif 用 generate 常量索引展开）
  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "s_vif", u_apb_s);
    run_test();
  end

  for (genvar gi = 0; gi < NS; gi++) begin : gen_vif_set
    initial begin
      uvm_config_db#(virtual apb_if)::set(null, "*", $sformatf("m_vif%0d", gi), u_apb_m[gi]);
    end
  end

endmodule : tb_top
