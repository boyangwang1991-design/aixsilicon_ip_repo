// =============================================================================
// File Name   : uart_env_dec.sv
// Description : UART environment declarations (modes, parameters)
//               Imported by uart_env_package for env type visibility.
//
// NOTE: uvm_analysis_imp_decl suffixes (_act/_exp/_tlul/_apb) are declared in
//       uart_checker.sv (the only consumer), not here, to avoid class
//       redefinition errors in the shared env package.
// =============================================================================

`ifndef UART_ENV_DEC__SV
`define UART_ENV_DEC__SV

/// @package uart_env_dec
/// @brief UART environment parameters, modes, and types
package uart_env_dec;

  // ---------------------------------------------------------------------------
  // Environment Parameters
  // ---------------------------------------------------------------------------
  parameter int UART_NUM_TLUL_AGENT = 1;  ///< Number of TL-UL agents
  parameter int UART_NUM_APB_AGENT  = 1;  ///< Number of APB agents
  parameter int UART_NUM_UART_AGENT = 1;  ///< Number of UART serial agents

  // ---------------------------------------------------------------------------
  // Environment Modes
  // ---------------------------------------------------------------------------

  /// @brief UART environment operation modes
  typedef enum int {
    UART_ENV_NORMAL = 0,  ///< Normal operation mode
    UART_ENV_STRESS = 1   ///< Stress test mode
  } uart_env_mode_e;

endpackage

`endif
