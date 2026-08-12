// =============================================================================
// File Name   : apb_dec.sv
// Description : APB4 protocol declarations and definitions
// =============================================================================

`ifndef APB_DEC__SV
`define APB_DEC__SV

package apb_dec;

  // Agent Mode Constants
  parameter bit APB_MASTER_MODE  = 1'b0;
  parameter bit APB_SLAVE_MODE   = 1'b1;
  parameter bit APB_AGENT_ACTIVE = 1'b1;
  parameter bit APB_AGENT_PASSIVE = 1'b0;

  // Protocol Parameters
  parameter int APB_ADDR_WIDTH = 8;
  parameter int APB_DATA_WIDTH = 32;
  parameter int APB_STRB_WIDTH = APB_DATA_WIDTH / 8;

  // Command type
  typedef enum bit {
    APB_READ  = 1'b0,
    APB_WRITE = 1'b1
  } apb_cmd_e;

  // Response type
  typedef enum bit {
    APB_RESP_OK    = 1'b0,
    APB_RESP_ERROR = 1'b1
  } apb_resp_e;

endpackage

`endif
