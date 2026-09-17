// ============================================================================
// pqc_keccak - Keccak-f[1600] permutation with SHA3/SHAKE streaming interface
//
// Implements:
//   * Keccak-f[1600] 24 rounds, configurable ROUNDS_PER_CYCLE (1 or 2)
//   * SHA3-256 / SHA3-512 / SHAKE128 / SHAKE256 rate selection
//   * hardware padding and domain separation
//   * two independent contexts (message absorb + XOF squeeze) sharing one
//     permutation datapath
//   * full state zeroization on a synchronous request
//
// PPA notes (LLD.PPA.PQC.KECCAK):
//   * single permutation datapath (area) with folded rounds per cycle (timing)
//   * enable is gated only by public state (start/valid/last), never by secrets
// ============================================================================
`ifndef PQC_KECCAK_SV
`define PQC_KECCAK_SV

module pqc_keccak #(
  parameter int unsigned ROUNDS_PER_CYCLE = 2
) (
  input  logic         clk,
  input  logic         rst_n,

  // command interface
  input  logic         start,
  input  logic [2:0]   function_id,   // keccak_func_e
  input  logic         ctx_sel,       // 0 = message context, 1 = XOF context
  input  logic [31:0]  out_len,       // squeeze byte count (SHAKE)

  // absorb byte stream
  input  logic         in_valid,
  output logic         in_ready,
  input  logic [7:0]   in_data,
  input  logic         in_last,

  // squeeze byte stream
  output logic         out_valid,
  input  logic         out_ready,
  output logic [7:0]   out_data,
  output logic         out_last,

  // status
  output logic         busy,
  output logic         done,

  // zeroize (independent synchronous path)
  input  logic         zeroize_req,
  output logic         zeroize_done
);

  import pqc_pkg::*;
  logic [2:0] function_id_q;
  logic [0:0] ctx_sel_q;
  logic [31:0] out_len_q;


  localparam int unsigned ROUNDS_TOTAL = 24;

  // ---------------------------------------------------------------------------
  // Rate and padding suffix per function
  // ---------------------------------------------------------------------------
  logic [9:0] rate_bytes;
  logic [7:0] pad_suffix;

  always_comb begin
    unique case (function_id_q)
      KEC_SHA3_256: begin rate_bytes = 10'd136; pad_suffix = 8'h06; end
      KEC_SHA3_512: begin rate_bytes = 10'd72;  pad_suffix = 8'h06; end
      KEC_SHAKE128: begin rate_bytes = 10'd168; pad_suffix = 8'h1F; end
      KEC_SHAKE256: begin rate_bytes = 10'd136; pad_suffix = 8'h1F; end
      default:      begin rate_bytes = 10'd136; pad_suffix = 8'h06; end
    endcase
  end

  // ---------------------------------------------------------------------------
  // Permutation work state and the two retained contexts
  // ---------------------------------------------------------------------------
  logic [63:0] perm_state [0:24];
  logic [63:0] state_msg  [0:24];
  logic [63:0] state_xof  [0:24];

  logic [7:0]  absorb_cnt;
  logic [31:0] squeeze_cnt;
  logic [5:0]  round_cnt;

  typedef enum logic [2:0] {
    K_IDLE, K_ABSORB, K_PAD, K_PERMUTE, K_SQUEEZE, K_DONE, K_ZERO
  } kstate_e;
  kstate_e kstate;

  // ---------------------------------------------------------------------------
  // Rho offsets indexed by lane index (x + 5y)
  // ---------------------------------------------------------------------------
  function automatic logic [5:0] rho_of(input int unsigned idx);
    case (idx)
      0:  rho_of = 6'd0;  1:  rho_of = 6'd1;  2:  rho_of = 6'd62; 3:  rho_of = 6'd28;
      4:  rho_of = 6'd27; 5:  rho_of = 6'd36; 6:  rho_of = 6'd44; 7:  rho_of = 6'd6;
      8:  rho_of = 6'd55; 9:  rho_of = 6'd20; 10: rho_of = 6'd3;  11: rho_of = 6'd10;
      12: rho_of = 6'd43; 13: rho_of = 6'd25; 14: rho_of = 6'd39; 15: rho_of = 6'd41;
      16: rho_of = 6'd45; 17: rho_of = 6'd15; 18: rho_of = 6'd21; 19: rho_of = 6'd8;
      20: rho_of = 6'd18; 21: rho_of = 6'd2;  22: rho_of = 6'd61; 23: rho_of = 6'd56;
      default: rho_of = 6'd14;
    endcase
  endfunction

  function automatic logic [63:0] rotl64(input logic [63:0] v, input logic [5:0] n);
    if (n == 6'd0) rotl64 = v;
    else rotl64 = (v << n) | (v >> (64 - n));
  endfunction

  // ---------------------------------------------------------------------------
  // One Keccak-f round: theta, rho, pi, chi, iota
  //   A[x][y] is indexed as x + 5*y
  // ---------------------------------------------------------------------------
  function automatic void keccak_f_round(
    input  logic [63:0] a [0:24],
    input  logic [63:0] round_const,
    output logic [63:0] out [0:24]
  );
    logic [63:0] c [0:4];
    logic [63:0] d [0:4];
    logic [63:0] b [0:24];
    int unsigned x, y, xp, yp, idx, didx;
    for (x = 0; x < 5; x++) begin
      c[x] = a[x] ^ a[x+5] ^ a[x+10] ^ a[x+15] ^ a[x+20];
    end
    for (x = 0; x < 5; x++) begin
      d[x] = c[(x+4)%5] ^ rotl64(c[(x+1)%5], 6'd1);
    end
    // rho + pi: destination (x',y') = (y, 2x+3y)
    for (x = 0; x < 5; x++) begin
      for (y = 0; y < 5; y++) begin
        idx  = x + 5*y;
        xp   = y;
        yp   = (2*x + 3*y) % 5;
        didx = xp + 5*yp;
        b[didx] = rotl64(a[idx] ^ d[x], rho_of(idx));
      end
    end
    // chi
    for (x = 0; x < 5; x++) begin
      for (y = 0; y < 5; y++) begin
        out[x + 5*y] = b[x + 5*y] ^ ((~b[((x+1)%5) + 5*y]) & b[((x+2)%5) + 5*y]);
      end
    end
    out[0] = out[0] ^ round_const;
  endfunction

  // ---------------------------------------------------------------------------
  // Folded round datapath result
  // ---------------------------------------------------------------------------
  logic [63:0] folded_out [0:24];

  // Single shared Keccak round-constant table (used by the folded datapath).
  function automatic logic [63:0] round_const_of(input logic [5:0] r);
    case (r)
      6'd0:  round_const_of = 64'h0000000000000001;
      6'd1:  round_const_of = 64'h0000000000008082;
      6'd2:  round_const_of = 64'h800000000000808A;
      6'd3:  round_const_of = 64'h8000000080008000;
      6'd4:  round_const_of = 64'h000000000000808B;
      6'd5:  round_const_of = 64'h0000000080000001;
      6'd6:  round_const_of = 64'h8000000080008081;
      6'd7:  round_const_of = 64'h8000000000008009;
      6'd8:  round_const_of = 64'h000000000000008A;
      6'd9:  round_const_of = 64'h0000000000000088;
      6'd10: round_const_of = 64'h0000000080008009;
      6'd11: round_const_of = 64'h000000008000000A;
      6'd12: round_const_of = 64'h000000008000808B;
      6'd13: round_const_of = 64'h800000000000008B;
      6'd14: round_const_of = 64'h8000000000008089;
      6'd15: round_const_of = 64'h8000000000008003;
      6'd16: round_const_of = 64'h8000000000008002;
      6'd17: round_const_of = 64'h8000000000000080;
      6'd18: round_const_of = 64'h000000000000800A;
      6'd19: round_const_of = 64'h800000008000000A;
      6'd20: round_const_of = 64'h8000000080008081;
      6'd21: round_const_of = 64'h8000000000008080;
      6'd22: round_const_of = 64'h0000000080000001;
      default: round_const_of = 64'h8000000080008008;
    endcase
  endfunction

  // Apply up to ROUNDS_PER_CYCLE rounds combinationally into folded_out
  function automatic void fold_rounds(
    input  logic [63:0] a [0:24],
    input  logic [5:0]  base_round,
    output logic [63:0] o [0:24]
  );
    logic [63:0] tmp [0:24];
    logic [63:0] cur [0:24];
    int unsigned k;
    for (k = 0; k < 25; k++) cur[k] = a[k];
    for (k = 0; k < 2; k++) begin
      if (k < ROUNDS_PER_CYCLE) begin
        keccak_f_round(cur, round_const_of(base_round + k[5:0]), tmp);
        for (int unsigned j = 0; j < 25; j++) cur[j] = tmp[j];
      end
    end
    for (int unsigned j = 0; j < 25; j++) o[j] = cur[j];
  endfunction

  // ---------------------------------------------------------------------------
  // Streaming helpers
  // ---------------------------------------------------------------------------
  logic [7:0]  byte_lane;     // lane index for the current absorb byte
  logic [7:0]  squeeze_lane;  // lane index for the current squeeze byte
  logic [7:0]  pad_lane;

  logic [7:0]  sqz_blk_cnt;   // byte offset inside the current squeeze block
  logic        sqz_filled;    // a squeeze byte is buffered and valid
  logic        sqz_ctx;       // pending squeeze byte belongs to this block
  logic        round_again;   // current permutation is an extra XOF block
  logic        pad_after_block;
  logic        absorb_more;   // after this permutation, keep absorbing

  // Padding byte offset is the position *after* the last absorbed byte.
  logic [7:0] pad_off;
  logic [7:0] pad_byte_lane;   // lane holding the pad10*1 suffix
  logic [7:0] pad_last_lane;   // lane holding the final rate bit

  // Block-internal byte counter. absorb_cnt is the byte offset inside the
  // current rate block [0, rate_bytes-1]; squeeze_cnt is the byte offset inside
  // the current squeeze block. Keeping them block-local (instead of counting up
  // over the whole message/output) is what makes multi-block absorb and long
  // XOF output both terminate correctly.
  always_comb begin
    byte_lane     = absorb_cnt[7:3];
    squeeze_lane  = sqz_blk_cnt[7:3];
    pad_off       = absorb_cnt;
    pad_byte_lane = pad_off[7:3];
    pad_last_lane = 8'((rate_bytes - 10'd1) >> 3);
    pad_lane      = pad_last_lane;
  end

  // `out_valid` is asserted only when a byte is actually buffered and ready to
  // be consumed, so a standard `valid && ready` consumer never samples a stale
  // or not-yet-loaded byte.
  assign in_ready  = rst_n && !zeroize_req && (kstate == K_ABSORB);
  assign out_valid = rst_n && !zeroize_req && (kstate == K_SQUEEZE) && sqz_filled;
  assign busy      = (kstate != K_IDLE) && (kstate != K_DONE) && (kstate != K_ZERO);
  assign done      = rst_n && !zeroize_req && (kstate == K_DONE);

  // Shift one byte into its little-endian bit position inside a lane.
  // `off` is the byte index within the lane (0..7).
  function automatic logic [63:0] byte_shifted(input logic [7:0] off, input logic [7:0] b);
    return {56'h0, b} << {off[2:0], 3'b000};
  endfunction

  // XOR one byte into a context lane (little-endian bit order)
  function automatic logic [63:0] xor_byte(input logic [63:0] lane, input logic [7:0] off, input logic [7:0] b);
    return lane ^ byte_shifted(off, b);
  endfunction

  // ---------------------------------------------------------------------------
  // Main control
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // Absorb: XOR one byte into the selected context. `last` requests padding of
  // the current block. `block_full` requests a permutation of the current block
  // followed by a return to absorb (multi-block messages).
  // ---------------------------------------------------------------------------
  task automatic absorb_byte(input logic [7:0] b);
    if (ctx_sel_q) state_xof[byte_lane] <= xor_byte(state_xof[byte_lane], absorb_cnt, b);
    else         state_msg[byte_lane] <= xor_byte(state_msg[byte_lane], absorb_cnt, b);
  endtask

  // Load the selected context into the permutation register, folding in the byte
  // that is being accepted on this very edge (non-blocking writes of the context
  // have not taken effect yet, so the byte is applied to the loaded copy).
  task automatic load_perm_with(input logic [7:0] b, input logic apply_byte);
    for (int unsigned i = 0; i < 25; i++) begin
      perm_state[i] <= ctx_sel_q ? state_xof[i] : state_msg[i];
    end
    if (apply_byte) begin
      perm_state[byte_lane] <= (ctx_sel_q ? state_xof[byte_lane] : state_msg[byte_lane])
                             ^ byte_shifted(absorb_cnt, b);
    end
  endtask

  // Write the permuted state back into the selected context.
  task automatic store_perm();
    for (int unsigned i = 0; i < 25; i++) begin
      if (ctx_sel_q) state_xof[i] <= perm_state[i];
      else         state_msg[i] <= perm_state[i];
    end
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      kstate       <= K_IDLE;
      absorb_cnt   <= 8'h0;
      squeeze_cnt  <= 32'h0;
      sqz_blk_cnt  <= 8'h0;
      sqz_filled   <= 1'b0;
      round_cnt    <= 6'h0;
      round_again  <= 1'b0;
      absorb_more <= 1'b0;
      pad_after_block <= 1'b0;
      out_data     <= 8'h0;
      out_last     <= 1'b0;
      zeroize_done <= 1'b0;
      for (int unsigned i = 0; i < 25; i++) begin
        perm_state[i] <= 64'h0;
        state_msg[i]  <= 64'h0;
        state_xof[i]  <= 64'h0;
      end
    end else begin
      zeroize_done <= 1'b0;

      if (zeroize_req) begin
        zeroize_done <= 1'b1;
        out_data <= '0;
        absorb_more <= 1'b0;
        pad_after_block <= 1'b0;
        kstate      <= K_ZERO;
        absorb_cnt  <= 8'h0;
        squeeze_cnt <= 32'h0;
        sqz_blk_cnt <= 8'h0;
        sqz_filled  <= 1'b0;
        round_cnt   <= 6'h0;
        round_again <= 1'b0;
        out_last    <= 1'b0;
        for (int unsigned i = 0; i < 25; i++) begin
          perm_state[i] <= 64'h0;
          state_msg[i]  <= 64'h0;
          state_xof[i]  <= 64'h0;
        end
      end else begin
        // pending squeeze byte is consumed on valid && ready
        if ((kstate == K_SQUEEZE) && sqz_filled && out_ready) begin
          sqz_filled <= 1'b0;
        end

        unique case (kstate)
          K_IDLE: begin
            if (start) begin
              absorb_cnt  <= 8'h0;
              squeeze_cnt <= 32'h0;
              sqz_blk_cnt <= 8'h0;
              sqz_filled  <= 1'b0;
              round_cnt   <= 6'h0;
              round_again <= 1'b0;
              for (int unsigned i = 0; i < 25; i++) begin
                if (ctx_sel) state_xof[i] <= 64'h0;
                else         state_msg[i] <= 64'h0;
              end
              kstate <= K_ABSORB;
            end
          end

          // ------------------------------------------------ multi-block absorb
          K_ABSORB: begin
            // in_last without in_valid is an explicit empty/end marker.
            if (in_valid || in_last) begin
              if (in_valid && ((absorb_cnt + 8'h1) == rate_bytes[7:0])) begin
                load_perm_with(in_data, 1'b1);
                absorb_cnt <= 0;
                round_cnt <= 0;
                absorb_more <= !in_last;
                pad_after_block <= in_last;
                round_again <= 0;
                kstate <= K_PERMUTE;
              end else if (in_last) begin
                load_perm_with(in_data, in_valid);
                if (in_valid) absorb_cnt <= absorb_cnt + 1'b1;
                kstate <= K_PAD;
              end else begin
                absorb_byte(in_data);
                absorb_cnt <= absorb_cnt + 1'b1;
              end
            end
          end

          K_PAD: begin
            // pad10*1: domain suffix at the first free byte, final bit in the
            // last byte of the rate. Both may land in the same lane.
            logic [63:0] suff_mask;
            logic [63:0] last_mask;
            suff_mask = byte_shifted(pad_off[2:0], pad_suffix);
            last_mask = byte_shifted(8'((rate_bytes - 10'd1) & 10'h7), 8'h80);
            if (pad_byte_lane == pad_last_lane) begin
              perm_state[pad_last_lane] <= perm_state[pad_last_lane] ^ suff_mask ^ last_mask;
            end else begin
              perm_state[pad_byte_lane] <= perm_state[pad_byte_lane] ^ suff_mask;
              perm_state[pad_last_lane] <= perm_state[pad_last_lane] ^ last_mask;
            end
            round_cnt   <= 6'h0;
            round_again <= 1'b0;
            absorb_more <= 1'b0;
            kstate      <= K_PERMUTE;
          end

          K_PERMUTE: begin
            fold_rounds(perm_state, round_cnt, folded_out);
            for (int i=0; i<25; i++) perm_state[i] <= folded_out[i];
            if (round_cnt + ROUNDS_PER_CYCLE >= ROUNDS_TOTAL) begin
              for (int i=0; i<25; i++) begin
                if (ctx_sel_q) state_xof[i] <= folded_out[i];
                else state_msg[i] <= folded_out[i];
              end
              round_again <= 0;
              if (pad_after_block) begin
                pad_after_block <= 0;
                kstate <= K_PAD;
              end else if (absorb_more) begin
                absorb_more <= 0;
                kstate <= K_ABSORB;
              end else begin
                sqz_blk_cnt <= 0;
                sqz_filled <= 0;
                kstate <= K_SQUEEZE;
              end
            end else round_cnt <= round_cnt + ROUNDS_PER_CYCLE;
          end

          K_SQUEEZE: begin : squeeze_step
            logic [31:0] next_count, limit;
            logic [7:0] next_offset;
            limit = (out_len_q == 0) ? 32'(rate_bytes) : out_len_q;
            // Replace a consumed byte on the same edge. Hold all outputs on stall.
            if (!sqz_filled || out_ready) begin
              next_count = squeeze_cnt + (sqz_filled ? 1 : 0);
              next_offset = sqz_blk_cnt + (sqz_filled ? 1 : 0);
              squeeze_cnt <= next_count;
              sqz_blk_cnt <= next_offset;
              if (next_count >= limit) begin
                sqz_filled <= 0;
                kstate <= K_DONE;
              end else if (next_offset == rate_bytes) begin
                sqz_filled <= 0;
                round_cnt <= 0;
                round_again <= 1;
                kstate <= K_PERMUTE;
              end else begin
                out_data <= 8'(perm_state[next_offset[7:3]] >> {next_offset[2:0],3'b000});
                out_last <= (next_count + 1 == limit);
                sqz_filled <= 1;
              end
            end
          end

          K_DONE: begin
            kstate <= K_IDLE;
          end

          K_ZERO: begin
            zeroize_done <= 1'b1;
            kstate       <= K_IDLE;
          end

          default: kstate <= K_IDLE;
        endcase
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      function_id_q <= '0;
      ctx_sel_q <= '0;
      out_len_q <= '0;
    end else if (zeroize_req) begin
      function_id_q <= '0;
      ctx_sel_q <= '0;
      out_len_q <= '0;
    end else if (start && kstate == K_IDLE) begin
      function_id_q <= function_id;
      ctx_sel_q <= ctx_sel;
      out_len_q <= out_len;
    end
  end

endmodule

`endif // PQC_KECCAK_SV
