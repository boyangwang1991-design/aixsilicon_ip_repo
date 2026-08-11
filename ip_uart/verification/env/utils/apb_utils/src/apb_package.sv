// =============================================================================
// File Name   : apb_package.sv
// Description : XX protocol package - aggregates all XX agent classes
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef APB_PACKAGE__SV
`define APB_PACKAGE__SV

// =============================================================================
// External includes (interface and package definitions must be outside package)
// =============================================================================
`include "apb_dec.sv"
`include "apb_interface.sv"

/// @package apb_package
/// @brief XX protocol package containing all agent components
///        Import this package to access XX-specific verification components:
///        - apb_driver, apb_slave_driver
///        - apb_monitor, apb_monitor_cov
///        - apb_sequencer, apb_interface_agent
///        - apb_xaction, apb_base_sequence, apb_default_sequence
package apb_package;

  import uvm_pkg::*;
  import apb_dec::*;  // Import protocol parameters, typedefs, and constants
  `include "uvm_macros.svh"

  // Include all XX classes in dependency order
  `include "apb_xaction.sv"
  `include "apb_driver_cfg.sv"
  `include "apb_driver.sv"
  `include "apb_slave_driver_cfg.sv"
  `include "apb_slave_driver.sv"
  `include "apb_monitor_cfg.sv"
  `include "apb_monitor.sv"
  `include "apb_monitor_cov.sv"
  `include "apb_sequencer.sv"
  `include "apb_interface_agent_cfg.sv"
  `include "apb_interface_agent.sv"
  `include "apb_sequence_library.svp"

endpackage

`endif
