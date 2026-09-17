// ============================================================================
// pqc_poly_engine - dual-modulus polynomial engine
//
// Implements, for both the ML-KEM domain (q = 3329) and the ML-DSA domain
// (q = 8380417):
//   * forward NTT and inverse NTT (radix-2, 256 coefficients, in place)
//   * DSA pointwise MAC and KEM paired base multiplication, accumulated in dst
//   * coefficient add / sub  dst = src0 +/- src1 with conditional reduction
//
// The twiddle schedule, zeta order and inverse stage order match the reference
// model `pqc_accel_model.HardwareNTT` exactly, so results are byte-identical to
// the golden vectors produced by scripts/gen_pqc_golden.py.
//
// Two scheduling modes share one datapath:
//   NTT mode (fwd/inv)   butterfly walk over (stage, group, bfly); 2 reads then
//                        2 writes; in place on src_page
//   ELEMENTWISE mode     linear walk over 256 coefficients:
//                          ADD/SUB : read src0, src1 -> write dst
//                          PW_MAC  : read src0, src1, dst -> write dst
//                        so the accumulator is never aliased with an operand
//
// PPA notes (LLD.PPA.PQC.POLY, LLD.DP.PQC.POLY.BFLY):
//   * one 23-bit normalized multiplier shared by both moduli and primitives
//   * operand, second-operand and accumulator pages are addressed explicitly
//   * reductions use fixed conditional corrections, never a secret-dependent
//     branch (constant time)
// ============================================================================
`ifndef PQC_POLY_ENGINE_SV
`define PQC_POLY_ENGINE_SV

