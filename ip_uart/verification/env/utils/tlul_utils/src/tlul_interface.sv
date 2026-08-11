// =============================================================================
// File Name   : tlul_interface.sv
// Description : TL-UL protocol virtual interface (flat signals)
//               Driver drives A channel, monitor samples A/D channels.
//               TL-UL struct packing/unpacking for DUT connection is done in
//               the harness (which compiles the RTL tlul_pkg), keeping this
//               interface self-contained for standalone agent lint.
// =============================================================================

`ifndef TLUL_INTERFACE__SV
`define TLUL_INTERFACE__SV

interface tlul_interface(
  input logic clk,
  input logic rst_n
);

  import tlul_dec::*;

  // =============================================================================
  // Flat TL-UL A channel signals (host -> device)
  // =============================================================================
  logic                    a_valid;
  logic [2:0]              a_opcode;
  logic [2:0]              a_param;
  logic [1:0]              a_size;
  logic [TLUL_SOURCE_WIDTH-1:0] a_source;
  logic [TLUL_ADDR_WIDTH-1:0]   a_address;
  logic [TLUL_STRB_WIDTH-1:0]   a_mask;
  logic [TLUL_DATA_WIDTH-1:0]   a_data;
  logic                    a_ready;

  // =============================================================================
  // Flat TL-UL D channel signals (device -> host)
  // =============================================================================
  logic                    d_valid;
  logic [2:0]              d_opcode;
  logic [1:0]              d_size;
  logic [TLUL_SOURCE_WIDTH-1:0] d_source;
  logic                    d_error;
  logic [TLUL_DATA_WIDTH-1:0]   d_data;
  logic                    d_ready;

  // =============================================================================
  // Clocking Blocks
  // =============================================================================
  clocking drv_cb @(posedge clk);
    default input #1step output #1step;
    output a_valid, a_opcode, a_param, a_size, a_source, a_address, a_mask, a_data;
    input  a_ready;
    output d_ready;
    input  d_valid, d_opcode, d_size, d_source, d_error, d_data;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step output #1step;
    input a_valid, a_opcode, a_address, a_mask, a_data, a_ready;
    input d_valid, d_opcode, d_error, d_data, d_source;
  endclocking

  modport master  (clocking drv_cb, input clk, input rst_n);
  modport monitor (clocking mon_cb, input clk, input rst_n);

endinterface

`endif
