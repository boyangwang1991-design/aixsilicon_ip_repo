// =============================================================================
// File Name   : uart_checker_cfg.sv
// Description : YY checker configuration class
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef UART_CHECKER_CFG__SV
`define UART_CHECKER_CFG__SV

/// @class uart_checker_cfg
/// @brief Configuration class for YY checker/scoreboard
///        Controls checker enable and comparison strictness
class uart_checker_cfg extends uvm_object;

  bit enable = 1;                 ///< Enable/disable the checker
  bit enable_strict_compare = 1;  ///< Enable strict comparison mode

  // ---------------------------------------------------------------------------
  // UVM Automation
  // ---------------------------------------------------------------------------
  `uvm_object_utils_begin(uart_checker_cfg)
    `uvm_field_int(enable, UVM_ALL_ON)
    `uvm_field_int(enable_strict_compare, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor
  /// @param name Configuration object name string
  extern function new(string name = "uart_checker_cfg");

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
function uart_checker_cfg::new(string name = "uart_checker_cfg");
  super.new(name);
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void uart_checker_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void uart_checker_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

`endif
