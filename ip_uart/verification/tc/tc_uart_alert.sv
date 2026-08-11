// =============================================================================
// File Name   : tc_uart_alert.sv
// Description : UART alert test - TC.SAFE.UART.01.007.ALERT
//               ALERT_TEST injection.
// =============================================================================

`ifndef TC_UART_ALERT__SV
`define TC_UART_ALERT__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_package::*;
  import uart_env_package::*;

// Include base class (required for separate compilation in VCS)
`include "tc_base.sv"

/// @class tc_uart_alert
/// @brief Alert testcase - ALERT_TEST injection
class tc_uart_alert extends tc_base;

  `uvm_component_utils(tc_uart_alert)

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_uart_alert", uvm_component parent = null);

  /// @brief Run phase - execute alert virtual sequence
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_uart_alert::new(string name = "tc_uart_alert", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_uart_alert::run_phase(uvm_phase phase);
  uart_alert_vseq vseq;

  phase.raise_objection(this);

  `uvm_info(get_type_name(), "=== tc_uart_alert: start ===", UVM_LOW)

  vseq = uart_alert_vseq::type_id::create("vseq");
  vseq.start(env.v_sqr);

  `uvm_info(get_type_name(), "=== tc_uart_alert: end ===", UVM_LOW)

  phase.drop_objection(this);
endtask

`endif
