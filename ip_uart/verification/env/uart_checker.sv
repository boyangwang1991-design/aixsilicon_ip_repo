// =============================================================================
// File Name   : uart_checker.sv
// Description : UART checker/scoreboard - compares DUT serial TX output with
//               reference model expectations, and monitors TL-UL / APB bus
//               register accesses for protocol integrity.
// =============================================================================

`ifndef UART_CHECKER__SV
`define UART_CHECKER__SV

// -----------------------------------------------------------------------------
// NOTE: Included inside uart_env_package, which provides the UVM import and the
//       analysis imp declarations (_act/_exp/_tlul/_apb) via uvm_analysis_imp_decl.
//       This file must NOT re-declare them (class redefinition error).
// -----------------------------------------------------------------------------

/// @class uart_checker
/// @brief UART checker/scoreboard component
///        Compares actual DUT serial output with expected reference model
///        output and validates TL-UL / APB bus accesses.
class uart_checker extends uvm_component;

  uart_checker_cfg cfg;  ///< Checker configuration handle

  // ===========================================================================
  // Analysis Imports
  // ===========================================================================
  uvm_analysis_imp_act  #(uart_xaction, uart_checker) act_export;  ///< Actual UART data input
  uvm_analysis_imp_exp  #(uart_xaction, uart_checker) exp_export;  ///< Expected UART data input
  uvm_analysis_imp_tlul #(tlul_xaction, uart_checker) tlul_export; ///< TL-UL bus access input
  uvm_analysis_imp_apb  #(apb_xaction,  uart_checker) apb_export;  ///< APB bus access input

  // ===========================================================================
  // Transaction Queues
  // ===========================================================================
  uart_xaction act_q[$];  ///< Queue for actual serial transactions
  uart_xaction exp_q[$];  ///< Queue for expected serial transactions
  tlul_xaction tlul_q[$]; ///< Queue for TL-UL bus transactions
  apb_xaction  apb_q[$];  ///< Queue for APB bus transactions

  // ===========================================================================
  // Statistics
  // ===========================================================================
  int match_count    = 0;  ///< Count of matched transactions
  int error_count    = 0;  ///< Count of mismatched transactions
  int tlul_count     = 0;  ///< Count of observed TL-UL accesses
  int apb_count      = 0;  ///< Count of observed APB accesses
  int tlul_err_count = 0;  ///< Count of TL-UL protocol violations
  int apb_err_count  = 0;  ///< Count of APB protocol violations

  `uvm_component_utils_begin(uart_checker)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Checker name string
  /// @param parent Parent component handle
  extern function new(string name = "uart_checker", uvm_component parent = null);

  /// @brief Build phase - get configuration
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Connect phase - establish TLM connections
  /// @param phase Current phase handle
  extern virtual function void connect_phase(uvm_phase phase);

  /// @brief Write actual serial data - called when DUT TX output arrives
  /// @param tr Actual transaction from UART monitor
  extern virtual function void write_act(uart_xaction tr);

  /// @brief Write expected serial data - called when reference model output arrives
  /// @param tr Expected transaction from reference model
  extern virtual function void write_exp(uart_xaction tr);

  /// @brief Write TL-UL bus access - called when TL-UL monitor samples a transfer
  /// @param tr TL-UL transaction from TL-UL monitor
  extern virtual function void write_tlul(tlul_xaction tr);

  /// @brief Write APB bus access - called when APB monitor samples a transfer
  /// @param tr APB transaction from APB monitor
  extern virtual function void write_apb(apb_xaction tr);

  /// @brief Compare actual and expected UART transactions (FIFO matching)
  extern virtual function void compare_uart();

  /// @brief Validate TL-UL transaction integrity (addr alignment, cmd/strb)
  /// @param tr TL-UL transaction under check
  extern virtual function void check_tlul(tlul_xaction tr);

  /// @brief Validate APB transaction integrity (cmd/strb consistency)
  /// @param tr APB transaction under check
  extern virtual function void check_apb(apb_xaction tr);

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
function uart_checker::new(string name = "uart_checker", uvm_component parent = null);
  super.new(name, parent);
  act_export  = new("act_export", this);
  exp_export  = new("exp_export", this);
  tlul_export = new("tlul_export", this);
  apb_export  = new("apb_export", this);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void uart_checker::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db #(uart_checker_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = uart_checker_cfg::type_id::create("cfg");
  end
endfunction

/// @brief Connect phase definition
/// @param phase Current phase handle
function void uart_checker::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // No sub-components to connect; all data arrives via analysis imports.
endfunction

/// @brief Write actual serial data definition
/// @param tr Actual transaction from UART monitor
function void uart_checker::write_act(uart_xaction tr);
  uart_xaction tr_clone;

  if (!$cast(tr_clone, tr.clone())) begin
    `uvm_fatal(get_type_name(), "Failed to clone actual transaction")
  end

  act_q.push_back(tr_clone);
  compare_uart();
