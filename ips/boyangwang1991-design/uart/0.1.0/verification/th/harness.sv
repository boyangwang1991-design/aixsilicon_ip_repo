// =============================================================================
// File Name   : harness.sv
// Description : UART top-level testbench harness
//               - Generates clock and reset
//               - Instantiates TL-UL, APB and UART serial interfaces
//               - Instantiates both DUT top wrappers (uart TL-UL + uart_apb_top)
//               - Connects interfaces to DUT ports
//               - Configures UVM config_db with virtual interfaces
//               - Starts UVM test
// =============================================================================

`timescale 1ns/1ps

/// @module harness
/// @brief Top-level testbench module
module harness;

  // Import UVM and verification packages
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import uart_package::*;
  import tlul_package::*;
  import apb_package::*;
  import uart_env_package::*;

  // ---------------------------------------------------------------------------
  // Clock and Reset Generation
  // ---------------------------------------------------------------------------
  logic clk;    ///< System clock
  logic rst_n;  ///< Active-low reset

  // ---------------------------------------------------------------------------
  // Interface Instantiation
  // ---------------------------------------------------------------------------

  /// TL-UL interface (direct TL-UL access path)
  tlul_interface tlul_if (
    .clk   (clk),
    .rst_n (rst_n)
  );

  /// APB interface (APB access path through apb2tlul bridge)
  apb_interface apb_if (
    .clk   (clk),
    .rst_n (rst_n)
  );

  /// UART serial interface
  uart_interface uart_if (
    .clk   (clk),
    .rst_n (rst_n)
  );

  // ---------------------------------------------------------------------------
  // TL-UL struct packing (interface exposes flat signals)
  // ---------------------------------------------------------------------------
  tlul_pkg::tl_h2d_t tl_h2d;
  tlul_pkg::tl_d2h_t tl_d2h;

  always_comb begin
    tl_h2d                  = tlul_pkg::TL_H2D_DEFAULT;
    tl_h2d.a_valid          = tlul_if.a_valid;
    tl_h2d.a_opcode         = tlul_if.a_opcode;
    tl_h2d.a_param          = tlul_if.a_param;
    tl_h2d.a_size           = tlul_if.a_size;
    tl_h2d.a_source         = tlul_if.a_source;
    tl_h2d.a_address        = tlul_if.a_address;
    tl_h2d.a_mask           = tlul_if.a_mask;
    tl_h2d.a_data           = tlul_if.a_data;
    tl_h2d.d_ready          = tlul_if.d_ready;
    // Generate TL-UL integrity fields so the DUT's adapter accepts the request.
    // (Same approach as apb2tlul: use the package integrity functions.)
    tl_h2d.a_user.rsvd      = '0;
    tl_h2d.a_user.instr_type= prim_mubi_pkg::MuBi4False;
    tl_h2d.a_user.cmd_intg  = tlul_pkg::get_cmd_intg(tl_h2d);
    tl_h2d.a_user.data_intg = tlul_pkg::get_data_intg(tl_h2d.a_data);
  end

  always_comb begin
    tlul_if.a_ready         = tl_d2h.a_ready;
    tlul_if.d_valid         = tl_d2h.d_valid;
    tlul_if.d_opcode        = tl_d2h.d_opcode;
    tlul_if.d_size          = tl_d2h.d_size;
    tlul_if.d_source        = tl_d2h.d_source;
    tlul_if.d_error         = tl_d2h.d_error;
    tlul_if.d_data          = tl_d2h.d_data;
  end

  // ---------------------------------------------------------------------------
  // DUT Instantiation
  // ---------------------------------------------------------------------------

  // Alert inputs (tied off, not exercised in functional TB)
  prim_alert_pkg::alert_rx_t [1:0] alert_rx;
  prim_alert_pkg::alert_tx_t [1:0] alert_tx;

  // Interrupt outputs (separate sets per DUT instance to avoid multi-driver)
  logic intr_tx_watermark_tlul, intr_tx_empty_tlul, intr_rx_watermark_tlul;
  logic intr_tx_done_tlul, intr_rx_overflow_tlul, intr_rx_frame_err_tlul;
  logic intr_rx_break_err_tlul, intr_rx_timeout_tlul, intr_rx_parity_err_tlul;

  logic intr_tx_watermark_apb, intr_tx_empty_apb, intr_rx_watermark_apb;
  logic intr_tx_done_apb, intr_rx_overflow_apb, intr_rx_frame_err_apb;
  logic intr_rx_break_err_apb, intr_rx_timeout_apb, intr_rx_parity_err_apb;

  assign alert_rx[0] = prim_alert_pkg::ALERT_RX_DEFAULT;
  assign alert_rx[1] = prim_alert_pkg::ALERT_RX_DEFAULT;

  /// DUT instance 1: TL-UL direct access top
  uart u_dut_tlul (
    .clk_i   (clk),
    .rst_ni  (rst_n),
    .tl_i    (tl_h2d),
    .tl_o    (tl_d2h),
    .alert_rx_i  (alert_rx),
    .alert_tx_o  (alert_tx),
    .racl_policies_i ('0),
    .racl_error_o  (),
    .lsio_trigger_o(),
    .cio_rx_i      (uart_if.rx),
    .cio_tx_o      (uart_if.tx),
    .cio_tx_en_o   (uart_if.tx_en),
    .intr_tx_watermark_o (intr_tx_watermark_tlul),
    .intr_tx_empty_o     (intr_tx_empty_tlul),
    .intr_rx_watermark_o (intr_rx_watermark_tlul),
    .intr_tx_done_o      (intr_tx_done_tlul),
    .intr_rx_overflow_o  (intr_rx_overflow_tlul),
    .intr_rx_frame_err_o (intr_rx_frame_err_tlul),
    .intr_rx_break_err_o (intr_rx_break_err_tlul),
    .intr_rx_timeout_o   (intr_rx_timeout_tlul),
    .intr_rx_parity_err_o(intr_rx_parity_err_tlul)
  );

  /// DUT instance 2: APB access top (apb2tlul + uart)
  uart_apb_top u_dut_apb (
    .clk_i   (clk),
    .rst_ni  (rst_n),
    .psel_i   (apb_if.psel),
    .penable_i(apb_if.penable),
    .pwrite_i (apb_if.pwrite),
    .paddr_i  (apb_if.paddr),
    .pwdata_i (apb_if.pwdata),
    .pstrb_i  (apb_if.pstrb),
    .prdata_o (apb_if.prdata),
    .pready_o (apb_if.pready),
    .pslverr_o(apb_if.pslverr),
    .alert_rx_i  (alert_rx[0:0]),
    .alert_tx_o  (),
    .cio_rx_i    (1'b1),
    .cio_tx_o    (),
    .cio_tx_en_o (),
    .intr_tx_watermark_o (intr_tx_watermark_apb),
    .intr_tx_empty_o     (intr_tx_empty_apb),
    .intr_rx_watermark_o (intr_rx_watermark_apb),
    .intr_tx_done_o      (intr_tx_done_apb),
    .intr_rx_overflow_o  (intr_rx_overflow_apb),
    .intr_rx_frame_err_o (intr_rx_frame_err_apb),
    .intr_rx_break_err_o (intr_rx_break_err_apb),
    .intr_rx_timeout_o   (intr_rx_timeout_apb),
    .intr_rx_parity_err_o(intr_rx_parity_err_apb)
  );

  // ---------------------------------------------------------------------------
  // Clock Generation
  // ---------------------------------------------------------------------------

  /// Generate 100MHz clock (10ns period)
  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  // ---------------------------------------------------------------------------
  // Reset Generation
  // ---------------------------------------------------------------------------

  /// Generate reset - assert for 10 clock cycles
  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end


  // ---------------------------------------------------------------------------
  // UVM Configuration and Test Execution
  // ---------------------------------------------------------------------------

  /// Configure virtual interfaces in UVM config_db and start test
  initial begin
    // Set virtual interfaces at agent level; the agent forwards them to sub-components.
    uvm_config_db #(virtual uart_interface)::set(
      null,
      "uvm_test_top.env.uart_agent",
      "vif",
      uart_if
    );

    uvm_config_db #(virtual tlul_interface)::set(
      null,
      "uvm_test_top.env.tlul_agent",
      "vif",
      tlul_if
    );

    uvm_config_db #(virtual apb_interface)::set(
      null,
      "uvm_test_top.env.apb_agent",
      "vif",
      apb_if
    );

    // Start UVM test
    run_test();
  end

endmodule
