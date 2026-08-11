// =============================================================================
// File Name   : uart_env_package.sv
// Description : UART environment package - wraps all env components so they
//               can access UVM imports and protocol agent package types.
//               Must be compiled AFTER the three agent packages.
// =============================================================================

`ifndef UART_ENV_PACKAGE__SV
`define UART_ENV_PACKAGE__SV

/// @package uart_env_package
/// @brief UART verification environment package
///        Aggregates env_cfg, env, virtual sequencer, RM, checker, coverage.
package uart_env_package;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Import protocol dec packages for parameter/enum visibility (TLUL_READ, ...)
  import uart_dec::*;
  import tlul_dec::*;
  import apb_dec::*;

  // Import protocol agent packages for type visibility (xaction, agent, ...)
  import uart_package::*;
  import tlul_package::*;
  import apb_package::*;

  // Import environment declarations (modes, parameters)
  import uart_env_dec::*;

  // =========================================================================
  // Analysis Imp Declarations (single definition point for the whole package)
  // Declared once here; consumed by uart_checker and uart_rm. Declaring these
  // in individual files would cause class redefinition errors.
  // =========================================================================
  `uvm_analysis_imp_decl(_act)
  `uvm_analysis_imp_decl(_exp)
  `uvm_analysis_imp_decl(_tlul)
  `uvm_analysis_imp_decl(_apb)
  `uvm_analysis_imp_decl(_uart)

  // Include all environment components in dependency order
  `include "uart_dut_cfg.sv"
  `include "uart_rm_cfg.sv"
  `include "uart_rm.sv"
  `include "uart_checker_cfg.sv"
  `include "uart_checker.sv"
  `include "uart_fcov.sv"
  `include "uart_virtual_sequencer.sv"
  `include "uart_virtual_sequence.sv"
  `include "uart_env_cfg.sv"
  `include "uart_env.sv"

endpackage

`endif
