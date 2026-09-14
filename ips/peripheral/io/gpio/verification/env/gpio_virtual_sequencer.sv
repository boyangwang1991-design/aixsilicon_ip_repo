// =============================================================================
// File Name   : gpio_virtual_sequencer.sv
// Description : YY virtual sequencer for coordinating multiple agents
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef GPIO_VIRTUAL_SEQUENCER__SV
`define GPIO_VIRTUAL_SEQUENCER__SV

/// @class gpio_virtual_sequencer
/// @brief YY virtual sequencer for coordinating multiple agent sequencers
///        Provides handles to all agent sequencers for virtual sequences
class gpio_virtual_sequencer extends uvm_sequencer;

  apb_sequencer apb_sqr;  ///< Handle to first protocol agent sequencer

  `uvm_component_utils(gpio_virtual_sequencer)

  /// @brief Constructor
  /// @param name   Virtual sequencer name string
  /// @param parent Parent component handle
  extern function new(string name = "gpio_virtual_sequencer", uvm_component parent = null);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Virtual sequencer name string
/// @param parent Parent component handle
function gpio_virtual_sequencer::new(string name = "gpio_virtual_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

`endif
