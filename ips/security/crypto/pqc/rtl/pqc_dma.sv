// ============================================================================
// pqc_dma - AXI4 master data mover with range checks, backpressure and
//           internal-buffer beat split / assemble
//
// Implements (LLD.IF.PQC.DMA.AXI, LLD.ERR.PQC.DMA):
//   * INCR bursts that never cross a 4 KiB boundary (AXI4 legality)
//   * IP-internal address window, alignment and overflow checking performed
//     before any external request is issued
//   * security/privilege attributes carried on every request on the full 3-bit
//     PROT field (privileged, non-secure, instruction)
//   * every internal buffer access waits for buf_ready, so a stalled buffer
//     neither drops nor duplicates a word
//   * wide AXI read beats are split into internal buffer words, and internal
//     words are assembled back into write beats, so data is not truncated when
//     DATA_WIDTH differs from the internal word width
//   * the final WSTRB of a partial-length transfer masks the invalid bytes
//   * unaligned starts are rejected up front rather than silently corrected
//   * RRESP/BRESP and m_r_last are checked against the expected beat count
//
// Accounting model
//   total_left      bytes still to move in the whole transfer
//   nbeats          AXI beats in the current burst (<= 256, boundary limited)
//   burst_left      bytes in the current burst
//   cur_beat_bytes  bytes of the beat currently being packed / assembled
// Internal buffer words are indexed linearly from buf_ptr; the address is
// advanced one beat at a time so a new 4 KiB burst starts at the right place.
// Note: `% WORD_B` uses a power-of-two constant divisor and maps to bit
// selection, not a divider.
// ============================================================================
`ifndef PQC_DMA_SV
`define PQC_DMA_SV

