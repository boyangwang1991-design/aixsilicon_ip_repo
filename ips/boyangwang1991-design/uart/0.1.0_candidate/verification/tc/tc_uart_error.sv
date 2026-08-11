// =============================================================================
// File Name   : tc_uart_error.sv
// Description : UART error test - TC.FUNC.UART.01.003.ERR
//               Error interrupt injection (frame/parity/break/overflow/timeout).
// =============================================================================

`ifndef TC_UART_ERROR__SV
`define TC_UART_ERROR__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_package::*;
  import uart_env_package::*;

// Include base class (required for separate compilation in VCS)
`include "tc_base.sv"

/// @class tc_uart_error
/// @brief Error injection testcase - error interrupts
class tc_uart_error extends tc_base;

  `uvm_component_utils(tc_uart_error)

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_uart_error", uvm_component parent = null);

  /// @brief Run phase - execute error virtual sequence
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_uart_error::new(string name = "tc_uart_error", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_uart_error::run_phase(uvm_phase phase);
  uart_error_vseq vseq;

  phase.raise_objection(this);

  `uvm_info(get_type_name(), "=== tc_uart_error: start ===", UVM_LOW)

  vseq = uart_error_vseq::type_id::create("vseq");
  vseq.start(env.v_sqr);

  `uvm_info(get_type_name(), "=== tc_uart_error: end ===", UVM_LOW)

  phase.drop_objection(this);
endtask

`endif
