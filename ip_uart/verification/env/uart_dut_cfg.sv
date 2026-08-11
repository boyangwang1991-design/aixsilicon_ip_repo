// =============================================================================
// File Name   : uart_dut_cfg.sv
// Description : YY DUT configuration class
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef UART_DUT_CFG__SV
`define UART_DUT_CFG__SV

/// @class uart_dut_cfg
/// @brief Configuration class for YY DUT
///        Controls DUT-level checking and coverage options
class uart_dut_cfg extends uvm_object;

  bit enable_check = 1;  ///< Enable DUT output checking
  bit enable_cov   = 1;  ///< Enable DUT coverage collection

  // ---------------------------------------------------------------------------
  // DUT Parameters (OpenTitan UART)
  // ---------------------------------------------------------------------------
  // TX/RX FIFO depth (in entries); OpenTitan default = 32 entries.
  int tx_fifo_depth = 32;   ///< TX FIFO depth (entries)
  int rx_fifo_depth = 32;   ///< RX FIFO depth (entries)
  // NCO (baud rate divider) field width in bits; OpenTitan = 16 bits.
  int nco_width = 16;       ///< NCO divider width (bits)
  // Default NCO value yielding ~115200 baud @ 100MHz with 16x oversampling.
  int nco_default_115200 = 54;  ///< NCO value for 115200 baud @ 100MHz
  // FIFO RX/TX watermark default values (OpenTitan FIFO_CTRL defaults).
  int rx_watermark_default = 1; ///< RX watermark default (entries)
  int tx_watermark_default = 1; ///< TX watermark default (entries)

  // ---------------------------------------------------------------------------
  // UVM Automation
  // ---------------------------------------------------------------------------
  `uvm_object_utils_begin(uart_dut_cfg)
    `uvm_field_int(enable_check, UVM_ALL_ON)
    `uvm_field_int(enable_cov, UVM_ALL_ON)
    `uvm_field_int(tx_fifo_depth, UVM_ALL_ON)
    `uvm_field_int(rx_fifo_depth, UVM_ALL_ON)
    `uvm_field_int(nco_width, UVM_ALL_ON)
    `uvm_field_int(nco_default_115200, UVM_ALL_ON)
    `uvm_field_int(rx_watermark_default, UVM_ALL_ON)
    `uvm_field_int(tx_watermark_default, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor
  /// @param name Configuration object name string
  extern function new(string name = "uart_dut_cfg");

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
  extern virtual task uart_dut_initial();

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name Configuration object name string
function uart_dut_cfg::new(string name = "uart_dut_cfg");
  super.new(name);
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void uart_dut_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void uart_dut_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

// ---------------------------------------------------------------------------
// DUT Initialization definition
// ---------------------------------------------------------------------------

/// @brief DUT initialization task
///        Initialize DUT registers and memory according to uart_cfg_reg / uart_cfg_mem
task uart_dut_cfg::uart_dut_initial();
  // TODO: Add DUT initialization logic here
  // e.g., configure uart_cfg_reg registers and uart_cfg_mem contents
endtask

`endif
