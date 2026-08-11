// =============================================================================
// File Name   : tlul_package.sv
// Description : XX protocol package - aggregates all XX agent classes
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef TLUL_PACKAGE__SV
`define TLUL_PACKAGE__SV

// =============================================================================
// External includes (interface and package definitions must be outside package)
// =============================================================================
`include "tlul_dec.sv"
`include "tlul_interface.sv"

/// @package tlul_package
/// @brief XX protocol package containing all agent components
///        Import this package to access XX-specific verification components:
///        - tlul_driver, tlul_slave_driver
///        - tlul_monitor, tlul_monitor_cov
///        - tlul_sequencer, tlul_interface_agent
///        - tlul_xaction, tlul_base_sequence, tlul_default_sequence
package tlul_package;

  import uvm_pkg::*;
  import tlul_dec::*;  // Import protocol parameters, typedefs, and constants
  `include "uvm_macros.svh"

  // Include all XX classes in dependency order
  `include "tlul_xaction.sv"
  `include "tlul_driver_cfg.sv"
  `include "tlul_driver.sv"
  `include "tlul_slave_driver_cfg.sv"
  `include "tlul_slave_driver.sv"
  `include "tlul_monitor_cfg.sv"
  `include "tlul_monitor.sv"
  `include "tlul_monitor_cov.sv"
  `include "tlul_sequencer.sv"
  `include "tlul_interface_agent_cfg.sv"
  `include "tlul_interface_agent.sv"
  `include "tlul_sequence_library.svp"

endpackage

`endif
