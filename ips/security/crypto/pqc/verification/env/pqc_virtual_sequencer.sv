// =============================================================================
// File Name   : pqc_virtual_sequencer.sv
// Description : YY virtual sequencer for coordinating multiple agents
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef PQC_VIRTUAL_SEQUENCER__SV
`define PQC_VIRTUAL_SEQUENCER__SV

/// @class pqc_virtual_sequencer
/// @brief YY virtual sequencer for coordinating multiple agent sequencers
///        Provides handles to all agent sequencers for virtual sequences
class pqc_virtual_sequencer extends uvm_sequencer;

  apb_sequencer apb_sqr;  ///< Handle to first protocol agent sequencer

  `uvm_component_utils(pqc_virtual_sequencer)

  /// @brief Constructor
  /// @param name   Virtual sequencer name string
  /// @param parent Parent component handle
  extern function new(string name = "pqc_virtual_sequencer", uvm_component parent = null);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Virtual sequencer name string
/// @param parent Parent component handle
function pqc_virtual_sequencer::new(string name = "pqc_virtual_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

`endif
