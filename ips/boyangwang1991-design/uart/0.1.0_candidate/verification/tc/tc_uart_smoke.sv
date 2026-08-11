// =============================================================================
// File Name   : tc_uart_smoke.sv
// Description : UART smoke test - TC.INTF.UART.01.001.SMOKE
//               Reset + basic register access + TX/RX system loopback.
// =============================================================================

`ifndef TC_UART_SMOKE__SV
`define TC_UART_SMOKE__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_package::*;
  import uart_env_package::*;

// Include base class (required for separate compilation in VCS)
`include "tc_base.sv"

/// @class tc_uart_smoke
/// @brief Smoke testcase - verifies reset, register access and loopback
class tc_uart_smoke extends tc_base;

  `uvm_component_utils(tc_uart_smoke)

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_uart_smoke", uvm_component parent = null);

  /// @brief Run phase - execute smoke virtual sequence
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_uart_smoke::new(string name = "tc_uart_smoke", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_uart_smoke::run_phase(uvm_phase phase);
  uart_smoke_vseq vseq;

  phase.raise_objection(this);

  `uvm_info(get_type_name(), "=== tc_uart_smoke: start ===", UVM_LOW)

  vseq = uart_smoke_vseq::type_id::create("vseq");
  vseq.start(env.v_sqr);

  `uvm_info(get_type_name(), "=== tc_uart_smoke: end ===", UVM_LOW)

  phase.drop_objection(this);
endtask

`endif
