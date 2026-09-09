// apb_cdc_bridge_env.sv - APB CDC Bridge UVM env
// 结构：源侧 apb_master_agent（驱动上游事务）+ 目的侧 apb_slave_agent（响应下游）
//       + 两侧 apb_monitor（观察流）-> scoreboard 比对（no loss / no duplicate / 读数据保真）
// 复用 APB VIP 组件（agent/driver/monitor），不强制实例化 apb_env（其 predictor 在
// 无 RAL 时无条件连接导致 null 崩溃）。
class apb_cdc_bridge_env extends uvm_env;

  `uvm_component_utils(apb_cdc_bridge_env)

  apb_cdc_bridge_scoreboard sb;

  apb_master_agent s_agent;   // 源侧：驱动上游事务（DUT 是 slave）
  apb_slave_agent  m_agent;   // 目的侧：响应下游事务
  apb_monitor      s_mon;     // 源侧观察
  apb_monitor      m_mon;     // 目的侧观察

  virtual apb_if s_vif;
  virtual apb_if m_vif;
  apb_config s_cfg;
  apb_config m_cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_if)::get(this, "", "s_vif", s_vif))
      `uvm_fatal(get_type_name(), "virtual interface 's_vif' not set")
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "m_vif", m_vif))
      `uvm_fatal(get_type_name(), "virtual interface 'm_vif' not set")

    // ---- 源侧配置（Requester 主动）----
    s_cfg = apb_config::type_id::create("s_cfg");
    s_cfg.data_width = 32;
    s_cfg.addr_width = 8;
    s_cfg.enable_strb  = 1;
    s_cfg.enable_prot  = 1;
    s_cfg.agent_mode = APB_ACTIVE_MASTER;
    uvm_config_db#(apb_config)::set(this, "s_agent", "config", s_cfg);
    uvm_config_db#(apb_config)::set(this, "s_agent.*", "config", s_cfg);
    uvm_config_db#(virtual apb_if)::set(this, "s_agent", "vif", s_vif);
    uvm_config_db#(virtual apb_if)::set(this, "s_agent.*", "vif", s_vif);
    s_agent = apb_master_agent::type_id::create("s_agent", this);

    // ---- 目的侧配置（Completer 主动响应）----
    m_cfg = apb_config::type_id::create("m_cfg");
    m_cfg.data_width = 32;
    m_cfg.addr_width = 8;
    m_cfg.enable_strb  = 1;
    m_cfg.enable_prot  = 1;
    m_cfg.agent_mode = APB_ACTIVE_SLAVE;
    m_cfg.slave_response_mode = APB_ZERO_WAIT;
    m_cfg.slave_error_mode    = APB_ERR_NEVER;
    uvm_config_db#(apb_config)::set(this, "m_agent", "config", m_cfg);
    uvm_config_db#(apb_config)::set(this, "m_agent.*", "config", m_cfg);
    uvm_config_db#(virtual apb_if)::set(this, "m_agent", "vif", m_vif);
    uvm_config_db#(virtual apb_if)::set(this, "m_agent.*", "vif", m_vif);
    m_agent = apb_slave_agent::type_id::create("m_agent", this);

    // ---- monitor 配置（观察）----
    uvm_config_db#(apb_config)::set(this, "s_mon", "config", s_cfg);
    uvm_config_db#(virtual apb_if)::set(this, "s_mon", "vif", s_vif);
    s_mon = apb_monitor::type_id::create("s_mon", this);
    uvm_config_db#(apb_config)::set(this, "m_mon", "config", m_cfg);
    uvm_config_db#(virtual apb_if)::set(this, "m_mon", "vif", m_vif);
    m_mon = apb_monitor::type_id::create("m_mon", this);

    sb = apb_cdc_bridge_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    s_mon.transaction_ap.connect(sb.up_imp);
    m_mon.transaction_ap.connect(sb.down_imp);
  endfunction

endclass : apb_cdc_bridge_env
