// =============================================================================
// File Name   : tlul_driver_cfg.sv
// Description : XX master driver configuration class
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef TLUL_DRIVER_CFG__SV
`define TLUL_DRIVER_CFG__SV

/// @class tlul_driver_cfg
/// @brief Configuration class for XX master driver
///        Stores driver-specific parameters that can be modified per test
class tlul_driver_cfg extends uvm_object;

  // =============================================================================
  // Configuration Parameters
  // =============================================================================
  // Purpose: Store driver-specific parameters that can be modified per test
  bit          enable         = 1;     // Enable/disable the driver
  bit          debug          = 0;     // Enable debug messages
  int unsigned idle_cycles    = 0;     // Number of idle cycles between transactions
  int unsigned timeout_cycles = 1000;  // Timeout counter for transaction completion

  // =============================================================================
  // UVM Automation
  // =============================================================================
  // Purpose: Enable UVM field automation for print, copy, compare operations
  `uvm_object_utils_begin(tlul_driver_cfg)
    `uvm_field_int(enable, UVM_ALL_ON)
    `uvm_field_int(idle_cycles, UVM_ALL_ON)
    `uvm_field_int(timeout_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor
  /// @param name Configuration object name string
  extern function new(string name = "tlul_driver_cfg");

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
function tlul_driver_cfg::new(string name = "tlul_driver_cfg");
  super.new(name);
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void tlul_driver_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void tlul_driver_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

`endif
