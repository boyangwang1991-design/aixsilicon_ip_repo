// ============================================================================
// pqc_kem_seq - ML-KEM KeyGen / Encaps / Decaps sequencing
//
// Current scalar control implements primitive request retirement and full-length
// ciphertext comparison / 32-byte selection. The complete KEM primitive chain,
// K_bar computation and secret input plumbing are still pending; see
// docs/lld/03_kemseq.md. Local control UT is not an end-to-end KEM KAT.
// ============================================================================
`ifndef PQC_KEM_SEQ_SV
`define PQC_KEM_SEQ_SV

module pqc_kem_seq (
  input  logic         clk,
  input  logic         rst_n,

  // dispatch from the command frontend
  input  logic         start,
  input  logic [1:0]   op,            // 0=keygen 1=encaps 2=decaps
  input  logic [1:0]   rank,          // k-2 index for the parameter set
  output logic         busy,
  output logic         done,
  output logic         op_error,

  // primitive dispatch to poly/keccak/sampler/codec
  output logic         prim_start,
  output logic [3:0]   prim_op,
  output logic         prim_domain,
  input  logic         prim_busy,
  input  logic         prim_done,

  // working-memory page operands for the polynomial primitive
  output logic [7:0]   poly_src_page,
  output logic [7:0]   poly_src2_page,
  output logic [7:0]   poly_dst_page,

  // ciphertext length in bytes, taken from the descriptor
  input  logic [15:0]  ct_bytes,

  // packed buffers (ciphertext compare / shared secret select)
  input  logic [7:0]   ct_read_data,
  output logic [15:0]  ct_read_addr,
  input  logic [7:0]   ct_calc_data,
  output logic [15:0]  ct_calc_addr,
  input  logic [7:0]   kprime_data,
  input  logic [7:0]   kbar_data,
  output logic [15:0]  ss_addr,
  output logic [7:0]   ss_wdata,
  output logic         ss_we,
  output logic [15:0]  ct_len,
  output logic [7:0]   verify_mask,

  input  logic         zeroize_req
);

  import pqc_pkg::*;

  localparam int unsigned SS_BYTES = 32;

  typedef enum logic [3:0] {
    Q_IDLE, Q_KEYGEN, Q_ENCAPS, Q_DECRYPT, Q_REENC, Q_COMPARE, Q_SELECT, Q_DONE, Q_ZERO
  } qstate_e;
  qstate_e qstate;

  logic [15:0] ctr;
  logic [7:0]  diff_acc;   // OR-accumulated full-length difference
  logic [15:0] ct_bytes_q;
  logic prim_pending;
  logic error_q;

  assign busy     = (qstate != Q_IDLE) && (qstate != Q_DONE) && (qstate != Q_ZERO);
  assign done     = rst_n && !zeroize_req && (qstate == Q_DONE);
  assign op_error = rst_n && !zeroize_req && error_q;

  assign prim_start  = rst_n && !zeroize_req && !prim_pending && !prim_busy &&
                       ((qstate == Q_KEYGEN) || (qstate == Q_ENCAPS) || (qstate == Q_REENC));
  assign prim_domain = 1'b0;
  always_comb begin
    unique case (qstate)
      Q_KEYGEN: prim_op = PRIM_NTT_FWD;
      Q_ENCAPS: prim_op = PRIM_PW_MAC;
      Q_REENC:  prim_op = PRIM_NTT_FWD;
      default:  prim_op = PRIM_NOP;
    endcase
  end

  // Working page layout (KEM): page 0 = A/s, page 1 = t/u, page 2 = accumulate.
  // The sequencer selects these per operation; the engine never aliases the
  // accumulator with an operand.
  always_comb begin
    unique case (qstate)
      Q_KEYGEN: begin poly_src_page = 8'h0; poly_src2_page = 8'h1; poly_dst_page = 8'h1; end
      Q_ENCAPS: begin poly_src_page = 8'h0; poly_src2_page = 8'h1; poly_dst_page = 8'h2; end
      Q_REENC:  begin poly_src_page = 8'h0; poly_src2_page = 8'h1; poly_dst_page = 8'h2; end
      default:  begin poly_src_page = 8'h0; poly_src2_page = 8'h0; poly_dst_page = 8'h0; end
    endcase
  end

  assign ct_read_addr  = ctr;
  assign ct_calc_addr  = ctr;
  assign ss_addr       = ctr;
  assign ct_len        = ct_bytes_q;
  assign verify_mask   = diff_acc;

  // The byte interface has no write backpressure. Address, selected data and
  // write enable therefore describe the SAME cycle and are consumed together.
  // Registering just data/enable shifts byte zero to address one.
  logic [7:0] select_mask;
  assign select_mask = {8{diff_acc == 8'h00}};
  assign ss_we = rst_n && !zeroize_req && qstate == Q_SELECT;
  assign ss_wdata = ss_we ? ((kprime_data & select_mask) |
                            (kbar_data & ~select_mask)) : 8'h00;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      qstate   <= Q_IDLE;
      ctr      <= 16'h0;
      diff_acc <= 8'h0;
      ct_bytes_q <= 16'h0;
      prim_pending <= 1'b0;
      error_q <= 1'b0;
    end else if (zeroize_req) begin
      qstate   <= Q_ZERO;
      ctr      <= 16'h0;
      diff_acc <= 8'h0;
      ct_bytes_q <= 16'h0;
      prim_pending <= 1'b0;
      error_q <= 1'b0;
    end else begin
      if (prim_start) prim_pending <= 1'b1;
      if (prim_pending && prim_done) prim_pending <= 1'b0;
      unique case (qstate)
        Q_IDLE: begin
          diff_acc <= 8'h0;
          if (start) begin
            ctr <= 16'h0;
            ct_bytes_q <= ct_bytes;
            error_q <= 1'b0;
            if (op == 2'd3 || rank == 2'd3 ||
                (op == 2'd2 && ct_bytes !=
                  (rank == 2'd0 ? 16'd768 : rank == 2'd1 ? 16'd1088 : 16'd1568))) begin
              error_q <= 1'b1;
              qstate <= Q_DONE;
            end else unique case (op)
              2'd0:    qstate <= Q_KEYGEN;
              2'd1:    qstate <= Q_ENCAPS;
              default: qstate <= Q_DECRYPT;
            endcase
          end
        end

        Q_KEYGEN: begin
          if (prim_pending && prim_done) qstate <= Q_DONE;
        end

        Q_ENCAPS: begin
          if (prim_pending && prim_done) qstate <= Q_DONE;
        end

        Q_DECRYPT: begin
          // fixed-length ciphertext read, then re-derivation and re-encryption
          if (ctr >= ct_bytes_q) qstate <= Q_REENC;
          else                 ctr <= ctr + 16'h1;
        end

        Q_REENC: begin
          if (prim_pending && prim_done) begin
            ctr      <= 16'h0;
            diff_acc <= 8'h0;
            qstate   <= Q_COMPARE;
          end
        end

        Q_COMPARE: begin
          // full-length OR accumulation of the byte differences
          diff_acc <= diff_acc | (ct_read_data ^ ct_calc_data);
          if (ctr + 16'h1 >= ct_bytes_q) begin
            qstate <= Q_SELECT;
            ctr    <= 16'h0;
          end else begin
            ctr <= ctr + 16'h1;
          end
        end

        Q_SELECT: begin
          // Retire exactly the byte presented on ss_addr/ss_wdata this cycle.
          if (ctr >= 16'(SS_BYTES - 1)) qstate <= Q_DONE;
          else ctr <= ctr + 16'h1;
        end

        Q_DONE: qstate <= Q_IDLE;

        Q_ZERO: qstate <= Q_IDLE;

        default: qstate <= Q_IDLE;
      endcase
    end
  end

endmodule

`endif // PQC_KEM_SEQ_SV
