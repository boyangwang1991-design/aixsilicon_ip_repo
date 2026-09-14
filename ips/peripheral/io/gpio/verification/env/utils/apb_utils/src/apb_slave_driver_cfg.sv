// =============================================================================
// File Name   : apb_slave_driver_cfg.sv
// Description : XX slave driver configuration class
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef APB_SLAVE_DRIVER_CFG__SV
`define APB_SLAVE_DRIVER_CFG__SV

/// @class apb_slave_driver_cfg
/// @brief Configuration class for XX slave driver
///        Stores slave driver-specific parameters for response behavior
class apb_slave_driver_cfg extends uvm_object;

  // =============================================================================
  // Configuration Parameters
  // =============================================================================
  // Purpose: Store slave driver-specific parameters for response behavior
  bit          enable           = 1;     // Enable/disable the slave driver
  int unsigned ready_delay_min  = 0;     // Minimum ready signal delay (cycles)
  int unsigned ready_delay_max  = 3;     // Maximum ready signal delay (cycles)
  // TODO: Define default_rdata and default_resp based on your protocol
  // bit [APB_DATA_WIDTH-1:0] default_rdata = '0;
  // apb_resp_e default_resp = APB_RESP_OKAY;

  // =============================================================================
  // UVM Automation
  // =============================================================================
  // Purpose: Enable UVM field automation for print, copy, compare operations
  `uvm_object_utils_begin(apb_slave_driver_cfg)
    `uvm_field_int(enable, UVM_ALL_ON)
    `uvm_field_int(ready_delay_min, UVM_ALL_ON)
    `uvm_field_int(ready_delay_max, UVM_ALL_ON)
    // `uvm_field_int(default_rdata, UVM_ALL_ON)
    // `uvm_field_enum(apb_resp_e, default_resp, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor
  /// @param name Configuration object name string
  extern function new(string name = "apb_slave_driver_cfg");

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
function apb_slave_driver_cfg::new(string name = "apb_slave_driver_cfg");
  super.new(name);
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void apb_slave_driver_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void apb_slave_driver_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

`endif
