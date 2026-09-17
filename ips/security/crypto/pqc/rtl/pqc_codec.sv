// ============================================================================
// pqc_codec - bit packing, compress/decompress, rounding/hint and norm check
//
// Implements (LLD.DP.PQC.CODEC.BITPACK):
//   * FIPS 203 Compress/Decompress with parameter-set dependent du/dv
//   * FIPS 204 Power2Round, Decompose (HighBits/LowBits with gamma2),
//     MakeHint / UseHint
//   * norm check over the CENTERED representative |v| = min(v, q-v), with a
//     strict bound (a coefficient exactly equal to the bound is rejected) and
//     an OR-reduction that never stops at the first violation
//   * canonical range check
//
// Notes:
//   * Compress/Decompress use the constant modulus 3329; the division by a
//     literal constant is strength-reduced by synthesis (no variable divider).
//   * Decompose follows FIPS 204 Algorithm 35/36 with the selected gamma2.
//
// PPA notes: the codec is a narrow serial unit (no wide barrel shifter tree);
// it shares the SRAM port with the NTT on a separate bank group.
// ============================================================================
`ifndef PQC_CODEC_SV
`define PQC_CODEC_SV

module pqc_codec (
  input  logic         clk,
  input  logic         rst_n,

  // command
  input  logic         start,
  input  logic [3:0]   op,            // codec opcode
  input  logic         domain,        // 0 = KEM, 1 = DSA
  input  logic [4:0]   d_comp,        // du or dv (KEM); ignored for DSA
  input  logic [1:0]   gamma2_sel,    // DSA gamma2 selector (0=(q-1)/88, 1=(q-1)/32)
  input  logic [7:0]   src_page,      // primary operand page
  input  logic [7:0]   src2_page,     // hint vector page (MAKEHINT / USEHINT)
  input  logic [7:0]   dst_page,
  input  logic [31:0]  bound,         // norm bound (DSA)
  output logic         busy,
  output logic         done,
  output logic         canonical_ok,
  output logic         norm_ok,

  // memory port
  output logic         mem_req,
  output logic         mem_we,
  output logic [15:0]  mem_addr,
  output logic [31:0]  mem_wdata,
  input  logic [31:0]  mem_rdata,
  input  logic         mem_ready,

  input  logic         zeroize_req
);

  import pqc_pkg::*;
  logic [3:0] op_q;
  logic [0:0] domain_q;
  logic [4:0] d_comp_q;
  logic [1:0] gamma2_sel_q;
  logic [7:0] src_page_q;
  logic [7:0] src2_page_q;
  logic [7:0] dst_page_q;
  logic [31:0] bound_q;


  localparam int unsigned N = POLY_N;
  localparam logic [31:0] DSA_Q = 32'd8380417;

  // codec opcodes
  localparam logic [3:0] C_PACK       = 4'h0;
  localparam logic [3:0] C_UNPACK     = 4'h1;
  localparam logic [3:0] C_COMPRESS   = 4'h2;
  localparam logic [3:0] C_DECOMPRESS = 4'h3;
  localparam logic [3:0] C_POWER2ROUND= 4'h4;
  localparam logic [3:0] C_DECOMPOSE  = 4'h5;
  localparam logic [3:0] C_MAKEHINT   = 4'h6;
  localparam logic [3:0] C_USEHINT    = 4'h7;
  localparam logic [3:0] C_NORMCHECK  = 4'h8;
  localparam logic [3:0] C_POWER2ROUND_HI = 4'h9;
  localparam logic [3:0] C_LOWBITS = 4'ha;

  typedef enum logic [3:0] {
    C_IDLE, C_RD, C_RD2, C_EXEC, C_WR, C_DONE, C_ZERO,
    C_PK_RD, C_PK_ADD, C_PK_WR, C_UP_RD, C_UP_GET, C_UP_WR
  } cstate_e;
  cstate_e cstate;

  logic [63:0] pack_bits;
  logic [6:0] pack_count;
  logic [8:0] word_idx;
  logic [8:0] idx;
  logic [31:0] acc, acc2;
  logic        canonical_acc;
  logic        norm_acc;

  // ---------------------------------------------------------------------------
  // KEM Compress / Decompress (FIPS 203, q = 3329)
  // ---------------------------------------------------------------------------
  function automatic logic [31:0] compress(input logic [31:0] x, input logic [4:0] d);
    logic [63:0] t;
    logic [31:0] mod_mask;
    if (d == 5'd0) return 32'h0;
    mod_mask = (32'h1 << d) - 32'h1;
    t = (64'(x % 32'(KEM_Q)) << d) + 64'(32'(KEM_Q) >> 1);
    compress = 32'( (t / 64'd3329) & 64'(mod_mask) );
  endfunction

  function automatic logic [31:0] decompress(input logic [31:0] y, input logic [4:0] d);
    if (d == 5'd0) return 32'h0;
    decompress = ((32'(y) * 32'(KEM_Q)) + (32'h1 << (d - 5'd1))) >> d;
  endfunction

  // ---------------------------------------------------------------------------
  // DSA Power2Round (FIPS 204, d = 13)
  // ---------------------------------------------------------------------------
  function automatic logic [31:0] power2round_hi(input logic [31:0] a);
    power2round_hi = (a % DSA_Q + (32'h1 << 12) - 32'h1) >> 13;
  endfunction

  function automatic logic [31:0] power2round_lo(input logic [31:0] a);
    power2round_lo = (a % DSA_Q) - (power2round_hi(a) << 13);
  endfunction

  // ---------------------------------------------------------------------------
  // DSA Decompose (FIPS 204 Algorithm 35/36) -> HighBits
  //   gamma2 = (q-1)/88 for ML-DSA-44, (q-1)/32 for ML-DSA-65/87
  // ---------------------------------------------------------------------------
  function automatic logic [31:0] gamma2_val(input logic [1:0] sel);
    return (sel == 2'd0) ? 32'd95232 : 32'd261888;   // (q-1)/88, (q-1)/32
  endfunction

  function automatic logic [31:0] decompose_hi(input logic [31:0] a, input logic [1:0] sel);
    logic [31:0] am, a1;
    begin
      am = a % DSA_Q;
      if (sel == 0) begin
        a1 = (am + 32'd95231) / 32'd190464;
        return (a1 == 44) ? 0 : a1;
      end else begin
        a1 = (am + 32'd261887) / 32'd523776;
        return (a1 == 16) ? 0 : a1;
      end
    end
  endfunction

  function automatic logic signed [31:0] decompose_lo(input logic [31:0] a, input logic [1:0] sel);
    logic signed [31:0] a0;
    a0 = $signed(a % DSA_Q) - $signed(decompose_hi(a, sel) * (2*gamma2_val(sel)));
    if (a0 > $signed(DSA_Q >> 1)) a0 = a0 - $signed(DSA_Q);
    return a0;
  endfunction

  // Operand A is a signed centered low part; B is its high part.
  function automatic logic make_hint(input logic [31:0] a0, input logic [31:0] a1,
                                     input logic [1:0] sel);
    logic signed [31:0] g2, low;
    g2 = $signed(gamma2_val(sel));
    low = $signed(a0);
    return (low > g2) || (low < -g2) || ((low == -g2) && (a1 != 0));
  endfunction

  function automatic logic [31:0] use_hint(input logic [31:0] h, input logic [31:0] a,
                                         input logic [1:0] sel);
    logic [31:0] a1, modulus;
    logic signed [31:0] a0;
    a1 = decompose_hi(a, sel);
    a0 = decompose_lo(a, sel);
    modulus = (sel == 0) ? 44 : 16;
    if (h == 0) return a1;
    if (a0 > 0) return (a1 == modulus-1) ? 0 : a1+1;
    return (a1 == 0) ? modulus-1 : a1-1;
  endfunction

  // centred absolute value for the norm check: |v| = min(v, q-v) in the
  // domain_q-appropriate modulus. Without the centring step a value just below
  // q (which represents a small negative coefficient) would be wrongly
  // rejected.
  function automatic logic [31:0] centered_abs(input logic [31:0] v);
    logic [31:0] q, m;
    q = domain_q ? DSA_Q : 32'(KEM_Q);
    if (v[31]) return (~v)+32'd1;
    m = domain_q ? (v % DSA_Q) : (v % 32'(KEM_Q));
    return (m > (q - m)) ? (q - m) : m;
  endfunction

  assign busy      = (cstate != C_IDLE) && (cstate != C_DONE) && (cstate != C_ZERO);
  assign done      = rst_n && !zeroize_req && (cstate == C_DONE);

  // memory addressing: operand A, optional operand B (hint vector), result
  logic rd2;
  always_comb begin
    rd2 = (op_q == C_MAKEHINT) || (op_q == C_USEHINT);
  end

  assign mem_req  = rst_n && !zeroize_req &&
                    ((cstate == C_RD) || (cstate == C_RD2) || (cstate == C_WR) ||
                     (cstate == C_PK_RD) || (cstate == C_PK_WR) || (cstate == C_UP_RD) || (cstate == C_UP_WR));
  assign mem_we   = mem_req && ((cstate == C_WR) || (cstate == C_PK_WR) || (cstate == C_UP_WR));
  always_comb begin
    if (cstate == C_PK_WR) mem_addr = {dst_page_q,8'd0}+word_idx;
    else if (cstate == C_UP_RD) mem_addr = {src_page_q,8'd0}+word_idx;
    else if (cstate == C_UP_WR) mem_addr = {dst_page_q,8'(idx)};
    else if (cstate == C_WR)       mem_addr = {dst_page_q,   8'(idx)};
    else if (cstate == C_RD2) mem_addr = {src2_page_q,  8'(idx)};
    else                      mem_addr = {src_page_q,   8'(idx)};
  end
  assign mem_wdata = (cstate == C_PK_WR) ? pack_bits[31:0] : acc;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cstate        <= C_IDLE;
      idx           <= 9'h0;
      pack_bits <= 0; pack_count <= 0; word_idx <= 0;
      acc           <= 32'h0;
      acc2          <= 32'h0;
      canonical_acc <= 1'b1;
      norm_acc      <= 1'b1;
    end else if (zeroize_req) begin
      cstate        <= C_ZERO;
      idx           <= 9'h0;
      pack_bits <= 0; pack_count <= 0; word_idx <= 0;
      acc           <= 32'h0;
      acc2          <= 32'h0;
      canonical_acc <= 1'b1;
      norm_acc      <= 1'b1;
    end else begin
      unique case (cstate)
        C_IDLE: begin
          if (start) begin
            idx           <= 9'h0;
      pack_bits <= 0; pack_count <= 0; word_idx <= 0;
            canonical_acc <= 1'b1;
            norm_acc      <= 1'b1;
            if (op == C_PACK || op == C_UNPACK) begin
              if (d_comp == 0 || d_comp > 24) begin canonical_acc <= 0; cstate <= C_DONE; end
              else cstate <= (op == C_PACK) ? C_PK_RD : C_UP_RD;
            end else cstate <= C_RD;
          end
        end

        C_PK_RD: if (mem_ready) begin acc <= mem_rdata; cstate <= C_PK_ADD; end
        C_PK_ADD: begin
          if ((acc >> d_comp_q) != 0) canonical_acc <= 0;
          pack_bits <= pack_bits | ((64'(acc) & ((64'd1 << d_comp_q)-1)) << pack_count);
          pack_count <= pack_count+d_comp_q;
          idx <= idx+1;
          cstate <= (pack_count+d_comp_q >= 32) ? C_PK_WR : C_PK_RD;
        end
        C_PK_WR: if (mem_ready) begin
          pack_bits <= pack_bits >> 32;
          pack_count <= pack_count-32;
          word_idx <= word_idx+1;
          cstate <= (idx == N) ? C_DONE : C_PK_RD;
        end
        C_UP_RD: if (mem_ready) begin
          pack_bits <= pack_bits | (64'(mem_rdata) << pack_count);
          pack_count <= pack_count+32;
          word_idx <= word_idx+1;
          cstate <= C_UP_GET;
        end
        C_UP_GET: begin
          if (pack_count >= d_comp_q) begin
            acc <= 32'(pack_bits & ((64'd1 << d_comp_q)-1));
            pack_bits <= pack_bits >> d_comp_q;
            pack_count <= pack_count-d_comp_q;
            cstate <= C_UP_WR;
          end else cstate <= C_UP_RD;
        end
        C_UP_WR: if (mem_ready) begin
          idx <= idx+1;
          cstate <= (idx == N-1) ? C_DONE : C_UP_GET;
        end

        C_RD: if (mem_ready) begin acc <= mem_rdata; cstate <= rd2 ? C_RD2 : C_EXEC; end

        C_RD2: if (mem_ready) begin acc2 <= mem_rdata; cstate <= C_EXEC; end

        C_EXEC: begin
          logic [31:0] v, h;
          v = acc;
          h = acc2;

          // canonical range check (all operations)
          if (domain_q && op_q != C_MAKEHINT && op_q != C_NORMCHECK) begin
            if (v >= DSA_Q) canonical_acc <= 1'b0;
          end else if (!domain_q) begin
            if (v >= 32'(KEM_Q)) canonical_acc <= 1'b0;
          end

          unique case (op_q)
            C_COMPRESS:    acc <= compress(v, 5'(d_comp_q));
            C_DECOMPRESS:  acc <= decompress(v, 5'(d_comp_q));
            C_POWER2ROUND: acc <= power2round_lo(v);
            C_POWER2ROUND_HI: acc <= power2round_hi(v);
            C_LOWBITS: acc <= decompose_lo(v, gamma2_sel_q);
            C_DECOMPOSE:   acc <= decompose_hi(v, gamma2_sel_q);
            C_MAKEHINT:    acc <= {31'h0, make_hint(v, h, gamma2_sel_q)};
            C_USEHINT:     acc <= use_hint(h, v, gamma2_sel_q);
            C_NORMCHECK: begin
              // strict bound_q: a coefficient exactly equal to the bound_q fails
              if (centered_abs(v) >= bound_q) norm_acc <= 1'b0;   // OR-reduce
              acc <= v;
            end
            C_PACK:        acc <= v;
            C_UNPACK:      acc <= v;
            default:       acc <= v;
          endcase
          cstate <= C_WR;
        end

        C_WR: begin
          if (mem_ready) begin
            if (idx == 9'(N - 1)) cstate <= C_DONE;
            else begin
              idx    <= idx + 9'h1;
              cstate <= C_RD;
            end
          end
        end

        C_DONE: cstate <= C_IDLE;
        C_ZERO: cstate <= C_IDLE;
        default: cstate <= C_IDLE;
      endcase
    end
  end

  assign canonical_ok = canonical_acc;
  assign norm_ok      = norm_acc;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      op_q <= '0;
      domain_q <= '0;
      d_comp_q <= '0;
      gamma2_sel_q <= '0;
      src_page_q <= '0;
      src2_page_q <= '0;
      dst_page_q <= '0;
      bound_q <= '0;
    end else if (zeroize_req) begin
      op_q <= '0;
      domain_q <= '0;
      d_comp_q <= '0;
      gamma2_sel_q <= '0;
      src_page_q <= '0;
      src2_page_q <= '0;
      dst_page_q <= '0;
      bound_q <= '0;
    end else if (start && cstate == C_IDLE) begin
      op_q <= op;
      domain_q <= domain;
      d_comp_q <= d_comp;
      gamma2_sel_q <= gamma2_sel;
      src_page_q <= src_page;
      src2_page_q <= src2_page;
      dst_page_q <= dst_page;
      bound_q <= bound;
    end
  end

endmodule

`endif // PQC_CODEC_SV
