// =============================================================================
// File Name   : apb_interface_agent.sv
// Description : XX interface agent top-level component
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef APB_INTERFACE_AGENT__SV
`define APB_INTERFACE_AGENT__SV

/// @class apb_interface_agent
/// @brief XX protocol agent - top-level container for driver, monitor, sequencer
///        Extends uvm_agent to create a complete XX protocol agent
class apb_interface_agent extends uvm_agent;

  // =============================================================================
  // Agent Configuration and Virtual Interface
  // =============================================================================
  // Purpose: Hold references to agent configuration object and shared virtual interface
  apb_interface_agent_cfg cfg;   // Agent configuration handle
  virtual apb_interface     vif; // Virtual interface handle

  // =============================================================================
  // Sub-components
  // =============================================================================
  // Purpose: Instantiate and manage driver, monitor, sequencer, and coverage components
  // Example declarations:
    apb_sequencer    sqr;         // Sequencer handle for generating transactions
    apb_driver       mst_drv;     // Master driver handle for active agent
    apb_slave_driver slv_drv;     // Slave driver handle for active agent
    apb_monitor      mon;         // Monitor handle for passive observation
    apb_monitor_cov  cov;         // Coverage collector handle for functional coverage

  // =============================================================================
  // Analysis Port
  // =============================================================================
  // Purpose: Broadcast observed transactions to scoreboard/checker via TLM
  uvm_analysis_port #(apb_xaction) ap;  // Analysis port for transaction broadcasting

  `uvm_component_utils_begin(apb_interface_agent)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Agent name string
  /// @param parent Parent component handle
  extern function new(string name = "apb_interface_agent", uvm_component parent = null);

  /// @brief Build phase - create and configure sub-components
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Connect phase - establish TLM connections between components
  /// @param phase Current phase handle
  extern virtual function void connect_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Agent name string
/// @param parent Parent component handle
function apb_interface_agent::new(string name = "apb_interface_agent", uvm_component parent = null);
  super.new(name, parent);
  ap = new("ap", this);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void apb_interface_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // =============================================================================
  // Configuration Retrieval and Validation
  // =============================================================================
  // Get configuration from config_db, or create default
  if (!uvm_config_db #(apb_interface_agent_cfg)::get(this, "", "cfg", cfg)) begin
    `uvm_info(get_type_name(), "No cfg found in config_db, creating default configuration", UVM_LOW)
    cfg = apb_interface_agent_cfg::type_id::create("cfg", this);
  end

  // Validate configuration object
  if (cfg == null) begin
    `uvm_fatal(get_type_name(), "Configuration object 'cfg' is null after creation")
  end
  `uvm_info(get_type_name(), $sformatf("Configuration retrieved: active=%0b, mode=%0b, enable_cov=%0b",
               cfg.active, cfg.mode, cfg.enable_cov), UVM_MEDIUM)

  // =============================================================================
  // Get virtual interface from config_db
  // =============================================================================
  if (!uvm_config_db #(virtual apb_interface)::get(this, "", "vif", vif)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end

  // =============================================================================
  // Create sub-components based on agent configuration
  // =============================================================================

  // Create sequencer (always needed for active agent)
  if (cfg.active) begin
    sqr = apb_sequencer::type_id::create("sqr", this);
  end

  // Create driver based on mode (master/slave)
  if (cfg.active) begin
    if (cfg.mode == APB_MASTER_MODE) begin
      mst_drv = apb_driver::type_id::create("mst_drv", this);
    end else begin
      slv_drv = apb_slave_driver::type_id::create("slv_drv", this);
    end
  end

  // Create monitor (always created for both active and passive agents)
  mon = apb_monitor::type_id::create("mon", this);

  // Create coverage collector if enabled
  if (cfg.enable_cov) begin
    cov = apb_monitor_cov::type_id::create("cov", this);
  end

  // =============================================================================
  // Pass virtual interface to sub-components
  // =============================================================================
  if (cfg.active) begin
    uvm_config_db #(virtual apb_interface)::set(this, "mst_drv", "vif", vif);
    uvm_config_db #(virtual apb_interface)::set(this, "slv_drv", "vif", vif);
  end
  uvm_config_db #(virtual apb_interface)::set(this, "mon", "vif", vif);

endfunction

/// @brief Connect phase definition
/// @param phase Current phase handle
function void apb_interface_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  // =============================================================================
  // Connect driver to sequencer
  // =============================================================================
  if (cfg.active) begin
    if (cfg.mode == APB_MASTER_MODE) begin
      mst_drv.seq_item_port.connect(sqr.seq_item_export);
    end
  end

  // =============================================================================
  // Connect monitor to coverage collector
  // =============================================================================
  if (cfg.enable_cov) begin
    mon.ap.connect(cov.analysis_export);
  end

endfunction


`endif
