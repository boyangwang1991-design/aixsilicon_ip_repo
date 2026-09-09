// apb_demux_env.sv - APB Demux UVM env
// 结构：1 上游 apb_master_agent（驱动 DUT 上游）+ N 下游 apb_slave_agent（响应 DUT 下游）
// + 两侧 apb_monitor（观察流）-> scoreboard 比对
// 复用 APB VIP 组件（agent/driver/monitor/checker），不实例化 apb_env
// （其 predictor 无 RAL 时无条件连接导致 null 崩溃）。
class apb_demux_env extends uvm_env;

  `uvm_component_utils(apb_demux_env)

  // 上游（Master 侧，驱动 DUT 上游）
  apb_master_agent master_agent;
  apb_monitor      master_mon;
  // 下游（Slave 侧，响应 DUT 下游）
  apb_slave_agent  slave_agent[4];
  apb_monitor      slave_mon[4];

  apb_demux_scoreboard scoreboard;

  virtual apb_if s_vif;
  virtual apb_if m_vif[4];
  apb_config s_cfg;
  apb_config m_cfg[4];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    string m_vif_name;
    super.build_phase(phase);

    if (!uvm_config_db#(virtual apb_if)::get(this, "", "s_vif", s_vif))
      `uvm_fatal(get_type_name(), "virtual interface 's_vif' not set")

    // ---- 上游配置（Requester 主动）----
    s_cfg = apb_config::type_id::create("s_cfg");
    s_cfg.data_width = 32;
    s_cfg.addr_width = 32;
    s_cfg.enable_strb  = 1;
    s_cfg.enable_prot  = 1;
    s_cfg.agent_mode = APB_ACTIVE_MASTER;
    uvm_config_db#(apb_config)::set(this, "master_agent", "config", s_cfg);
    uvm_config_db#(apb_config)::set(this, "master_agent.*", "config", s_cfg);
    uvm_config_db#(virtual apb_if)::set(this, "master_agent", "vif", s_vif);
    uvm_config_db#(virtual apb_if)::set(this, "master_agent.*", "vif", s_vif);
    master_agent = apb_master_agent::type_id::create("master_agent", this);

    // ---- 下游配置（Completer 主动响应，4 端口）----
    for (int i = 0; i < 4; i++) begin
      m_vif_name = $sformatf("m_vif%0d", i);
      if (!uvm_config_db#(virtual apb_if)::get(this, "", m_vif_name, m_vif[i]))
        `uvm_fatal(get_type_name(), $sformatf("virtual interface '%s' not set", m_vif_name))
      m_cfg[i] = apb_config::type_id::create($sformatf("m_cfg%0d", i));
      m_cfg[i].data_width = 32;
      m_cfg[i].addr_width = 32;
      m_cfg[i].enable_strb  = 1;
      m_cfg[i].enable_prot  = 1;
      m_cfg[i].agent_mode = APB_ACTIVE_SLAVE;
      m_cfg[i].slave_response_mode = APB_ZERO_WAIT;
      m_cfg[i].slave_error_mode    = APB_ERR_NEVER;
      uvm_config_db#(apb_config)::set(this, $sformatf("slave_agent[%0d]", i), "config", m_cfg[i]);
      uvm_config_db#(apb_config)::set(this, $sformatf("slave_agent[%0d].*", i), "config", m_cfg[i]);
      uvm_config_db#(virtual apb_if)::set(this, $sformatf("slave_agent[%0d]", i), "vif", m_vif[i]);
      uvm_config_db#(virtual apb_if)::set(this, $sformatf("slave_agent[%0d].*", i), "vif", m_vif[i]);
      slave_agent[i] = apb_slave_agent::type_id::create($sformatf("slave_agent[%0d]", i), this);
    end

    // ---- monitor（观察流）----
    uvm_config_db#(apb_config)::set(this, "master_mon", "config", s_cfg);
    uvm_config_db#(virtual apb_if)::set(this, "master_mon", "vif", s_vif);
    master_mon = apb_monitor::type_id::create("master_mon", this);
    for (int i = 0; i < 4; i++) begin
      uvm_config_db#(apb_config)::set(this, $sformatf("slave_mon[%0d]", i), "config", m_cfg[i]);
      uvm_config_db#(virtual apb_if)::set(this, $sformatf("slave_mon[%0d]", i), "vif", m_vif[i]);
      slave_mon[i] = apb_monitor::type_id::create($sformatf("slave_mon[%0d]", i), this);
    end

    scoreboard = apb_demux_scoreboard::type_id::create("scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    master_mon.transaction_ap.connect(scoreboard.up_imp);
    for (int i = 0; i < 4; i++) begin
      slave_mon[i].transaction_ap.connect(scoreboard.down_imp);
    end
  endfunction

endclass
