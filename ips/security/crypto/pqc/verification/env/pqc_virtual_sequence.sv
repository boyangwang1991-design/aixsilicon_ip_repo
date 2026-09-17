// =============================================================================
// File Name   : pqc_virtual_sequence.sv
// Description : PQC virtual sequence base
//
// Provides register access helpers on top of the APB VIP's public API
// (ADR-13: the VIP exposes sequences; there is no blocking env-level API).
// Concrete testcases extend this class.
// =============================================================================

`ifndef PQC_VIRTUAL_SEQUENCE__SV
`define PQC_VIRTUAL_SEQUENCE__SV

class pqc_virtual_sequence extends uvm_sequence;

  `uvm_object_utils(pqc_virtual_sequence)

  // Handle to the virtual sequencer is fetched from config_db in body()
  pqc_virtual_sequencer v_sqr;

  function new(string name = "pqc_virtual_sequence");
    super.new(name);
  endfunction

  task body();
    if (!uvm_config_db #(pqc_virtual_sequencer)::get(null, get_full_name(), "v_sqr", v_sqr))
      `uvm_fatal(get_type_name(), "virtual sequencer handle not set")
  endtask

endclass

`endif // PQC_VIRTUAL_SEQUENCE__SV
