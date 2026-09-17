// ============================================================================
// pqc_sampler - rejection / CBD / Expand* / SampleInBall coefficient sampling
//
// Consumes the Keccak squeeze stream as a CONTINUOUS LSB-first bit stream and
// emits coefficients into polynomial pages. Rejected candidates are never
// written to a polynomial page.
//
// Implementation notes (FIPS 203 Alg. 7/8, FIPS 204 Alg. 29-34):
//   * a bit accumulator refills from squeeze bytes; extraction is LSB-first and
//     continuous, so a coefficient may straddle a byte boundary
//   * KEM uniform rejection sampling consumes a 3-byte group and considers BOTH
//     12-bit candidates d1 = b0 + 256*(b1 mod 16) and d2 = floor(b1/16) + 16*b2,
//     writing every accepted candidate in order
//   * a write is only advanced when the memory reports ready, so a stalled or
//     arbitrated store never drops a sample
//
// PPA notes: the bit accumulator is narrow and the unit shares the codec bank.
// ============================================================================
`ifndef PQC_SAMPLER_SV
`define PQC_SAMPLER_SV

module pqc_sampler (
  input  logic         clk,
  input  logic         rst_n,

  input  logic         start,
  input  logic [2:0]   mode,          // samp_mode_e
  input  logic         domain,        // 0 = KEM, 1 = DSA
  input  logic [7:0]   dst_page,
  input  logic [3:0]   eta,
  input  logic [6:0]   tau,           // DSA challenge weight: 39, 49 or 60
  input  logic [4:0]   gamma1_sel,    // DSA gamma1 bit count (17 or 19)
  output logic         busy,
  output logic         done,
  output logic         op_error,

  // squeeze stream in
  input  logic         sqz_valid,
  output logic         sqz_ready,
  input  logic [7:0]   sqz_data,

  // coefficient write port
  output logic         mem_req,
  output logic         mem_we,
  output logic [15:0]  mem_addr,
  output logic         [31:0] mem_wdata,
  input  logic         mem_ready,

  input  logic         zeroize_req
);

  import pqc_pkg::*;
  logic [2:0] mode_q;
  logic [7:0] dst_page_q;
  logic [3:0] eta_q;
  logic [4:0] gamma1_sel_q;


  localparam int unsigned N    = POLY_N;
  localparam int unsigned QKEM = 3329;

  typedef enum logic [3:0] {
    SP_IDLE, SP_GET, SP_WR, SP_DONE, SP_ZERO, SP_SIGNS, SP_BALL
  } spstate_e;
  spstate_e spstate;

  logic [63:0] signs;
  logic [3:0] sign_bytes;
  logic [8:0] ball_idx;
  logic [1:0] ball [0:255]; // 00=0, 01=+1, 11=-1
  logic [30:0] bitbuf;
  logic [4:0]  bitcnt;
  logic [8:0]  wr_idx;        // index of the coefficient currently written
  logic [8:0]  nxt_idx;       // index of the next coefficient to produce
  logic [1:0]  cand_phase;    // KEM candidate phase within the 3-byte group
  logic [7:0]  g_b0, g_b1;    // bytes of the current KEM group
  logic [11:0] pend_d2;       // second acceptable candidate held for the next write
  logic        pend_valid;
  logic [31:0] sample_val;
  logic        last_emitted;
  logic configuration_ok, error_q;

  always_comb begin
    configuration_ok = 1'b0;
    case (mode)
      SAMP_CBD_KEM: configuration_ok = !domain && (eta == 4'd2 || eta == 4'd3);
      SAMP_REJ_KEM: configuration_ok = !domain;
      SAMP_EXPAND_A: configuration_ok = domain;
      SAMP_EXPAND_S: configuration_ok = domain && (eta == 4'd2 || eta == 4'd4);
      SAMP_EXPAND_MASK: configuration_ok = domain && (gamma1_sel == 5'd17 || gamma1_sel == 5'd19);
      SAMP_IN_BALL: configuration_ok = domain && (tau == 7'd39 || tau == 7'd49 || tau == 7'd60);
      default: configuration_ok = 1'b0;
    endcase
  end
  assign op_error = rst_n && !zeroize_req && error_q;

  logic [4:0] bitcnt_need;
  always_comb begin
    unique case (mode_q)
      SAMP_CBD_KEM:     bitcnt_need = 5'(2 * eta_q);
      SAMP_EXPAND_S:    bitcnt_need = 5'd4;
      SAMP_EXPAND_A:    bitcnt_need = 5'd24;
      SAMP_EXPAND_MASK: bitcnt_need = gamma1_sel_q + 5'd1;
      SAMP_IN_BALL:     bitcnt_need = 5'd8;
      default:          bitcnt_need = 5'd8;
    endcase
  end

  // Bit-stream modes only consume a squeeze byte on cycles that refill the bit
  // accumulator; on the cycle that emits a coefficient the byte stream must be
  // paused. Presenting sqz_ready on emit cycles loses a byte (the producer
  // advances but the sampler does not consume), which shifts every following
  // coefficient. KEM byte modes consume a byte on every SP_GET cycle.
  logic refill_now;
  logic is_byte_mode;
  always_comb begin
    is_byte_mode = (mode_q == SAMP_REJ_KEM);
    if (is_byte_mode)
      // in byte modes a byte is consumed only while collecting the 3-byte group
      refill_now = !pend_valid;
    else
      refill_now = (bitcnt < bitcnt_need);
  end

  assign busy      = (spstate != SP_IDLE) && (spstate != SP_DONE) && (spstate != SP_ZERO);
  assign sqz_ready = rst_n && !zeroize_req &&
                     (((spstate == SP_GET) && refill_now && mode_q != SAMP_IN_BALL) ||
                      (spstate == SP_SIGNS) || (spstate == SP_BALL));
  assign mem_req   = rst_n && !zeroize_req && (spstate == SP_WR);
  assign mem_we    = mem_req;
  assign mem_addr  = {dst_page_q, 8'(wr_idx[7:0])};
  assign mem_wdata = sample_val;

  // centred binomial over 2*eta_q consecutive bits (LSB-first)
  function automatic logic [31:0] cbd(input logic [30:0] bits, input logic [3:0] e);
    logic signed [31:0] a, b;
    a = 0;
    b = 0;
    for (int unsigned i = 0; i < 4; i++) begin
      if (i < e) a = a + ($signed({31'h0, bits[i]}));
      if (i < e) b = b + ($signed({31'h0, bits[i + e]}));
    end
    // (a - b) encoded as a non-negative residue for storage
    cbd = (a >= b) ? 32'(a - b)
                   : 32'(32'd3329 + a - b);
  endfunction

  function automatic logic rej_accept(input logic [11:0] v);
    rej_accept = (32'(v) < 32'(QKEM));
  endfunction


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      spstate      <= SP_IDLE;
      signs <= 0; sign_bytes <= 0; ball_idx <= 0;
      bitbuf       <= 31'h0;
      bitcnt       <= 5'h0;
      wr_idx       <= 9'h0;
      nxt_idx      <= 9'h0;
      cand_phase   <= 2'h0;
      g_b0         <= 8'h0;
      g_b1         <= 8'h0;
      pend_d2      <= 12'h0;
      pend_valid   <= 1'b0;
      sample_val   <= 32'h0;
      last_emitted <= 1'b0;
      error_q <= 1'b0;
      for (int i=0;i<256;i++) ball[i] <= 0;
    end else if (zeroize_req) begin
      spstate      <= SP_ZERO;
      g_b0 <= 0; g_b1 <= 0; cand_phase <= 0;
      signs <= 0; sign_bytes <= 0; ball_idx <= 0;
      for (int i=0;i<256;i++) ball[i] <= 0;
      bitbuf       <= 31'h0;
      bitcnt       <= 5'h0;
      wr_idx       <= 9'h0;
      nxt_idx      <= 9'h0;
      pend_d2      <= 12'h0;
      pend_valid   <= 1'b0;
      sample_val   <= 32'h0;
      last_emitted <= 1'b0;
      error_q <= 1'b0;
    end else begin
      unique case (spstate)
        SP_IDLE: begin
          if (start) begin
            error_q <= !configuration_ok;
            bitbuf       <= 31'h0;
            bitcnt       <= 5'h0;
            wr_idx       <= 9'h0;
            nxt_idx      <= 9'h0;
            cand_phase   <= 2'h0;
            pend_valid   <= 1'b0;
            last_emitted <= 1'b0;
            if (!configuration_ok) spstate <= SP_DONE;
            else if (mode == SAMP_IN_BALL) begin
              signs <= 0; sign_bytes <= 0; ball_idx <= 256-tau;
              for (int i=0;i<256;i++) ball[i] <= 0;
              spstate <= SP_SIGNS;
            end else spstate <= SP_GET;
          end
        end

        // ------------------------------------------------------------------
        // produce the next coefficient (possibly after refilling bits)
        // ------------------------------------------------------------------
        SP_GET: begin
          if (mode_q == SAMP_REJ_KEM) begin
            if (pend_valid) begin
              // a group produced two acceptable candidates: emit the second one
              // now, before accepting more bytes
              sample_val <= {20'h0, pend_d2};
              pend_valid <= 1'b0;
              wr_idx     <= nxt_idx;
              last_emitted <= (nxt_idx == 9'(N-1));
              if (nxt_idx != 9'(N-1)) nxt_idx <= nxt_idx + 9'h1;
              spstate <= SP_WR;
            end else if (sqz_valid) begin
              if (cand_phase == 2'd0) begin
                g_b0       <= sqz_data;
                cand_phase <= 2'd1;
              end else if (cand_phase == 2'd1) begin
                g_b1       <= sqz_data;
                cand_phase <= 2'd2;
              end else begin
                logic [11:0] d1, d2;
                cand_phase <= 2'd0;
                // d1 = b0 + 256*(b1 mod 16), d2 = floor(b1/16) + 16*b2
                d1 = {4'h0, g_b0} + ({8'h0, g_b1[3:0]} << 8);
                d2 = {8'h0, g_b1[7:4]} + ({8'h0, sqz_data} << 4);
                if (rej_accept(d1)) begin
                  // remember d2 so the second acceptable candidate of the same
                  // group is not lost
                  pend_d2    <= d2;
                  pend_valid <= rej_accept(d2);
                  sample_val <= {20'h0, d1};
                  wr_idx     <= nxt_idx;
                  last_emitted <= (nxt_idx == 9'(N-1));
                  if (nxt_idx != 9'(N-1)) nxt_idx <= nxt_idx + 9'h1;
                  spstate <= SP_WR;
                end else if (rej_accept(d2)) begin
                  sample_val <= {20'h0, d2};
                  wr_idx     <= nxt_idx;
                  last_emitted <= (nxt_idx == 9'(N-1));
                  if (nxt_idx != 9'(N-1)) nxt_idx <= nxt_idx + 9'h1;
                  spstate <= SP_WR;
                end
              end
            end
          end else if (mode_q == SAMP_IN_BALL) begin
            sample_val <= (ball[nxt_idx] == 2'b11) ? 32'd8380416 : {31'd0,ball[nxt_idx][0]};
            wr_idx <= nxt_idx;
            last_emitted <= (nxt_idx == N-1);
            nxt_idx <= nxt_idx+1;
            spstate <= SP_WR;
          end else if (refill_now) begin
            if (sqz_valid) begin
              bitbuf <= bitbuf | (31'(sqz_data) << bitcnt);
              bitcnt <= bitcnt + 8;
            end
          end else begin : extract_sample
            logic accept_sample;
            logic signed [31:0] candidate;
            accept_sample = 1;
            candidate = 0;
            case (mode_q)
              SAMP_CBD_KEM: candidate = cbd(bitbuf, eta_q);
              SAMP_EXPAND_A: begin
                candidate = {9'd0,bitbuf[22:0]};
                accept_sample = (candidate < 8380417);
              end
              SAMP_EXPAND_S: begin
                if (eta_q == 2) begin
                  accept_sample = (bitbuf[3:0] < 15);
                  candidate = 2 - int'(bitbuf[3:0] % 5);
                end else begin
                  accept_sample = (eta_q == 4) && (bitbuf[3:0] < 9);
                  candidate = 4 - int'(bitbuf[3:0]);
                end
              end
              SAMP_EXPAND_MASK:
                candidate = (32'sd1 << gamma1_sel_q) - $signed(32'(bitbuf) & ((32'd1 << bitcnt_need)-1));
              default: accept_sample = 0;
            endcase
            bitbuf <= bitbuf >> bitcnt_need;
            bitcnt <= bitcnt-bitcnt_need;
            if (accept_sample) begin
              sample_val <= (candidate < 0) ? candidate + 8380417 : candidate;
              wr_idx <= nxt_idx;
              last_emitted <= (nxt_idx == N-1);
              if (nxt_idx != N-1) nxt_idx <= nxt_idx+1;
              spstate <= SP_WR;
            end
          end
        end

        SP_SIGNS: if (sqz_valid) begin
          signs[sign_bytes*8 +: 8] <= sqz_data;
          if (sign_bytes == 7) spstate <= SP_BALL;
          else sign_bytes <= sign_bytes+1;
        end
        SP_BALL: if (sqz_valid && (sqz_data <= ball_idx)) begin
          ball[ball_idx] <= ball[sqz_data];
          ball[sqz_data] <= signs[0] ? 2'b11 : 2'b01;
          signs <= signs >> 1;
          if (ball_idx == 255) spstate <= SP_GET;
          else ball_idx <= ball_idx+1;
        end

        // ------------------------------------------------------------------
        // write the coefficient, waiting for the store to accept it
        // ------------------------------------------------------------------
        SP_WR: begin
          if (mem_ready) begin
            if (last_emitted) spstate <= SP_DONE;
            else              spstate <= SP_GET;
          end
        end

        SP_DONE: spstate <= SP_IDLE;
        SP_ZERO: spstate <= SP_IDLE;
        default: spstate <= SP_IDLE;
      endcase
    end
  end

  // done is held until the next start so a level-sensitive waiter cannot miss
  // the completion window
  logic done_q;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) done_q <= 1'b0;
    else if (zeroize_req) done_q <= 1'b0;
    else if (spstate == SP_DONE) done_q <= 1'b1;
    else if (start) done_q <= 1'b0;
  end

  assign done = rst_n && !zeroize_req && ((spstate == SP_DONE) || done_q);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mode_q <= '0;
      dst_page_q <= '0;
      eta_q <= '0;
      gamma1_sel_q <= '0;
    end else if (zeroize_req) begin
      mode_q <= '0;
      dst_page_q <= '0;
      eta_q <= '0;
      gamma1_sel_q <= '0;
    end else if (start && spstate == SP_IDLE) begin
      mode_q <= mode;
      dst_page_q <= dst_page;
      eta_q <= eta;
      gamma1_sel_q <= gamma1_sel;
    end
  end

endmodule

`endif // PQC_SAMPLER_SV
