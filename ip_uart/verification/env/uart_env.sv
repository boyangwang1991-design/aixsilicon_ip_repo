// =============================================================================
// File Name   : uart_env.sv
// Description : UART environment - top-level container
//               Instantiates TL-UL, APB, and UART serial agents.
// =============================================================================

`ifndef UART_ENV__SV
`define UART_ENV__SV

class uart_env extends uvm_env;

  uart_env_cfg cfg;

  // Agents
  uart_interface_agent   uart_agent;   ///< UART serial agent
  tlul_interface_agent   tlul_agent;   ///< TL-UL bus agent (register access)
  apb_interface_agent    apb_agent;    ///< APB bus agent (APB access path)

  // Verification components
  uart_rm                rm;
  uart_checker           scb;
  uart_virtual_sequencer v_sqr;

  `uvm_component_utils_begin(uart_env)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name = "uart_env", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual task reset_phase(uvm_phase phase);
  extern virtual task configure_phase(uvm_phase phase);
  extern virtual task shutdown_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

endclass

function uart_env::new(string name = "uart_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void uart_env::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db #(uart_env_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = uart_env_cfg::type_id::create("cfg");
  end

  // UART serial agent
  uvm_config_db #(uart_interface_agent_cfg)::set(this, "uart_agent", "cfg", cfg.uart_agent_cfg);
  uart_agent = uart_interface_agent::type_id::create("uart_agent", this);

  // TL-UL bus agent
  if (cfg.enable_tlul) begin
    uvm_config_db #(tlul_interface_agent_cfg)::set(this, "tlul_agent", "cfg", cfg.tlul_agent_cfg);
    tlul_agent = tlul_interface_agent::type_id::create("tlul_agent", this);
  end

  // APB bus agent
  if (cfg.enable_apb) begin
    uvm_config_db #(apb_interface_agent_cfg)::set(this, "apb_agent", "cfg", cfg.apb_agent_cfg);
    apb_agent = apb_interface_agent::type_id::create("apb_agent", this);
  end

  // Virtual sequencer
  v_sqr = uart_virtual_sequencer::type_id::create("v_sqr", this);

  // Reference model
  if (cfg.enable_rm) begin
    uvm_config_db #(uart_rm_cfg)::set(this, "rm", "cfg", cfg.rm_cfg);
    rm = uart_rm::type_id::create("rm", this);
  end

  // Checker
  if (cfg.enable_checker) begin
    uvm_config_db #(uart_checker_cfg)::set(this, "scb", "cfg", cfg.checker_cfg);
    scb = uart_checker::type_id::create("scb", this);
  end
endfunction

function void uart_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  // Virtual sequencer handles
  if (uart_agent.cfg.active) begin
    v_sqr.uart_sqr = uart_agent.sqr;
  end
  if (cfg.enable_tlul && tlul_agent.cfg.active) begin
    v_sqr.tlul_sqr = tlul_agent.sqr;
  end
  if (cfg.enable_apb && apb_agent.cfg.active) begin
    v_sqr.apb_sqr = apb_agent.sqr;
  end

  // Connect agents to RM (RM predicts TX output from register writes)
  if (cfg.enable_rm) begin
    if (cfg.enable_tlul) begin
      tlul_agent.ap.connect(rm.tlul_in_export);
    end
    if (cfg.enable_apb) begin
      apb_agent.ap.connect(rm.apb_in_export);
    end
    uart_agent.ap.connect(rm.uart_in_export);
  end

  // Connect agents to checker
  if (cfg.enable_checker) begin
    uart_agent.ap.connect(scb.act_export);
    if (cfg.enable_tlul) begin
      tlul_agent.ap.connect(scb.tlul_export);
    end
    if (cfg.enable_apb) begin
      apb_agent.ap.connect(scb.apb_export);
    end
    // RM expected output -> checker expected input
    if (cfg.enable_rm) begin
      rm.exp_ap.connect(scb.exp_export);
    end
  end
endfunction

task uart_env::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
endtask

task uart_env::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
endtask

task uart_env::shutdown_phase(uvm_phase phase);
  super.shutdown_phase(phase);
endtask

function void uart_env::check_phase(uvm_phase phase);
  super.check_phase(phase);
endfunction

function void uart_env::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction

`endif
