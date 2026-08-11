// =============================================================================
// File Name   : tlul_interface_agent_cfg.sv
// Description : XX interface agent configuration class
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
//
// NOTE: Agent Mode Filtering
//   - MASTER mode: Keep mst_drv_cfg, remove slv_drv_cfg
//   - SLAVE mode: Keep slv_drv_cfg, remove mst_drv_cfg
//   - MONITOR mode: Remove both mst_drv_cfg and slv_drv_cfg
//   When instantiating, adjust this file based on agent_plan.md
// =============================================================================

`ifndef TLUL_INTERFACE_AGENT_CFG__SV
`define TLUL_INTERFACE_AGENT_CFG__SV

/// @class tlul_interface_agent_cfg
/// @brief Configuration class for XX interface agent
///        Aggregates all sub-component configurations (driver, slave driver, monitor)
class tlul_interface_agent_cfg extends uvm_object;

  // =============================================================================
  // Agent Mode Configuration
  // =============================================================================
  // Purpose: Control agent active/passive mode and master/slave operation
  bit active = 1;  // Agent active mode (0=PASSIVE, 1=ACTIVE)
  bit mode   = 0;  // Agent operation mode (0=MASTER, 1=SLAVE)

  // =============================================================================
  // Sub-component Configuration Handles
  // =============================================================================
  // Purpose: Aggregate configurations for all sub-components (driver, slave driver, monitor)
  //          Using 'rand' keyword enables randomization of sub-component configurations
  // NOTE: Remove unused configurations based on agent mode (see file header)
  rand tlul_driver_cfg       mst_drv_cfg;  // Master driver configuration (randomizable)
  rand tlul_slave_driver_cfg slv_drv_cfg;  // Slave driver configuration (randomizable)
  rand tlul_monitor_cfg      mon_cfg;      // Monitor configuration (randomizable)

  // =============================================================================
  // Coverage Configuration
  // =============================================================================
  // Purpose: Control coverage collection enable/disable
  bit enable_cov = 1;  // Enable coverage collection

  // =============================================================================
  // UVM Automation
  // =============================================================================
  // Purpose: Enable UVM field automation for print, copy, compare operations
  `uvm_object_utils_begin(tlul_interface_agent_cfg)
    `uvm_field_int(active, UVM_ALL_ON)
    `uvm_field_int(mode, UVM_ALL_ON)
    `uvm_field_object(mst_drv_cfg, UVM_ALL_ON)
    `uvm_field_object(slv_drv_cfg, UVM_ALL_ON)
    `uvm_field_object(mon_cfg, UVM_ALL_ON)
    `uvm_field_int(enable_cov, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor - creates default sub-component configurations
  /// @param name Configuration object name string
  extern function new(string name = "tlul_interface_agent_cfg");

  // ---------------------------------------------------------------------------
  // UVM Hooks
  // ---------------------------------------------------------------------------

  /// @brief Pre-randomize hook, called before randomize()
  ///        Can be used to set dynamic constraints or pre-condition checks
  extern function void pre_randomize();

  /// @brief Post-randomize hook, called after randomize()
  ///        Can be used for post-processing or validation of randomized values
  extern function void post_randomize();

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name Configuration object name string
function tlul_interface_agent_cfg::new(string name = "tlul_interface_agent_cfg");
  super.new(name);

  this.mst_drv_cfg = tlul_driver_cfg::type_id::create("mst_drv_cfg");
  this.slv_drv_cfg = tlul_slave_driver_cfg::type_id::create("slv_drv_cfg");
  this.mon_cfg     = tlul_monitor_cfg::type_id::create("mon_cfg");
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void tlul_interface_agent_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void tlul_interface_agent_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

`endif
