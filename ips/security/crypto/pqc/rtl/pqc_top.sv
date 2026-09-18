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

  // Trusted context for newly generated material. KM advances epoch on reset.
  input logic [31:0] km_generated_handle, km_generated_epoch,
  input logic [7:0] km_generated_owner, km_generated_domain,
  output logic km_custody_header_valid, input logic km_custody_header_ready,
  output logic [31:0] km_custody_transaction, km_custody_epoch, km_custody_handle,
  output logic [7:0] km_custody_owner, km_custody_domain,
  output logic [3:0] km_custody_algo, km_custody_pset,
  output logic [15:0] km_custody_bytes,
  output logic km_custody_valid, input logic km_custody_ready,
  output logic [31:0] km_custody_data, output logic km_custody_last,
  input logic km_custody_ack_valid, output logic km_custody_ack_ready,
  input logic [31:0] km_custody_ack_transaction, km_custody_ack_epoch, km_custody_ack_handle,
  input logic [7:0] km_custody_ack_owner, km_custody_ack_domain,
  input logic [15:0] km_custody_ack_bytes, input logic km_custody_ack_success,


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

  // Encaps transaction: validated descriptor -> input -> compute -> two outputs
  // -> completion B response -> frontend retirement. Unsupported full programs
  // fail closed until their own schedulers are integrated.
  typedef enum logic [5:0] {TX_IDLE,TX_INPUT,TX_COMPUTE,TX_CT,TX_SS,
    TX_RECORD,TX_RECORD_GAP,TX_COMMIT,TX_DONE,TX_ERROR,TX_CT_GAP,
    TX_DC_IN,TX_DC_COMPUTE,TX_DC_SS,TX_DC_RECORD,TX_DC_RECORD_GAP,
    TX_DC_COMMIT,TX_DC_DONE,TX_KG_PREP,TX_KG_BEGIN,TX_KG_COMPUTE,TX_KG_SCAN,
    TX_KG_CUST_START,TX_KG_CUST_WAIT,TX_KG_HANDLE_WRITE,TX_KG_PK,TX_KG_PK_GAP,TX_KG_HANDLE,TX_DV_IN,TX_DV_CTX_GAP,TX_DV_CTX,TX_DV_COMPUTE,TX_DS_BEGIN,TX_DS_CTX,TX_DS_COMPUTE,TX_DS_OUT} tx_state_t;
  tx_state_t tx_state;
  pqc_command_t tx_command;
  logic tx_dma_req, tx_dma_we, enc_start;
  logic [39:0] tx_dma_addr;
  logic [63:0] tx_dma_len;
  logic [15:0] tx_base;
  logic [2:0] tx_record_idx;
  logic [31:0] tx_record_data, tx_cycles;
  // Decaps program signals (selected over the Encaps signals when the command
  // is OP_KEM_DECAPS). Both programs share the same engines and SRAM ports,
  // and only one command runs at a time, so a static per-command mux is safe.
  logic dec_start;
  logic d_busy,d_done,d_error,d_mem_req,d_mem_we,d_entropy_ready;
  logic [15:0] d_mem_addr;
  logic [31:0] d_mem_wdata;
  logic d_poly_start,d_codec_start,d_sampler_start,d_sampler_valid;
  logic [3:0] d_poly_op,d_codec_op,d_sampler_eta;
  logic [7:0] d_poly_src,d_poly_src2,d_poly_dst,d_codec_src,d_codec_dst,d_sampler_dst;
  logic [4:0] d_codec_bits;
  logic [2:0] d_sampler_mode,d_hash_function;
  logic d_hash_start,d_hash_in_valid,d_hash_in_last,d_hash_in_ready,d_hash_out_ready;
  logic [7:0] d_hash_in_data;
  logic [31:0] d_hash_length;
  logic [15:0] d_wk_read_word;
  logic d_wk_read_req;
  logic wk_read_valid, wk_read_error;
  logic [31:0] wk_read_data;
  logic algo_is_decaps;
  assign algo_is_decaps = (tx_command.opcode==OP_KEM_DECAPS);
  logic e_busy,e_done,e_error,e_mem_req,e_mem_we,e_entropy_ready;
  logic [15:0] e_mem_addr;
  logic [31:0] e_mem_wdata;
  logic e_poly_start,e_codec_start,e_sampler_start,e_sampler_valid;
  logic [3:0] e_poly_op,e_codec_op,e_sampler_eta;
  logic [7:0] e_poly_src,e_poly_src2,e_poly_dst,e_codec_src,e_codec_dst,e_sampler_dst;
  logic [4:0] e_codec_bits;
  logic [2:0] e_sampler_mode,e_hash_function;
  logic e_hash_start,e_hash_in_valid,e_hash_in_last,e_hash_in_ready,e_hash_out_ready;
  logic [7:0] e_hash_in_data;
  logic [31:0] e_hash_length;
  logic s_busy,s_done,s_error,s_mem_req,s_mem_we,s_entropy_ready;
  logic [15:0] s_mem_addr;
  logic [31:0] s_mem_wdata;
  logic s_poly_start,s_codec_start,s_sampler_start,s_sampler_valid;
  logic [3:0] s_poly_op,s_codec_op,s_sampler_eta;
  logic [7:0] s_poly_src,s_poly_src2,s_poly_dst,s_codec_src,s_codec_dst,s_sampler_dst;
  logic [4:0] s_codec_bits;
  logic [2:0] s_sampler_mode,s_hash_function;
  logic s_hash_start,s_hash_in_valid,s_hash_in_last,s_hash_in_ready,s_hash_out_ready;
  logic [7:0] s_hash_in_data;
  logic [31:0] s_hash_length;
  logic algo_is_sign,s_start,s_message_dma_req,s_wk_read_req;
  logic [39:0] s_message_dma_addr;
  logic [63:0] s_message_dma_len;
  logic [15:0] s_wk_read_word;
  logic [7:0] s_codec_src2;
  logic [1:0] s_codec_gamma2;
  assign algo_is_sign=tx_command.opcode==OP_DSA_SIGN && tx_state!=TX_IDLE;
  assign s_hash_in_ready=e_hash_in_ready;
  logic v_busy,v_done,v_error,v_mem_req,v_mem_we,v_entropy_ready;
  logic [15:0] v_mem_addr;
  logic [31:0] v_mem_wdata;
  logic v_poly_start,v_codec_start,v_sampler_start,v_sampler_valid;
  logic [3:0] v_poly_op,v_codec_op,v_sampler_eta;
  logic [7:0] v_poly_src,v_poly_src2,v_poly_dst,v_codec_src,v_codec_dst,v_sampler_dst;
  logic [4:0] v_codec_bits;
  logic [2:0] v_sampler_mode,v_hash_function;
  logic v_hash_start,v_hash_in_valid,v_hash_in_last,v_hash_in_ready,v_hash_out_ready;
  logic [7:0] v_hash_in_data;
  logic [31:0] v_hash_length;
  logic algo_is_verify,v_start,v_verify_valid,v_message_dma_req;
  logic [39:0] v_message_dma_addr;
  logic [63:0] v_message_dma_len;
  logic [7:0] v_codec_src2;
  logic [1:0] v_codec_gamma2;
  logic verify_result_q,verify_done_q;
  assign algo_is_verify=tx_command.opcode==OP_DSA_VERIFY && tx_state!=TX_IDLE;
  assign v_hash_in_ready=e_hash_in_ready;
  assign v_entropy_ready=1'b0;
  logic j_busy,j_done,j_error,j_mem_req,j_mem_we,j_entropy_ready;
  logic [15:0] j_mem_addr;
  logic [31:0] j_mem_wdata;
  logic j_poly_start,j_codec_start,j_sampler_start,j_sampler_valid;
  logic [3:0] j_poly_op,j_codec_op,j_sampler_eta;
  logic [7:0] j_poly_src,j_poly_src2,j_poly_dst,j_codec_src,j_codec_dst,j_sampler_dst;
  logic [4:0] j_codec_bits;
  logic [2:0] j_sampler_mode,j_hash_function;
  logic j_hash_start,j_hash_in_valid,j_hash_in_last,j_hash_in_ready,j_hash_out_ready;
  logic [7:0] j_hash_in_data;
  logic [31:0] j_hash_length;
  logic g_busy,g_done,g_error,g_mem_req,g_mem_we,g_entropy_ready;
  logic [15:0] g_mem_addr;
  logic [31:0] g_mem_wdata;
  logic g_poly_start,g_codec_start,g_sampler_start,g_sampler_valid;
  logic [3:0] g_poly_op,g_codec_op,g_sampler_eta;
  logic [7:0] g_poly_src,g_poly_src2,g_poly_dst,g_codec_src,g_codec_dst,g_sampler_dst;
  logic [4:0] g_codec_bits;
  logic [2:0] g_sampler_mode,g_hash_function;
  logic g_hash_start,g_hash_in_valid,g_hash_in_last,g_hash_in_ready,g_hash_out_ready;
  logic [7:0] g_hash_in_data;
  logic [31:0] g_hash_length;
  logic algo_is_dsa_keygen,j_gen_valid,j_gen_last,g_gen_valid,g_gen_last;
  logic [31:0] j_gen_data,g_gen_data;
  assign algo_is_dsa_keygen=tx_command.opcode==OP_DSA_KEYGEN && tx_state!=TX_IDLE;
  assign j_hash_in_ready=e_hash_in_ready;
  logic algo_is_keygen,gen_start,gen_valid,gen_last,gen_ready;
  logic [31:0] gen_data,gen_handle,gen_epoch,gen_transaction,transaction_counter;
  logic [7:0] gen_owner,gen_domain;
  logic [15:0] gen_bytes;
  logic wk_load_ready,wk_load_done,wk_load_error;
  logic custody_busy,custody_done,custody_error,custody_read_req;
  logic [15:0] custody_read_word;
  assign algo_is_keygen=(tx_command.opcode==OP_KEM_KEYGEN || tx_command.opcode==OP_DSA_KEYGEN) && tx_state!=TX_IDLE;
  assign gen_bytes=algo_is_dsa_keygen ? (tx_command.pset==4 ? 16'd2560 : tx_command.pset==5 ? 16'd4032 : 16'd4896) : tx_command.pset==1 ? 16'd1632 : tx_command.pset==2 ? 16'd2400 : 16'd3168;
  assign g_hash_in_ready=e_hash_in_ready;
  assign gen_valid=algo_is_dsa_keygen ? j_gen_valid : g_gen_valid;
  assign gen_last=algo_is_dsa_keygen ? j_gen_last : g_gen_last;
  assign gen_data=algo_is_dsa_keygen ? j_gen_data : g_gen_data;
  assign gen_ready=wk_load_ready && algo_is_keygen;
  always_comb begin
    tx_dma_req=0; tx_dma_we=0; tx_dma_addr=0; tx_dma_len=0; tx_base=0;
    case(tx_state)
      TX_INPUT: begin tx_dma_req=1;tx_dma_addr=tx_command.src0_addr[39:0];tx_dma_len=tx_command.src0_len;tx_base=4096;end
      TX_CT: begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.dst0_addr[39:0];tx_dma_len=64'(tx_command.output0_bytes);tx_base=5120;end
      TX_SS: begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.dst1_addr[39:0];tx_dma_len=32;tx_base=5632;end
      TX_COMMIT: begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.completion_addr[39:0];tx_dma_len=32;tx_base=5888;end
      // Decaps: ciphertext in (src0 -> 0x1000), shared secret out (dst0 -> 0x1600).
      TX_DC_IN: begin tx_dma_req=1;tx_dma_addr=tx_command.src0_addr[39:0];tx_dma_len=tx_command.src0_len;tx_base=4096;end
      TX_DC_SS: begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.dst0_addr[39:0];tx_dma_len=32;tx_base=5632;end
      TX_DC_COMMIT: begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.completion_addr[39:0];tx_dma_len=32;tx_base=5888;end
      TX_KG_PK:begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.dst0_addr[39:0];tx_dma_len=64'(tx_command.output0_bytes);tx_base=algo_is_dsa_keygen ? 7168 : 4096;end
      TX_KG_HANDLE:begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.dst1_addr[39:0];tx_dma_len=4;tx_base=5632;end
      TX_DV_IN:begin tx_dma_req=1;tx_dma_addr=tx_command.src1_addr[39:0];tx_dma_len=tx_command.src1_len;tx_base=4352;end
      TX_DV_CTX:begin tx_dma_req=1;tx_dma_addr=tx_command.context_addr[39:0];tx_dma_len={32'd0,tx_command.context_len};tx_base=6912;end
      TX_DS_CTX:begin tx_dma_req=1;tx_dma_addr=tx_command.context_addr[39:0];tx_dma_len={32'd0,tx_command.context_len};tx_base=6912;end
      TX_DS_COMPUTE:begin tx_dma_req=s_message_dma_req;tx_dma_addr=s_message_dma_addr;tx_dma_len=s_message_dma_len;tx_base=7168;end
      TX_DS_OUT:begin tx_dma_req=1;tx_dma_we=1;tx_dma_addr=tx_command.dst0_addr[39:0];tx_dma_len=64'(tx_command.output0_bytes);tx_base=4864;end
      TX_DV_COMPUTE:begin tx_dma_req=v_message_dma_req;tx_dma_addr=v_message_dma_addr;tx_dma_len=v_message_dma_len;tx_base=7168;end
      default: ;
    endcase
    // Little-endian 32-byte completion: id/status/len0/len1/valid/error/cycles/reserved.
    case(tx_record_idx)
      0:tx_record_data=tx_command.command_id;
      1:tx_record_data=(algo_is_verify && !verify_result_q) ? 32'(ST_VERIFY_INVALID) : 32'(ST_SUCCESS);
      4:tx_record_data=algo_is_verify ? {31'd0,verify_result_q} : 32'd0;
      2:tx_record_data=32'(tx_command.output0_bytes);
      3:tx_record_data=32'(tx_command.output1_bytes);
      6:tx_record_data=tx_cycles;
      default:tx_record_data=0;
    endcase
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin transaction_counter<=0;tx_state<=TX_IDLE;tx_command<='0;tx_record_idx<=0;tx_cycles<=0;enc_start<=0;dec_start<=0;gen_start<=0;gen_handle<=0;gen_epoch<=0;gen_owner<=0;gen_domain<=0;gen_transaction<=0;v_start<=0;s_start<=0;verify_result_q<=0;verify_done_q<=0;end
    else if(zeroize_req_any) begin tx_state<=TX_IDLE;tx_command<='0;tx_record_idx<=0;tx_cycles<=0;enc_start<=0;dec_start<=0;gen_start<=0;gen_handle<=0;gen_epoch<=0;gen_owner<=0;gen_domain<=0;gen_transaction<=0;v_start<=0;s_start<=0;verify_result_q<=0;verify_done_q<=0;end
    else begin
      enc_start<=0;dec_start<=0;gen_start<=0;v_start<=0;s_start<=0;
      if(tx_state==TX_DONE && tx_command.opcode==OP_DSA_VERIFY) verify_done_q<=1;
      if(tx_state!=TX_IDLE && tx_state!=TX_DONE && tx_state!=TX_DC_DONE && tx_state!=TX_ERROR) tx_cycles<=tx_cycles+1'b1;
      if(dma_error && tx_dma_req) tx_state<=TX_ERROR;
      else case(tx_state)
        TX_IDLE: if(alg_start) begin
          tx_command<=validated_command;tx_cycles<=0;verify_result_q<=0;verify_done_q<=0;
          if(validated_command.opcode==OP_KEM_ENCAPS && SCA_LEVEL<2) tx_state<=TX_INPUT;
          else if(validated_command.opcode==OP_KEM_DECAPS && SCA_LEVEL<2) tx_state<=TX_DC_IN;
          else if((validated_command.opcode==OP_KEM_KEYGEN || validated_command.opcode==OP_DSA_KEYGEN) && SCA_LEVEL<2 && transaction_counter!=32'hffffffff) begin
            gen_handle<=km_generated_handle;gen_epoch<=km_generated_epoch;
            gen_owner<=km_generated_owner;gen_domain<=km_generated_domain;
            transaction_counter<=transaction_counter+1'b1;gen_transaction<=transaction_counter+1'b1;
            tx_state<=TX_KG_PREP;
          end else if(validated_command.opcode==OP_DSA_SIGN && SCA_LEVEL<2) tx_state<=TX_DS_BEGIN;
          else if(validated_command.opcode==OP_DSA_VERIFY && SCA_LEVEL<2) tx_state<=TX_DV_IN;
          else tx_state<=TX_ERROR;
        end
        TX_INPUT: if(dma_done) begin enc_start<=1;tx_state<=TX_COMPUTE;end
        TX_COMPUTE: if(e_error) tx_state<=TX_ERROR; else if(e_done) tx_state<=TX_CT;
        TX_CT: if(dma_done) tx_state<=TX_CT_GAP;
        TX_CT_GAP: tx_state<=TX_SS;
        TX_SS: if(dma_done) begin tx_record_idx<=0;tx_state<=TX_RECORD;end
        TX_RECORD: if(sram_c0_ready) tx_state<=TX_RECORD_GAP;
        TX_RECORD_GAP: if(tx_record_idx==7) tx_state<=TX_COMMIT;
          else begin tx_record_idx<=tx_record_idx+1'b1;tx_state<=TX_RECORD;end
        TX_COMMIT: if(dma_done) tx_state<=TX_DONE;
        TX_DONE: tx_state<=TX_IDLE;
        // --- Decaps transaction ---
        TX_DC_IN: if(dma_done) begin dec_start<=1;tx_state<=TX_DC_COMPUTE;end
        TX_DC_COMPUTE: if(d_error) tx_state<=TX_ERROR; else if(d_done) tx_state<=TX_DC_SS;
        TX_DC_SS: if(dma_done) begin tx_record_idx<=0;tx_state<=TX_DC_RECORD;end
        TX_DC_RECORD: if(sram_c0_ready) tx_state<=TX_DC_RECORD_GAP;
        TX_DC_RECORD_GAP: if(tx_record_idx==7) tx_state<=TX_DC_COMMIT;
          else begin tx_record_idx<=tx_record_idx+1'b1;tx_state<=TX_DC_RECORD;end
        TX_DC_COMMIT: if(dma_done) tx_state<=TX_DC_DONE;
        TX_DC_DONE: tx_state<=TX_IDLE;
        TX_KG_PREP:tx_state<=TX_KG_BEGIN;
        TX_KG_BEGIN:if(work_key_begin_ready) begin gen_start<=1;tx_state<=TX_KG_COMPUTE;end
        TX_KG_COMPUTE:if(g_error || j_error || wk_load_error) tx_state<=TX_ERROR;else if(algo_is_dsa_keygen ? j_done : g_done) tx_state<=TX_KG_SCAN;
        TX_KG_SCAN:if(wk_load_error) tx_state<=TX_ERROR;else if(work_key_ok) tx_state<=TX_KG_CUST_START;
        TX_KG_CUST_START:tx_state<=TX_KG_CUST_WAIT;
        TX_KG_CUST_WAIT:if(custody_error) tx_state<=TX_ERROR;else if(custody_done) tx_state<=TX_KG_HANDLE_WRITE;
        TX_KG_HANDLE_WRITE:if(sram_c0_ready) tx_state<=TX_KG_PK;
        TX_KG_PK:if(dma_done) tx_state<=TX_KG_PK_GAP;
        TX_KG_PK_GAP:tx_state<=TX_KG_HANDLE;
        TX_KG_HANDLE:if(dma_done) begin tx_record_idx<=0;tx_state<=TX_RECORD;end
        TX_DS_BEGIN:if(tx_command.context_len==0) begin s_start<=1;tx_state<=TX_DS_COMPUTE;end else tx_state<=TX_DS_CTX;
        TX_DS_CTX:if(dma_done) begin s_start<=1;tx_state<=TX_DS_COMPUTE;end
        TX_DS_COMPUTE:if(s_error) tx_state<=TX_ERROR;else if(s_done) tx_state<=TX_DS_OUT;
        TX_DS_OUT:if(dma_done) begin tx_record_idx<=0;tx_state<=TX_RECORD;end
        TX_DV_IN:if(dma_done) begin
          if(tx_command.context_len==0) begin v_start<=1;tx_state<=TX_DV_COMPUTE;end
          else tx_state<=TX_DV_CTX_GAP;
        end
        TX_DV_CTX_GAP:tx_state<=TX_DV_CTX;
        TX_DV_CTX:if(dma_done) begin v_start<=1;tx_state<=TX_DV_COMPUTE;end
        TX_DV_COMPUTE:if(v_error) tx_state<=TX_ERROR;else if(v_done) begin
          verify_result_q<=v_verify_valid;tx_record_idx<=0;tx_state<=TX_RECORD;
        end
        TX_ERROR: if(!fe_busy) tx_state<=TX_IDLE;
        default: tx_state<=TX_ERROR;
      endcase
    end
  end
  pqc_kem_encaps u_encaps (
    .clk(clk),.rst_n(rst_n),.start(enc_start),.clear(zeroize_req_any),.pset(tx_command.pset),
    .busy(e_busy),.done(e_done),.error(e_error),
    .mem_req(e_mem_req),.mem_we(e_mem_we),.mem_addr(e_mem_addr),.mem_wdata(e_mem_wdata),
    .mem_ready(sram_c0_ready && e_mem_req),.mem_rdata(sram_c0_rdata),
    .entropy_valid(entropy_valid),.entropy_health_ok(entropy_health_ok),.entropy_tag(entropy_domain_tag),
    .entropy_data(entropy_data),.entropy_ready(e_entropy_ready),
    .poly_start(e_poly_start),.poly_op(e_poly_op),.poly_src(e_poly_src),.poly_src2(e_poly_src2),.poly_dst(e_poly_dst),.poly_done(poly_done),
    .codec_start(e_codec_start),.codec_op(e_codec_op),.codec_bits(e_codec_bits),.codec_src(e_codec_src),.codec_dst(e_codec_dst),.codec_done(codec_done),
    .sampler_start(e_sampler_start),.sampler_mode(e_sampler_mode),.sampler_eta(e_sampler_eta),.sampler_dst(e_sampler_dst),
    .sampler_done(samp_done),.sampler_error(samp_op_error),.sampler_ready(samp_sqz_ready),.sampler_valid(e_sampler_valid),
    .hash_start(e_hash_start),.hash_function(e_hash_function),.hash_length(e_hash_length),
    .hash_in_valid(e_hash_in_valid),.hash_in_last(e_hash_in_last),.hash_in_data(e_hash_in_data),.hash_in_ready(e_hash_in_ready),
    .hash_out_valid(kec_out_valid),.hash_done(kec_done),.hash_out_data(kec_out_data),.hash_out_ready(e_hash_out_ready)
  );

  pqc_dsa_sign u_sign (
    .clk(clk),.rst_n(rst_n),.start(s_start),.clear(zeroize_req_any),.pset(tx_command.pset),
    .busy(s_busy),.done(s_done),.error(s_error),
    .mem_req(s_mem_req),.mem_we(s_mem_we),.mem_addr(s_mem_addr),.mem_wdata(s_mem_wdata),
    .mem_ready(sram_c0_ready && s_mem_req),.mem_rdata(sram_c0_rdata),
    .poly_start(s_poly_start),.poly_op(s_poly_op),.poly_src(s_poly_src),.poly_src2(s_poly_src2),.poly_dst(s_poly_dst),.poly_done(poly_done),
    .codec_start(s_codec_start),.codec_op(s_codec_op),.codec_bits(s_codec_bits),.codec_src(s_codec_src),.codec_src2(s_codec_src2),.codec_gamma2(s_codec_gamma2),.codec_dst(s_codec_dst),.codec_done(codec_done),
    .sampler_start(s_sampler_start),.sampler_mode(s_sampler_mode),.sampler_eta(s_sampler_eta),.sampler_dst(s_sampler_dst),
    .sampler_done(samp_done),.sampler_error(samp_op_error),.sampler_ready(samp_sqz_ready),.sampler_valid(s_sampler_valid),
    .hash_start(s_hash_start),.hash_function(s_hash_function),.hash_length(s_hash_length),
    .hash_in_valid(s_hash_in_valid),.hash_in_last(s_hash_in_last),.hash_in_data(s_hash_in_data),.hash_in_ready(s_hash_in_ready),
    .hash_out_valid(kec_out_valid),.hash_done(kec_done),.hash_out_data(kec_out_data),.hash_out_ready(s_hash_out_ready)
,
    .message_addr(tx_command.src0_addr[39:0]),.message_bytes(tx_command.src0_len),.context_bytes(tx_command.context_len[7:0]),
     .hedged(tx_command.entropy_policy!=0),
    .entropy_valid(entropy_valid),.entropy_health_ok(entropy_health_ok),.entropy_tag(entropy_domain_tag),
    .entropy_data(entropy_data),.entropy_ready(s_entropy_ready),
    .wk_read_req(s_wk_read_req),.wk_read_word(s_wk_read_word),.wk_read_valid(wk_read_valid),.wk_read_error(wk_read_error),.wk_read_data(wk_read_data),.message_dma_req(s_message_dma_req),.message_dma_addr(s_message_dma_addr),
    .message_dma_len(s_message_dma_len),.message_dma_done(dma_done),.message_dma_error(dma_error)
  );
  pqc_dsa_verify u_verify (
    .clk(clk),.rst_n(rst_n),.start(v_start),.clear(zeroize_req_any),.pset(tx_command.pset),
    .busy(v_busy),.done(v_done),.error(v_error),
    .mem_req(v_mem_req),.mem_we(v_mem_we),.mem_addr(v_mem_addr),.mem_wdata(v_mem_wdata),
    .mem_ready(sram_c0_ready && v_mem_req),.mem_rdata(sram_c0_rdata),
    .poly_start(v_poly_start),.poly_op(v_poly_op),.poly_src(v_poly_src),.poly_src2(v_poly_src2),.poly_dst(v_poly_dst),.poly_done(poly_done),
    .codec_start(v_codec_start),.codec_op(v_codec_op),.codec_bits(v_codec_bits),.codec_src(v_codec_src),.codec_src2(v_codec_src2),.codec_gamma2(v_codec_gamma2),.codec_dst(v_codec_dst),.codec_done(codec_done),
    .sampler_start(v_sampler_start),.sampler_mode(v_sampler_mode),.sampler_eta(v_sampler_eta),.sampler_dst(v_sampler_dst),
    .sampler_done(samp_done),.sampler_error(samp_op_error),.sampler_ready(samp_sqz_ready),.sampler_valid(v_sampler_valid),
    .hash_start(v_hash_start),.hash_function(v_hash_function),.hash_length(v_hash_length),
    .hash_in_valid(v_hash_in_valid),.hash_in_last(v_hash_in_last),.hash_in_data(v_hash_in_data),.hash_in_ready(v_hash_in_ready),
    .hash_out_valid(kec_out_valid),.hash_done(kec_done),.hash_out_data(kec_out_data),.hash_out_ready(v_hash_out_ready)
,
    .message_addr(tx_command.src0_addr[39:0]),.message_bytes(tx_command.src0_len),.context_bytes(tx_command.context_len[7:0]),
    .verify_valid(v_verify_valid),.message_dma_req(v_message_dma_req),.message_dma_addr(v_message_dma_addr),
    .message_dma_len(v_message_dma_len),.message_dma_done(dma_done),.message_dma_error(dma_error)
  );
  pqc_kem_keygen u_keygen (
    .clk(clk),.rst_n(rst_n),.start(gen_start && !algo_is_dsa_keygen),.clear(zeroize_req_any),.pset(tx_command.pset),
    .busy(g_busy),.done(g_done),.error(g_error),
    .mem_req(g_mem_req),.mem_we(g_mem_we),.mem_addr(g_mem_addr),.mem_wdata(g_mem_wdata),
    .mem_ready(sram_c0_ready && g_mem_req),.mem_rdata(sram_c0_rdata),
    .entropy_valid(entropy_valid),.entropy_health_ok(entropy_health_ok),.entropy_tag(entropy_domain_tag),
    .entropy_data(entropy_data),.entropy_ready(g_entropy_ready),
    .poly_start(g_poly_start),.poly_op(g_poly_op),.poly_src(g_poly_src),.poly_src2(g_poly_src2),.poly_dst(g_poly_dst),.poly_done(poly_done),
    .codec_start(g_codec_start),.codec_op(g_codec_op),.codec_bits(g_codec_bits),.codec_src(g_codec_src),.codec_dst(g_codec_dst),.codec_done(codec_done),
    .sampler_start(g_sampler_start),.sampler_mode(g_sampler_mode),.sampler_eta(g_sampler_eta),.sampler_dst(g_sampler_dst),
    .sampler_done(samp_done),.sampler_error(samp_op_error),.sampler_ready(samp_sqz_ready),.sampler_valid(g_sampler_valid),
    .hash_start(g_hash_start),.hash_function(g_hash_function),.hash_length(g_hash_length),
    .hash_in_valid(g_hash_in_valid),.hash_in_last(g_hash_in_last),.hash_in_data(g_hash_in_data),.hash_in_ready(g_hash_in_ready),
    .hash_out_valid(kec_out_valid),.hash_done(kec_done),.hash_out_data(kec_out_data),.hash_out_ready(g_hash_out_ready),
    .generated_valid(g_gen_valid),.generated_last(g_gen_last),.generated_data(g_gen_data),.generated_ready(gen_ready)
  );
  pqc_dsa_keygen u_dsa_keygen (
    .clk(clk),.rst_n(rst_n),.start(gen_start && algo_is_dsa_keygen),.clear(zeroize_req_any),.pset(tx_command.pset),
    .busy(j_busy),.done(j_done),.error(j_error),
    .mem_req(j_mem_req),.mem_we(j_mem_we),.mem_addr(j_mem_addr),.mem_wdata(j_mem_wdata),
    .mem_ready(sram_c0_ready && j_mem_req),.mem_rdata(sram_c0_rdata),
    .entropy_valid(entropy_valid),.entropy_health_ok(entropy_health_ok),.entropy_tag(entropy_domain_tag),
    .entropy_data(entropy_data),.entropy_ready(j_entropy_ready),
    .poly_start(j_poly_start),.poly_op(j_poly_op),.poly_src(j_poly_src),.poly_src2(j_poly_src2),.poly_dst(j_poly_dst),.poly_done(poly_done),
    .codec_start(j_codec_start),.codec_op(j_codec_op),.codec_bits(j_codec_bits),.codec_src(j_codec_src),.codec_dst(j_codec_dst),.codec_done(codec_done),
    .sampler_start(j_sampler_start),.sampler_mode(j_sampler_mode),.sampler_eta(j_sampler_eta),.sampler_dst(j_sampler_dst),
    .sampler_done(samp_done),.sampler_error(samp_op_error),.sampler_ready(samp_sqz_ready),.sampler_valid(j_sampler_valid),
    .hash_start(j_hash_start),.hash_function(j_hash_function),.hash_length(j_hash_length),
    .hash_in_valid(j_hash_in_valid),.hash_in_last(j_hash_in_last),.hash_in_data(j_hash_in_data),.hash_in_ready(j_hash_in_ready),
    .hash_out_valid(kec_out_valid),.hash_done(kec_done),.hash_out_data(kec_out_data),.hash_out_ready(j_hash_out_ready),
    .generated_valid(j_gen_valid),.generated_last(j_gen_last),.generated_data(j_gen_data),.generated_ready(gen_ready)
  );
  // Decaps program: reads dk from the work-key RAM, computes the shared secret
  // and writes it to the 0x1600 region for the TX_DC_SS DMA. Shares engines and
  // the SRAM c0 port with the Encaps program; only one command runs at a time.
  pqc_kem_decaps u_decaps (
    .clk(clk),.rst_n(rst_n),.start(dec_start),.clear(zeroize_req_any),
    .pset(tx_command.pset),.ct_bytes(tx_command.src0_len[15:0]),
    .busy(d_busy),.done(d_done),.error(d_error),
    .mem_req(d_mem_req),.mem_we(d_mem_we),.mem_addr(d_mem_addr),.mem_wdata(d_mem_wdata),
    .mem_ready(sram_c0_ready && d_mem_req),.mem_rdata(sram_c0_rdata),
    .wk_read_req(d_wk_read_req),.wk_read_word(d_wk_read_word),
    .wk_read_valid(wk_read_valid),.wk_read_error(wk_read_error),.wk_read_data(wk_read_data),
    .entropy_valid(entropy_valid),.entropy_health_ok(entropy_health_ok),
    .entropy_tag(entropy_domain_tag),.entropy_data(entropy_data),.entropy_ready(d_entropy_ready),
    .poly_start(d_poly_start),.poly_op(d_poly_op),.poly_src(d_poly_src),.poly_src2(d_poly_src2),.poly_dst(d_poly_dst),.poly_done(poly_done),
    .codec_start(d_codec_start),.codec_op(d_codec_op),.codec_bits(d_codec_bits),.codec_src(d_codec_src),.codec_dst(d_codec_dst),.codec_done(codec_done),
    .sampler_start(d_sampler_start),.sampler_mode(d_sampler_mode),.sampler_eta(d_sampler_eta),.sampler_dst(d_sampler_dst),
    .sampler_done(samp_done),.sampler_error(samp_op_error),.sampler_ready(samp_sqz_ready),.sampler_valid(d_sampler_valid),
    .hash_start(d_hash_start),.hash_function(d_hash_function),.hash_length(d_hash_length),
    .hash_in_valid(d_hash_in_valid),.hash_in_last(d_hash_in_last),.hash_in_data(d_hash_in_data),.hash_in_ready(d_hash_in_ready),
    .hash_out_valid(kec_out_valid),.hash_done(kec_done),.hash_out_data(kec_out_data),.hash_out_ready(d_hash_out_ready)
  );
  // Both programs share the single Keccak absorb-ready; the mux on in_valid
  // selects which program feeds the stream.
  assign d_hash_in_ready = e_hash_in_ready;

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
    hwif_in.RESULT.verify_valid.next    = verify_result_q;
    hwif_in.RESULT.verify_done.next     = verify_done_q;
    hwif_in.RESULT.completion_tag.next  = fe_completion_tag[31:2];
    hwif_in.ERROR_CODE.error_code.next  = fe_comp_error;
    hwif_in.ERROR_CODE.last_cmd_failed.next = (fe_comp_status != ST_SUCCESS);
    hwif_in.COMPLETION_STATUS.status.next     = fe_comp_status;
    hwif_in.COMPLETION_STATUS.verify_valid.next = verify_result_q;
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
    hwif_in.CAPABILITY1.abi_minor.next       = 6'h01;

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
    .alg_verify_valid   (verify_result_q),
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
  assign km_ready=wk_load_ready && !algo_is_keygen;
  assign km_done=wk_load_done && !algo_is_keygen;
  assign km_error=wk_load_error && !algo_is_keygen;
  pqc_work_key_ram u_work_key_ram (
    .clk(clk), .rst_n(rst_n),
    .load_begin(tx_state==TX_KG_BEGIN || (km_begin && fe_idle && !fault_locked)), .load_begin_ready(work_key_begin_ready),
    .load_handle(algo_is_keygen ? gen_handle : km_handle), .load_algo(algo_is_keygen ? (algo_is_dsa_keygen ? 4'd2 : 4'd1) : km_algo), .load_pset(algo_is_keygen ? tx_command.pset : km_pset),
    .load_usage(algo_is_keygen ? (algo_is_dsa_keygen ? 8'h02 : 8'h04) : km_usage), .load_bytes(algo_is_keygen ? gen_bytes : km_bytes),
    .load_valid(algo_is_keygen ? gen_valid : km_valid), .load_ready(wk_load_ready), .load_data(algo_is_keygen ? gen_data : km_data), .load_last(algo_is_keygen ? gen_last : km_last),
    .load_done(wk_load_done), .load_error(wk_load_error),
    .check_handle(algo_is_keygen ? gen_handle : command_key_handle),
    .check_algo(pqc_pkg::is_dsa(param_set_e'(alg_pset)) ? 4'd2 : 4'd1),
    .check_pset({1'b0,alg_pset}), .check_usage(algo_is_keygen ? (algo_is_dsa_keygen ? 8'h02 : 8'h04) : (8'd1 << alg_op)), .check_ok(work_key_ok),
    // The private read port is reserved for the algorithm sequencer. It is not
    // connected to either public DMA or CSR. Full algorithm scheduling remains pending.
    .read_req(algo_is_keygen ? custody_read_req : algo_is_sign ? s_wk_read_req : d_wk_read_req), .read_word(algo_is_keygen ? custody_read_word : algo_is_sign ? s_wk_read_word : d_wk_read_word),
    .read_valid(wk_read_valid), .read_error(wk_read_error), .read_data(wk_read_data),
    .retire(fe_done_pulse || tx_state==TX_KG_PREP), .zeroize_req(zeroize_req_any), .zeroize_done(work_key_zero_done), .integrity_error(work_key_integrity_error)
  );


  pqc_key_custody u_custody (
    .clk(clk),.rst_n(rst_n),.clear(zeroize_req_any || km_revoke),.start(tx_state==TX_KG_CUST_START),
    .transaction(gen_transaction),.epoch(gen_epoch),.handle(gen_handle),.owner(gen_owner),.domain(gen_domain),
    .algo(algo_is_dsa_keygen ? 4'd2 : 4'd1),.pset(tx_command.pset),.bytes(gen_bytes),.busy(custody_busy),.done(custody_done),.error(custody_error),
    .header_valid(km_custody_header_valid),.header_ready(km_custody_header_ready),
    .out_transaction(km_custody_transaction),.out_epoch(km_custody_epoch),.out_handle(km_custody_handle),
    .out_owner(km_custody_owner),.out_domain(km_custody_domain),.out_algo(km_custody_algo),.out_pset(km_custody_pset),.out_bytes(km_custody_bytes),
    .word_valid(km_custody_valid),.word_ready(km_custody_ready),.word_data(km_custody_data),.word_last(km_custody_last),
    .ack_valid(km_custody_ack_valid),.ack_ready(km_custody_ack_ready),
    .ack_transaction(km_custody_ack_transaction),.ack_epoch(km_custody_ack_epoch),.ack_handle(km_custody_ack_handle),
    .ack_owner(km_custody_ack_owner),.ack_domain(km_custody_ack_domain),.ack_bytes(km_custody_ack_bytes),.ack_success(km_custody_ack_success),
    .read_req(custody_read_req),.read_word(custody_read_word),.read_valid(wk_read_valid),.read_error(wk_read_error),.read_data(wk_read_data)
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
    .start        (algo_is_sign ? s_hash_start : algo_is_verify ? v_hash_start : algo_is_dsa_keygen ? j_hash_start : algo_is_keygen ? g_hash_start : algo_is_decaps ? d_hash_start : e_hash_start),
    .function_id  (algo_is_sign ? s_hash_function : algo_is_verify ? v_hash_function : algo_is_dsa_keygen ? j_hash_function : algo_is_keygen ? g_hash_function : algo_is_decaps ? d_hash_function : e_hash_function),
    .ctx_sel      (1'b1),
    .out_len      (algo_is_sign ? s_hash_length : algo_is_verify ? v_hash_length : algo_is_dsa_keygen ? j_hash_length : algo_is_keygen ? g_hash_length : algo_is_decaps ? d_hash_length : e_hash_length),
    .in_valid     (algo_is_sign ? s_hash_in_valid : algo_is_verify ? v_hash_in_valid : algo_is_dsa_keygen ? j_hash_in_valid : algo_is_keygen ? g_hash_in_valid : algo_is_decaps ? d_hash_in_valid : e_hash_in_valid),
    .in_ready     (e_hash_in_ready),
    .in_data      (algo_is_sign ? s_hash_in_data : algo_is_verify ? v_hash_in_data : algo_is_dsa_keygen ? j_hash_in_data : algo_is_keygen ? g_hash_in_data : algo_is_decaps ? d_hash_in_data : e_hash_in_data),
    .in_last      (algo_is_sign ? s_hash_in_last : algo_is_verify ? v_hash_in_last : algo_is_dsa_keygen ? j_hash_in_last : algo_is_keygen ? g_hash_in_last : algo_is_decaps ? d_hash_in_last : e_hash_in_last),
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
  assign kec_out_ready = algo_is_sign ? s_hash_out_ready : algo_is_verify ? v_hash_out_ready : algo_is_dsa_keygen ? j_hash_out_ready : algo_is_keygen ? g_hash_out_ready : algo_is_decaps ? d_hash_out_ready : e_hash_out_ready;

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

  // The Decaps program shares the compute-port and engines with Encaps; both
  // run in disjoint TX states, so a per-command mux selects the active program.
  assign poly_mem_ready = sram_c0_ready && !(algo_is_sign ? s_mem_req : algo_is_verify ? v_mem_req : algo_is_dsa_keygen ? j_mem_req : algo_is_keygen ? g_mem_req : algo_is_decaps ? d_mem_req : e_mem_req) &&
                         tx_state!=TX_RECORD && tx_state!=TX_DC_RECORD && tx_state!=TX_KG_HANDLE_WRITE;
  assign poly_mem_rdata = sram_c0_rdata;

  // Primitive arbitration: only one sequencer drives the shared polynomial
  // engine at a time. KEM owns it while kem_busy, otherwise the DSA sequencer.
  always_comb begin
    if (tx_state==TX_COMPUTE) begin
      poly_start=e_poly_start;poly_prim=e_poly_op;poly_domain=0;
      poly_src_page=e_poly_src;poly_src2_page=e_poly_src2;poly_dst_page=e_poly_dst;
    end else if (tx_state==TX_DC_COMPUTE) begin
      poly_start=d_poly_start;poly_prim=d_poly_op;poly_domain=0;
      poly_src_page=d_poly_src;poly_src2_page=d_poly_src2;poly_dst_page=d_poly_dst;
    end else if (tx_state==TX_KG_COMPUTE) begin
      poly_start=algo_is_dsa_keygen ? j_poly_start : g_poly_start;poly_prim=algo_is_dsa_keygen ? j_poly_op : g_poly_op;poly_domain=algo_is_dsa_keygen;
      poly_src_page=algo_is_dsa_keygen ? j_poly_src : g_poly_src;poly_src2_page=algo_is_dsa_keygen ? j_poly_src2 : g_poly_src2;poly_dst_page=algo_is_dsa_keygen ? j_poly_dst : g_poly_dst;
    end else if (tx_state==TX_DS_COMPUTE) begin
      poly_start=s_poly_start;poly_prim=s_poly_op;poly_domain=1;
      poly_src_page=s_poly_src;poly_src2_page=s_poly_src2;poly_dst_page=s_poly_dst;
    end else if (tx_state==TX_DV_COMPUTE) begin
      poly_start=v_poly_start;poly_prim=v_poly_op;poly_domain=1;
      poly_src_page=v_poly_src;poly_src2_page=v_poly_src2;poly_dst_page=v_poly_dst;
    end else if (kem_prim_start && !dsa_prim_start) begin
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
    .start        (algo_is_sign ? s_codec_start : algo_is_verify ? v_codec_start : algo_is_dsa_keygen ? j_codec_start : algo_is_keygen ? g_codec_start : algo_is_decaps ? d_codec_start : e_codec_start),
    .op           (algo_is_sign ? s_codec_op : algo_is_verify ? v_codec_op : algo_is_dsa_keygen ? j_codec_op : algo_is_keygen ? g_codec_op : algo_is_decaps ? d_codec_op : e_codec_op),
    .domain       (algo_is_sign || algo_is_verify || algo_is_dsa_keygen),
    .d_comp       (algo_is_sign ? s_codec_bits : algo_is_verify ? v_codec_bits : algo_is_dsa_keygen ? j_codec_bits : algo_is_keygen ? g_codec_bits : algo_is_decaps ? d_codec_bits : e_codec_bits),
    .gamma2_sel   (algo_is_sign ? s_codec_gamma2 : algo_is_verify ? v_codec_gamma2 : 2'h1),
    .src_page     (algo_is_sign ? s_codec_src : algo_is_verify ? v_codec_src : algo_is_dsa_keygen ? j_codec_src : algo_is_keygen ? g_codec_src : algo_is_decaps ? d_codec_src : e_codec_src),
    .src2_page    (algo_is_sign ? s_codec_src2 : algo_is_verify ? v_codec_src2 : 8'h1),
    .dst_page     (algo_is_sign ? s_codec_dst : algo_is_verify ? v_codec_dst : algo_is_dsa_keygen ? j_codec_dst : algo_is_keygen ? g_codec_dst : algo_is_decaps ? d_codec_dst : e_codec_dst),
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
    .sqz_valid    (algo_is_sign ? s_sampler_valid : algo_is_verify ? v_sampler_valid : algo_is_dsa_keygen ? j_sampler_valid : algo_is_keygen ? g_sampler_valid : algo_is_decaps ? d_sampler_valid : e_sampler_valid),
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
  // as used by the reference model). Decaps shares the sampler through the
  // per-command mux.
  assign samp_start    = algo_is_sign ? s_sampler_start : algo_is_verify ? v_sampler_start : algo_is_dsa_keygen ? j_sampler_start : algo_is_keygen ? g_sampler_start : algo_is_decaps ? d_sampler_start : e_sampler_start;
  assign samp_mode     = algo_is_sign ? s_sampler_mode : algo_is_verify ? v_sampler_mode : algo_is_dsa_keygen ? j_sampler_mode : algo_is_keygen ? g_sampler_mode : algo_is_decaps ? d_sampler_mode : e_sampler_mode;
  assign samp_domain   = algo_is_sign || algo_is_verify || algo_is_dsa_keygen;
  assign samp_dst_page = algo_is_sign ? s_sampler_dst : algo_is_verify ? v_sampler_dst : algo_is_dsa_keygen ? j_sampler_dst : algo_is_keygen ? g_sampler_dst : algo_is_decaps ? d_sampler_dst : e_sampler_dst;
  assign samp_eta      = algo_is_sign ? s_sampler_eta : algo_is_verify ? v_sampler_eta : algo_is_dsa_keygen ? j_sampler_eta : algo_is_keygen ? g_sampler_eta : algo_is_decaps ? d_sampler_eta : e_sampler_eta;
  assign samp_gamma1   = alg_pset==4 ? 5'd17 : 5'd19;

  // ===========================================================================
  // Sequencers
  // ===========================================================================
  pqc_kem_seq u_kem_seq (
    .clk          (clk),
    .rst_n        (rst_n),
    .start        (1'b0),
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
    .start           (1'b0),
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

  assign alg_busy    = tx_state!=TX_IDLE && tx_state!=TX_DC_DONE;
  assign alg_done    = (tx_state==TX_DONE) || (tx_state==TX_DC_DONE);
  // A DSA signature rejected by the normative checks is a public API result
  // (ST_VERIFY_INVALID), not an operation error; only retry exhaustion is an
  // internal error.
  assign alg_op_error= (tx_state==TX_ERROR) | e_error | d_error | g_error | j_error | v_error | s_error | custody_error | kem_op_error | dsa_op_error | dsa_retry_exhausted | samp_op_error | sram_access_denied;

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
    .xfer_req     (tx_dma_req),
    .xfer_we      (tx_dma_we),
    .xfer_addr    (tx_dma_addr),
    .xfer_len     (tx_dma_len),
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

  // SRAM port sharing: compute0 = program data path / poly, compute1 =
  // codec/sampler, DMA = dma. The Decaps program drives c0 with its own
  // request/address/write-data muxed with the Encaps program by the command.
  logic d_mux_req;
  assign d_mux_req = algo_is_decaps ? d_mem_req : 1'b0;
  assign sram_c0_req   = (tx_state==TX_RECORD) | (tx_state==TX_DC_RECORD) |
                         e_mem_req | d_mux_req | g_mem_req | j_mem_req | v_mem_req | s_mem_req | poly_mem_req | (tx_state==TX_KG_HANDLE_WRITE);
  assign sram_c0_we    = (tx_state==TX_RECORD || tx_state==TX_DC_RECORD) ? 1'b1 :
                         tx_state==TX_KG_HANDLE_WRITE ? 1'b1 : s_mem_req ? s_mem_we : v_mem_req ? v_mem_we : j_mem_req ? j_mem_we : g_mem_req ? g_mem_we : d_mux_req ? d_mem_we : e_mem_req ? e_mem_we : poly_mem_we;
  assign sram_c0_addr  = (tx_state==TX_RECORD) ? 16'd5888+16'(tx_record_idx) :
                         (tx_state==TX_DC_RECORD) ? 16'd5888+16'(tx_record_idx) :
                         tx_state==TX_KG_HANDLE_WRITE ? 16'd5632 : s_mem_req ? s_mem_addr : v_mem_req ? v_mem_addr : j_mem_req ? j_mem_addr : g_mem_req ? g_mem_addr : d_mux_req ? d_mem_addr : e_mem_req ? e_mem_addr : poly_mem_addr;
  assign sram_c0_wdata = (tx_state==TX_RECORD || tx_state==TX_DC_RECORD) ? tx_record_data :
                         tx_state==TX_KG_HANDLE_WRITE ? gen_handle : s_mem_req ? s_mem_wdata : v_mem_req ? v_mem_wdata : j_mem_req ? j_mem_wdata : g_mem_req ? g_mem_wdata : d_mux_req ? d_mem_wdata : e_mem_req ? e_mem_wdata : poly_mem_wdata;

  assign sram_c1_req   = codec_mem_req | samp_mem_req;
  assign sram_c1_we    = c1_select_codec ? codec_mem_we : samp_mem_we;
  assign sram_c1_addr  = c1_select_codec ? codec_mem_addr : samp_mem_addr;
  assign sram_c1_wdata = c1_select_codec ? codec_mem_wdata : samp_mem_wdata;

  assign sram_d_req    = dma_buf_req;
  assign sram_d_we     = dma_buf_we;
  assign sram_d_addr   = tx_base + dma_buf_addr;
  assign sram_d_wdata  = dma_buf_wdata;

  // ===========================================================================
  // Entropy and interrupt aggregation
  // ===========================================================================
  assign entropy_ready = algo_is_sign ? s_entropy_ready : algo_is_verify ? v_entropy_ready : algo_is_dsa_keygen ? j_entropy_ready : algo_is_keygen ? g_entropy_ready : algo_is_decaps ? d_entropy_ready : e_entropy_ready;

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
