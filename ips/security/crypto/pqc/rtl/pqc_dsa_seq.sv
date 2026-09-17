// ============================================================================
// pqc_dsa_seq - ML-DSA KeyGen / Sign / Verify sequencing with the attempt loop
//
// Implements (LLD.FSM.PQC.DSASEQ.ATTEMPT, LLD.BUF.PQC.DSASEQ.STAGE,
//             LLD.SAFE.PQC.VERIFY_DUAL):
//   * scalar rejection control skeleton; reject conditions accumulate into
//     reject_accum and branch once after the mandatory operations of the
//     attempt complete
//   * candidate signatures are streamed through an external invisible buffer
//     and committed atomically only after every check passes; a rejected
//     attempt emits nothing (commit_valid never asserts)
//   * reaching the attempt limit returns a generic internal retry error and
//     clears all candidate values
//   * Verify scans the FULL challenge digest byte-by-byte and the final result
//     is the conjunction of (norm_z_ok & norm_r0_ok & hint_weight_ok) and the
//     digest equality. A failed numeric check can never be reported valid.
//   * the digest equality is evaluated by two independently coded monitors
//     (AND-of-equal / OR-of-differ) whose results must agree. A fault on one
//     monitor therefore turns the result invalid (fail-closed), not valid.
//
// Complete Sign/Verify primitive dependencies and independent ct0 checks are
// still pending. These control checks are not an end-to-end algorithm KAT.
//
// The challenge digest store (max 64 bytes) is a small register file owned by
// this module; the recomputed digest arrives from the Keccak XOF stream and the
// reference digest is staged from the input buffer, both as byte write ports.
// ============================================================================
`ifndef PQC_DSA_SEQ_SV
`define PQC_DSA_SEQ_SV

