// ============================================================================
// pqc_desc_fetch - AXI4 read of the 128-byte command descriptor
//
// Issues a single beat-aligned INCR read of exactly DESC_BYTES and streams the
// captured bytes to the command frontend one byte per cycle, in memory order.
// The descriptor address is 128-byte aligned by contract, so no unaligned
// handling is required here.
//
// Implements (LLD.BUF.PQC.FE.DESC): the descriptor is fetched atomically before
// validation; the frontend assembles the shadow and checks its CRC.
// ============================================================================
`ifndef PQC_DESC_FETCH_SV
`define PQC_DESC_FETCH_SV

module pqc_desc_fetch #(
  parameter int unsigned DATA_WIDTH = 128,
  parameter int unsigned ADDR_WIDTH = 40,
  parameter int unsigned DESC_BYTES = 128,
  parameter logic [ADDR_WIDTH-1:0] WIN_BASE = '0,
  parameter logic [ADDR_WIDTH-1:0] WIN_LIMIT = {ADDR_WIDTH{1'b1}}
) (
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic                    start,
  input  logic [ADDR_WIDTH-1:0]   addr,
  output logic                    busy,
  output logic                    done,
  output logic                    error,

  // AXI4 read channel
  output logic                    m_ar_valid,
  input  logic                    m_ar_ready,
  output logic [ADDR_WIDTH-1:0]   m_ar_addr,
  output logic [7:0]              m_ar_len,
  output logic [2:0]              m_ar_prot,
  input  logic                    m_r_valid,
  output logic                    m_r_ready,
  input  logic [DATA_WIDTH-1:0]   m_r_data,
  input  logic [1:0]              m_r_resp,
  input  logic                    m_r_last,

  // byte stream to the frontend
  output logic [7:0]              desc_data,
  output logic [7:0]              desc_data_idx,
  output logic                    desc_data_valid,

  input  logic                    zeroize_req,
  output logic                   zeroize_done
);

  localparam int unsigned STRB_W  = DATA_WIDTH / 8;
  localparam int unsigned NBEATS  = (DESC_BYTES + STRB_W - 1) / STRB_W;

  typedef enum logic [2:0] { F_IDLE, F_AR, F_RX, F_EMIT, F_DONE, F_ERR, F_DRAIN } fst_e;
  fst_e fstate;

  logic [ADDR_WIDTH:0] entry_last;
  logic entry_ok;
  assign entry_last = {1'b0,addr} + (ADDR_WIDTH+1)'(DESC_BYTES-1);
  assign entry_ok = addr[6:0] == 0 && addr >= WIN_BASE &&
                    !entry_last[ADDR_WIDTH] && entry_last <= {1'b0,WIN_LIMIT};
  logic cancel_q;
  logic [ADDR_WIDTH-1:0] addr_q;
  assign zeroize_done = cancel_q && fstate == F_IDLE;
  logic [7:0]          beat_cnt;
  logic [7:0]          emit_idx;
  logic [DATA_WIDTH-1:0] hold;
  logic [7:0]          hold_bytes;

  assign busy      = (fstate != F_IDLE);
  assign done      = (fstate == F_DONE);
  assign error     = (fstate == F_ERR);

  assign m_ar_valid = (fstate == F_AR);
  assign m_ar_addr  = addr_q;
  assign m_ar_len   = 8'(NBEATS - 1);
  assign m_ar_prot  = 3'b000;            // data access, secure, privileged-less
  assign m_r_ready  = (fstate == F_RX) || (fstate == F_DRAIN);

  assign desc_data       = hold[emit_idx*8 +: 8];
  assign desc_data_idx   = 8'((beat_cnt - 1) * STRB_W) + emit_idx;
  assign desc_data_valid = (fstate == F_EMIT) && !zeroize_req && !cancel_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fstate     <= F_IDLE;
      addr_q     <= '0;
      cancel_q <= 0;
      beat_cnt   <= 8'h0;
      emit_idx   <= 8'h0;
      hold       <= '0;
      hold_bytes <= 8'h0;
    end else if (zeroize_req || cancel_q) begin
      cancel_q <= 1;
      hold <= 0;
      // Keep an offered AR address stable until its handshake. Everything
      // else is scratch and can be wiped while the external read drains.
      if (fstate != F_AR) addr_q <= '0;
      beat_cnt <= '0;
      emit_idx <= '0;
      hold_bytes <= '0;
      case (fstate)
        F_AR: if (m_ar_ready) fstate <= F_RX;
        F_RX, F_DRAIN: if (m_r_valid && m_r_last) fstate <= F_IDLE;
        F_EMIT: fstate <= (beat_cnt == NBEATS) ? F_IDLE : F_RX;
        default: fstate <= F_IDLE;
      endcase
      if (!zeroize_req && fstate == F_IDLE) cancel_q <= 0;
    end else begin
      unique case (fstate)
        F_IDLE: begin
          if (start) begin
            addr_q <= addr;
            beat_cnt <= 8'h0;
            emit_idx <= 8'h0;
            fstate   <= entry_ok ? F_AR : F_ERR;
          end
        end

        F_AR: if (m_ar_ready) fstate <= F_RX;

        F_RX: begin
          if (m_r_valid && m_r_ready) begin
            if ((m_r_resp != 2'b00) || (m_r_last != (beat_cnt == NBEATS-1))) begin
              fstate <= m_r_last ? F_ERR : F_DRAIN;
            end else begin
              hold       <= m_r_data;
              hold_bytes <= (beat_cnt == 8'(NBEATS-1))
                            ? 8'(DESC_BYTES - (NBEATS-1)*STRB_W)
                            : 8'(STRB_W);
              emit_idx   <= 8'h0;
              beat_cnt   <= beat_cnt + 8'h1;
              fstate     <= F_EMIT;
            end
          end
        end

        F_EMIT: begin
          if (emit_idx + 8'h1 == hold_bytes) begin
            if (beat_cnt == 8'(NBEATS)) fstate <= F_DONE;
            else                        fstate <= F_RX;
          end else begin
            emit_idx <= emit_idx + 8'h1;
          end
        end

        F_DRAIN: if (m_r_valid && m_r_last) fstate <= F_ERR;
        F_DONE: if (!start) fstate <= F_IDLE;
        F_ERR:  if (!start) fstate <= F_IDLE;
        default: fstate <= F_IDLE;
      endcase
    end
  end

endmodule

`endif // PQC_DESC_FETCH_SV
