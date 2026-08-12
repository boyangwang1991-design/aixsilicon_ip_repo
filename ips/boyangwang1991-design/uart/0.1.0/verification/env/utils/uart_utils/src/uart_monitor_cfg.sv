// =============================================================================
// File Name   : uart_monitor_cfg.sv
// Description : XX monitor configuration class
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef UART_MONITOR_CFG__SV
`define UART_MONITOR_CFG__SV

/// @class uart_monitor_cfg
/// @brief Configuration class for XX monitor
///        Controls monitor enable, coverage collection, and trace output
class uart_monitor_cfg extends uvm_object;

  // =============================================================================
  // Configuration Parameters
  // =============================================================================
  // Purpose: Store monitor-specific parameters for runtime control
  bit enable       = 1;  // Enable/disable the monitor
  bit enable_cov   = 1;  // Enable coverage collection
  bit enable_trace = 0;  // Enable transaction trace output
  int unsigned baud_div = 16;  // Baud divider for frame sampling
  int unsigned idle_cycles = 0; // Idle cycles between frames

  // =============================================================================
  // UVM Automation
  // =============================================================================
  // Purpose: Enable UVM field automation for print, copy, compare operations
  `uvm_object_utils_begin(uart_monitor_cfg)
    `uvm_field_int(enable, UVM_ALL_ON)
    `uvm_field_int(enable_cov, UVM_ALL_ON)
    `uvm_field_int(enable_trace, UVM_ALL_ON)
    `uvm_field_int(baud_div, UVM_ALL_ON)
    `uvm_field_int(idle_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor
  /// @param name Configuration object name string
  extern function new(string name = "uart_monitor_cfg");

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
function uart_monitor_cfg::new(string name = "uart_monitor_cfg");
  super.new(name);
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void uart_monitor_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void uart_monitor_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

`endif