endfunction

/// @brief Write expected serial data definition
/// @param tr Expected transaction from reference model
function void uart_checker::write_exp(uart_xaction tr);
  uart_xaction tr_clone;

  if (!$cast(tr_clone, tr.clone())) begin
    `uvm_fatal(get_type_name(), "Failed to clone expected transaction")
  end

  exp_q.push_back(tr_clone);
  compare_uart();
endfunction

/// @brief Write TL-UL bus access definition
/// @param tr TL-UL transaction from TL-UL monitor
function void uart_checker::write_tlul(tlul_xaction tr);
  tlul_xaction tr_clone;

  if (!$cast(tr_clone, tr.clone())) begin
    `uvm_fatal(get_type_name(), "Failed to clone TL-UL transaction")
  end

  tlul_q.push_back(tr_clone);
  tlul_count++;
  check_tlul(tr_clone);
endfunction

/// @brief Write APB bus access definition
/// @param tr APB transaction from APB monitor
function void uart_checker::write_apb(apb_xaction tr);
  apb_xaction tr_clone;

  if (!$cast(tr_clone, tr.clone())) begin
    `uvm_fatal(get_type_name(), "Failed to clone APB transaction")
  end

  apb_q.push_back(tr_clone);
  apb_count++;
  check_apb(tr_clone);
endfunction

/// @brief Compare actual vs expected UART transactions definition
function void uart_checker::compare_uart();
  uart_xaction act;
  uart_xaction exp;

  // Compare when both actual and expected data are available
  while (act_q.size() > 0 && exp_q.size() > 0) begin
    act = act_q.pop_front();
    exp = exp_q.pop_front();

    // Field-level comparison: data byte and parity configuration
    if ((act.data != exp.data) ||
        (act.parity_en != exp.parity_en) ||
        (act.parity_odd != exp.parity_odd)) begin
      error_count++;
      `uvm_error(get_type_name(), $sformatf(
        "UART compare failed (%0d)\nACT:\n%s\nEXP:\n%s",
        error_count, act.sprint(), exp.sprint()
      ))
    end
    else begin
      match_count++;
      `uvm_info(get_type_name(), $sformatf(
        "UART compare passed (%0d): data=0x%02x", match_count, act.data
      ), UVM_HIGH)
    end
  end
endfunction

/// @brief Validate TL-UL transaction integrity definition
/// @param tr TL-UL transaction under check
function void uart_checker::check_tlul(tlul_xaction tr);
  // TL-UL word-aligned access check
  if (tr.addr[1:0] != 2'b00) begin
    tlul_err_count++;
    `uvm_error(get_type_name(), $sformatf(
      "TL-UL misaligned access: addr=0x%0h cmd=%s", tr.addr, tr.cmd.name()
    ))
  end
  // Command / strobe consistency
  if ((tr.cmd == TLUL_READ) && (tr.strb != '0)) begin
    tlul_err_count++;
    `uvm_error(get_type_name(), $sformatf(
      "TL-UL read with non-zero strb: strb=0x%0h", tr.strb
    ))
  end
  if ((tr.cmd == TLUL_WRITE) && (tr.strb == '0)) begin
    tlul_err_count++;
    `uvm_error(get_type_name(), "TL-UL write with zero strb")
  end
endfunction

/// @brief Validate APB transaction integrity definition
/// @param tr APB transaction under check
function void uart_checker::check_apb(apb_xaction tr);
  // Command / strobe consistency
  if ((tr.cmd == APB_READ) && (tr.strb != '0)) begin
    apb_err_count++;
    `uvm_error(get_type_name(), $sformatf(
      "APB read with non-zero strb: strb=0x%0h", tr.strb
    ))
  end
  if ((tr.cmd == APB_WRITE) && (tr.strb == '0)) begin
    apb_err_count++;
    `uvm_error(get_type_name(), "APB write with zero strb")
  end
endfunction

/// @brief Check phase definition
/// @param phase Current phase handle
function void uart_checker::check_phase(uvm_phase phase);
  super.check_phase(phase);

  if (act_q.size() > 0) begin
    `uvm_error(get_type_name(), $sformatf(
      "Test ended with %0d unmatched actual UART transactions", act_q.size()
    ))
  end

  if (exp_q.size() > 0) begin
    `uvm_error(get_type_name(), $sformatf(
      "Test ended with %0d unmatched expected UART transactions", exp_q.size()
    ))
  end

  `uvm_info(get_type_name(), $sformatf(
    "Checker summary: %0d UART matches, %0d UART errors, ",
    match_count, error_count
  ), UVM_LOW)
  `uvm_info(get_type_name(), $sformatf(
    "Checker summary: %0d TL-UL accesses (%0d violations), %0d APB accesses (%0d violations)",
    tlul_count, tlul_err_count, apb_count, apb_err_count
  ), UVM_LOW)
endfunction

`endif