`include "pqc_ntt_rom.svh"

module pqc_poly_engine #(
  parameter int unsigned NTT_LANES = 2
) (
  input  logic         clk,
  input  logic         rst_n,

  // command
  input  logic         start,
  input  logic [3:0]   prim,          // poly_prim_e
  input  logic         domain,        // 0 = KEM, 1 = DSA
  input  logic [7:0]   src_page,      // operand A page
  input  logic [7:0]   src2_page,     // operand B page (PW_MAC / ADD / SUB)
  input  logic [7:0]   dst_page,      // result / accumulator page
  output logic         busy,
  output logic         done,

  // coefficient memory port
  output logic         mem_req,
  output logic         mem_we,
  output logic [15:0]  mem_addr,      // {page[7:0], coeff[7:0]}
  output logic [31:0]  mem_wdata,
  input  logic [31:0]  mem_rdata,
  input  logic         mem_ready,

  input  logic         zeroize_req
);

  import pqc_pkg::*;
  logic [3:0] prim_q;
  logic [0:0] domain_q;
  logic [7:0] src_page_q;
  logic [7:0] src2_page_q;
  logic [7:0] dst_page_q;


  localparam int unsigned N    = POLY_N;
  localparam int unsigned NLOG = POLY_N_LOG;

  // ---------------------------------------------------------------------------
  // Modulus-dependent constants
  // ---------------------------------------------------------------------------
  logic [31:0] mod_q;

  always_comb begin
    if (domain_q) begin
      mod_q = 32'(DSA_Q);
    end else begin
      mod_q = 32'(KEM_Q);
    end
  end

  // ---------------------------------------------------------------------------
  // Modular arithmetic. The modulus is known per domain_q, so the reductions are
  // written against literal constants: KEM uses a 32x32 reciprocal (Barrett)
  // chain and DSA uses the constant-modulus remainder. No runtime divider.
  // ---------------------------------------------------------------------------
  localparam logic [63:0] KEM_RECIP = 64'd1290167;   // floor(2^32 / 3329)

  function automatic logic [31:0] kem_reduce(input logic [31:0] v);
    logic [63:0] q_est, r;
    q_est = (64'(v) * KEM_RECIP) >> 32;   // floor(v / 3329) or one less
    r     = 64'(v) - 64'(q_est) * 64'(KEM_Q);
    if (r >= 64'(KEM_Q)) kem_reduce = 32'(r - 64'(KEM_Q));
    else                 kem_reduce = 32'(r);
  endfunction

  function automatic logic [31:0] mod_mul(input logic [31:0] a, input logic [31:0] b);
    logic [45:0] prod;
    // All operands are normalized residues: DSA needs 23 bits, KEM 12.
    prod = 46'(a[22:0]) * 46'(b[22:0]);
    mod_mul = domain_q ? 32'(prod % 46'd8380417) : kem_reduce(32'(prod));
  endfunction

  function automatic logic [31:0] mod_add(input logic [31:0] a, input logic [31:0] b);
    logic [32:0] s;
    s = 33'(a) + 33'(b);
    mod_add = (s >= 33'(mod_q)) ? 32'(s - 33'(mod_q)) : 32'(s);
  endfunction

  function automatic logic [31:0] mod_sub(input logic [31:0] a, input logic [31:0] b);
    mod_sub = (a >= b) ? (a - b) : (a + mod_q - b);
  endfunction

  // ---------------------------------------------------------------------------
  // Twiddle lookup
  // ---------------------------------------------------------------------------
  logic [8:0] rom_idx_i;

  function automatic logic [31:0] twiddle(input logic [3:0] stage, input logic [7:0] k);
    logic [8:0] idx;
    idx = 9'(zeta_stage_offset(stage)) + 9'(k);
    twiddle = domain_q ? {9'h0, dsa_zeta(idx)}
                     : {16'h0, kem_zeta(idx)};
  endfunction

  function automatic logic [31:0] twiddle_inv(input logic [8:0] idx);
    twiddle_inv = domain_q ? {9'h0, dsa_zeta_inv(idx)}
                         : {16'h0, kem_zeta_inv(idx)};
  endfunction

  // ---------------------------------------------------------------------------
  // Stage geometry / elementwise index
  // ---------------------------------------------------------------------------
  logic [3:0]  stage;
  logic [7:0]  group;
  logic [8:0]  bfly;
  logic [8:0]  len;
  logic [8:0]  a_idx;
  logic [8:0]  b_idx;
  logic [31:0] zeta;
  logic [3:0]  stage_last;
  logic        stage_dir_fwd;
  logic [8:0]  elem_idx;

  logic is_ntt, is_mac, is_add, is_sub;

  always_comb begin
    stage_last = domain_q ? 4'(DSA_STAGES - 1) : 4'(KEM_STAGES - 1);
    is_ntt = (prim_q == PRIM_NTT_FWD) || (prim_q == PRIM_NTT_INV);
    is_mac = (prim_q == PRIM_PW_MAC);
    is_add = (prim_q == PRIM_ADD);
    is_sub = (prim_q == PRIM_SUB);
  end

  always_comb begin
    len   = 9'(128 >> stage);
    a_idx = 9'(group * 2 * len) + bfly;
    b_idx = a_idx + len;
    zeta  = twiddle(stage, group);
    rom_idx_i = 9'(zeta_stage_offset(stage)) + 9'(group);
  end

  // ---------------------------------------------------------------------------
  // Sequencing
  // ---------------------------------------------------------------------------
  typedef enum logic [4:0] {
    P_IDLE, P_ADDR, P_READ_A, P_READ_B, P_READ_ACC, P_CALC,
    P_WR_A, P_WR_B, P_ADDR_NEXT, P_DONE, P_ZERO,
    P_PAIR_A, P_PAIR_B, P_PAIR_C, P_MUL0, P_MUL1, P_MUL2, P_MUL3, P_MUL4, P_PAIR_WR
  } pstate_e;
  pstate_e pstate;

  logic [31:0] a_val, b_val, acc_val;
  logic [31:0] a_odd, b_odd, c_odd, pair_tmp;
  logic [31:0] mul_a, mul_b, mul_result, pair_zeta;
  logic [15:0] a_addr, b_addr, acc_addr;
  logic [31:0] w_a, w_b;
  logic        ntt_started;

  // NTT writes back in place; elementwise writes to dst_page_q
  logic [7:0] wr_page;
  always_comb wr_page = is_ntt ? src_page_q : dst_page_q;

  assign mem_req = rst_n && !zeroize_req && ((pstate == P_READ_A) || (pstate == P_READ_B) ||
                   (pstate == P_READ_ACC) || (pstate == P_WR_A) || (pstate == P_WR_B) ||
                   (pstate == P_PAIR_A) || (pstate == P_PAIR_B) || (pstate == P_PAIR_C) || (pstate == P_PAIR_WR));
  assign mem_we  = mem_req && ((pstate == P_WR_A) || (pstate == P_WR_B) || (pstate == P_PAIR_WR));

  always_comb begin
    case (pstate)
      P_PAIR_A: mem_addr = a_addr + 1'b1;
      P_PAIR_B: mem_addr = b_addr + 1'b1;
      P_PAIR_C: mem_addr = acc_addr + 1'b1;
      P_PAIR_WR: mem_addr = acc_addr + 1'b1;
      P_READ_A:  mem_addr = a_addr;
      P_READ_B:  mem_addr = b_addr;
      P_READ_ACC:mem_addr = acc_addr;
      P_WR_A:    mem_addr = is_ntt ? {wr_page, 8'(a_idx[7:0])}
                                   : {wr_page, 8'(elem_idx[7:0])};
      P_WR_B:    mem_addr = {wr_page, 8'(b_idx[7:0])};
      default:   mem_addr = 16'h0;
    endcase
    mem_wdata = (pstate == P_WR_A) ? w_a : w_b;
  end

  function automatic logic [31:0] mod_half(input logic [31:0] a);
    logic [32:0] t;
    t = {1'b0,a} + (a[0] ? {1'b0,mod_q} : 33'd0);
    return t[32:1];
  endfunction

  // Exactly one multiplier/reducer call, selected by the public schedule.
  always_comb begin
    pair_zeta = {16'd0,kem_zeta(63 + (elem_idx >> 2))};
    if (elem_idx[1]) pair_zeta = 3329-pair_zeta;
    mul_a = 0; mul_b = 0;
    case (pstate)
      P_CALC: begin
        if (prim_q == PRIM_NTT_FWD) begin mul_a=zeta; mul_b=b_val; end
        else if (prim_q == PRIM_NTT_INV) begin mul_a=mod_half(mod_sub(a_val,b_val)); mul_b=twiddle_inv(rom_idx_i); end
        else if (is_mac) begin mul_a=a_val; mul_b=b_val; end
      end
      P_MUL0: begin mul_a=a_odd; mul_b=b_odd; end
      P_MUL1: begin mul_a=pair_tmp; mul_b=pair_zeta; end
      P_MUL2: begin mul_a=a_val; mul_b=b_val; end
      P_MUL3: begin mul_a=a_val; mul_b=b_odd; end
      P_MUL4: begin mul_a=a_odd; mul_b=b_val; end
      default: begin end
    endcase
    mul_result = mod_mul(mul_a,mul_b);
  end

  assign busy = (pstate != P_IDLE) && (pstate != P_DONE) && (pstate != P_ZERO);
  assign done = rst_n && !zeroize_req && (pstate == P_DONE);

  task automatic advance_ntt();
    if (bfly < len - 9'd1) begin
      bfly   <= bfly + 9'h1;
      pstate <= P_ADDR;
    end else begin
      bfly <= 9'h0;
      if (group < 8'((1 << stage) - 1)) begin
        group  <= group + 8'h1;
        pstate <= P_ADDR;
      end else begin
        group <= 8'h0;
        if (stage_dir_fwd ? (stage >= stage_last) : (stage == 4'h0))
          pstate <= P_DONE;
        else begin
          stage  <= stage_dir_fwd ? (stage + 4'h1) : (stage - 4'h1);
          pstate <= P_ADDR;
        end
      end
    end
  endtask

  task automatic advance_elem();
    if (elem_idx + 9'd1 >= 9'(N)) pstate <= P_DONE;
    else begin
      elem_idx <= elem_idx + 9'h1;
      pstate   <= P_ADDR;
    end
  endtask

  // ---------------------------------------------------------------------------
  // The single procedural owner of the engine state
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pstate        <= P_IDLE;
      stage         <= 4'h0;
      group         <= 8'h0;
      bfly          <= 9'h0;
      elem_idx      <= 9'h0;
      a_val         <= 32'h0;
      a_odd <= 0; b_odd <= 0; c_odd <= 0; pair_tmp <= 0;
      b_val         <= 32'h0;
      acc_val       <= 32'h0;
      a_addr        <= 16'h0;
      b_addr        <= 16'h0;
      acc_addr      <= 16'h0;
      w_a           <= 32'h0;
      w_b           <= 32'h0;
      stage_dir_fwd <= 1'b1;
    end else if (zeroize_req) begin
      pstate  <= P_ZERO;
      a_odd <= 0; b_odd <= 0; c_odd <= 0; pair_tmp <= 0;
      a_val   <= 32'h0;
      b_val   <= 32'h0;
      acc_val <= 32'h0;
      w_a     <= 32'h0;
      w_b     <= 32'h0;
    end else begin
      unique case (pstate)
        P_IDLE: begin
          if (start) begin
            stage_dir_fwd <= (prim != PRIM_NTT_INV);
            stage    <= (prim == PRIM_NTT_INV)
                        ? (domain ? 4'(DSA_STAGES - 1) : 4'(KEM_STAGES - 1)) : 4'h0;
            group    <= 8'h0;
            bfly     <= 9'h0;
            elem_idx <= 9'h0;
            pstate   <= P_ADDR;
          end
        end

        // address phase: latch the operand addresses for this transaction
        P_ADDR: begin
          if (is_ntt) begin
            a_addr <= {src_page_q, 8'(a_idx[7:0])};
            b_addr <= {src_page_q, 8'(b_idx[7:0])};
          end else begin
            a_addr   <= {src_page_q,  8'(elem_idx[7:0])};
            b_addr   <= {src2_page_q, 8'(elem_idx[7:0])};
            acc_addr <= {dst_page_q,  8'(elem_idx[7:0])};
          end
          pstate <= P_READ_A;
        end

        P_READ_A: if (mem_ready) begin a_val <= mem_rdata; pstate <= P_READ_B; end

        P_READ_B: if (mem_ready) begin
          b_val <= mem_rdata;
          pstate <= is_mac ? P_READ_ACC : P_CALC;
        end

        P_READ_ACC: if (mem_ready) begin acc_val <= mem_rdata; pstate <= (!domain_q && is_mac) ? P_PAIR_A : P_CALC; end

        P_CALC: begin
          if (prim_q == PRIM_NTT_FWD) begin
            logic [31:0] t;
            t   = mul_result;
            w_a <= mod_add(a_val, t);
            w_b <= mod_sub(a_val, t);
          end else if (prim_q == PRIM_NTT_INV) begin
            w_a  <= mod_half(mod_add(a_val, b_val));
            w_b  <= mul_result;
          end else if (is_mac) begin
            w_a <= mod_add(acc_val, mul_result);
          end else if (is_add) begin
            w_a <= mod_add(a_val, b_val);
          end else if (is_sub) begin
            w_a <= mod_sub(a_val, b_val);
          end else begin
            w_a <= a_val;   // unknown primitive: pass through (never a silent mul)
          end
          pstate <= P_WR_A;
        end

        P_PAIR_A: if (mem_ready) begin a_odd <= mem_rdata; pstate <= P_PAIR_B; end
        P_PAIR_B: if (mem_ready) begin b_odd <= mem_rdata; pstate <= P_PAIR_C; end
        P_PAIR_C: if (mem_ready) begin c_odd <= mem_rdata; pstate <= P_MUL0; end
        P_MUL0: begin pair_tmp <= mul_result; pstate <= P_MUL1; end
        P_MUL1: begin pair_tmp <= mul_result; pstate <= P_MUL2; end
        P_MUL2: begin w_a <= mod_add(acc_val,mod_add(pair_tmp,mul_result)); pstate <= P_MUL3; end
        P_MUL3: begin pair_tmp <= mul_result; pstate <= P_MUL4; end
        P_MUL4: begin w_b <= mod_add(c_odd,mod_add(pair_tmp,mul_result)); pstate <= P_WR_A; end
        P_PAIR_WR: if (mem_ready) begin
          if (elem_idx == 254) pstate <= P_DONE;
          else begin elem_idx <= elem_idx+2; pstate <= P_ADDR; end
        end
        P_WR_A: if (mem_ready) pstate <= is_ntt ? P_WR_B : (!domain_q && is_mac) ? P_PAIR_WR : P_ADDR_NEXT;

        P_WR_B: if (mem_ready) advance_ntt();

        // elementwise: move to the next coefficient once the single write lands
        P_ADDR_NEXT: advance_elem();

        P_DONE: pstate <= P_IDLE;
        P_ZERO: pstate <= P_IDLE;
        default: pstate <= P_IDLE;
      endcase
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prim_q <= '0;
      domain_q <= '0;
      src_page_q <= '0;
      src2_page_q <= '0;
      dst_page_q <= '0;
    end else if (zeroize_req) begin
      prim_q <= '0;
      domain_q <= '0;
      src_page_q <= '0;
      src2_page_q <= '0;
      dst_page_q <= '0;
    end else if (start && pstate == P_IDLE) begin
      prim_q <= prim;
      domain_q <= domain;
      src_page_q <= src_page;
      src2_page_q <= src2_page;
      dst_page_q <= dst_page;
    end
  end

endmodule

`endif // PQC_POLY_ENGINE_SV
