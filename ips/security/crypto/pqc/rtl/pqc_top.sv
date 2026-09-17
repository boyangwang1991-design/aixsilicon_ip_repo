// ============================================================================
// pqc_top - ML-KEM + ML-DSA post-quantum crypto accelerator top level
//
// Integrates the APB4 control interface, the generated CSR block, the command
// frontend, both algorithm sequencers, the shared cryptographic primitives,
// secure working memory, key slots, AXI4 DMA and the fault/zeroize controller.
//
// Security boundary: only commands, public data and policy-permitted results
// cross this boundary; secret intermediates remain inside.
// ============================================================================
`ifndef PQC_TOP_SV
`define PQC_TOP_SV

module pqc_top #(
  parameter int unsigned NTT_LANES                = 2,
  parameter int unsigned KECCAK_ROUNDS_PER_CYCLE  = 2,
  parameter int unsigned LOCAL_SRAM_KIB           = 64,
  parameter int unsigned DMA_DATA_WIDTH           = 128,
  parameter int unsigned KEY_SLOT_NUM             = 8,
  parameter int unsigned SCA_LEVEL                = 1,
  parameter logic [5:0]  ENABLE_ALGO_MASK         = 6'h3F,
  parameter bit          ENABLE_HASH_ML_DSA       = 1'b0,
  parameter bit          ENABLE_PIO               = 1'b1,
  parameter bit          ECC_ENABLED              = 1'b1,
  parameter int unsigned ZEROIZE_MAX_CYCLES       = LOCAL_SRAM_KIB*256+16
) (
  input  logic         clk,
  input  logic         rst_n,

  // ---------------------------------------------------------------------------
  // APB4 control interface
  // ---------------------------------------------------------------------------
  input  logic         s_apb_psel,
  input  logic         s_apb_penable,
  input  logic         s_apb_pwrite,
  input  logic [2:0]   s_apb_pprot,
  input  logic [9:0]   s_apb_paddr,
  input  logic [31:0]  s_apb_pwdata,
  input  logic [3:0]   s_apb_pstrb,
  output logic         s_apb_pready,
  output logic [31:0]  s_apb_prdata,
  output logic         s_apb_pslverr,

  // ---------------------------------------------------------------------------
  // AXI4 master data interface (flattened)
  // ---------------------------------------------------------------------------
  output logic                    m_ar_valid,
  input  logic                    m_ar_ready,
  output logic [39:0]             m_ar_addr,
  output logic [7:0]              m_ar_len,
  output logic [2:0]              m_ar_prot,
  input  logic                    m_r_valid,
  output logic                    m_r_ready,
  input  logic [DMA_DATA_WIDTH-1:0] m_r_data,
  input  logic [1:0]              m_r_resp,
  input  logic                    m_r_last,
  output logic                    m_aw_valid,
  input  logic                    m_aw_ready,
  output logic [39:0]             m_aw_addr,
  output logic [7:0]              m_aw_len,
  output logic [2:0]              m_aw_prot,
  output logic                    m_w_valid,
  input  logic                    m_w_ready,
  output logic [DMA_DATA_WIDTH-1:0] m_w_data,
  output logic [DMA_DATA_WIDTH/8-1:0] m_w_strb,
  output logic                    m_w_last,
  input  logic                    m_b_valid,
  output logic                    m_b_ready,
  input  logic [1:0]              m_b_resp,

  // ---------------------------------------------------------------------------
  // Entropy interface
  // ---------------------------------------------------------------------------
  input  logic         entropy_valid,
  output logic         entropy_ready,
  input  logic [63:0]  entropy_data,
  input  logic         entropy_health_ok,
  input  logic [7:0]   entropy_domain_tag,

  // ---------------------------------------------------------------------------
  // Sideband / security
  // ---------------------------------------------------------------------------
  input  logic         lifecycle_strap,
  input  logic         tamper_in,
  input  logic         zeroize_req_in,
  input  logic         privileged,
  input  logic         debug_unlocked,
  output logic         irq,

  // Trusted Key Manager sideload. There is deliberately no material readback.
  // Import a complete serialized private key before submitting its descriptor.
  input logic km_begin,
  output logic km_begin_ready,
  input logic [31:0] km_handle,
  input logic [3:0] km_algo, km_pset,
  input logic [7:0] km_usage,
  input logic [15:0] km_bytes,
  input logic km_valid,
  output logic km_ready,
  input logic [31:0] km_data,
  input logic km_last,
  output logic km_done, km_error,
  input logic km_revoke,

  // ---------------------------------------------------------------------------
  // DFT injection (test lifecycle only)
  // ---------------------------------------------------------------------------
  input  logic         fault_inject_ecc_ue,
  input  logic         fault_inject_ctrl
);

  import pqc_pkg::*;
  initial begin
    if(!((NTT_LANES==1)||(NTT_LANES==2)||(NTT_LANES==4)) ||
       !((KECCAK_ROUNDS_PER_CYCLE==1)||(KECCAK_ROUNDS_PER_CYCLE==2)) ||
       !((LOCAL_SRAM_KIB==32)||(LOCAL_SRAM_KIB==64)||(LOCAL_SRAM_KIB==96)) ||
       !((DMA_DATA_WIDTH==64)||(DMA_DATA_WIDTH==128)||(DMA_DATA_WIDTH==256)) ||
       KEY_SLOT_NUM<8 || KEY_SLOT_NUM>32)
      $fatal(1,"PQC_INVALID_PARAMETERS");
  end

  // ===========================================================================
  // CSR block (PeakRDL generated)
  // ===========================================================================
  pqc_csr_pkg::pqc_csr__in_t  hwif_in;
  pqc_csr_pkg::pqc_csr__out_t hwif_out;

  logic csr_psel, csr_penable, csr_pwrite;
  logic [2:0]  csr_pprot;
  logic [9:0]  csr_paddr;
  logic [31:0] csr_pwdata;
  logic [3:0]  csr_pstrb;
  logic csr_pready, csr_pslverr;
  logic [31:0] csr_prdata;
  logic busy_write_error;

  // ===========================================================================
  // Frontend <-> sequencer / primitives wiring
  // ===========================================================================
  logic        fe_busy, fe_idle, fe_done_pulse;
  logic [2:0]  fe_comp_status;
  logic [5:0]  fe_comp_error;
  logic [31:0] fe_completion_tag;
  logic [9:0]  fe_fsm_state;
  logic        alg_start;
  logic        fe_alg_busy, fe_alg_done, fe_alg_op_error;
  logic [1:0]  alg_op;
  logic [2:0]  alg_pset;
  logic        alg_busy, alg_done, alg_op_error;

  // descriptor fetch path: the frontend requests a descriptor and the input DMA
  // streams 128 bytes back from the programmed descriptor address.
  logic        fe_desc_fetch_req;
  logic [39:0] fe_desc_fetch_addr;
  logic [7:0]  fe_desc_data, fe_desc_data_idx;
  logic        fe_desc_data_valid;
  logic        df_busy, df_done, df_error;
  logic [5:0]  cap_algo_mask;

  logic irq_done, irq_error, irq_rng, irq_tamper, irq_selftest;

  // fault controller
  logic fault_zeroize_req, fault_zeroize_done, fault_locked;
  logic alert_recoverable, alert_fatal, integrity_fault;

  // key slots
  logic        ks_hnd_ok, ks_access_denied, ks_zeroize_done;
  logic [7:0]  ks_key_ref;
  logic [7:0]  ks_meta_owner, ks_meta_usage;
  logic [15:0] ks_meta_generation;
  logic [3:0]  ks_meta_algo, ks_meta_pset;
  logic        ks_meta_exportable, ks_meta_valid, ks_meta_locked;

  // SRAM controller ports
  logic        sram_c0_req, sram_c0_we, sram_c0_ready;
  logic [15:0] sram_c0_addr;
  logic [31:0] sram_c0_wdata, sram_c0_rdata;
  logic        sram_c1_req, sram_c1_we, sram_c1_ready;
  logic [15:0] sram_c1_addr;
  logic [31:0] sram_c1_wdata, sram_c1_rdata;
  logic        sram_d_req, sram_d_we, sram_d_ready;
  logic [15:0] sram_d_addr;
  logic [31:0] sram_d_wdata, sram_d_rdata;
  logic        ecc_ded, ecc_ued, sram_zeroize_done, sram_access_denied;
  logic        sram_tag_check_ok;
  logic        sram_tag_we, sram_tag_secret, sram_tag_valid, sram_tag_check_req;
  logic [7:0]  sram_tag_page, sram_tag_check_page;
  logic [3:0]  sram_tag_rep, sram_tag_algo, sram_tag_pset;

  // Keccak <-> sampler
  logic        kec_busy, kec_done, kec_out_valid, kec_out_ready, kec_out_last;
  logic [7:0]  kec_out_data;
  logic        kec_zeroize_done;

  // poly engine <-> SRAM
  logic        poly_busy, poly_done;
  logic        poly_mem_req, poly_mem_we, poly_mem_ready;
  logic [15:0] poly_mem_addr;
  logic [31:0] poly_mem_wdata, poly_mem_rdata;

  // poly engine control, arbitrated between the KEM and DSA sequencers
  logic        poly_start, poly_domain;
  logic [3:0]  poly_prim;
  logic [7:0]  poly_src_page, poly_src2_page, poly_dst_page;
  logic        kem_prim_start, dsa_prim_start;
  logic [3:0]  kem_prim_op, dsa_prim_op;
  logic        kem_prim_domain, dsa_prim_domain;
  logic [7:0]  kem_poly_src, kem_poly_src2, kem_poly_dst;
  logic [7:0]  dsa_poly_src, dsa_poly_src2, dsa_poly_dst;

  // codec <-> SRAM
  logic        codec_busy, codec_done, codec_canonical_ok, codec_norm_ok;
  logic        codec_mem_req, codec_mem_we, codec_mem_ready;
  logic [15:0] codec_mem_addr;
  logic [31:0] codec_mem_wdata, codec_mem_rdata;

  // sampler <-> SRAM
  logic        samp_busy, samp_done, samp_op_error, samp_mem_req, samp_mem_we, samp_mem_ready;
  logic [15:0] samp_mem_addr;
  logic [31:0] samp_mem_wdata;

  // sampler control
  logic        samp_start, samp_domain, samp_sqz_ready;
  logic [2:0]  samp_mode;
  logic [7:0]  samp_dst_page;
  logic [3:0]  samp_eta;
  logic [4:0]  samp_gamma1;

  // DMA: the AXI data path is DMA_DATA_WIDTH wide while the internal working
  // buffer port is 32-bit; the mover splits/assembles beats to bridge the two.
  logic        dma_buf_req, dma_buf_we, dma_buf_ready;
  logic [3:0]  dma_buf_wstrb;
  logic [15:0] dma_buf_addr;
  logic [31:0] dma_buf_wdata, dma_buf_rdata;
  logic        dma_done, dma_error;

  // DMA-side read channel (arbitrated with the descriptor fetch). Declared
  // before the DMA instance so no implicit net is created by first use.
  logic        m_ar_valid_dma, m_ar_ready_dma;
  logic [39:0] m_ar_addr_dma;
  logic [7:0]  m_ar_len_dma;
  logic [2:0]  m_ar_prot_dma;
  logic        m_r_ready_dma;
  logic        m_r_valid_dma, read_arb_fault;

  // sequencer control
  logic        kem_busy, kem_done, kem_op_error;
  logic        dsa_busy, dsa_done, dsa_verify_valid, dsa_retry_exhausted, dsa_op_error;

  // DSA staging buffer (invisible candidate signature) and verify challenge
  // digest byte ports. The candidate signature is streamed from the compute
  // SRAM into the sequencer's staging path; the challenge digest store lives
  // inside the sequencer (small register file).
  logic        dsa_stage_req, dsa_stage_we, dsa_stage_ready;
  logic [15:0] dsa_stage_addr;
  logic [7:0]  dsa_stage_wdata, dsa_stage_rdata;
  logic        dsa_commit_valid;
  logic [15:0] dsa_sig_len;
  logic        dsa_ct_calc_we, dsa_ct_ref_we, dsa_ct_clear;
  logic [7:0]  dsa_ct_calc_byte, dsa_ct_ref_byte;
  logic        alg_start_q;

  // ===========================================================================
  // Zeroize aggregation (independent of the main FSM)
  // ===========================================================================
  logic        zeroize_req_any;
  assign zeroize_req_any = fault_zeroize_req;

  // DFT lifecycle gate for fault injection
  logic dma_zero_done, desc_zero_done, work_key_zero_done;
  logic work_key_ok, work_key_begin_ready, work_key_integrity_error;
  logic datapath_abort_q;
  logic [31:0] command_key_handle;
  pqc_command_t validated_command;
  logic validated_command_valid;
  logic c1_owner_valid, c1_owner_codec, c1_select_codec;
  logic dft_enable;
  logic doorbell_observed_q;
  logic command_pending;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) doorbell_observed_q <= 1'b0;
    else doorbell_observed_q <= hwif_out.DOORBELL.doorbell.value;
  end
  assign command_pending = hwif_out.DOORBELL.doorbell.value && !doorbell_observed_q;

  // Capability mapping: the elaboration-time algorithm mask gates which
  // parameter sets the frontend will accept.
  assign cap_algo_mask = ENABLE_ALGO_MASK;

  // ===========================================================================
  // APB adapter
  // ===========================================================================
  pqc_apb_if u_apb_if (
    .clk               (clk),
    .rst_n             (rst_n),
    .s_apb_psel        (s_apb_psel),
    .s_apb_penable     (s_apb_penable),
    .s_apb_pwrite      (s_apb_pwrite),
    .s_apb_pprot       (s_apb_pprot),
    .s_apb_paddr       (s_apb_paddr),
    .s_apb_pwdata      (s_apb_pwdata),
    .s_apb_pstrb       (s_apb_pstrb),
    .s_apb_pready      (s_apb_pready),
    .s_apb_prdata      (s_apb_prdata),
    .s_apb_pslverr     (s_apb_pslverr),
    .csr_pready        (csr_pready),
    .csr_prdata        (csr_prdata),
    .csr_pslverr       (csr_pslverr),
    .csr_psel          (csr_psel),
    .csr_penable       (csr_penable),
    .csr_pwrite        (csr_pwrite),
    .csr_pprot         (csr_pprot),
    .csr_paddr         (csr_paddr),
    .csr_pwdata        (csr_pwdata),
    .csr_pstrb         (csr_pstrb),
    .busy              (fe_busy || command_pending),
    .privileged        (privileged),
    .busy_write_error  (busy_write_error)
  );

  // ===========================================================================
  // CSR block
  // ===========================================================================
  pqc_csr u_csr (
    .clk           (clk),
    .arst_n        (rst_n),
    .s_apb_psel    (csr_psel),
    .s_apb_penable (csr_penable),
    .s_apb_pwrite  (csr_pwrite),
    .s_apb_pprot   (csr_pprot),
    .s_apb_paddr   (csr_paddr),
    .s_apb_pwdata  (csr_pwdata),
    .s_apb_pstrb   (csr_pstrb),
    .s_apb_pready  (csr_pready),
    .s_apb_prdata  (csr_prdata),
    .s_apb_pslverr (csr_pslverr),
    .hwif_in       (hwif_in),
    .hwif_out      (hwif_out)
  );

  // ===========================================================================
  // hwif_in: hardware-driven register inputs
  // ===========================================================================

  // busy write protection: allow writes only when not busy
  logic swwe_ok;
  assign swwe_ok = !(fe_busy || command_pending);

  always_comb begin
    hwif_in = '{default: '0};

    hwif_in.CTRL.enable.swwe = swwe_ok;

    // COMMAND group (busy locked)
    hwif_in.COMMAND.opcode.swwe        = swwe_ok;
    hwif_in.COMMAND.parameter_set.swwe = swwe_ok;
    hwif_in.COMMAND.flags.swwe         = swwe_ok;
    hwif_in.COMMAND.abi.swwe           = swwe_ok;

    // descriptor group (busy locked)
    hwif_in.SRC0_ADDR_LO.src0_addr_lo.swwe          = swwe_ok;
    hwif_in.SRC0_ADDR_HI.src0_addr_hi.swwe          = swwe_ok;
    hwif_in.SRC0_LEN_LO.src0_len_lo.swwe            = swwe_ok;
    hwif_in.SRC0_LEN_HI.src0_len_hi.swwe            = swwe_ok;
    hwif_in.SRC1_ADDR_LO.src1_addr_lo.swwe          = swwe_ok;
    hwif_in.SRC1_ADDR_HI.src1_addr_hi.swwe          = swwe_ok;
    hwif_in.SRC1_LEN_LO.src1_len_lo.swwe            = swwe_ok;
    hwif_in.SRC1_LEN_HI.src1_len_hi.swwe            = swwe_ok;
    hwif_in.CONTEXT_ADDR_LO.context_addr_lo.swwe    = swwe_ok;
    hwif_in.CONTEXT_ADDR_HI.context_addr_hi.swwe    = swwe_ok;
    hwif_in.ENTROPY_POLICY.entropy_policy.swwe      = swwe_ok;
    hwif_in.DST0_ADDR_LO.dst0_addr_lo.swwe          = swwe_ok;
    hwif_in.DST0_ADDR_HI.dst0_addr_hi.swwe          = swwe_ok;
    hwif_in.DST0_CAPACITY_LO.dst0_capacity_lo.swwe  = swwe_ok;
    hwif_in.DST0_CAPACITY_HI.dst0_capacity_hi.swwe  = swwe_ok;
    hwif_in.DST1_ADDR_LO.dst1_addr_lo.swwe          = swwe_ok;
    hwif_in.DST1_ADDR_HI.dst1_addr_hi.swwe          = swwe_ok;
    hwif_in.DST1_CAPACITY_LO.dst1_capacity_lo.swwe  = swwe_ok;
    hwif_in.DST1_CAPACITY_HI.dst1_capacity_hi.swwe  = swwe_ok;
    hwif_in.COMPLETION_ADDR_LO.completion_addr_lo.swwe = swwe_ok;
    hwif_in.COMPLETION_ADDR_HI.completion_addr_hi.swwe = swwe_ok;
    hwif_in.TIMEOUT_HINT.timeout_hint.swwe          = swwe_ok;
    hwif_in.DESCRIPTOR_CRC.descriptor_crc.swwe      = swwe_ok;
    hwif_in.KEY_HANDLE.slot_id.swwe                 = swwe_ok;
    hwif_in.KEY_HANDLE.owner.swwe                   = swwe_ok;
    hwif_in.KEY_HANDLE.generation.swwe              = swwe_ok;
    hwif_in.CONTEXT_LEN.context_len.swwe            = swwe_ok;
    hwif_in.DESC_ADDR_LO.desc_addr_lo.swwe          = swwe_ok;
    hwif_in.DESC_ADDR_HI.desc_addr_hi.swwe          = swwe_ok;

    // STATUS is hardware driven
    hwif_in.STATUS.idle.next    = fe_idle;
    hwif_in.STATUS.busy.next    = fe_busy;
    hwif_in.STATUS.done.next    = fe_done_pulse;
    hwif_in.STATUS.error.next   = (fe_comp_status != ST_SUCCESS) &&
                                  (fe_comp_status != ST_VERIFY_INVALID);
    hwif_in.STATUS.locked.next  = fault_locked;

    // RESULT / completion
    hwif_in.RESULT.verify_valid.next    = dsa_verify_valid;
    hwif_in.RESULT.verify_done.next     = dsa_done;
    hwif_in.RESULT.completion_tag.next  = fe_completion_tag[31:2];
    hwif_in.ERROR_CODE.error_code.next  = fe_comp_error;
    hwif_in.ERROR_CODE.last_cmd_failed.next = (fe_comp_status != ST_SUCCESS);
    hwif_in.COMPLETION_STATUS.status.next     = fe_comp_status;
    hwif_in.COMPLETION_STATUS.verify_valid.next = dsa_verify_valid;
    hwif_in.COMPLETION_INFO.error_info.next   = fe_comp_error;

    // interrupt hardware set: real events OR software test-forced bits
    hwif_in.INTR_STATE.done.hwset           = irq_done ||
                                              hwif_out.INTR_TEST.done_test.value;
    hwif_in.INTR_STATE.error.hwset          = irq_error ||
                                              hwif_out.INTR_TEST.error_test.value;
    hwif_in.INTR_STATE.rng_fault.hwset      = irq_rng ||
                                              hwif_out.INTR_TEST.rng_fault_test.value;
    hwif_in.INTR_STATE.tamper.hwset         = irq_tamper ||
                                              hwif_out.INTR_TEST.tamper_test.value;
    hwif_in.INTR_STATE.self_test_fail.hwset = irq_selftest ||
                                              hwif_out.INTR_TEST.self_test_fail_test.value;

    // CAPABILITY0/1 report the ELABORATED configuration, not fixed constants
    hwif_in.CAPABILITY0.algo_mask.next       = ENABLE_ALGO_MASK;
    hwif_in.CAPABILITY0.kem_supported.next   = 1'b1;
    hwif_in.CAPABILITY0.dsa_supported.next   = 1'b1;
    hwif_in.CAPABILITY0.ntt_lanes.next       = ((NTT_LANES == 4) ? 2'd0 : 2'(NTT_LANES));
    hwif_in.CAPABILITY0.keccak_rounds.next   = 2'(KECCAK_ROUNDS_PER_CYCLE);
    hwif_in.CAPABILITY0.sca_level.next       = 2'(SCA_LEVEL);
    hwif_in.CAPABILITY0.hash_ml_dsa.next     = ENABLE_HASH_ML_DSA;
    hwif_in.CAPABILITY0.pure_ml_dsa.next     = 1'b1;
    hwif_in.CAPABILITY0.deterministic_mode.next = 1'b1;
    hwif_in.CAPABILITY0.hedged_mode.next     = 1'b1;

    hwif_in.CAPABILITY1.local_sram_kib.next  = 8'(LOCAL_SRAM_KIB);
    hwif_in.CAPABILITY1.dma_data_width.next  = ((DMA_DATA_WIDTH == 256) ? 8'd0 : 8'(DMA_DATA_WIDTH));
    hwif_in.CAPABILITY1.key_slot_num.next    = 8'(KEY_SLOT_NUM);
    hwif_in.CAPABILITY1.pio_enabled.next     = ENABLE_PIO;
    hwif_in.CAPABILITY1.ecc_enabled.next     = ECC_ENABLED;

    // key slot metadata readback (metadata only, never key bytes)
    hwif_in.KEY_SLOT_META.owner.next        = ks_meta_owner;
    hwif_in.KEY_SLOT_META.algorithm.next    = ks_meta_algo[2:0];
    hwif_in.KEY_SLOT_META.parameter_set.next= ks_meta_pset;
    hwif_in.KEY_SLOT_META.usage_mask.next   = ks_meta_usage;
    hwif_in.KEY_SLOT_META.exportable.next   = ks_meta_exportable;
    hwif_in.KEY_SLOT_META.valid.next        = ks_meta_valid;
    hwif_in.KEY_SLOT_META.locked.next       = ks_meta_locked;
    hwif_in.KEY_SLOT_GEN.generation.next    = ks_meta_generation;
  end

  // ===========================================================================
  // Command frontend
  // ===========================================================================
  pqc_cmd_frontend #(
    .DMA_DATA_WIDTH(DMA_DATA_WIDTH), .DMA_WINDOW_LIMIT(64'h00000000ffffffff)
  ) u_frontend (
    .clk                (clk),
    .rst_n              (rst_n),
    .enable_sw          (hwif_out.CTRL.enable.value),
    .abort_sw           (hwif_out.CTRL.abort.value),
    .zeroize_sw         (hwif_out.CTRL.zeroize.value),
    .self_test_sw       (hwif_out.CTRL.self_test.value),
    .doorbell_sw        (hwif_out.DOORBELL.doorbell.value),
    .desc_addr_lo_sw    (hwif_out.DESC_ADDR_LO.desc_addr_lo.value),
    .desc_addr_hi_sw    (hwif_out.DESC_ADDR_HI.desc_addr_hi.value),
    .key_handle_slot    (hwif_out.KEY_HANDLE.slot_id.value[7:0]),
    .key_handle_gen     (hwif_out.KEY_HANDLE.generation.value),
    .key_handle_owner   (8'h0),
    .key_handle_type    (3'b0 /* type is not encoded in the opaque handle */),
    .key_handle_ok      (work_key_ok),
    .cap_enabled        (hwif_out.CTRL.enable.value),
    .cap_algo_mask      (cap_algo_mask),
    .desc_fetch_req     (fe_desc_fetch_req),
    .desc_fetch_addr    (fe_desc_fetch_addr),
    .desc_data          (fe_desc_data),
    .desc_data_idx      (fe_desc_data_idx),
    .desc_data_valid    (fe_desc_data_valid),
    .desc_fetch_done    (df_done),
    .desc_fetch_error   (df_error),
    .alg_start          (alg_start),
    .alg_op             (alg_op),
    .alg_pset           (alg_pset),
    .command_key_handle (command_key_handle),
    .command            (validated_command),
    .command_valid      (validated_command_valid),
    .alg_busy           (fe_alg_busy),
    .alg_done           (fe_alg_done),
    .alg_op_error       (fe_alg_op_error),
    .busy               (fe_busy),
    .idle               (fe_idle),
    .done_pulse         (fe_done_pulse),
    .comp_status        (fe_comp_status),
    .comp_error         (fe_comp_error),
    .completion_tag     (fe_completion_tag),
    .fsm_state_o        (fe_fsm_state),
    .locked             (fault_locked),
    .zeroize_req        (zeroize_req_any),
    .tamper             (tamper_in),
    .rng_fault          (~entropy_health_ok),
    .selftest_fail      (1'b0),
    .irq_done           (irq_done),
    .irq_error          (irq_error),
    .irq_rng            (irq_rng),
    .irq_tamper         (irq_tamper),
    .irq_selftest       (irq_selftest)
  );

  // ===========================================================================
  // Fault / zeroize controller
  // ===========================================================================
  pqc_fault_ctrl #(
    .ZEROIZE_MAX_CYCLES (ZEROIZE_MAX_CYCLES)
  ) u_fault_ctrl (
    .clk                 (clk),
    .rst_n               (rst_n),
    .tamper              (tamper_in),
    .ecc_ued             (ecc_ued || work_key_integrity_error),
    .ecc_ded             (ecc_ded),
    .selftest_fail       (irq_selftest),
    .lifecycle_change    (lifecycle_strap),
    .dma_error           (dma_error),
    .timeout             (1'b0),
    .rng_health_fail     (~entropy_health_ok),
    .zeroize_req_ext     (zeroize_req_in || km_revoke || hwif_out.CTRL.zeroize.value || hwif_out.CTRL.abort.value || datapath_abort_q),
    .fsm_state           (fe_fsm_state),
    .counter_parity_err  (read_arb_fault),
    .dft_enable          (dft_enable),
    .fault_inject_ecc_ue (fault_inject_ecc_ue),
    .sram_zeroize_done   (sram_zeroize_done),
    .keccak_zeroize_done (kec_zeroize_done),
    .work_key_zeroize_done (work_key_zero_done),
    .dma_zeroize_done (dma_zero_done),
    .desc_zeroize_done (desc_zero_done),
    .keys_zeroize_done   (ks_zeroize_done),
    .zeroize_req         (fault_zeroize_req),
    .zeroize_done        (fault_zeroize_done),
    .locked              (fault_locked),
    .alert_recoverable   (alert_recoverable),
    .alert_fatal         (alert_fatal),
    .integrity_fault     (integrity_fault),
    .fsm_state_o         ()
  );

  // DFT/extension fault injection is only effective while the DFT lifecycle
  // gate is open (the fault controller applies the same gate internally).
  assign dft_enable = lifecycle_strap;

  // ===========================================================================
  // Key slots
  // ===========================================================================
  pqc_key_slots #(
    .KEY_SLOT_NUM (KEY_SLOT_NUM)
  ) u_key_slots (
    .clk              (clk),
    .rst_n            (rst_n),
    .ctl_we           (1'b0),
    .ctl_index        (hwif_out.KEY_SLOT_CTRL.slot_index.value),
    .ctl_type         (hwif_out.KEY_SLOT_CTRL.key_type.value),
    .ctl_import       (hwif_out.KEY_SLOT_CTRL.import_req.value),
    .ctl_destroy      (hwif_out.KEY_SLOT_CTRL.destroy_req.value),
    .ctl_export       (hwif_out.KEY_SLOT_CTRL.export_req.value),
    .ctl_lock         (hwif_out.KEY_SLOT_CTRL.lock_req.value),
    .ctl_owner        (8'h0),
    .ctl_algo         (4'h0),
    .ctl_pset         (4'h0),
    .ctl_usage        (8'h0),
    .ctl_exportable   (1'b0),
    .ctl_privileged   (privileged),
    .meta_owner       (ks_meta_owner),
    .meta_algo        (ks_meta_algo),
    .meta_pset        (ks_meta_pset),
    .meta_usage       (ks_meta_usage),
    .meta_exportable  (ks_meta_exportable),
    .meta_valid       (ks_meta_valid),
    .meta_locked      (ks_meta_locked),
    .meta_generation  (ks_meta_generation),
    .hnd_valid        (1'b1),
    .hnd_slot         (hwif_out.KEY_HANDLE.slot_id.value[7:0]),
    .hnd_generation   (hwif_out.KEY_HANDLE.generation.value),
    .hnd_owner        (hwif_out.KEY_HANDLE.owner.value),
    .hnd_type         (3'b0 /* type is not encoded in the opaque handle */),
    .hnd_algo         (pqc_pkg::is_dsa(param_set_e'(alg_pset)) ? 4'd2 : 4'd1),
    .hnd_pset         ({1'b0,alg_pset}),
    .hnd_usage        (8'd1 << alg_op),
    .hnd_ok           (ks_hnd_ok),
    .key_ref          (ks_key_ref),
    .privileged       (privileged),
    .debug_unlocked   (debug_unlocked),
    .lifecycle_change (lifecycle_strap),
    .access_denied    (ks_access_denied),
    .zeroize_req      (zeroize_req_any),
    .zeroize_done     (ks_zeroize_done)
  );

  assign km_begin_ready = work_key_begin_ready && fe_idle && !fault_locked;
  pqc_work_key_ram u_work_key_ram (
    .clk(clk), .rst_n(rst_n),
    .load_begin(km_begin && fe_idle && !fault_locked), .load_begin_ready(work_key_begin_ready),
    .load_handle(km_handle), .load_algo(km_algo), .load_pset(km_pset),
    .load_usage(km_usage), .load_bytes(km_bytes),
    .load_valid(km_valid), .load_ready(km_ready), .load_data(km_data), .load_last(km_last),
    .load_done(km_done), .load_error(km_error),
    .check_handle(command_key_handle),
    .check_algo(pqc_pkg::is_dsa(param_set_e'(alg_pset)) ? 4'd2 : 4'd1),
    .check_pset({1'b0,alg_pset}), .check_usage(8'd1 << alg_op), .check_ok(work_key_ok),
    // The private read port is reserved for the algorithm sequencer. It is not
    // connected to either public DMA or CSR. Full algorithm scheduling remains pending.
    .read_req(1'b0), .read_word(16'd0), .read_valid(), .read_error(), .read_data(),
    .retire(fe_done_pulse), .zeroize_req(zeroize_req_any), .zeroize_done(work_key_zero_done), .integrity_error(work_key_integrity_error)
  );

  // ===========================================================================
  // Secure working SRAM
  // ===========================================================================
  pqc_secure_sram_ctrl #(
    .LOCAL_SRAM_KIB (LOCAL_SRAM_KIB)
  ) u_sram (
    .clk            (clk),
    .rst_n          (rst_n),
    .c0_req         (sram_c0_req),
    .c0_we          (sram_c0_we),
    .c0_addr        (sram_c0_addr),
    .c0_wdata       (sram_c0_wdata),
    .c0_rdata       (sram_c0_rdata),
    .c0_ready       (sram_c0_ready),
    .c1_req         (sram_c1_req),
    .c1_we          (sram_c1_we),
    .c1_addr        (sram_c1_addr),
    .c1_wdata       (sram_c1_wdata),
    .c1_rdata       (sram_c1_rdata),
    .c1_ready       (sram_c1_ready),
    .d_req          (sram_d_req),
    .d_we           (sram_d_we),
    .d_addr         (sram_d_addr),
    .d_wdata        (sram_d_wdata),
    .d_wstrb        (dma_buf_wstrb),
    .d_rdata        (sram_d_rdata),
    .d_ready        (sram_d_ready),
    // Page metadata is auto-tagged by the controller (a page becomes valid on
    // its first accepted write) so a primitive cannot read an uninitialised
    // page; explicit tag_we is reserved for secret/representation tagging.
    .tag_we         (1'b0),
    .tag_page       (8'h0),
    .tag_rep        (4'h0),
    .tag_algo       (4'h0),
    .tag_pset       (4'h0),
    .tag_secret     (1'b0),
    .tag_valid      (1'b0),
    .tag_check_req  (1'b0),
    .tag_check_page (8'h0),
    .tag_check_ok   (sram_tag_check_ok),
    .access_denied  (sram_access_denied),
    .ecc_ded        (ecc_ded),
    .ecc_ued        (ecc_ued),
    .ecc_inject_en  (1'b0),
    .ecc_inject_idx (16'h0),
    .ecc_inject_mask(39'h0),
    .zeroize_req    (zeroize_req_any),
    .zeroize_done   (sram_zeroize_done)
  );

  // ===========================================================================
  // Keccak engine
  // ===========================================================================
  pqc_keccak #(
    .ROUNDS_PER_CYCLE (KECCAK_ROUNDS_PER_CYCLE)
  ) u_keccak (
    .clk          (clk),
    .rst_n        (rst_n),
    .start        (1'b0),
    .function_id  (KEC_SHAKE128),
    .ctx_sel      (1'b1),
    .out_len      (32'h0),
    .in_valid     (1'b0),
    .in_ready     (),
    .in_data      (8'h0),
    .in_last      (1'b0),
    .out_valid    (kec_out_valid),
    .out_ready    (kec_out_ready),
    .out_data     (kec_out_data),
    .out_last     (kec_out_last),
    .busy         (kec_busy),
    .done         (kec_done),
    .zeroize_req  (zeroize_req_any),
    .zeroize_done (kec_zeroize_done)
  );

  // The Keccak output is consumed by the sampler when it is active; otherwise
  // the digest path drains. Back-pressure is the real sampler squeeze-ready.
  assign kec_out_ready = samp_sqz_ready | dsa_busy;

  // ===========================================================================
  // Polynomial engine
  // ===========================================================================
  pqc_poly_engine #(
    .NTT_LANES (NTT_LANES)
  ) u_poly (
    .clk          (clk),
    .rst_n        (rst_n),
    .start        (poly_start),
    .prim         (poly_prim),
    .domain       (poly_domain),
    .src_page     (poly_src_page),
    .src2_page    (poly_src2_page),
    .dst_page     (poly_dst_page),
    .busy         (poly_busy),
    .done         (poly_done),
    .mem_req      (poly_mem_req),
    .mem_we       (poly_mem_we),
    .mem_addr     (poly_mem_addr),
    .mem_wdata    (poly_mem_wdata),
    .mem_rdata    (poly_mem_rdata),
    .mem_ready    (poly_mem_ready),
    .zeroize_req  (zeroize_req_any)
  );

  assign poly_mem_ready = sram_c0_ready;
  assign poly_mem_rdata = sram_c0_rdata;

  // Primitive arbitration: only one sequencer drives the shared polynomial
  // engine at a time. KEM owns it while kem_busy, otherwise the DSA sequencer.
  always_comb begin
    if (kem_prim_start && !dsa_prim_start) begin
      poly_start     = 1'b1;
      poly_prim      = kem_prim_op;
      poly_domain    = kem_prim_domain;
      poly_src_page  = kem_poly_src;
      poly_src2_page = kem_poly_src2;
      poly_dst_page  = kem_poly_dst;
    end else begin
      poly_start     = dsa_prim_start;
      poly_prim      = dsa_prim_op;
      poly_domain    = dsa_prim_domain;
      poly_src_page  = dsa_poly_src;
      poly_src2_page = dsa_poly_src2;
      poly_dst_page  = dsa_poly_dst;
    end
  end

  // ===========================================================================
  // Codec
  // ===========================================================================
  pqc_codec u_codec (
    .clk          (clk),
    .rst_n        (rst_n),
    .start        (1'b0),
    .op           (4'h0),
    .domain       (1'b0),
    .d_comp       (5'd10),
    .gamma2_sel   (2'h1),
    .src_page     (8'h0),
    .src2_page    (8'h1),
    .dst_page     (8'h0),
    .bound        (32'h0),
    .busy         (codec_busy),
    .done         (codec_done),
    .canonical_ok (codec_canonical_ok),
    .norm_ok      (codec_norm_ok),
    .mem_req      (codec_mem_req),
    .mem_we       (codec_mem_we),
    .mem_addr     (codec_mem_addr),
    .mem_wdata    (codec_mem_wdata),
    .mem_rdata    (codec_mem_rdata),
    .mem_ready    (codec_mem_ready),
    .zeroize_req  (zeroize_req_any)
  );

  assign codec_mem_ready = sram_c1_ready && c1_owner_valid && c1_owner_codec;
  assign codec_mem_rdata = sram_c1_rdata;

  // ===========================================================================
  // Sampler
  // ===========================================================================
  pqc_sampler u_sampler (
    .clk          (clk),
    .rst_n        (rst_n),
    .start        (samp_start),
    .mode         (samp_mode),
    .domain       (samp_domain),
    .dst_page     (samp_dst_page),
    .eta          (samp_eta),
    .tau          ((alg_pset == 4'd4) ? 7'd39 : (alg_pset == 4'd5) ? 7'd49 : 7'd60),
    .gamma1_sel   (samp_gamma1),
    .busy         (samp_busy),
    .done         (samp_done),
    .op_error     (samp_op_error),
    .sqz_valid    (kec_out_valid),
    .sqz_ready    (samp_sqz_ready),
    .sqz_data     (kec_out_data),
    .mem_req      (samp_mem_req),
    .mem_we       (samp_mem_we),
    .mem_addr     (samp_mem_addr),
    .mem_wdata    (samp_mem_wdata),
    .mem_ready    (samp_mem_ready),
    .zeroize_req  (zeroize_req_any)
  );

  assign samp_mem_ready = sram_c1_ready && c1_owner_valid && !c1_owner_codec;

  // KEM ExpandA drives the sampler with the rejection mode into the A page;
  // the mode/eta follow the parameter set (eta = 2 for all three ML-KEM sets
  // as used by the reference model).
  assign samp_start    = kem_prim_start && (kem_prim_op == PRIM_NOP);
  assign samp_mode     = SAMP_REJ_KEM;
  assign samp_domain   = 1'b0;
  assign samp_dst_page = kem_poly_src;
  assign samp_eta      = 4'd2;
  assign samp_gamma1   = 5'd17;

  // ===========================================================================
  // Sequencers
  // ===========================================================================
  pqc_kem_seq u_kem_seq (
    .clk          (clk),
    .rst_n        (rst_n),
    .start        (alg_start && (alg_pset <= 3'd3)),
    .op           (alg_op),
    .rank         (kem_rank(param_set_e'(alg_pset))),
    .busy         (kem_busy),
    .done         (kem_done),
    .op_error     (kem_op_error),
    .prim_start      (kem_prim_start),
    .prim_op         (kem_prim_op),
    .prim_domain     (kem_prim_domain),
    .prim_busy       (poly_busy),
    .prim_done       (poly_done | kec_done),
    .poly_src_page   (kem_poly_src),
    .poly_src2_page  (kem_poly_src2),
    .poly_dst_page   (kem_poly_dst),
    .ct_bytes     (kem_ciphertext_bytes(param_set_e'(alg_pset))),
    .ct_read_data (8'h0),
    .ct_read_addr (),
    .ct_calc_data (8'h0),
    .ct_calc_addr (),
    .kprime_data  (8'h0),
    .kbar_data    (8'h0),
    .ss_addr      (),
    .ss_wdata     (),
    .ss_we        (),
    .ct_len       (),
    .verify_mask  (),
    .zeroize_req  (zeroize_req_any)
  );

  pqc_dsa_seq u_dsa_seq (
    .clk             (clk),
    .rst_n           (rst_n),
    .start           (alg_start && is_dsa(param_set_e'(alg_pset))),
    .op              (alg_op),
    .pset            (alg_pset),
    .busy            (dsa_busy),
    .done            (dsa_done),
    .verify_valid    (dsa_verify_valid),
    .retry_exhausted (dsa_retry_exhausted),
    .op_error        (dsa_op_error),
    .prim_start      (dsa_prim_start),
    .prim_op         (dsa_prim_op),
    .prim_domain     (dsa_prim_domain),
    .prim_busy       (poly_busy),
    .prim_done       (poly_done | kec_done),
    .poly_src_page   (dsa_poly_src),
    .poly_src2_page  (dsa_poly_src2),
    .poly_dst_page   (dsa_poly_dst),
    .norm_z_ok       (codec_norm_ok),
    .norm_r0_ok      (codec_norm_ok),
    .hint_weight_ok  (codec_canonical_ok),
    .stage_req       (dsa_stage_req),
    .stage_we        (dsa_stage_we),
    .stage_addr      (dsa_stage_addr),
    .stage_wdata     (dsa_stage_wdata),
    .stage_rdata     (dsa_stage_rdata),
    .stage_ready     (dsa_stage_ready),
    .commit_valid    (dsa_commit_valid),
    .sig_len         (dsa_sig_len),
    .ct_calc_we      (dsa_ct_calc_we),
    .ct_calc_byte    (dsa_ct_calc_byte),
    .ct_ref_we       (dsa_ct_ref_we),
    .ct_ref_byte     (dsa_ct_ref_byte),
    .ct_clear        (dsa_ct_clear),
    .zeroize_req     (zeroize_req_any)
  );

  // Staging buffer staging path: the candidate signature is streamed from the
  // compute SRAM byte lane 0. stage_ready follows the SRAM port handshake.
  assign dsa_stage_rdata = sram_c0_rdata[7:0];
  assign dsa_stage_ready = sram_c0_ready;

  // Challenge digest byte ports: recomputed digest from the Keccak XOF stream,
  // reference digest from the input buffer path; cleared at command start.
  assign dsa_ct_calc_we   = kec_out_valid & kec_out_ready & dsa_busy;
  assign dsa_ct_calc_byte = kec_out_data;
  // one-shot rewind at command start (alg_start is a level held through EXECUTE)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) alg_start_q <= 1'b0;
    else        alg_start_q <= alg_start;
  end
  assign dsa_ct_clear     = alg_start & ~alg_start_q;

  // The reference digest is staged by the frontend into a descriptor shadow;
  // until that path is enabled the reference bytes read as zero and verify
  // therefore fails closed rather than falsely succeeding.
  assign dsa_ct_ref_we   = 1'b0;
  assign dsa_ct_ref_byte = 8'h0;

  assign alg_busy    = kem_busy | dsa_busy;
  assign alg_done    = kem_done | dsa_done;
  // A DSA signature rejected by the normative checks is a public API result
  // (ST_VERIFY_INVALID), not an operation error; only retry exhaustion is an
  // internal error.
  assign alg_op_error= kem_op_error | dsa_op_error | dsa_retry_exhausted | samp_op_error | sram_access_denied;

  // Algorithm feedback into the command frontend (F01): the frontend EXECUTE
  // state waits for alg_done and reacts to alg_op_error, so these must be the
  // real sequencer signals, not left floating.
  assign fe_alg_busy     = alg_busy;
  assign fe_alg_done     = alg_done;
  assign fe_alg_op_error = alg_op_error;

  // ===========================================================================
  // DMA
  // ===========================================================================
  pqc_dma #(
    .DATA_WIDTH (DMA_DATA_WIDTH),
    .ADDR_WIDTH (40),
    .WORD_WIDTH (32),
    .LOCAL_WORDS (LOCAL_SRAM_KIB*256),
    .WIN_BASE   (40'h0),
    .WIN_LIMIT  (40'hFFFF_FFFF)
  ) u_dma (
    .clk          (clk),
    .rst_n        (rst_n),
    .xfer_req     (1'b0),
    .xfer_we      (1'b0),
    .xfer_addr    (40'h0),
    .xfer_len     (64'h0),
    .xfer_secure  (1'b1),
    .xfer_priv    (privileged),
    .xfer_done    (dma_done),
    .xfer_error   (dma_error),
    .buf_req      (dma_buf_req),
    .buf_we       (dma_buf_we),
    .buf_addr     (dma_buf_addr),
    .buf_wdata    (dma_buf_wdata),
    .buf_wstrb    (dma_buf_wstrb),
    .buf_rdata    (dma_buf_rdata),
    .buf_ready    (dma_buf_ready),
    .m_ar_valid   (m_ar_valid_dma),
    .m_ar_ready   (m_ar_ready_dma),
    .m_ar_addr    (m_ar_addr_dma),
    .m_ar_len     (m_ar_len_dma),
    .m_ar_prot    (m_ar_prot_dma),
    .m_r_valid    (m_r_valid_dma),
    .m_r_ready    (m_r_ready_dma),
    .m_r_data     (m_r_data),
    .m_r_resp     (m_r_resp),
    .m_r_last     (m_r_last),
    .m_aw_valid   (m_aw_valid),
    .m_aw_ready   (m_aw_ready),
    .m_aw_addr    (m_aw_addr),
    .m_aw_len     (m_aw_len),
    .m_aw_prot    (m_aw_prot),
    .m_w_valid    (m_w_valid),
    .m_w_ready    (m_w_ready),
    .m_w_data     (m_w_data),
    .m_w_strb     (m_w_strb),
    .m_w_last     (m_w_last),
    .m_b_valid    (m_b_valid),
    .m_b_ready    (m_b_ready),
    .m_b_resp     (m_b_resp),
    .zeroize_req  (zeroize_req_any),
    .zeroize_done (dma_zero_done)
  );

  // ===========================================================================
  // Descriptor fetch engine (dedicated 128-byte AXI read) with read-channel
  // arbitration: the descriptor fetch has priority because the DMA is busy
  // only while a command is executing, which is after the fetch completes.
  // ===========================================================================
  logic        df_ar_valid, df_ar_ready;
  logic [39:0] df_ar_addr;
  logic [7:0]  df_ar_len;
  logic [2:0]  df_ar_prot;
  logic        df_r_valid, df_r_ready;
  logic [DMA_DATA_WIDTH-1:0] df_r_data;
  logic [1:0]  df_r_resp;
  logic        df_r_last;

  // (DMA-side AXI declarations are at the top with the other DMA signals)

  pqc_desc_fetch #(
    .DATA_WIDTH (DMA_DATA_WIDTH),
    .ADDR_WIDTH (40),
    .DESC_BYTES (128),
    .WIN_LIMIT  (40'h00ffffffff)
  ) u_desc_fetch (
    .clk             (clk),
    .rst_n           (rst_n),
    .start           (fe_desc_fetch_req),
    .addr            (fe_desc_fetch_addr),
    .busy            (df_busy),
    .done            (df_done),
    .error           (df_error),
    .m_ar_valid      (df_ar_valid),
    .m_ar_ready      (df_ar_ready),
    .m_ar_addr       (df_ar_addr),
    .m_ar_len        (df_ar_len),
    .m_ar_prot       (df_ar_prot),
    .m_r_valid       (df_r_valid),
    .m_r_ready       (df_r_ready),
    .m_r_data        (df_r_data),
    .m_r_resp        (df_r_resp),
    .m_r_last        (df_r_last),
    .desc_data       (fe_desc_data),
    .desc_data_idx   (fe_desc_data_idx),
    .desc_data_valid (fe_desc_data_valid),
    .zeroize_req     (zeroize_req_any),
    .zeroize_done (desc_zero_done)
  );

  // Ownership starts before AR is offered, and lasts through the final R beat.
  // Cancel is handled by the clients; never clear ownership before AXI drains.
  pqc_axi_read_arb #(.ADDR_WIDTH(40), .DATA_WIDTH(DMA_DATA_WIDTH)) u_read_arb (
    .clk(clk), .rst_n(rst_n),
    .s_ar_valid({m_ar_valid_dma, df_ar_valid}),
    .s_ar_ready({m_ar_ready_dma, df_ar_ready}),
    .s_ar_addr({m_ar_addr_dma, df_ar_addr}),
    .s_ar_len({m_ar_len_dma, df_ar_len}),
    .s_ar_prot({m_ar_prot_dma, df_ar_prot}),
    .s_r_valid({m_r_valid_dma, df_r_valid}),
    .s_r_ready({m_r_ready_dma, df_r_ready}),
    .s_r_data(df_r_data), .s_r_resp(df_r_resp), .s_r_last(df_r_last),
    .m_ar_valid(m_ar_valid), .m_ar_ready(m_ar_ready), .m_ar_addr(m_ar_addr),
    .m_ar_len(m_ar_len), .m_ar_prot(m_ar_prot),
    .m_r_valid(m_r_valid), .m_r_ready(m_r_ready), .m_r_data(m_r_data),
    .m_r_resp(m_r_resp), .m_r_last(m_r_last), .fault(read_arb_fault)
  );

  assign dma_buf_ready = sram_d_ready;
  assign dma_buf_rdata = sram_d_rdata;

  // SRAM port sharing: compute0 = poly, compute1 = codec/sampler, DMA = dma
  assign sram_c0_req   = poly_mem_req;
  assign sram_c0_we    = poly_mem_we;
  assign sram_c0_addr  = poly_mem_addr;
  assign sram_c0_wdata = poly_mem_wdata;

  assign sram_c1_req   = codec_mem_req | samp_mem_req;
  assign sram_c1_we    = c1_select_codec ? codec_mem_we : samp_mem_we;
  assign sram_c1_addr  = c1_select_codec ? codec_mem_addr : samp_mem_addr;
  assign sram_c1_wdata = c1_select_codec ? codec_mem_wdata : samp_mem_wdata;

  assign sram_d_req    = dma_buf_req;
  assign sram_d_we     = dma_buf_we;
  assign sram_d_addr   = dma_buf_addr;
  assign sram_d_wdata  = dma_buf_wdata;

  // ===========================================================================
  // Entropy and interrupt aggregation
  // ===========================================================================
  assign entropy_ready = alg_busy && entropy_health_ok;

  // Interrupt output is gated by INTR_STATE & INTR_ENABLE, so a masked source
  // never reaches the output pin. INTR_TEST sets INTR_STATE (above), which this
  // path then observes, so a software-forced interrupt is also delivered.
  logic irq_state, irq_enable;
  assign irq_state  = hwif_out.INTR_STATE.done.value          | hwif_out.INTR_STATE.error.value |
                      hwif_out.INTR_STATE.rng_fault.value     | hwif_out.INTR_STATE.tamper.value |
                      hwif_out.INTR_STATE.self_test_fail.value;
  assign irq_enable = hwif_out.INTR_ENABLE.done_en.value          |
                      hwif_out.INTR_ENABLE.error_en.value         |
                      hwif_out.INTR_ENABLE.rng_fault_en.value     |
                      hwif_out.INTR_ENABLE.tamper_en.value        |
                      hwif_out.INTR_ENABLE.self_test_fail_en.value;
  assign irq = (hwif_out.INTR_STATE.done.value & hwif_out.INTR_ENABLE.done_en.value)
             | (hwif_out.INTR_STATE.error.value & hwif_out.INTR_ENABLE.error_en.value)
             | (hwif_out.INTR_STATE.rng_fault.value & hwif_out.INTR_ENABLE.rng_fault_en.value)
             | (hwif_out.INTR_STATE.tamper.value & hwif_out.INTR_ENABLE.tamper_en.value)
             | (hwif_out.INTR_STATE.self_test_fail.value & hwif_out.INTR_ENABLE.self_test_fail_en.value);

  // Register the abort decision: DMA suppresses buf_req while zeroizing, so
  // feeding its combinational access_denied straight back would form a loop.
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) datapath_abort_q<=0;
    else datapath_abort_q<=alg_op_error && fe_busy;
  end

  assign c1_select_codec = c1_owner_valid ? c1_owner_codec : codec_mem_req;
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin c1_owner_valid<=0; c1_owner_codec<=0; end
    else if(zeroize_req_any) begin c1_owner_valid<=0; c1_owner_codec<=0; end
    else if(c1_owner_valid && sram_c1_ready) c1_owner_valid<=0;
    else if(!c1_owner_valid && (codec_mem_req || samp_mem_req)) begin
      c1_owner_valid<=1; c1_owner_codec<=codec_mem_req;
    end
  end
endmodule

`endif // PQC_TOP_SV
