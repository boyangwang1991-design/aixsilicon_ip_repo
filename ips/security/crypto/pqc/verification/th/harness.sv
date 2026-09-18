// =============================================================================
// File Name   : harness.sv
// Description : PQC UVM testbench harness
//               Clock/reset generation, protocol interface instantiation,
//               DUT instantiation and UVM config_db setup.
//
// APB control uses apb_if / apb_pkg from the external APB VIP, read-only.
// DMA currently uses pqc_main_if's memory responder. AXI4 VIP integration and
// protocol coverage remain open; this harness does not instantiate axi4_env.
// DUT orientation: APB completer, AXI4 DMA master.
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

  pqc_main_if main_bus(clk,rst_n);
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

    .m_ar_valid(main_bus.arvalid),.m_ar_ready(main_bus.arready),.m_ar_addr(main_bus.araddr),.m_ar_len(main_bus.arlen),.m_ar_prot(),
    .m_r_valid(main_bus.rvalid),.m_r_ready(main_bus.rready),.m_r_data(main_bus.rdata),.m_r_resp(main_bus.rresp),.m_r_last(main_bus.rlast),
    .m_aw_valid(main_bus.awvalid),.m_aw_ready(main_bus.awready),.m_aw_addr(main_bus.awaddr),.m_aw_len(main_bus.awlen),.m_aw_prot(),
    .m_w_valid(main_bus.wvalid),.m_w_ready(main_bus.wready),.m_w_data(main_bus.wdata),.m_w_strb(main_bus.wstrb),.m_w_last(main_bus.wlast),
    .m_b_valid(main_bus.bvalid),.m_b_ready(main_bus.bready),.m_b_resp(main_bus.bresp),

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

    // Trusted Key Manager sideload (driven by the test through main_bus)
    .km_begin       (main_bus.km_begin),
    .km_begin_ready (km_begin_ready),
    .km_handle      (main_bus.km_handle),
    .km_algo        (main_bus.km_algo),
    .km_pset        (main_bus.km_pset),
    .km_usage       (main_bus.km_usage),
    .km_bytes       (main_bus.km_bytes),
    .km_valid       (main_bus.km_valid),
    .km_ready       (km_ready),
    .km_data        (main_bus.km_data),
    .km_last        (main_bus.km_last),
    .km_done        (km_done),
    .km_error       (km_error),
    .km_generated_handle(main_bus.km_generated_handle),
    .km_generated_epoch(main_bus.km_generated_epoch),
    .km_generated_owner(main_bus.km_generated_owner),
    .km_generated_domain(main_bus.km_generated_domain),
    .km_custody_header_valid(main_bus.km_custody_header_valid),
    .km_custody_header_ready(main_bus.km_custody_header_ready),
    .km_custody_transaction(main_bus.km_custody_transaction),
    .km_custody_epoch(main_bus.km_custody_epoch),
    .km_custody_handle(main_bus.km_custody_handle),
    .km_custody_owner(main_bus.km_custody_owner),
    .km_custody_domain(main_bus.km_custody_domain),
    .km_custody_algo(main_bus.km_custody_algo),
    .km_custody_pset(main_bus.km_custody_pset),
    .km_custody_bytes(main_bus.km_custody_bytes),
    .km_custody_valid(main_bus.km_custody_valid),
    .km_custody_ready(main_bus.km_custody_ready),
    .km_custody_last(main_bus.km_custody_last),
    .km_custody_data(main_bus.km_custody_data),
    .km_custody_ack_valid(main_bus.km_custody_ack_valid),
    .km_custody_ack_ready(main_bus.km_custody_ack_ready),
    .km_custody_ack_transaction(main_bus.km_custody_ack_transaction),
    .km_custody_ack_epoch(main_bus.km_custody_ack_epoch),
    .km_custody_ack_handle(main_bus.km_custody_ack_handle),
    .km_custody_ack_owner(main_bus.km_custody_ack_owner),
    .km_custody_ack_domain(main_bus.km_custody_ack_domain),
    .km_custody_ack_bytes(main_bus.km_custody_ack_bytes),
    .km_custody_ack_success(main_bus.km_custody_ack_success),
    .km_revoke      (1'b0),

    // DFT injection (test lifecycle only)
    .fault_inject_ecc_ue (1'b0),
    .fault_inject_ctrl   (1'b0)
  );

  assign entropy_valid=main_bus.entropy_enable;
  assign entropy_data=main_bus.entropy_data;
  assign entropy_health_ok=1'b1;
  assign entropy_domain_tag=main_bus.entropy_tag;
  assign main_bus.entropy_ready=entropy_ready;
  assign main_bus.irq=irq;
  // KM sideload handshake back into the testbench interface
  assign main_bus.km_begin_ready=km_begin_ready;
  assign main_bus.km_ready=km_ready;
  assign main_bus.km_done=km_done;
  assign main_bus.km_error=km_error;

  // ---------------------------------------------------------------------------
  // UVM configuration and test execution
  // ---------------------------------------------------------------------------
  initial begin
    // Scope note: use wildcard scopes because UVM config_db exact scope does not
    // cascade into deeper components (APB VIP user-guide §9).
    uvm_config_db #(virtual apb_if)::set(null, "*", "vif", u_apb_if);
    uvm_config_db #(virtual pqc_main_if)::set(null,"*","main_bus",main_bus);
    run_test();
  end

  // Read-only diagnostics; algorithm verdicts never use internal DUT state.
  initial begin
    #1ms;
    if($test$plusargs("PQC_DIAG")) $display("PQC_DIAG tx=%0d e=%0d ret=%0d hash_kind=%0d hi=%0d ho=%0d hs=%b ss=%b dma=%0d poly=%0d codec=%0d samp=%0d kec=%0d c0req=%b c0rdy=%b c1req=%b c1rdy=%b",
      u_dut.tx_state,u_dut.u_encaps.state,u_dut.u_encaps.ret,u_dut.u_encaps.hash_kind,u_dut.u_encaps.hidx,u_dut.u_encaps.houtput_idx,
      u_dut.u_encaps.hash_seen,u_dut.u_encaps.sample_seen,u_dut.u_dma.dstate,u_dut.u_poly.pstate,u_dut.u_codec.cstate,u_dut.u_sampler.spstate,u_dut.u_keccak.kstate,
      u_dut.sram_c0_req,u_dut.sram_c0_ready,u_dut.sram_c1_req,u_dut.sram_c1_ready);
    if($test$plusargs("PQC_DIAG")) $display("PQC_KM_DIAG wk_state=%0d km_begin_ready=%b wk_begin_ready=%b fe_idle=%b locked=%b load_ready=%b load_done=%b load_error=%b",
      u_dut.u_work_key_ram.state,u_dut.km_begin_ready,u_dut.work_key_begin_ready,u_dut.fe_idle,u_dut.fault_locked,
      km_ready,km_done,km_error);
  end
  // Per-100us TX trace for Decaps bring-up debugging.
  initial begin
    #2us;
    forever begin
      #2us;
      if($test$plusargs("PQC_DIAG")) $display("PQC_TX_DIAG t=%0t tx=%0d d.state=%0d c0rdy=%b c1rdy=%b | accept=%b acc_valid=%b zreq=%b resp_rev=%b acc_port=%0d grant=%b%b%b",
        $time,u_dut.tx_state,u_dut.u_decaps.state,
        u_dut.sram_c0_ready,u_dut.sram_c1_ready,
        u_dut.u_sram.accept,u_dut.u_sram.acc_valid,u_dut.zeroize_req_any,
        u_dut.u_sram.response_revoked,u_dut.u_sram.acc_port,
        u_dut.u_sram.grant0,u_dut.u_sram.grant1,u_dut.u_sram.grantd);
    end
  end
  // TX-phase trace: every TX-state transition of the Decaps transaction.
  logic [5:0] tx_prev = '1;
  always @(posedge clk) begin
    if (u_dut.tx_state != tx_prev) begin
      if($test$plusargs("PQC_DIAG")) $display("PQC_TX t=%0t tx=%0d -> %0d d.state=%0d d_done=%b d_err=%b dec_start=%b dma_req=%b dma_done=%b",
        $time,tx_prev,u_dut.tx_state,u_dut.u_decaps.state,
        u_dut.d_done,u_dut.d_error,u_dut.dec_start,u_dut.tx_dma_req,u_dut.dma_done);
      tx_prev <= u_dut.tx_state;
    end
  end
  // Stuck-state triage: when the Decaps program dwells in one state for 5k
  // cycles, dump the full handshake snapshot once (and re-arm every 5k).
  logic [31:0] dwell = 0;
  logic [8:0]  d_prev = '1;
  logic [8:0]  d_last_dump = '1;
  always @(posedge clk) begin
    if (u_dut.u_decaps.state == d_prev) dwell <= dwell + 1;
    else begin dwell <= 0; d_prev <= u_dut.u_decaps.state; end
    if (dwell == 32'd5000 && d_prev != d_last_dump) begin
      d_last_dump <= d_prev;
      if($test$plusargs("PQC_DIAG")) $display("PQC_STUCK t=%0t d.state=%0d idx=%0d memreq=%b memrdy=%b c0req=%b c0rdy=%b daddr=%h pvalid=%b wvalid=%b grant0=%b accept=%b denied=%b poly_start=%b poly_busy=%b codec_start=%b codec_busy=%b",
        $time,u_dut.u_decaps.state,u_dut.u_decaps.idx,
        u_dut.d_mem_req,u_dut.sram_c0_ready && u_dut.d_mem_req,
        u_dut.sram_c0_req,u_dut.sram_c0_ready,
        u_dut.u_sram.sel_addr,
        u_dut.u_sram.page_valid[u_dut.u_sram.addr_page],
        u_dut.u_sram.word_valid[u_dut.u_sram.addr_idx],
        u_dut.u_sram.grant0,u_dut.u_sram.accept,u_dut.u_sram.access_denied,
        u_dut.poly_start,u_dut.poly_busy,
        u_dut.e_codec_start,u_dut.d_codec_start,u_dut.codec_busy);
    end
  end
  always @(posedge clk) begin
    if ($test$plusargs("DSA_KEYGEN_DIAG") && u_dut.j_gen_valid && u_dut.gen_ready && u_dut.u_dsa_keygen.idx<2)
      $display("DSAKG_DIAG state=%d idx=%d part=%d word=%h seed0=%h xi0=%h",u_dut.u_dsa_keygen.state,u_dut.u_dsa_keygen.idx,u_dut.u_dsa_keygen.sk_part,u_dut.gen_data,u_dut.u_dsa_keygen.seed[0],u_dut.u_dsa_keygen.xi[0]);
  end
  always @(posedge clk) if(u_dut.u_frontend.fsm_state==pqc_pkg::S_VALIDATE)
    $display("VALIDATE_DIAG valid=%b error=%h keyok=%b handle=%h/%h algo=%h/%h pset=%h/%h usage=%h/%h",u_dut.u_frontend.descriptor_valid,u_dut.u_frontend.descriptor_error,u_dut.work_key_ok,u_dut.command_key_handle,u_dut.u_work_key_ram.handle_q,u_dut.u_work_key_ram.check_algo,u_dut.u_work_key_ram.algo_q,u_dut.u_work_key_ram.check_pset,u_dut.u_work_key_ram.pset_q,u_dut.u_work_key_ram.check_usage,u_dut.u_work_key_ram.usage_q);
endmodule
