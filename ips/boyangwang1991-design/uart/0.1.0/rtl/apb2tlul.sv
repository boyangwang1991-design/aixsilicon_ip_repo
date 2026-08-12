// apb2tlul — APB4 slave → TL-UL master protocol adapter (UART APB 接入)
//
// Bridges an AMBA APB4 slave port to a TileLink Uncached Lightweight (TL-UL)
// master port, enabling APB host access to the TL-UL UART register block
// (uart_reg_top) WITHOUT modifying the UART core RTL.
//
// Design reference:
//   - FSM structure modeled after vyges/tlul-apb-adapter (Apache-2.0),
//     direction reversed (APB slave → TL-UL master).
//   - TL-UL bus-integrity fields (a_user.cmd_intg / data_intg) generated via
//     tlul_pkg::get_cmd_intg / get_data_intg so uart_reg_top's integrity
//     check (tlul_cmd_intg_chk) passes on normal access.
//
// Protocol timing (zero-wait):
//   Cycle 0: APB Setup phase (PSEL=1, PENABLE=0) → issue TL-UL request
//   Cycle 1..: TL-UL A channel accepted (a_valid & a_ready), wait D channel
//   Cycle N: TL-UL D valid → capture data/error
//   Cycle N+1: APB Access phase (PENABLE=1) → PREADY=1, PRDATA, PSLVERR
//
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module apb2tlul #(
  parameter int unsigned AW = 32,  // Address width (byte)
  parameter int unsigned DW = 32,  // Data width (must be 32)
  parameter int unsigned DBW = DW/8  // Data byte width
) (
  input  logic clk_i,     // System clock
  input  logic rst_ni,    // Active-low async reset

  // -------------------------------------------------------------------------
  // APB Slave Interface (host-facing)
  // -------------------------------------------------------------------------
  input  logic              psel_i,
  input  logic              penable_i,
  input  logic              pwrite_i,
  input  logic [AW-1:0]     paddr_i,
  input  logic [DW-1:0]     pwdata_i,
  input  logic [DBW-1:0]    pstrb_i,
  output logic [DW-1:0]     prdata_o,
  output logic              pready_o,
  output logic              pslverr_o,

  // -------------------------------------------------------------------------
  // TL-UL Master Interface (device-facing, drives uart_reg_top)
  // -------------------------------------------------------------------------
  output tlul_pkg::tl_h2d_t tl_o,
  input  tlul_pkg::tl_d2h_t tl_i
);

  import tlul_pkg::*;

  // -------------------------------------------------------------------------
  // Parameters
  // -------------------------------------------------------------------------
  localparam logic [2:0] TL_OP_PUT_FULL = 3'h0;
  localparam logic [2:0] TL_OP_GET      = 3'h4;
  localparam logic [2:0] TL_D_ACCESSACKDATA = 3'h1;

  // FSM state encoding (explicit, DC-friendly)
  localparam logic [1:0] ST_IDLE   = 2'b00;
  localparam logic [1:0] ST_WAIT_A = 2'b01;
  localparam logic [1:0] ST_WAIT_D = 2'b10;
  localparam logic [1:0] ST_DONE   = 2'b11;

  logic [1:0] state_q, state_d;

  // -------------------------------------------------------------------------
  // Request capture registers
  // -------------------------------------------------------------------------
  logic             req_write_q;
  logic [AW-1:0]    req_addr_q;
  logic [DW-1:0]    req_wdata_q;
  logic [DBW-1:0]   req_strb_q;
  logic [2:0]       req_opcode_q;

  // -------------------------------------------------------------------------
  // Response capture registers
  // -------------------------------------------------------------------------
  logic [DW-1:0]    rsp_rdata_q;
  logic             rsp_error_q;

  // -------------------------------------------------------------------------
  // State register
  // -------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) state_q <= ST_IDLE;
    else         state_q <= state_d;
  end

  // -------------------------------------------------------------------------
  // Request capture
  // -------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      req_write_q  <= 1'b0;
      req_addr_q   <= '0;
      req_wdata_q  <= '0;
      req_strb_q   <= '0;
      req_opcode_q <= '0;
    end else if (state_q == ST_IDLE && psel_i && !penable_i) begin
      req_write_q  <= pwrite_i;
      req_addr_q   <= paddr_i;
      req_wdata_q  <= pwdata_i;
      req_strb_q   <= pstrb_i;
      req_opcode_q <= pwrite_i ? TL_OP_PUT_FULL : TL_OP_GET;
    end
  end

  // -------------------------------------------------------------------------
  // Response capture
  // -------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rsp_rdata_q <= '0;
      rsp_error_q <= 1'b0;
    end else if (state_q == ST_WAIT_D && tl_i.d_valid) begin
      rsp_rdata_q <= tl_i.d_data;
      rsp_error_q <= tl_i.d_error;
    end
  end

  // -------------------------------------------------------------------------
  // Next-state logic
  // -------------------------------------------------------------------------
  always_comb begin
    state_d = state_q;
    case (state_q)
      ST_IDLE:   if (psel_i && !penable_i)   state_d = ST_WAIT_A;
      ST_WAIT_A: if (tl_i.a_ready)           state_d = ST_WAIT_D;
      ST_WAIT_D: if (tl_i.d_valid)           state_d = ST_DONE;
      ST_DONE:   if (!penable_i)             state_d = ST_IDLE;
      default:                               state_d = ST_IDLE;
    endcase
  end

  // -------------------------------------------------------------------------
  // TL-UL request generation (combinational)
  // -------------------------------------------------------------------------
  always_comb begin
    tl_o          = TL_H2D_DEFAULT;
    tl_o.d_ready  = 1'b1;
    tl_o.a_valid  = (state_q == ST_WAIT_A);
    if (state_q == ST_WAIT_A) begin
      tl_o.a_opcode  = req_opcode_q;
      tl_o.a_param   = 3'h0;
      tl_o.a_size    = top_pkg::TL_SZW'(2);  // 4-byte transfer
      tl_o.a_source  = '0;
      tl_o.a_address = req_addr_q;
      tl_o.a_mask    = req_strb_q;
      tl_o.a_data    = req_wdata_q;
      // Integrity fields computed from the request so uart_reg_top's
      // tlul_cmd_intg_chk passes.
      tl_o.a_user    = TL_A_USER_DEFAULT;
      tl_o.a_user.cmd_intg  = get_cmd_intg(tl_o);
      tl_o.a_user.data_intg = get_data_intg(tl_o.a_data);
    end
  end

  // -------------------------------------------------------------------------
  // APB output drive
  // -------------------------------------------------------------------------
  always_comb begin
    prdata_o = '0;
    pready_o = 1'b0;
    pslverr_o = 1'b0;
    if (state_q == ST_DONE) begin
      prdata_o = req_write_q ? '0 : rsp_rdata_q;
      pready_o = 1'b1;
      pslverr_o = rsp_error_q;
    end
  end

  // -------------------------------------------------------------------------
  // Assertions
  // -------------------------------------------------------------------------
  `ASSERT_KNOWN(PreadyKnown_A, pready_o)
  `ASSERT_KNOWN(PrdataKnown_A, prdata_o)
  `ASSERT_KNOWN(PslverrKnown_A, pslverr_o)

endmodule : apb2tlul
