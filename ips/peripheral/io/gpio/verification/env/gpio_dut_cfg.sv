// =============================================================================
// File Name   : gpio_dut_cfg.sv
// Description : YY DUT configuration class
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef GPIO_DUT_CFG__SV
`define GPIO_DUT_CFG__SV

/// @class gpio_dut_cfg
/// @brief Configuration class for YY DUT
///        Controls DUT-level checking and coverage options
class gpio_dut_cfg extends uvm_object;

  bit enable_check = 1;  ///< Enable DUT output checking
  bit enable_cov   = 1;  ///< Enable DUT coverage collection

  // DUT Parameters (replace with actual DUT specifications)
  int num_queues = 16;         ///< Number of internal queues
  int max_queue_depth = 256;   ///< Maximum queue depth

  // ---------------------------------------------------------------------------
  // UVM Automation
  // ---------------------------------------------------------------------------
  `uvm_object_utils_begin(gpio_dut_cfg)
    `uvm_field_int(enable_check, UVM_ALL_ON)
    `uvm_field_int(enable_cov, UVM_ALL_ON)
    `uvm_field_int(num_queues, UVM_ALL_ON)
    `uvm_field_int(max_queue_depth, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor
  /// @param name Configuration object name string
  extern function new(string name = "gpio_dut_cfg");

  // ---------------------------------------------------------------------------
  // UVM Hooks
  // ---------------------------------------------------------------------------

  /// @brief Pre-randomize hook, called before randomize()
  ///        Can be used to set dynamic constraints or pre-condition checks
  extern function void pre_randomize();

  /// @brief Post-randomize hook, called after randomize()
  ///        Can be used for post-processing or validation of randomized values
  extern function void post_randomize();

  // ---------------------------------------------------------------------------
  // DUT Initialization
  // ---------------------------------------------------------------------------

  /// @brief DUT initialization task
  ///        Called during test setup to initialize DUT registers and memory
  extern virtual task gpio_dut_initial();

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name Configuration object name string
function gpio_dut_cfg::new(string name = "gpio_dut_cfg");
  super.new(name);
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void gpio_dut_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void gpio_dut_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

// ---------------------------------------------------------------------------
// DUT Initialization definition
// ---------------------------------------------------------------------------

/// @brief DUT initialization task
///        Initialize DUT registers and memory according to gpio_cfg_reg / gpio_cfg_mem
task gpio_dut_cfg::gpio_dut_initial();
  // TODO: Add DUT initialization logic here
  // e.g., configure gpio_cfg_reg registers and gpio_cfg_mem contents
endtask

`endif
