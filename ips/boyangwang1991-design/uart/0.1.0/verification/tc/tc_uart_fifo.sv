// =============================================================================
// File Name   : tc_uart_fifo.sv
// Description : UART FIFO test - TC.FUNC.UART.01.004.FIFO
//               FIFO status, watermarks and soft reset.
// =============================================================================

`ifndef TC_UART_FIFO__SV
`define TC_UART_FIFO__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_package::*;
  import uart_env_package::*;

// Include base class (required for separate compilation in VCS)
`include "tc_base.sv"

/// @class tc_uart_fifo
/// @brief FIFO boundary testcase
class tc_uart_fifo extends tc_base;

  `uvm_component_utils(tc_uart_fifo)

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_uart_fifo", uvm_component parent = null);

  /// @brief Run phase - execute FIFO virtual sequence
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_uart_fifo::new(string name = "tc_uart_fifo", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_uart_fifo::run_phase(uvm_phase phase);
  uart_fifo_vseq vseq;

  phase.raise_objection(this);

  `uvm_info(get_type_name(), "=== tc_uart_fifo: start ===", UVM_LOW)

  vseq = uart_fifo_vseq::type_id::create("vseq");
  vseq.start(env.v_sqr);

  `uvm_info(get_type_name(), "=== tc_uart_fifo: end ===", UVM_LOW)

  phase.drop_objection(this);
endtask

`endif
