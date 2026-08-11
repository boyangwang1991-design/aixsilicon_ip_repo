// =============================================================================
// File Name   : tc_uart_perf.sv
// Description : UART performance test - TC.PERF.UART.01.006.PERF
//               Baud rate / NCO configuration coverage.
// =============================================================================

`ifndef TC_UART_PERF__SV
`define TC_UART_PERF__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_package::*;
  import uart_env_package::*;

// Include base class (required for separate compilation in VCS)
`include "tc_base.sv"

/// @class tc_uart_perf
/// @brief Performance testcase - baud rate / NCO
class tc_uart_perf extends tc_base;

  `uvm_component_utils(tc_uart_perf)

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_uart_perf", uvm_component parent = null);

  /// @brief Run phase - execute performance virtual sequence
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_uart_perf::new(string name = "tc_uart_perf", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_uart_perf::run_phase(uvm_phase phase);
  uart_perf_vseq vseq;

  phase.raise_objection(this);

  `uvm_info(get_type_name(), "=== tc_uart_perf: start ===", UVM_LOW)

  vseq = uart_perf_vseq::type_id::create("vseq");
  vseq.start(env.v_sqr);

  `uvm_info(get_type_name(), "=== tc_uart_perf: end ===", UVM_LOW)

  phase.drop_objection(this);
endtask

`endif
