// =============================================================================
// File Name   : pqc_rm.sv
// Description : YY reference model implementation
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef PQC_RM__SV
`define PQC_RM__SV

/// @class pqc_rm
/// @brief YY reference model (golden model)
///        Receives input transactions and generates expected output for comparison
class pqc_rm extends uvm_component;

  pqc_rm_cfg cfg;  ///< Reference model configuration handle

  uvm_analysis_imp #(apb_xaction, pqc_rm) in_export;  ///< Input analysis export
  uvm_analysis_port #(apb_xaction)       exp_ap;     ///< Expected output analysis port

  `uvm_component_utils_begin(pqc_rm)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Reference model name string
  /// @param parent Parent component handle
  extern function new(string name = "pqc_rm", uvm_component parent = null);

  /// @brief Build phase - get configuration
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Process input transaction and generate expected output
  ///        Override this method in subclass to implement DUT-specific reference model logic
  /// @param tr Input transaction to process
  /// @return Expected output transaction
  extern virtual function apb_xaction process_transaction(apb_xaction tr);

  /// @brief Write function - process input transaction and broadcast expected output
  /// @param tr Input transaction to process
  extern virtual function void write(apb_xaction tr);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Reference model name string
/// @param parent Parent component handle
function pqc_rm::new(string name = "pqc_rm", uvm_component parent = null);
  super.new(name, parent);
  in_export = new("in_export", this);
  exp_ap    = new("exp_ap", this);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void pqc_rm::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db #(pqc_rm_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = pqc_rm_cfg::type_id::create("cfg");
  end
endfunction

/// @brief Process input transaction definition
/// @param tr Input transaction to process
/// @return Expected output transaction
function apb_xaction pqc_rm::process_transaction(apb_xaction tr);
  apb_xaction exp;

  exp = apb_xaction::type_id::create("exp");
  exp.copy(tr);

  // TODO: Override this method in subclass to implement DUT-specific logic
  //       Transform input transaction to expected output based on DUT specification

  return exp;
endfunction

/// @brief Write function definition
/// @param tr Input transaction to process
function void pqc_rm::write(apb_xaction tr);
  apb_xaction exp = process_transaction(tr);
  exp_ap.write(exp);
endfunction

`endif
