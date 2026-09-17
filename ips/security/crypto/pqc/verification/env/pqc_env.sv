// =============================================================================
// File Name   : pqc_env.sv
// Description : YY environment top-level component
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef PQC_ENV__SV
`define PQC_ENV__SV

/// @class pqc_env
/// @brief YY environment - top-level container for all verification components
///        Extends uvm_env to create a complete YY verification environment
class pqc_env extends uvm_env;

  pqc_env_cfg cfg;  ///< Environment configuration handle

  // Sub-components
  apb_interface_agent   apb_agent;   ///< XX protocol agent
  pqc_rm                rm;         ///< Reference model
  pqc_checker           scb;        ///< Scoreboard/checker (avoid 'checker' keyword)
  pqc_virtual_sequencer v_sqr;      ///< Virtual sequencer

  `uvm_component_utils_begin(pqc_env)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Environment name string
  /// @param parent Parent component handle
  extern function new(string name = "pqc_env", uvm_component parent = null);

  /// @brief Build phase - create and configure all sub-components
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Connect phase - establish TLM connections between components
  /// @param phase Current phase handle
  extern virtual function void connect_phase(uvm_phase phase);

  // ---------------------------------------------------------------------------
  // Runtime Phases
  // ---------------------------------------------------------------------------

  /// @brief Reset phase - reset DUT and components to initial state
  /// @param phase Current phase handle
  extern virtual task reset_phase(uvm_phase phase);

  /// @brief Configure phase - apply runtime configuration to components
  /// @param phase Current phase handle
  extern virtual task configure_phase(uvm_phase phase);

  /// @brief Shutdown phase - wait for DUT idle state and drain residual traffic
  /// @param phase Current phase handle
  extern virtual task shutdown_phase(uvm_phase phase);

  /// @brief Check phase - verify end-of-test conditions and data integrity
  /// @param phase Current phase handle
  extern virtual function void check_phase(uvm_phase phase);

  /// @brief Report phase - output summary report of verification results
  /// @param phase Current phase handle
  extern virtual function void report_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Environment name string
/// @param parent Parent component handle
function pqc_env::new(string name = "pqc_env", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void pqc_env::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Get environment configuration from config_db, or create default
  if (!uvm_config_db #(pqc_env_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = pqc_env_cfg::type_id::create("cfg");
  end

  // Create XX agent and pass configuration
  uvm_config_db #(apb_interface_agent_cfg)::set(this, "apb_agent", "cfg", cfg.apb_agent_cfg);
  apb_agent = apb_interface_agent::type_id::create("apb_agent", this);

  // Create virtual sequencer for coordinating agent sequences
  v_sqr = pqc_virtual_sequencer::type_id::create("v_sqr", this);

  // Create reference model if enabled
  if (cfg.enable_rm) begin
    uvm_config_db #(pqc_rm_cfg)::set(this, "rm", "cfg", cfg.rm_cfg);
    rm = pqc_rm::type_id::create("rm", this);
  end

  // Create checker if enabled
  if (cfg.enable_checker) begin
    uvm_config_db #(pqc_checker_cfg)::set(this, "scb", "cfg", cfg.checker_cfg);
    scb = pqc_checker::type_id::create("scb", this);
  end
endfunction

/// @brief Connect phase definition
/// @param phase Current phase handle
function void pqc_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  // Connect virtual sequencer to agent sequencer (only for active agent)
  if (apb_agent.cfg.active) begin
    v_sqr.apb_sqr = apb_agent.sqr;
  end

  // Connect agent output to reference model input
  if (cfg.enable_rm) begin
    apb_agent.ap.connect(rm.in_export);
  end

  // Connect agent output and reference model output to checker
  if (cfg.enable_checker) begin
    apb_agent.ap.connect(scb.act_export);

    if (cfg.enable_rm) begin
      rm.exp_ap.connect(scb.exp_export);
    end
  end
endfunction

// ---------------------------------------------------------------------------
// Runtime Phase definitions
// ---------------------------------------------------------------------------

/// @brief Reset phase definition
/// @param phase Current phase handle
task pqc_env::reset_phase(uvm_phase phase);
  super.reset_phase(phase);
  // TODO: Add reset logic here (e.g., assert reset signal, clear internal state)
endtask

/// @brief Configure phase definition
/// @param phase Current phase handle
task pqc_env::configure_phase(uvm_phase phase);
  super.configure_phase(phase);
  // TODO: Add runtime configuration logic here
endtask

/// @brief Shutdown phase definition
/// @param phase Current phase handle
task pqc_env::shutdown_phase(uvm_phase phase);
  super.shutdown_phase(phase);
  // TODO: Add shutdown logic here (e.g., wait for DUT idle, drain residual traffic)
endtask

/// @brief Check phase definition
/// @param phase Current phase handle
function void pqc_env::check_phase(uvm_phase phase);
  super.check_phase(phase);
  // TODO: Add end-of-test checking logic here
endfunction

/// @brief Report phase definition
/// @param phase Current phase handle
function void pqc_env::report_phase(uvm_phase phase);
  super.report_phase(phase);
  // TODO: Add summary report logic here
endfunction

`endif
