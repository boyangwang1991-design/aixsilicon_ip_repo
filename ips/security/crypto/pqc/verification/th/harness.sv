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

  // The APB VIP declares `virtual apb_if vif` WITHOUT parameters, so the
  // interface instance must use the VIP's default parameterisation
  // (ADDR_WIDTH=32) or the config_db virtual-interface type will not match.
  // pqc_top only decodes the low 10 bits, so the low bits are connected to the
  // DUT and the upper bits are left unused; "unmapped" checks still work
  // because they target holes inside the DUT's own 10-bit window.
  localparam int unsigned APB_ADDR_WIDTH = 32;

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

  // AXI4 master observation nets (idle handshake, see note)
  logic                     axi_ar_valid;
  logic [39:0]              axi_ar_addr;
  logic [7:0]               axi_ar_len;
  logic [2:0]               axi_ar_prot;
  logic                     axi_r_ready;
  logic                     axi_aw_valid;
  logic [39:0]              axi_aw_addr;
  logic [7:0]               axi_aw_len;
  logic [2:0]               axi_aw_prot;
  logic                     axi_w_valid;
  logic [DMA_DATA_WIDTH-1:0] axi_w_data;
  logic [DMA_DATA_WIDTH/8-1:0] axi_w_strb;
  logic                     axi_w_last;
  logic                     axi_b_ready;

  // ---------------------------------------------------------------------------
  // AXI4 paths are deliberately NOT wired to a VIP in this increment.
  //
  // The published AXI4 VIP declares `virtual axi4_if vif` without parameters
  // (default 32-bit data / 32-bit address), while pqc_top's DMA master is
  // 128-bit data / 40-bit address; the two specialisations are not
  // interchangeable, so the VIP cannot be attached to this DUT without an
  // (unsupported) type override.
  //
  // This is not worked around by a hand-written responder: the DMA data path is
  // itself still incomplete in RTL (input -> algorithm -> output -> completion
  // is not closed, reports/report.md ISSUE A03 / A11). DMA verification is
  // therefore deferred together with that RTL work and recorded as an open G4
  // item rather than simulated against a stub.
  //
  // The DUT master handshake is held idle (no requests, no responses) so the
  // unimplemented path can never silently "succeed".
  // ---------------------------------------------------------------------------

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

    // AXI4 master data interface: held idle (see the AXI4 note above).
    // Outputs are observed but never driven back; inputs are tied to "no
    // response" so the DUT master cannot complete a phantom transaction.
    .m_ar_valid (axi_ar_valid),
    .m_ar_ready (1'b0),
    .m_ar_addr  (axi_ar_addr),
    .m_ar_len   (axi_ar_len),
    .m_ar_prot  (axi_ar_prot),
    .m_r_valid  (1'b0),
    .m_r_ready  (axi_r_ready),
    .m_r_data   ({DMA_DATA_WIDTH{1'b0}}),
    .m_r_resp   (2'b00),
    .m_r_last   (1'b0),
    .m_aw_valid (axi_aw_valid),
    .m_aw_ready (1'b0),
    .m_aw_addr  (axi_aw_addr),
    .m_aw_len   (axi_aw_len),
    .m_aw_prot  (axi_aw_prot),
    .m_w_valid  (axi_w_valid),
    .m_w_ready  (1'b0),
    .m_w_data   (axi_w_data),
    .m_w_strb   (axi_w_strb),
    .m_w_last   (axi_w_last),
    .m_b_valid  (1'b0),
    .m_b_ready  (axi_b_ready),
    .m_b_resp   (2'b00),

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
    // No AXI4 VIP vif is published: the DMA path is out of scope this increment.
    run_test();
  end

endmodule
