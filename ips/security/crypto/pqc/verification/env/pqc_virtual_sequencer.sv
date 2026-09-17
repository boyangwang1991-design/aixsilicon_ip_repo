// =============================================================================
// File Name   : pqc_virtual_sequencer.sv
// Description : PQC virtual sequencer
//
// Holds handles to the protocol VIP sequencers so virtual sequences can
// coordinate APB (control) and AXI4 (DMA) traffic from one place. No
// transaction logic lives here.
//
// The VIP sequencer types come from the VIP packages, which are compiled before
// this unit; import them explicitly because this is a separate compilation unit.
// =============================================================================

`ifndef PQC_VIRTUAL_SEQUENCER__SV
`define PQC_VIRTUAL_SEQUENCER__SV

  import apb_types_pkg::*;
  import apb_pkg::*;

class pqc_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(pqc_virtual_sequencer)

  // APB VIP requester sequencer (the VIP owns the driver).
  // No AXI4 VIP sequencer is held: DMA verification is deferred together with
  // the open DMA data path (see verification/th/harness.sv).
  apb_master_sequencer apb_sqr;

  function new(string name = "pqc_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

`endif // PQC_VIRTUAL_SEQUENCER__SV
