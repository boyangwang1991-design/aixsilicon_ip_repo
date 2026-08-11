// =============================================================================
// File Name   : apb_interface.sv
// Description : APB4 protocol virtual interface (APB slave-facing master)
// =============================================================================

`ifndef APB_INTERFACE__SV
`define APB_INTERFACE__SV

interface apb_interface(
  input logic clk,
  input logic rst_n
);

  import apb_dec::*;

  // APB4 slave interface signals
  logic                    psel;
  logic                    penable;
  logic                    pwrite;
  logic [APB_ADDR_WIDTH-1:0] paddr;
  logic [APB_DATA_WIDTH-1:0] pwdata;
  logic [APB_STRB_WIDTH-1:0] pstrb;
  logic [APB_DATA_WIDTH-1:0] prdata;
  logic                    pready;
  logic                    pslverr;

  clocking drv_cb @(posedge clk);
    default input #1step output #1step;
    output psel, penable, pwrite, paddr, pwdata, pstrb;
    input  prdata, pready, pslverr;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step output #1step;
    input psel, penable, pwrite, paddr, pwdata, pstrb, prdata, pready, pslverr;
  endclocking

  modport master  (clocking drv_cb, input clk, input rst_n);
  modport monitor (clocking mon_cb, input clk, input rst_n);

endinterface

`endif
