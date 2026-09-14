// =============================================================================
// File Name   : gpio_env_dec.sv
// Description : YY environment declarations and definitions
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
//
// IMPORTANT: This file is compiled as a standalone compilation unit.
//            It MUST import uvm_pkg and include uvm_macros.svh before using
//            any UVM macros (e.g., uvm_analysis_imp_decl).
// =============================================================================

`ifndef GPIO_ENV_DEC__SV
`define GPIO_ENV_DEC__SV

  // -----------------------------------------------------------------------------
  // UVM Package Import (required for uvm_analysis_imp_decl macros)
  // -----------------------------------------------------------------------------
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // -----------------------------------------------------------------------------
  // Analysis Imp Declarations
  // Required when multiple analysis ports use different transaction types.
  // Declare once here to avoid redefinition errors.
  // Uncomment and add suffixes as needed for your environment.
  // Common suffixes: _act (actual), _exp (expected), _apb, _sram, _axi, etc.
  // -----------------------------------------------------------------------------
  `uvm_analysis_imp_decl(_act)
  `uvm_analysis_imp_decl(_exp)

  // -----------------------------------------------------------------------------
  // Environment Parameters
  // -----------------------------------------------------------------------------
  parameter int GPIO_NUM_XX_AGENT = 1;  ///< Number of XX agents in the environment

  // -----------------------------------------------------------------------------
  // Environment Modes
  // -----------------------------------------------------------------------------

  /// @brief YY environment operation modes
  typedef enum int {
    GPIO_ENV_NORMAL = 0,  ///< Normal operation mode
    GPIO_ENV_STRESS = 1   ///< Stress test mode
  } gpio_env_mode_e;

`endif