module pqc_dsa_seq #(
  parameter int unsigned MAX_ATTEMPTS  = 256,
  parameter int unsigned MAX_SIG_BYTES = 4627,
  parameter int unsigned CT_MAX_BYTES  = 64
) (
  input  logic         clk,
  input  logic         rst_n,

  // dispatch from the command frontend
  input  logic         start,
  input  logic [1:0]   op,            // 0=keygen 1=sign 2=verify
  input  logic [2:0]   pset,          // param_set_e encoding
  output logic         busy,
  output logic         done,
  output logic         verify_valid,
  output logic         retry_exhausted,
  output logic         op_error,

  // primitive dispatch
  output logic         prim_start,
  output logic [3:0]   prim_op,
  output logic         prim_domain,
  input  logic         prim_busy,
  input  logic         prim_done,

  // working-memory page operands for the polynomial primitive
  output logic [7:0]   poly_src_page,
  output logic [7:0]   poly_src2_page,
  output logic [7:0]   poly_dst_page,

  // rejection inputs from numeric checks
  input  logic         norm_z_ok,
  input  logic         norm_r0_ok,
  input  logic         hint_weight_ok,

  // staging buffer (external invisible candidate signature storage)
  output logic         stage_req,
  output logic         stage_we,
  output logic [15:0]  stage_addr,
  output logic [7:0]   stage_wdata,
  input  logic [7:0]   stage_rdata,
  input  logic         stage_ready,
  output logic         commit_valid,
  output logic [15:0]  sig_len,

  // verify challenge digest byte write ports
  input  logic         ct_calc_we,    // recomputed digest byte (Keccak XOF output)
  input  logic [7:0]   ct_calc_byte,
  input  logic         ct_ref_we,     // reference digest byte (input buffer staging)
  input  logic [7:0]   ct_ref_byte,
  input  logic         ct_clear,      // rewind both digest write pointers

  input  logic         zeroize_req
);

  import pqc_pkg::*;
  logic [1:0] op_q;
  logic [2:0] pset_q;
  logic prim_pending;

  typedef enum logic [4:0] {
    A_IDLE, A_INIT, A_EXPAND_Y, A_NTT_W, A_CHALLENGE,
    A_NORM_Z, A_NORM_R0, A_HINT, A_STAGE, A_COMMIT, A_DONE,
    A_REJECT, A_EXHAUST, A_VCHK, A_VCOMP, A_VRES, A_ZERO
  } astate_e;
  astate_e astate;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      op_q <= '0;
      pset_q <= '0;
      prim_pending <= 1'b0;
    end else if (zeroize_req) begin
      op_q <= '0;
      pset_q <= '0;
      prim_pending <= 1'b0;
    end else begin
      if (start && astate == A_IDLE) begin
        op_q <= op;
        pset_q <= pset;
      end
      if (prim_start) prim_pending <= 1'b1;
      if (prim_pending && prim_done) prim_pending <= 1'b0;
    end
  end

  logic [15:0] attempt;
  logic        reject_accum;
  logic [15:0] stage_idx;
  logic        exhausted_latched;
  logic verify_valid_q;
  logic op_error_q;

  // verify pipeline
  logic [2:0]  v_norm_ok_q;      // {norm_z, norm_r0, hint} latched per verify
  logic [5:0]  v_idx;
  logic        v_acc_and;        // monitor A: AND of byte equality
  logic        v_acc_or;         // monitor B: OR  of byte difference

  logic [7:0]  ct_calc_rf [0:CT_MAX_BYTES-1];
  logic [7:0]  ct_ref_rf  [0:CT_MAX_BYTES-1];
  logic [6:0]  ct_calc_wp;
  logic [6:0]  ct_ref_wp;
  logic [6:0]  ct_len_c;

  logic [15:0] sig_len_c;

  // ---------------------------------------------------------------------------
  // Derived sizes (parameter-set dependent, combinational lookup, no divide)
  // ---------------------------------------------------------------------------
  assign ct_len_c  = dsa_ct_bytes(param_set_e'(pset_q));
  assign sig_len_c = dsa_sig_bytes(param_set_e'(pset_q));
  assign sig_len   = sig_len_c;

  assign busy            = (astate != A_IDLE) && (astate != A_ZERO);
  assign done            = rst_n && !zeroize_req && (astate == A_DONE);
  assign retry_exhausted = rst_n && !zeroize_req && exhausted_latched;
  assign verify_valid = rst_n && !zeroize_req && verify_valid_q;
  assign op_error = rst_n && !zeroize_req && op_error_q;

  // ---------------------------------------------------------------------------
  // Primitive dispatch
  // ---------------------------------------------------------------------------
  assign prim_start  = rst_n && !zeroize_req && !prim_pending && !prim_busy &&
                       ((astate == A_EXPAND_Y) || (astate == A_NTT_W) || (astate == A_CHALLENGE));
  assign prim_domain = 1'b1;
  always_comb begin
    unique case (astate)
      A_EXPAND_Y:  prim_op = PRIM_NOP;
      A_NTT_W:     prim_op = PRIM_NTT_INV;
      A_CHALLENGE: prim_op = PRIM_PW_MAC;
      default:     prim_op = PRIM_NOP;
    endcase
  end

  // Working page layout (DSA): page 0 = y/A, page 1 = w, page 2 = accumulate.
  always_comb begin
    unique case (astate)
      A_NTT_W:     begin poly_src_page = 8'h0; poly_src2_page = 8'h0; poly_dst_page = 8'h0; end
      A_CHALLENGE: begin poly_src_page = 8'h0; poly_src2_page = 8'h1; poly_dst_page = 8'h2; end
      default:     begin poly_src_page = 8'h0; poly_src2_page = 8'h0; poly_dst_page = 8'h0; end
    endcase
  end

  // ---------------------------------------------------------------------------
  // Staging: stream the candidate into the invisible buffer, one byte per
  // accepted beat. Nothing reaches the output until A_COMMIT.
  // ---------------------------------------------------------------------------
  assign stage_req   = rst_n && !zeroize_req && (astate == A_STAGE);
  assign stage_we    = stage_req;
  assign stage_addr  = stage_idx;
  assign stage_wdata = stage_rdata;
  assign commit_valid= rst_n && !zeroize_req && (astate == A_COMMIT);

  // digest comparison uses the on-chip RF, so both operands are available on
  // the same cycle (no read-latency handshake required)
  logic [7:0] ct_calc_q, ct_ref_q;
  assign ct_calc_q = ct_calc_rf[v_idx];
  assign ct_ref_q  = ct_ref_rf[v_idx];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ct_calc_wp <= 6'h0;
      ct_ref_wp  <= 6'h0;
    end else if (zeroize_req || ct_clear || done) begin
      ct_calc_wp <= 6'h0;
      ct_ref_wp  <= 6'h0;
    end else begin
      if (ct_calc_we && ct_calc_wp < CT_MAX_BYTES+1) ct_calc_wp <= ct_calc_wp + 7'd1;
      if (ct_ref_we && ct_ref_wp < CT_MAX_BYTES+1) ct_ref_wp <= ct_ref_wp + 7'd1;
    end
  end

  // Small digest banks are physically wiped, not merely made unreachable by
  // rewinding pointers. Clear and retirement win over simultaneous byte writes.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i=0;i<CT_MAX_BYTES;i++) begin
        ct_calc_rf[i] <= '0;
        ct_ref_rf[i] <= '0;
      end
    end else if (zeroize_req || ct_clear || done) begin
      for (int i=0;i<CT_MAX_BYTES;i++) begin
        ct_calc_rf[i] <= '0;
        ct_ref_rf[i] <= '0;
      end
    end else begin
      if (ct_calc_we && ct_calc_wp < CT_MAX_BYTES) ct_calc_rf[ct_calc_wp] <= ct_calc_byte;
      if (ct_ref_we && ct_ref_wp < CT_MAX_BYTES) ct_ref_rf[ct_ref_wp] <= ct_ref_byte;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      astate            <= A_IDLE;
      attempt           <= 16'h0;
      reject_accum      <= 1'b0;
      verify_valid_q    <= 1'b0;
      exhausted_latched <= 1'b0;
      op_error_q        <= 1'b0;
      stage_idx         <= 16'h0;
      v_norm_ok_q       <= 3'b000;
      v_idx             <= 6'h0;
      v_acc_and         <= 1'b0;
      v_acc_or          <= 1'b0;
    end else if (zeroize_req) begin
      astate            <= A_ZERO;
      attempt           <= 16'h0;
      reject_accum      <= 1'b0;
      verify_valid_q    <= 1'b0;
      exhausted_latched <= 1'b0;
      op_error_q        <= 1'b0;
      stage_idx         <= 16'h0;
      v_idx             <= 6'h0;
      v_norm_ok_q       <= 3'b000;
      v_acc_and         <= 1'b0;
      v_acc_or          <= 1'b0;
    end else begin
      unique case (astate)
        A_IDLE: begin
          reject_accum <= 1'b0;
          attempt      <= 16'h0;
          stage_idx    <= 16'h0;
          // verify_valid is intentionally NOT cleared here: the result is
          // latched until the next command so software can read it after DONE.
          if (start) begin
            verify_valid_q    <= 1'b0;
            exhausted_latched <= 1'b0;
            op_error_q <= op > 2'd2 || pset < 3'd4 || pset > 3'd6;
            if (op > 2'd2 || pset < 3'd4 || pset > 3'd6) astate <= A_DONE;
            else astate <= A_INIT;
          end
        end

        A_INIT: begin
          if (op_q == 2'd2) astate <= A_CHALLENGE;  // verify computes c~ first
          else            astate <= A_EXPAND_Y;
        end

        A_EXPAND_Y: begin
          if (prim_pending && prim_done) astate <= A_NTT_W;
        end

        A_NTT_W: begin
          if (prim_pending && prim_done) astate <= A_CHALLENGE;
        end

        A_CHALLENGE: begin
          if (prim_pending && prim_done) begin
            if (op_q == 2'd2)      astate <= A_VCHK;   // verify: gates + digest
            else if (op_q == 2'd0) astate <= A_STAGE;  // keygen: no reject loop
            else                 astate <= A_NORM_Z;
          end
        end

        // ------------------------------------------------------------------
        // Sign numeric gates
        // ------------------------------------------------------------------
        A_NORM_Z: begin
          // all mandatory per-attempt operations complete before branching
          reject_accum <= reject_accum | ~norm_z_ok;
          astate       <= A_NORM_R0;
        end

        A_NORM_R0: begin
          reject_accum <= reject_accum | ~norm_r0_ok;
          astate       <= A_HINT;
        end

        A_HINT: begin
          reject_accum <= reject_accum | ~hint_weight_ok;
          if (reject_accum | ~norm_z_ok | ~norm_r0_ok | ~hint_weight_ok)
            astate <= A_REJECT;
          else
            astate <= A_STAGE;
        end

        A_REJECT: begin
          if (attempt + 16'h1 >= 16'(MAX_ATTEMPTS)) begin
            astate <= A_EXHAUST;
          end else begin
            attempt      <= attempt + 16'h1;
            reject_accum <= 1'b0;
            astate       <= A_EXPAND_Y;
          end
        end

        A_EXHAUST: begin
          // generic internal error, no partial output
          exhausted_latched <= 1'b1;
          astate            <= A_DONE;
        end

        // ------------------------------------------------------------------
        // Verify: latch the numeric gates, then scan the full digest
        // ------------------------------------------------------------------
        A_VCHK: begin
          v_norm_ok_q <= {norm_z_ok, norm_r0_ok, hint_weight_ok};
          v_idx       <= 6'h0;
          v_acc_and   <= (ct_calc_wp == ct_len_c) && (ct_ref_wp == ct_len_c) && (ct_len_c != 0);
          v_acc_or    <= 1'b0;
          astate      <= A_VCOMP;
        end

        A_VCOMP: begin
          // monitor A and monitor B are coded independently and must agree
          v_acc_and <= v_acc_and & (ct_calc_q == ct_ref_q);
          v_acc_or  <= v_acc_or  | (ct_calc_q != ct_ref_q);
          if ({1'b0, v_idx} + 7'd1 >= ct_len_c) astate <= A_VRES;
          else                                  v_idx  <= v_idx + 6'd1;
        end

        A_VRES: begin
          // fail-closed conjunction: digest equality (both redundant monitors)
          // AND every numeric rejection gate AND a clear reject accumulator.
          verify_valid_q <= !ct_clear && !ct_calc_we && !ct_ref_we &&
                          (ct_calc_wp == ct_len_c) && (ct_ref_wp == ct_len_c) &&
                          (v_acc_and & ~v_acc_or) &
                          v_norm_ok_q[2] & v_norm_ok_q[1] & v_norm_ok_q[0] &
                          ~reject_accum;
          astate       <= A_DONE;
        end

        // ------------------------------------------------------------------
        // Sign / keygen staging + commit
        // ------------------------------------------------------------------
        A_STAGE: begin
          if (stage_ready) begin
            if (stage_idx + 16'd1 >= sig_len_c) begin
              stage_idx <= 16'h0;
              astate    <= A_COMMIT;
            end else begin
              stage_idx <= stage_idx + 16'd1;
            end
          end
        end

        A_COMMIT: begin
          astate <= A_DONE;
        end

        A_DONE: begin
          astate <= A_IDLE;
        end

        A_ZERO: astate <= A_IDLE;

        default: astate <= A_IDLE;
      endcase
    end
  end

endmodule

`endif // PQC_DSA_SEQ_SV
