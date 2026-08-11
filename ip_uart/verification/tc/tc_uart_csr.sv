// =============================================================================
// File Name   : tc_uart_csr.sv
// Description : UART CSR test - TC.REG.UART.01.005.CSR
//               Register read/write, W1C and reset values.
// =============================================================================

`ifndef TC_UART_CSR__SV
`define TC_UART_CSR__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_package::*;
  import uart_env_package::*;

// Include base class (required for separate compilation in VCS)
`include "tc_base.sv"

/// @class tc_uart_csr
/// @brief Register access testcase
class tc_uart_csr extends tc_base;

  `uvm_component_utils(tc_uart_csr)

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_uart_csr", uvm_component parent = null);

  /// @brief Run phase - execute CSR virtual sequence
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_uart_csr::new(string name = "tc_uart_csr", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_uart_csr::run_phase(uvm_phase phase);
  uart_csr_vseq vseq;

  phase.raise_objection(this);

  `uvm_info(get_type_name(), "=== tc_uart_csr: start ===", UVM_LOW)

  vseq = uart_csr_vseq::type_id::create("vseq");
  vseq.start(env.v_sqr);

  `uvm_info(get_type_name(), "=== tc_uart_csr: end ===", UVM_LOW)

  phase.drop_objection(this);
endtask

`endif
