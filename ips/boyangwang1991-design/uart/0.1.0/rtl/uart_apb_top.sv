// uart_apb_top — UART APB 接入顶层封装
//
// Wraps the original OpenTitan UART core (uart, TL-UL slave) behind an
// APB4 slave port via the apb2tlul adapter. The UART core RTL is used
// unchanged; apb2tlul performs APB → TL-UL protocol conversion only.
//
// Exposes the same serial / interrupt / alert interfaces as the TL-UL
// uart top so that an APB host can fully drive the UART.
//
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module uart_apb_top (
  input           clk_i,
  input           rst_ni,

  // APB Slave Interface (host-facing)
  input           psel_i,
  input           penable_i,
  input           pwrite_i,
  input  [7:0]    paddr_i,
  input  [31:0]   pwdata_i,
  input  [3:0]    pstrb_i,
  output [31:0]   prdata_o,
  output          pready_o,
  output          pslverr_o,

  // Alerts
  input  prim_alert_pkg::alert_rx_t [1-1:0] alert_rx_i,
  output prim_alert_pkg::alert_tx_t [1-1:0] alert_tx_o,

  // Generic IO
  input           cio_rx_i,
  output logic    cio_tx_o,
  output logic    cio_tx_en_o,

  // Interrupts
  output logic    intr_tx_watermark_o,
  output logic    intr_tx_empty_o,
  output logic    intr_rx_watermark_o,
  output logic    intr_tx_done_o,
  output logic    intr_rx_overflow_o,
  output logic    intr_rx_frame_err_o,
  output logic    intr_rx_break_err_o,
  output logic    intr_rx_timeout_o,
  output logic    intr_rx_parity_err_o
);

  tlul_pkg::tl_h2d_t tl_h2d;
  tlul_pkg::tl_d2h_t tl_d2h;

  // APB → TL-UL adapter (new, does not modify UART core)
  apb2tlul #(
    .AW(8),
    .DW(32),
    .DBW(4)
  ) u_apb2tlul (
    .clk_i,
    .rst_ni,

    .psel_i,
    .penable_i,
    .pwrite_i,
    .paddr_i,
    .pwdata_i,
    .pstrb_i,
    .prdata_o,
    .pready_o,
    .pslverr_o,

    .tl_o(tl_h2d),
    .tl_i(tl_d2h)
  );

  // Original OpenTitan UART core (TL-UL slave), unchanged
  uart u_uart (
    .clk_i,
    .rst_ni,
    .tl_i(tl_h2d),
    .tl_o(tl_d2h),
    .alert_rx_i,
    .alert_tx_o,
    .racl_policies_i('0),
    .racl_error_o(),
    .lsio_trigger_o(),
    .cio_rx_i,
    .cio_tx_o,
    .cio_tx_en_o,
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

endmodule : uart_apb_top