module pqc_dma #(
  parameter int unsigned DATA_WIDTH = 128,
  parameter int unsigned ADDR_WIDTH = 40,
  parameter int unsigned WORD_WIDTH = 32,
  parameter int unsigned LOCAL_WORDS = 65536,
  // Address window the IP is allowed to touch; an access outside it is denied
  // before any external request is issued.
  parameter logic [ADDR_WIDTH-1:0] WIN_BASE  = '0,
  parameter logic [ADDR_WIDTH-1:0] WIN_LIMIT = {ADDR_WIDTH{1'b1}}
) (
  input  logic                  clk,
  input  logic                  rst_n,

  // descriptor-side request
  input  logic                  xfer_req,
  input  logic                  xfer_we,
  input  logic [ADDR_WIDTH-1:0] xfer_addr,
  input  logic [63:0]           xfer_len,
  input  logic                  xfer_secure,
  input  logic                  xfer_priv,
  output logic                  xfer_done,
  output logic                  xfer_error,

  // internal buffer port
  output logic                  buf_req,
  output logic                  buf_we,
  output logic [15:0]           buf_addr,
  output logic [WORD_WIDTH-1:0] buf_wdata,
  output logic [WORD_WIDTH/8-1:0] buf_wstrb,
  input  logic [WORD_WIDTH-1:0] buf_rdata,
  input  logic                  buf_ready,

  // AXI4 master (flattened subset used by the IP)
  output logic                  m_ar_valid,
  input  logic                  m_ar_ready,
  output logic [ADDR_WIDTH-1:0] m_ar_addr,
  output logic [7:0]            m_ar_len,
  output logic [2:0]            m_ar_prot,

  input  logic                  m_r_valid,
  output logic                  m_r_ready,
  input  logic [DATA_WIDTH-1:0] m_r_data,
  input  logic [1:0]            m_r_resp,
  input  logic                  m_r_last,

  output logic                  m_aw_valid,
  input  logic                  m_aw_ready,
  output logic [ADDR_WIDTH-1:0] m_aw_addr,
  output logic [7:0]            m_aw_len,
  output logic [2:0]            m_aw_prot,

  output logic                  m_w_valid,
  input  logic                  m_w_ready,
  output logic [DATA_WIDTH-1:0] m_w_data,
  output logic [DATA_WIDTH/8-1:0] m_w_strb,
  output logic                  m_w_last,

  input  logic                  m_b_valid,
  output logic                  m_b_ready,
  input  logic [1:0]            m_b_resp,

  input  logic                  zeroize_req,
  output logic                 zeroize_done
);

  import pqc_pkg::*;

  localparam int unsigned STRB_W = DATA_WIDTH / 8;
  localparam int unsigned WORD_B = WORD_WIDTH / 8;

  typedef enum logic [4:0] {
    D_IDLE, D_CHECK, D_AR, D_R_RX, D_R_PACK, D_R_WR, D_R_FLUSH, D_R_END,
    D_AW, D_W_FETCH, D_W_TX, D_B, D_DONE, D_ERR, D_CLEAR, D_ZERO, D_R_DRAIN
  } dst_e;
  dst_e dstate;

  logic [ADDR_WIDTH-1:0] cur_addr;
  logic [63:0]           total_left;
  logic [8:0]            nbeats;
  logic [63:0]           burst_left;
  logic [63:0]           cur_beat_bytes;
  logic [7:0]            beat_cnt;
  logic [15:0]           buf_ptr;

  // read-side unpack / pack
  logic [DATA_WIDTH-1:0] rx_hold;
  logic [7:0]            rx_bytes;
  logic [7:0]            rx_pos;
  logic [WORD_WIDTH-1:0] fill;
  logic [WORD_B-1:0] fill_strb;

  // write-side assembly
  logic [DATA_WIDTH-1:0] stage_reg;
  logic [7:0]            stage_cnt;

  // ---------------------------------------------------------------------------
  // 4 KiB boundary split and burst geometry
  // ---------------------------------------------------------------------------
  function automatic logic [63:0] burst_bytes_of(
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [63:0] remaining
  );
    logic [ADDR_WIDTH-1:0] to_boundary;
    to_boundary = 13'h1000 - {1'b0, addr[11:0]};
    return (remaining < 64'(to_boundary)) ? remaining : 64'(to_boundary);
  endfunction

  function automatic logic [8:0] nbeats_of(input logic [63:0] bytes);
    logic [63:0] beats;
    beats = (bytes + 64'(STRB_W) - 64'h1) / 64'(STRB_W);
    if (beats > 64'd256) beats = 64'd256;
    return 9'(beats);
  endfunction

  function automatic logic [63:0] beat_bytes_of(input logic [63:0] left);
    return (left > 64'(STRB_W)) ? 64'(STRB_W) : left;
  endfunction

  // ---------------------------------------------------------------------------
  // Address range / window / overflow check (before any external access)
  // ---------------------------------------------------------------------------
  logic addr_ok;
  logic align_ok;
  logic [64:0] xfer_end;
  logic we_q, secure_q, priv_q;
  logic cancel_q, cancel_empty;
  assign zeroize_done = (dstate == D_ZERO);
  logic request_ok_q;
  always_comb begin
    xfer_end = 65'(xfer_addr) + 65'(xfer_len) - 65'd1;
    align_ok = (xfer_addr[$clog2(STRB_W)-1:0] == '0);  // beat-aligned start
    addr_ok  = (xfer_len != 64'h0) && (xfer_len <= 64'(LOCAL_WORDS)*WORD_B) &&
               align_ok &&
               (xfer_addr >= WIN_BASE) &&
               (xfer_end <= {1'b0, WIN_LIMIT});
  end

  // ---------------------------------------------------------------------------
  // Outputs
  // ---------------------------------------------------------------------------
  assign xfer_done  = rst_n && !zeroize_req && !cancel_q && (dstate == D_DONE);
  assign xfer_error = rst_n && !zeroize_req && !cancel_q && (dstate == D_ERR);

  assign m_ar_valid = (dstate == D_AR);
  assign m_ar_addr  = cur_addr;
  assign m_ar_len   = 8'(nbeats - 9'h1);
  assign m_ar_prot  = {1'b0, !secure_q, priv_q};

  assign m_aw_valid = (dstate == D_AW);
  assign m_aw_addr  = cur_addr;
  assign m_aw_len   = 8'(nbeats - 9'h1);
  assign m_aw_prot  = {1'b0, !secure_q, priv_q};

  assign m_r_ready  = (dstate == D_R_RX) || (dstate == D_R_DRAIN);

  assign m_w_valid  = (dstate == D_W_TX);
  assign m_w_data   = stage_reg;
  assign m_w_strb   = cancel_empty ? '0 : (cur_beat_bytes >= 64'(STRB_W))
                      ? {STRB_W{1'b1}}
                      : (({{(STRB_W-1){1'b0}}, 1'b1} << cur_beat_bytes[6:0]) - 1'b1);
  assign m_w_last   = (beat_cnt == 8'(nbeats - 9'h1));

  assign m_b_ready  = (dstate == D_B);

  assign buf_req    = rst_n && !zeroize_req && !cancel_q && ((dstate == D_R_WR) || (dstate == D_R_FLUSH) ||
                      (dstate == D_W_FETCH && stage_cnt < cur_beat_bytes));
  assign buf_we     = (dstate == D_R_WR) || (dstate == D_R_FLUSH);
  assign buf_addr   = buf_ptr;
  assign buf_wdata  = fill;
  assign buf_wstrb  = buf_req && buf_we ? fill_strb : '0;

  // ---------------------------------------------------------------------------
  // Sequencing
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dstate         <= D_IDLE;
      cancel_q <= 0; cancel_empty <= 0;
      we_q <= 0; secure_q <= 0; priv_q <= 0; request_ok_q <= 0;
      cur_addr       <= '0;
      total_left     <= 64'h0;
      nbeats         <= 9'h0;
      burst_left     <= 64'h0;
      cur_beat_bytes <= 64'h0;
      beat_cnt       <= 8'h0;
      buf_ptr        <= 16'h0;
      rx_pos         <= 8'h0;
      rx_bytes       <= 8'h0;
      rx_hold        <= '0;
      fill           <= '0;
      fill_strb <= '0;
      stage_reg      <= '0;
      stage_cnt      <= 8'h0;
    end else if (zeroize_req || cancel_q) begin
      cancel_q <= 1;
      fill <= 0; fill_strb <= '0; rx_hold <= 0;
      // Preserve already asserted AXI VALID/payload until its handshake.
      // Accepted reads are drained; remaining writes use zero strobes.
      case (dstate)
        D_AR: if (m_ar_ready) dstate <= D_R_RX;
        D_R_RX, D_R_DRAIN: if (m_r_valid && m_r_last) dstate <= D_CLEAR;
        D_R_PACK, D_R_WR, D_R_FLUSH, D_R_END:
          dstate <= (beat_cnt == nbeats-1) ? D_CLEAR : D_R_RX;
        D_AW: if (m_aw_ready) begin
          stage_reg <= 0; cancel_empty <= 1; dstate <= D_W_TX;
        end
        D_W_FETCH: begin stage_reg <= 0; cancel_empty <= 1; dstate <= D_W_TX; end
        D_W_TX: if (m_w_ready) begin
          stage_reg <= 0; cancel_empty <= 1;
          beat_cnt <= beat_cnt+1;
          if (m_w_last) dstate <= D_B;
        end
        D_B: if (m_b_valid) dstate <= D_CLEAR;
        D_CLEAR: begin
          // The acknowledgement state is reached only after every local field
          // has been wiped and all offered/outstanding bus transactions drained.
          we_q <= 0; secure_q <= 0; priv_q <= 0; request_ok_q <= 0;
          cur_addr <= 0; total_left <= 0; nbeats <= 0; burst_left <= 0;
          cur_beat_bytes <= 0; beat_cnt <= 0; buf_ptr <= 0;
          rx_pos <= 0; rx_bytes <= 0; rx_hold <= 0; fill <= 0;
          stage_reg <= 0; stage_cnt <= 0; cancel_empty <= 0;
          dstate <= D_ZERO;
        end
        D_ZERO: begin
          if (!zeroize_req) begin cancel_q <= 0; cancel_empty <= 0; dstate <= D_IDLE; end
        end
        default: begin stage_reg <= 0; dstate <= D_CLEAR; end
      endcase
    end else begin
      unique case (dstate)
        D_IDLE: begin
          if (xfer_req) begin
            we_q <= xfer_we; secure_q <= xfer_secure; priv_q <= xfer_priv;
            request_ok_q <= (xfer_len == 64'd0) || addr_ok;
            cur_addr   <= xfer_addr;
            total_left <= xfer_len;
            buf_ptr    <= 16'h0;
            beat_cnt   <= 8'h0;
            rx_pos     <= 8'h0;
            stage_cnt  <= 8'h0;
            dstate     <= D_CHECK;
          end
        end

        D_CHECK: begin
          if (!request_ok_q) begin
            dstate <= D_ERR;
          end else if (total_left == 64'd0) begin
            dstate <= D_DONE;
          end else begin
            burst_left     <= burst_bytes_of(cur_addr, total_left);
            nbeats         <= nbeats_of(burst_bytes_of(cur_addr, total_left));
            cur_beat_bytes <= beat_bytes_of(total_left);
            beat_cnt       <= 8'h0;
            stage_cnt      <= 8'h0;
            dstate         <= we_q ? D_AW : D_AR;
          end
        end

        D_AR: if (m_ar_ready) dstate <= D_R_RX;

        D_R_RX: begin
          if (m_r_valid && m_r_ready) begin
            // m_r_last must coincide with the last beat of the burst
            if ((m_r_resp != 2'b00) ||
                (m_r_last !== (beat_cnt == 8'(nbeats - 9'h1)))) begin
              dstate <= m_r_last ? D_ERR : D_R_DRAIN;
            end else begin
              rx_hold  <= m_r_data;
              rx_bytes <= cur_beat_bytes[7:0];
              rx_pos   <= 8'h0;
              dstate   <= D_R_PACK;
            end
          end
        end

        D_R_PACK: begin
          // Fixed word lanes replace byte-at-a-time packing. Mask only the tail.
          if (rx_pos < rx_bytes) begin
            for (int k=0; k<WORD_B; k++) begin
              fill[k*8 +: 8] <= ((rx_pos+k) < rx_bytes) ? rx_hold[(rx_pos+k)*8 +: 8] : 8'h0;
              fill_strb[k] <= (rx_pos+k) < rx_bytes;
            end
            rx_pos <= ((rx_pos+WORD_B) > rx_bytes) ? rx_bytes : rx_pos+WORD_B;
            dstate <= D_R_WR;
          end else dstate <= D_R_END;
        end

        D_R_WR: begin
          if (buf_ready) begin
            buf_ptr <= buf_ptr + 16'h1;
            fill    <= '0;
            fill_strb <= '0;
            dstate  <= D_R_PACK;
          end
        end

        D_R_FLUSH: begin
          if (buf_ready) begin
            buf_ptr <= buf_ptr + 16'h1;
            fill    <= '0;
            fill_strb <= '0;
            dstate  <= D_R_END;
          end
        end

        D_R_END: begin
          total_left     <= total_left - 64'(rx_bytes);
          burst_left     <= burst_left - 64'(rx_bytes);
          beat_cnt       <= beat_cnt + 8'h1;
          cur_addr       <= cur_addr + ADDR_WIDTH'(rx_bytes);
          cur_beat_bytes <= beat_bytes_of(total_left - 64'(rx_bytes));
          if (beat_cnt == 8'(nbeats - 9'h1))
            dstate <= (total_left == 64'(rx_bytes)) ? D_DONE : D_CHECK;
          else
            dstate <= D_R_RX;
        end

        D_AW: if (m_aw_ready) dstate <= D_W_FETCH;

        D_W_FETCH: begin
          if (stage_cnt >= cur_beat_bytes[7:0]) begin
            dstate <= D_W_TX;
          end else if (buf_ready) begin
            for (int unsigned k = 0; k < WORD_B; k++) begin
              if ((stage_cnt + k) < cur_beat_bytes[7:0])
                stage_reg[(stage_cnt+k)*8 +: 8] <= buf_rdata[k*8 +: 8];
            end
            buf_ptr   <= buf_ptr + 16'h1;
            stage_cnt <= ((stage_cnt + 8'(WORD_B)) > cur_beat_bytes[7:0])
                         ? cur_beat_bytes[7:0] : (stage_cnt + 8'(WORD_B));
          end
        end

        D_W_TX: begin
          if (m_w_valid && m_w_ready) begin
            total_left     <= total_left - cur_beat_bytes;
            burst_left     <= burst_left - cur_beat_bytes;
            beat_cnt       <= beat_cnt + 8'h1;
            cur_addr       <= cur_addr + ADDR_WIDTH'(cur_beat_bytes);
            stage_cnt      <= 8'h0;
            stage_reg      <= '0;
            cur_beat_bytes <= beat_bytes_of(total_left - cur_beat_bytes);
            dstate         <= (beat_cnt == 8'(nbeats - 9'h1)) ? D_B : D_W_FETCH;
          end
        end

        D_B: begin
          if (m_b_valid && m_b_ready) begin
            if (m_b_resp != 2'b00)        dstate <= D_ERR;
            else if (total_left == 64'h0) dstate <= D_DONE;
            else                          dstate <= D_CHECK;   // next 4 KiB burst
          end
        end

        D_R_DRAIN: if (m_r_valid && m_r_last) dstate <= D_ERR;
        D_DONE: if (!xfer_req) dstate <= D_IDLE;
        D_ERR:  if (!xfer_req) dstate <= D_IDLE;
        D_ZERO: dstate <= D_IDLE;
        default: dstate <= D_IDLE;
      endcase
    end
  end

endmodule

`endif // PQC_DMA_SV