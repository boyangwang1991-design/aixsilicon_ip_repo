// =============================================================================
// File Name   : tlul_sequencer.sv
// Description : XX protocol sequencer
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef TLUL_SEQUENCER__SV
`define TLUL_SEQUENCER__SV

/// @class tlul_sequencer
/// @brief XX protocol sequencer
///        Extends uvm_sequencer to handle tlul_xaction transactions
///        Connects to driver and manages sequence item requests
class tlul_sequencer extends uvm_sequencer #(tlul_xaction);

  `uvm_component_utils_begin(tlul_sequencer)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Sequencer name string
  /// @param parent Parent component handle
  extern function new(string name = "tlul_sequencer", uvm_component parent = null);

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
function tlul_sequencer::new(string name = "tlul_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void tlul_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // TODO: Add build logic here (e.g., get config from config_db)
endfunction

`endif
