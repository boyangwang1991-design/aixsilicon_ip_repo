// =============================================================================
// File Name   : tc_sanity.sv
// Description : Sanity test case for basic functionality verification
// =============================================================================

`ifndef TC_SANITY__SV
`define TC_SANITY__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_package::*;

// Include base class (required for separate compilation in VCS)
`include "tc_base.sv"

/// @class tc_sanity
/// @brief Sanity test case - verifies basic environment functionality
///        Extends tc_base and runs the sanity virtual sequence
class tc_sanity extends tc_base;

  `uvm_component_utils(tc_sanity)

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_sanity", uvm_component parent = null);

  /// @brief Run phase - execute sanity test sequence
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_sanity::new(string name = "tc_sanity", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_sanity::run_phase(uvm_phase phase);
  watchdog_sanity_vseq vseq;

  // Raise objection to prevent test from ending
  phase.raise_objection(this);

  `uvm_info(get_type_name(), "Start tc_sanity", UVM_LOW)

  // Create and start sanity virtual sequence
  // Sequence completion is synchronous - no fixed delay needed
  vseq = watchdog_sanity_vseq::type_id::create("vseq");
  vseq.start(env.v_sqr);

  `uvm_info(get_type_name(), "End tc_sanity", UVM_LOW)

  // Drop objection to allow test to end
  phase.drop_objection(this);
endtask

`endif
