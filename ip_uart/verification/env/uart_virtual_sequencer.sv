// =============================================================================
// File Name   : uart_virtual_sequencer.sv
// Description : YY virtual sequencer for coordinating multiple agents
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef UART_VIRTUAL_SEQUENCER__SV
`define UART_VIRTUAL_SEQUENCER__SV

/// @class uart_virtual_sequencer
/// @brief YY virtual sequencer for coordinating multiple agent sequencers
///        Provides handles to all agent sequencers for virtual sequences
class uart_virtual_sequencer extends uvm_sequencer;

  uart_sequencer uart_sqr;  ///< Handle to UART serial agent sequencer
  tlul_sequencer tlul_sqr;  ///< Handle to TL-UL bus agent sequencer
  apb_sequencer  apb_sqr;   ///< Handle to APB bus agent sequencer

  `uvm_component_utils(uart_virtual_sequencer)

  /// @brief Constructor
  /// @param name   Virtual sequencer name string
  /// @param parent Parent component handle
  extern function new(string name = "uart_virtual_sequencer", uvm_component parent = null);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Virtual sequencer name string
/// @param parent Parent component handle
function uart_virtual_sequencer::new(string name = "uart_virtual_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

`endif
