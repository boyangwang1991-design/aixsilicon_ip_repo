// =============================================================================
// File Name   : apb_sequencer.sv
// Description : XX protocol sequencer
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef APB_SEQUENCER__SV
`define APB_SEQUENCER__SV

/// @class apb_sequencer
/// @brief XX protocol sequencer
///        Extends uvm_sequencer to handle apb_xaction transactions
///        Connects to driver and manages sequence item requests
class apb_sequencer extends uvm_sequencer #(apb_xaction);

  `uvm_component_utils_begin(apb_sequencer)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Sequencer name string
  /// @param parent Parent component handle
  extern function new(string name = "apb_sequencer", uvm_component parent = null);

  /// @brief Build phase - get configuration from config_db
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Sequencer name string
/// @param parent Parent component handle
function apb_sequencer::new(string name = "apb_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void apb_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // TODO: Add build logic here (e.g., get config from config_db)
endfunction

`endif
