// =============================================================================
// File Name   : harness.sv
// Description : PQC UVM testbench harness
//               Clock/reset generation, protocol interface instantiation,
//               DUT instantiation and UVM config_db setup.
//
// Protocol agents are NOT implemented here: the APB (CSR/control) and AXI4
// (DMA to SoC memory) agents come from aixsilicon_vip_repo and are pulled in
// through the FuseSoC `depend` of the `uvm` target (see docs/reuse_plan.md).
//   APB  : aixsilicon:vip:apb:1.0.0   -> apb_if / apb_pkg / apb_env
//   AXI4 : aixsilicon:vip:axi4:1.0.0  -> axi4_if / axi4_pkg / axi4_env
//
// DUT orientation:
//   * DUT is an APB **Completer**  -> VIP APB agent runs APB_ACTIVE_MASTER
//     (Requester) and drives the CSR/control interface.
//   * DUT is an AXI4 **Master**    -> VIP AXI4 agent runs AXI4_ACTIVE_SLAVE
//     and provides the memory-backed responder for descriptor/output DMA.
// =============================================================================

`timescale 1ns/1ps

module harness;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_types_pkg::*;
  import apb_pkg::*;
  import axi4_types_pkg::*;
  import axi4_pkg::*;
  import pqc_pkg::*;

  // ---------------------------------------------------------------------------
  // Parameters
  // ---------------------------------------------------------------------------
  // Configuration under verification. Defaults match pqc_top defaults and the
  // deliverable (CFG_BALANCED) configuration of model/parameter_space.yaml.
  localparam int unsigned NTT_LANES               = 2;
  localparam int unsigned KECCAK_ROUNDS_PER_CYCLE = 2;
  localparam int unsigned LOCAL_SRAM_KIB           = 64;
  localparam int unsigned DMA_DATA_WIDTH          = 128;
  localparam int unsigned KEY_SLOT_NUM            = 8;
  localparam int unsigned SCA_LEVEL               = 1;

  // APB CSR window of pqc_top is 10 bits wide (1 KiB).
  localparam int unsigned APB_ADDR_WIDTH = 10;

  // ---------------------------------------------------------------------------
  // Clock and reset
  // ---------------------------------------------------------------------------
  logic clk;
  logic rst_n;

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;   // 100 MHz
  end

  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // Protocol interfaces (VIP-owned types)
  // ---------------------------------------------------------------------------
  apb_if #(
    .ADDR_WIDTH (APB_ADDR_WIDTH),
    .DATA_WIDTH (32),
    .HAS_PSTRB  (1'b1),
    .HAS_PPROT  (1'b1)
  ) u_apb_if (
    .pclk         (clk),
    .presetn      (rst_n),
    .check_enable (1'b0)
  );

  axi4_if #(
    .ID_WIDTH      (8),
    .ADDRESS_WIDTH (40),
    .DATA_WIDTH    (DMA_DATA_WIDTH),
    .USER_WIDTH    (1)
  ) u_axi_if (
    .aclk     (clk),
    .areset_n (rst_n)
  );

  // ---------------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------------
  logic         entropy_valid;
  logic         entropy_ready;
  logic [63:0]  entropy_data;
  logic         entropy_health_ok;
  logic [7:0]   entropy_domain_tag;

  logic         irq;
  logic         km_begin_ready;
  logic         km_ready;
  logic         km_done;
  logic         km_error;

  pqc_top #(
    .NTT_LANES               (NTT_LANES),
    .KECCAK_ROUNDS_PER_CYCLE (KECCAK_ROUNDS_PER_CYCLE),
    .LOCAL_SRAM_KIB           (LOCAL_SRAM_KIB),
    .DMA_DATA_WIDTH          (DMA_DATA_WIDTH),
    .KEY_SLOT_NUM            (KEY_SLOT_NUM),
    .SCA_LEVEL               (SCA_LEVEL)
  ) u_dut (
    .clk    (clk),
    .rst_n  (rst_n),

    // APB4 control (DUT is completer; VIP drives)
    .s_apb_psel    (u_apb_if.psel[0]),
    .s_apb_penable (u_apb_if.penable),
    .s_apb_pwrite  (u_apb_if.pwrite),
    .s_apb_pprot   (u_apb_if.pprot_w),
    .s_apb_paddr   (u_apb_if.paddr),
    .s_apb_pwdata  (u_apb_if.pwdata),
    .s_apb_pstrb   (u_apb_if.pstrb_w),
    .s_apb_pready  (u_apb_if.pready),
    .s_apb_prdata  (u_apb_if.prdata),
    .s_apb_pslverr (u_apb_if.pslverr),

    // AXI4 master data interface (DUT is master; VIP is slave responder)
    .m_ar_valid (u_axi_if.arvalid),
    .m_ar_ready (u_axi_if.arready),
    .m_ar_addr  (u_axi_if.araddr),
    .m_ar_len   (u_axi_if.arlen),
    .m_ar_prot  (u_axi_if.arprot),
    .m_r_valid  (u_axi_if.rvalid),
    .m_r_ready  (u_axi_if.rready),
    .m_r_data   (u_axi_if.rdata),
    .m_r_resp   (u_axi_if.rresp),
    .m_r_last   (u_axi_if.rlast),
    .m_aw_valid (u_axi_if.awvalid),
    .m_aw_ready (u_axi_if.awready),
    .m_aw_addr  (u_axi_if.awaddr),
    .m_aw_len   (u_axi_if.awlen),
    .m_aw_prot  (u_axi_if.awprot),
    .m_w_valid  (u_axi_if.wvalid),
    .m_w_ready  (u_axi_if.wready),
    .m_w_data   (u_axi_if.wdata),
    .m_w_strb   (u_axi_if.wstrb),
    .m_w_last   (u_axi_if.wlast),
    .m_b_valid  (u_axi_if.bvalid),
    .m_b_ready  (u_axi_if.bready),
    .m_b_resp   (u_axi_if.bresp),

    // Entropy source (external RNG service feed)
    .entropy_valid      (entropy_valid),
    .entropy_ready      (entropy_ready),
    .entropy_data       (entropy_data),
    .entropy_health_ok  (entropy_health_ok),
    .entropy_domain_tag (entropy_domain_tag),

    // Sideband / security
    .lifecycle_strap  (1'b0),
    .tamper_in        (1'b0),
    .zeroize_req_in   (1'b0),
    .privileged       (1'b1),
    .debug_unlocked   (1'b0),
    .irq              (irq),

    // Trusted Key Manager sideload (idle in the current verification scope)
    .km_begin       (1'b0),
    .km_begin_ready (km_begin_ready),
    .km_handle      (32'h0),
    .km_algo        (4'h0),
    .km_pset        (4'h0),
    .km_usage       (8'h0),
    .km_bytes       (16'h0),
    .km_valid       (1'b0),
    .km_ready       (km_ready),
    .km_data        (32'h0),
    .km_last        (1'b0),
    .km_done        (km_done),
    .km_error       (km_error),
    .km_revoke      (1'b0),

    // DFT injection (test lifecycle only)
    .fault_inject_ecc_ue (1'b0),
    .fault_inject_ctrl   (1'b0)
  );

  // ---------------------------------------------------------------------------
  // Entropy driver: always valid, health OK, deterministic public stream.
  // The entropy path is a public interface; the value is not secret in
  // simulation but the same 64-bit word is xored with a counter so that
  // repeated consumption is observable in waveforms.
  // ---------------------------------------------------------------------------
  logic [63:0] entropy_counter;

  initial begin
    entropy_valid      = 1'b0;
    entropy_data       = 64'h0;
    entropy_health_ok  = 1'b1;
    entropy_domain_tag = 8'h0;
    entropy_counter    = 64'h0;
    repeat (12) @(posedge clk);
    forever begin
      @(posedge clk);
      entropy_valid      = 1'b1;
      entropy_health_ok  = 1'b1;
      entropy_domain_tag = 8'h0;
      if (entropy_ready) begin
        entropy_data    = entropy_data + 64'h9E37_79B9_7F4A_7C15;
        entropy_counter = entropy_counter + 64'h1;
      end
    end
  end

  // ---------------------------------------------------------------------------
  // UVM configuration and test execution
  // ---------------------------------------------------------------------------
  initial begin
    // Scope note: use wildcard scopes because UVM config_db exact scope does not
    // cascade into deeper components (APB VIP user-guide §9).
    uvm_config_db #(virtual apb_if)::set(null, "*", "vif", u_apb_if);
    uvm_config_db #(virtual axi4_if)::set(null, "*", "vif", u_axi_if);
    run_test();
  end

endmodule
