// =============================================================================
// File Name   : pqc_checker.sv
// Description : YY checker/scoreboard implementation
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef PQC_CHECKER__SV
`define PQC_CHECKER__SV

// Declare analysis import suffixes for actual and expected data paths
`uvm_analysis_imp_decl(_act)
`uvm_analysis_imp_decl(_exp)

/// @class pqc_checker
/// @brief YY checker/scoreboard component
///        Compares actual DUT output with expected reference model output
class pqc_checker extends uvm_component;

  pqc_checker_cfg cfg;  ///< Checker configuration handle

  uvm_analysis_imp_act #(apb_xaction, pqc_checker) act_export;  ///< Actual data input
  uvm_analysis_imp_exp #(apb_xaction, pqc_checker) exp_export;  ///< Expected data input

  apb_xaction act_q[$];  ///< Queue for actual transactions
  apb_xaction exp_q[$];  ///< Queue for expected transactions

  int match_count = 0;  ///< Count of matched transactions
  int error_count = 0;  ///< Count of mismatched transactions

  `uvm_component_utils_begin(pqc_checker)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Checker name string
  /// @param parent Parent component handle
  extern function new(string name = "pqc_checker", uvm_component parent = null);

  /// @brief Build phase - get configuration
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Connect phase - establish TLM connections
  /// @param phase Current phase handle
  extern virtual function void connect_phase(uvm_phase phase);

  /// @brief Write actual data - called when DUT output arrives
  /// @param tr Actual transaction from DUT
  extern virtual function void write_act(apb_xaction tr);

  /// @brief Write expected data - called when reference model output arrives
  /// @param tr Expected transaction from reference model
  extern virtual function void write_exp(apb_xaction tr);

  /// @brief Compare actual and expected transactions
  ///        Performs FIFO matching of transactions
  extern virtual function void compare();

  /// @brief Check phase - verify no unmatched transactions at end of test
  /// @param phase Current phase handle
  extern virtual function void check_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Checker name string
/// @param parent Parent component handle
function pqc_checker::new(string name = "pqc_checker", uvm_component parent = null);
  super.new(name, parent);
  act_export = new("act_export", this);
  exp_export = new("exp_export", this);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void pqc_checker::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db #(pqc_checker_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = pqc_checker_cfg::type_id::create("cfg");
  end
endfunction

/// @brief Connect phase definition
/// @param phase Current phase handle
function void pqc_checker::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // TODO: Add connect logic here (e.g., connect analysis ports to sub-components)
endfunction

/// @brief Write actual data definition
/// @param tr Actual transaction from DUT
function void pqc_checker::write_act(apb_xaction tr);
  apb_xaction tr_clone;

  if (!$cast(tr_clone, tr.clone())) begin
    `uvm_fatal(get_type_name(), "Failed to clone actual transaction")
  end

  act_q.push_back(tr_clone);
  compare();
endfunction

/// @brief Write expected data definition
/// @param tr Expected transaction from reference model
function void pqc_checker::write_exp(apb_xaction tr);
  apb_xaction tr_clone;

  if (!$cast(tr_clone, tr.clone())) begin
    `uvm_fatal(get_type_name(), "Failed to clone expected transaction")
  end

  exp_q.push_back(tr_clone);
  compare();
endfunction

/// @brief Compare definition
function void pqc_checker::compare();
  apb_xaction act;
  apb_xaction exp;

  // Compare when both actual and expected data are available
  while (act_q.size() > 0 && exp_q.size() > 0) begin
    act = act_q.pop_front();
    exp = exp_q.pop_front();

    if (!act.compare(exp)) begin
      error_count++;
      `uvm_error(get_type_name(), $sformatf(
        "Compare failed (%0d)\nACT:\n%s\nEXP:\n%s",
        error_count, act.sprint(), exp.sprint()
      ))
    end
    else begin
      match_count++;
      `uvm_info(get_type_name(), $sformatf("Compare passed (%0d)", match_count), UVM_HIGH)
    end
  end
endfunction

/// @brief Check phase definition
/// @param phase Current phase handle
function void pqc_checker::check_phase(uvm_phase phase);
  super.check_phase(phase);

  if (act_q.size() > 0) begin
    `uvm_error(get_type_name(), $sformatf(
      "Test ended with %0d unmatched actual transactions", act_q.size()
    ))
  end

  if (exp_q.size() > 0) begin
    `uvm_error(get_type_name(), $sformatf(
      "Test ended with %0d unmatched expected transactions", exp_q.size()
    ))
  end

  `uvm_info(get_type_name(), $sformatf(
    "Checker summary: %0d matches, %0d errors",
    match_count, error_count
  ), UVM_LOW)
endfunction

`endif
