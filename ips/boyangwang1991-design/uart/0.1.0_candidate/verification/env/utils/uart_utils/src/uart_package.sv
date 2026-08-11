// =============================================================================
// File Name   : uart_package.sv
// Description : XX protocol package - aggregates all XX agent classes
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef UART_PACKAGE__SV
`define UART_PACKAGE__SV

// =============================================================================
// External includes (interface and package definitions must be outside package)
// =============================================================================
`include "uart_dec.sv"
`include "uart_interface.sv"

/// @package uart_package
/// @brief XX protocol package containing all agent components
///        Import this package to access XX-specific verification components:
///        - uart_driver, uart_slave_driver
///        - uart_monitor, uart_monitor_cov
///        - uart_sequencer, uart_interface_agent
///        - uart_xaction, uart_base_sequence, uart_default_sequence
package uart_package;

  import uvm_pkg::*;
  import uart_dec::*;  // Import protocol parameters, typedefs, and constants
  `include "uvm_macros.svh"

  // Include all XX classes in dependency order
  `include "uart_xaction.sv"
  `include "uart_driver_cfg.sv"
  `include "uart_driver.sv"
  `include "uart_slave_driver_cfg.sv"
  `include "uart_slave_driver.sv"
  `include "uart_monitor_cfg.sv"
  `include "uart_monitor.sv"
  `include "uart_monitor_cov.sv"
  `include "uart_sequencer.sv"
  `include "uart_interface_agent_cfg.sv"
  `include "uart_interface_agent.sv"
  `include "uart_sequence_library.svp"

endpackage

`endif
