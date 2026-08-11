// =============================================================================
// File Name   : smoke_tb.sv
// Description : UART standalone smoke testbench
//               Minimal independent top-level that compiles/elaborates the DUT
//               so the verification suite has an autonomous testbench entry.
//               Functional stimulus is provided by the UVM environment in
//               verification/tc (tc_uart_*).
// =============================================================================

`timescale 1ns/1ps

/// @module smoke_tb
/// @brief Standalone testbench for UART DUT compile/elab check
module smoke_tb;

  import uart_pkg::*;

  logic clk = 1'b0;
  logic rst_n = 1'b0;

  tlul_pkg::tl_h2d_t tl_h2d = tlul_pkg::TL_H2D_DEFAULT;
  tlul_pkg::tl_d2h_t tl_d2h;
  prim_alert_pkg::alert_rx_t [1:0] alert_rx;
  prim_alert_pkg::alert_tx_t [1:0] alert_tx;
  logic cio_rx_i = 1'b1;
  logic cio_tx_o;
  logic cio_tx_en_o;
  logic intr_tx_watermark_o, intr_tx_empty_o, intr_rx_watermark_o, intr_tx_done_o;
  logic intr_rx_overflow_o, intr_rx_frame_err_o, intr_rx_break_err_o;
  logic intr_rx_timeout_o, intr_rx_parity_err_o;

  assign alert_rx[0] = prim_alert_pkg::ALERT_RX_DEFAULT;
  assign alert_rx[1] = prim_alert_pkg::ALERT_RX_DEFAULT;

  // DUT instance (TL-UL access top)
  uart u_dut (
    .clk_i   (clk),
    .rst_ni  (rst_n),
    .tl_i    (tl_h2d),
    .tl_o    (tl_d2h),
    .alert_rx_i  (alert_rx),
    .alert_tx_o  (alert_tx),
    .racl_policies_i ('0),
    .racl_error_o  (),
    .lsio_trigger_o(),
    .cio_rx_i      (cio_rx_i),
    .cio_tx_o      (cio_tx_o),
    .cio_tx_en_o   (cio_tx_en_o),
    .intr_tx_watermark_o,
    .intr_tx_empty_o,
    .intr_rx_watermark_o,
    .intr_tx_done_o,
    .intr_rx_overflow_o,
    .intr_rx_frame_err_o,
    .intr_rx_break_err_o,
    .intr_rx_timeout_o,
    .intr_rx_parity_err_o
  );

  // 100 MHz clock
  initial forever #5ns clk = ~clk;

  // Reset: deassert after 10 cycles
  initial begin
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
    repeat (10) @(posedge clk);
    $display("smoke_tb: DUT elaborated and reset released");
    $finish;
  end

endmodule
