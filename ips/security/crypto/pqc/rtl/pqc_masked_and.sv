// LLD.MOD.PQC.KECCAK.MASK_AND: two-share HPC3+ with two register boundaries.
// Functional implementation; compositional/netlist leakage signoff is separate.
module pqc_masked_and #(
  parameter int unsigned WIDTH = 1,
  parameter int unsigned TOKEN_WIDTH = 32
) (
  input logic clk,
  input logic rst_n,
  input logic in_valid,
  output logic in_ready,
  input logic [WIDTH-1:0] a0, a1, b0, b1,
  input logic [WIDTH-1:0] random_r, random_s, random_m,
  input logic [TOKEN_WIDTH-1:0] in_token,
  output logic out_valid,
  input logic out_ready,
  output logic [WIDTH-1:0] c0, c1,
  output logic [TOKEN_WIDTH-1:0] out_token,
  input logic zeroize_req,
  output logic zeroize_done
);
  logic v1, v2, advance;
  logic [WIDTH-1:0] a0_q, a1_q, b0_q, b1_q;
  logic [WIDTH-1:0] u0_q, u1_q, d0_q, d1_q, m_q;
  logic [TOKEN_WIDTH-1:0] token_q;
  // One global, public enable freezes data and token at both boundaries.
  assign advance = !v2 || out_ready;
  assign in_ready = rst_n && !zeroize_req && advance;
  assign out_valid = rst_n && !zeroize_req && v2;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      v1 <= 1'b0; v2 <= 1'b0;
      a0_q <= '0; a1_q <= '0; b0_q <= '0; b1_q <= '0;
      u0_q <= '0; u1_q <= '0; d0_q <= '0; d1_q <= '0; m_q <= '0;
      token_q <= '0; out_token <= '0; c0 <= '0; c1 <= '0;
      zeroize_done <= 1'b0;
    end else if (zeroize_req) begin
      v1 <= 1'b0; v2 <= 1'b0;
      a0_q <= '0; a1_q <= '0; b0_q <= '0; b1_q <= '0;
      u0_q <= '0; u1_q <= '0; d0_q <= '0; d1_q <= '0; m_q <= '0;
      token_q <= '0; out_token <= '0; c0 <= '0; c1 <= '0;
      zeroize_done <= 1'b1;
    end else begin
      zeroize_done <= 1'b0;
      if (advance) begin
        v1 <= in_valid;
        v2 <= v1;
        if (in_valid) begin
          a0_q <= a0;
          a1_q <= a1;
          b0_q <= b1 ^ random_r;
          b1_q <= b0 ^ random_r;
          u0_q <= (a0 & random_r) ^ random_s;
          u1_q <= (a1 & random_r) ^ random_s;
          d0_q <= a0 & b0;
          d1_q <= a1 & b1;
          m_q <= random_m;
          token_q <= in_token;
        end
        if (v1) begin
          c0 <= d0_q ^ (a0_q & b0_q) ^ u0_q ^ m_q;
          c1 <= d1_q ^ (a1_q & b1_q) ^ u1_q ^ m_q;
          out_token <= token_q;
        end
      end
    end
  end
endmodule
