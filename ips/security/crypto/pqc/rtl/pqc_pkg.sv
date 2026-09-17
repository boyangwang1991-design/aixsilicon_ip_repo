// ============================================================================
// pqc_pkg - shared types, parameters and constants for the PQC accelerator
// ============================================================================
`ifndef PQC_PKG_SV
`define PQC_PKG_SV

package pqc_pkg;

  // --------------------------------------------------------------------------
  // Synthesis-time parameters (see docs/lrs/01_configuration.md)
  // --------------------------------------------------------------------------
  parameter int unsigned NTT_LANES_DEFAULT            = 2;
  parameter int unsigned KECCAK_ROUNDS_PER_CYCLE_DEF  = 2;
  parameter int unsigned LOCAL_SRAM_KIB_DEFAULT       = 64;
  parameter int unsigned DMA_DATA_WIDTH_DEFAULT       = 128;
  parameter int unsigned KEY_SLOT_NUM_DEFAULT         = 8;
  parameter int unsigned SCA_LEVEL_DEFAULT            = 1;
  parameter int unsigned ENABLE_ALGO_MASK_DEFAULT     = 6'h3F;

  // --------------------------------------------------------------------------
  // Algorithm parameter sets
  // --------------------------------------------------------------------------
  typedef enum logic [3:0] {
    PS_ML_KEM_512  = 4'd1,
    PS_ML_KEM_768  = 4'd2,
    PS_ML_KEM_1024 = 4'd3,
    PS_ML_DSA_44   = 4'd4,
    PS_ML_DSA_65   = 4'd5,
    PS_ML_DSA_87   = 4'd6
  } param_set_e;

  typedef enum logic [0:0] {
    FAM_KEM = 1'b0,
    FAM_DSA = 1'b1
  } family_e;

  // Polynomial length is fixed at 256 coefficients for both families.
  parameter int unsigned POLY_N     = 256;
  parameter int unsigned POLY_N_LOG = 8;

  // KEM domain
  parameter logic [15:0] KEM_Q = 16'd3329;

  // DSA domain
  parameter logic [22:0] DSA_Q = 23'd8380417;

  // --------------------------------------------------------------------------
  // Coefficient representation tags (SRAM page metadata)
  // --------------------------------------------------------------------------
  typedef enum logic [1:0] {
    REP_COEFF_STD  = 2'd0,
    REP_COEFF_LAZY = 2'd1,
    REP_NTT_MONT   = 2'd2
  } representation_e;

  // --------------------------------------------------------------------------
  // Opcodes
  // --------------------------------------------------------------------------
  typedef enum logic [7:0] {
    OP_KEM_KEYGEN  = 8'h00,
    OP_KEM_ENCAPS  = 8'h01,
    OP_KEM_DECAPS  = 8'h02,
    OP_DSA_KEYGEN  = 8'h10,
    OP_DSA_SIGN    = 8'h11,
    OP_DSA_VERIFY  = 8'h12,
    OP_ZEROIZE     = 8'h20,
    OP_SELF_TEST   = 8'h21
  } opcode_e;

  // Decoded public descriptor. Consumers may use it only with command_valid;
  // full-width addresses/lengths are retained until validation has succeeded.
  typedef struct packed {
    logic [7:0] opcode;
    logic [3:0] pset;
    logic [1:0] operation;
    logic is_dsa, needs_private_key;
    logic [31:0] command_id, key_handle;
    logic [63:0] src0_addr, src0_len, src1_addr, src1_len;
    logic [63:0] context_addr;
    logic [31:0] context_len, entropy_policy;
    logic [63:0] dst0_addr, dst0_capacity, dst1_addr, dst1_capacity;
    logic [63:0] completion_addr;
    logic [31:0] timeout_hint;
    logic [15:0] output0_bytes, output1_bytes;
  } pqc_command_t;

  // --------------------------------------------------------------------------
  // Completion / error status
  // --------------------------------------------------------------------------
  typedef enum logic [2:0] {
    ST_SUCCESS       = 3'd0,
    ST_VERIFY_INVALID= 3'd1,
    ST_CONFIG_ERROR  = 3'd2,
    ST_DMA_ERROR     = 3'd3,
    ST_RNG_ERROR     = 3'd4,
    ST_FATAL         = 3'd5
  } comp_status_e;

  typedef enum logic [5:0] {
    ERR_NONE          = 6'h00,
    ERR_BAD_OPCODE    = 6'h01,
    ERR_BAD_PARAMSET  = 6'h02,
    ERR_BAD_ABI       = 6'h03,
    ERR_BAD_ALIGN     = 6'h04,
    ERR_BAD_LENGTH    = 6'h05,
    ERR_BAD_CAPACITY  = 6'h06,
    ERR_BAD_KEY       = 6'h07,
    ERR_PERMISSION    = 6'h08,
    ERR_DMA           = 6'h10,
    ERR_RNG           = 6'h11,
    ERR_SELFTEST      = 6'h12,
    ERR_INTERNAL      = 6'h20,
    ERR_RETRY_EXHAUST = 6'h21,
    ERR_ECC_UE        = 6'h22
  } error_code_e;

  // --------------------------------------------------------------------------
  // Top-level FSM states (sparse one-hot with redundant parity)
  // --------------------------------------------------------------------------
  typedef enum logic [9:0] {
    S_DISABLED = 10'b0000000001,
    S_SELFTEST = 10'b0000000010,
    S_IDLE     = 10'b0000000100,
    S_VALIDATE = 10'b0000001000,
    S_FETCH    = 10'b0000010000,
    S_EXECUTE  = 10'b0000100000,
    S_COMMIT   = 10'b0001000000,
    S_COMPLETE = 10'b0010000000,
    S_ZEROIZE  = 10'b0100000000,
    S_LOCKED   = 10'b1000000000
  } top_state_e;

  // --------------------------------------------------------------------------
  // Primitive dispatch modes
  // --------------------------------------------------------------------------
  typedef enum logic [3:0] {
    PRIM_NOP        = 4'h0,
    PRIM_NTT_FWD    = 4'h1,
    PRIM_NTT_INV    = 4'h2,
    PRIM_PW_MAC     = 4'h3,
    PRIM_ADD        = 4'h4,
    PRIM_SUB        = 4'h5
  } poly_prim_e;

  typedef enum logic [2:0] {
    SAMP_CBD_KEM      = 3'd0,
    SAMP_REJ_KEM      = 3'd1,
    SAMP_EXPAND_A     = 3'd2,
    SAMP_EXPAND_S     = 3'd3,
    SAMP_EXPAND_MASK  = 3'd4,
    SAMP_IN_BALL      = 3'd5
  } samp_mode_e;

  typedef enum logic [2:0] {
    KEC_SHA3_256 = 3'd0,
    KEC_SHA3_512 = 3'd1,
    KEC_SHAKE128 = 3'd2,
    KEC_SHAKE256 = 3'd3
  } keccak_func_e;

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------
  function automatic logic is_kem(param_set_e ps);
    return (ps == PS_ML_KEM_512) || (ps == PS_ML_KEM_768) || (ps == PS_ML_KEM_1024);
  endfunction

  function automatic logic is_dsa(param_set_e ps);
    return (ps == PS_ML_DSA_44) || (ps == PS_ML_DSA_65) || (ps == PS_ML_DSA_87);
  endfunction

  function automatic logic [1:0] kem_rank(param_set_e ps);
    case (ps)
      PS_ML_KEM_512:  return 2'd0; // k=2 -> stored as index, rank width 2
      PS_ML_KEM_768:  return 2'd1;
      PS_ML_KEM_1024: return 2'd2;
      default:        return 2'd0;
    endcase
  endfunction

  function automatic logic [15:0] bitrev8(logic [7:0] v);
    return {8'h00,v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7]};
  endfunction

  function automatic logic [15:0] kem_ciphertext_bytes(param_set_e ps);
    case (ps)
      PS_ML_KEM_512: return 16'd768;
      PS_ML_KEM_768: return 16'd1088;
      PS_ML_KEM_1024: return 16'd1568;
      default: return 16'd0;
    endcase
  endfunction

  // ML-DSA signature length per FIPS 204 (bytes, excludes the 1-byte Table-2
  // context selector). Selected combinationally so no runtime multiply/divide
  // is required in the sequencer.
  function automatic logic [15:0] dsa_sig_bytes(param_set_e ps);
    case (ps)
      PS_ML_DSA_44: return 16'd2420;
      PS_ML_DSA_65: return 16'd3309;
      PS_ML_DSA_87: return 16'd4627;
      default:      return 16'd3309;
    endcase
  endfunction

  // Full-length challenge digest c~ length per FIPS 204: lambda/4 bytes, i.e.
  // 32 / 48 / 64 for ML-DSA-44 / -65 / -87.
  function automatic logic [6:0] dsa_ct_bytes(param_set_e ps);
    case (ps)
      PS_ML_DSA_44: return 7'd32;
      PS_ML_DSA_65: return 7'd48;
      PS_ML_DSA_87: return 7'd64;
      default:      return 7'd48;
    endcase
  endfunction

  // Fixed eight-bank coefficient mapping (LLD.DERIVED.PQC.BANKHASH).
  // The mapping is independent of NTT stage; all partner bit flips change bank.
  function automatic logic [2:0] bank_hash(logic [7:0] coeff_idx);
    return {coeff_idx[2]^coeff_idx[5],
            coeff_idx[1]^coeff_idx[4]^coeff_idx[7],
            coeff_idx[0]^coeff_idx[3]^coeff_idx[6]};
  endfunction

endpackage

`endif // PQC_PKG_SV
