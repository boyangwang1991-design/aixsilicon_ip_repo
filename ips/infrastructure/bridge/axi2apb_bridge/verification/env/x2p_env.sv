// =============================================================================
// x2p_env.sv - X2P VIP 集成验证环境
// 拓扑：X2P 是 AXI slave + APB master
//   - AXI 侧：VIP axi4_master_agent（AXI4_ACTIVE_MASTER）激励 x2p AXI 从口
//   - APB 侧：VIP apb_slave_agent（APB_ACTIVE_SLAVE, ZERO_WAIT，内置 memory）
//            响应 x2p 的 APB 主口（写存 memory / 读回 memory）
// 复用：aixsilicon:vip:axi4:1.0.0 / aixsilicon:vip:apb:1.0.0（只读引用，不复制）
//
// 超时专项：+X2P_APB_TIMEOUT=1 → apb 侧不创建 responder（agent_mode=DISABLED，
// PREADY 恒低）→ 触发 x2p 内部 APB 超时 → AXI 返回 SLVERR（tc_timeout 用）。
// =============================================================================

`ifndef X2P_ENV__SV
`define X2P_ENV__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_pkg::*;
import axi4_types_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class x2p_env extends uvm_env;

  `uvm_component_utils(x2p_env)

  // VIP 组件
  axi4_master_agent axi_master;   // AXI 主激励（驱动 x2p AXI slave）
  apb_slave_agent   apb_slave;    // APB completer（响应 x2p APB master）

  axi4_configuration am_cfg;
  apb_config         ps_cfg;

  virtual axi4_if    aif;
  virtual apb_if     pif;

  bit apb_timeout_mode;

  function new(string name = "x2p_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if ($test$plusargs("X2P_APB_TIMEOUT")) apb_timeout_mode = 1'b1;

    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "axi_vif", aif))
      `uvm_fatal(get_type_name(), "axi4 vif 'axi_vif' not found (harness must set)")
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", pif))
      `uvm_fatal(get_type_name(), "apb vif 'apb_vif' not found (harness must set)")

    // ---- AXI4 master config（数据 64bit、ID 4、地址 32） ----
    // randomize（含默认 ready 拉 1：default_bready/default_rready 等 soft=1 约束
    // 仅在 randomize 时生效，手工创建不 randomize 会得到 0）
    am_cfg = axi4_configuration::type_id::create("am_cfg");
    void'(am_cfg.randomize() with {
      protocol        == AXI4_PROTOCOL;
      agent_mode      == AXI4_ACTIVE_MASTER;
      id_width        == 4;
      address_width   == 32;
      data_width      == 64;
      strobe_width    == 8;
      enable_checker  == 0;
      enable_coverage == 0;
      enable_timeout  == 0;      // DUT 自身超时/响应，无需 VIP 侧超时
    });
    am_cfg.vif = aif;
    axi_master = axi4_master_agent::type_id::create("axi_master", this);
    uvm_config_db#(axi4_configuration)::set(this, "axi_master", "cfg", am_cfg);

    // ---- APB slave（completer）config：FIXED_WAIT=1 内置 memory 响应 ----
    // enable_strb/enable_prot=0：memory responder 全字读写（不依赖 pstrb/pprot
    // 采样；DUT 的 32-bit 子传输为全 lane 写）。
    // 注意：不能用 ZERO_WAIT——x2p apb_engine 在 (ACCESS && PREADY) 沿锁存
    // prdata，ZERO_WAIT 使 PREADY 恒高，DUT 首个 ACCESS 拍即完成并锁存到
    // 尚未更新的 prdata（读回 0）。FIXED_WAIT=1：ACCESS 第 1 拍 PREADY=0、
    // 第 2 拍 PREADY=1 且 prdata 已就绪（与读时序匹配）。
    ps_cfg = apb_config::type_id::create("ps_cfg");
    ps_cfg.protocol_version     = APB4;
    ps_cfg.enable_strb          = 1'b0;
    ps_cfg.enable_prot          = 1'b0;
    ps_cfg.slave_response_mode  = APB_FIXED_WAIT;
    ps_cfg.default_wait_cycles  = 1;
    ps_cfg.slave_error_mode     = APB_ERR_NEVER;
    ps_cfg.enable_checker       = 0;
    ps_cfg.enable_coverage      = 0;
    if (apb_timeout_mode) begin
      // 超时专项：保持 APB_ACTIVE_SLAVE，靠 harness 置 u_apb.suppress_pready=1
      // 抑制 completion 拍 PREADY（恒低）→ x2p APB 引擎挂起 → 内部超时 → AXI SLVERR。
      // 注意：不能用 APB_DISABLED——P3 修复后必选信号纯声明无初值，禁用 agent 时
      // pready 悬空 X，DUT if(!pready) 判定假 → timeout 计数永不递增 → 永不超时。
      ps_cfg.agent_mode = APB_ACTIVE_SLAVE;
    end else begin
      ps_cfg.agent_mode = APB_ACTIVE_SLAVE;
    end
    apb_slave = apb_slave_agent::type_id::create("apb_slave", this);
    // 通配 scope：apb_slave 自身的 agent build 与它内部的 driver/sequencer 都能取到
    // （config_db 精确 scope 不向更深层子组件级联，VIP 自测采用 "agent*" 通配）
    uvm_config_db#(apb_config)::set(this, "apb_slave*", "config", ps_cfg);
    uvm_config_db#(virtual apb_if)::set(this, "apb_slave*", "vif", pif);
  endfunction

endclass : x2p_env

`endif // X2P_ENV__SV
