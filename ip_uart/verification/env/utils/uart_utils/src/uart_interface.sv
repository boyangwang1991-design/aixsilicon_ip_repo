// =============================================================================
// File Name   : uart_interface.sv
// Description : UART serial protocol virtual interface
//               Driver drives rx line (external UART), monitor samples tx.
// =============================================================================

`ifndef UART_INTERFACE__SV
`define UART_INTERFACE__SV

interface uart_interface(
  input logic clk,
  input logic rst_n
);

  import uart_dec::*;

  // Serial IO signals
  logic rx;       // DUT rx input (driven by external UART driver)
  logic tx;       // DUT tx output (sampled by monitor)
  logic tx_en;

  // Loopback/observation
  logic [UART_NCO_WIDTH-1:0] baud_div;  // configurable baud divider (from DUT ctrl)

  clocking drv_cb @(posedge clk);
    default input #1step output #1step;
    output rx;
    input  tx, tx_en;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step output #1step;
    input rx, tx, tx_en;
  endclocking

  modport master  (clocking drv_cb, input clk, input rst_n);
  modport monitor (clocking mon_cb, input clk, input rst_n);

endinterface

`endif
