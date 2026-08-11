// =============================================================================
// File Name   : tlul_dec.sv
// Description : TL-UL protocol declarations and definitions
// =============================================================================

`ifndef TLUL_DEC__SV
`define TLUL_DEC__SV

package tlul_dec;

  // Agent Mode Constants
  parameter bit TLUL_MASTER_MODE  = 1'b0;
  parameter bit TLUL_SLAVE_MODE   = 1'b1;
  parameter bit TLUL_AGENT_ACTIVE = 1'b1;
  parameter bit TLUL_AGENT_PASSIVE = 1'b0;

  // Protocol Parameters
  parameter int TLUL_ADDR_WIDTH = 32;
  parameter int TLUL_DATA_WIDTH = 32;
  parameter int TLUL_STRB_WIDTH = TLUL_DATA_WIDTH / 8;
  parameter int TLUL_SOURCE_WIDTH = 8;

  // TL-UL opcodes (match tlul_pkg)
  typedef enum logic [2:0] {
    TLUL_PUTFULLDATA    = 3'h0,
    TLUL_PUTPARTIALDATA = 3'h1,
    TLUL_GET            = 3'h4
  } tlul_op_e;

  // Response opcodes
  typedef enum logic [2:0] {
    TLUL_ACCESSACK     = 3'h0,
    TLUL_ACCESSACKDATA = 3'h1
  } tlul_dop_e;

  // Command type (simplified for sequence generation)
  typedef enum bit {
    TLUL_READ  = 1'b0,
    TLUL_WRITE = 1'b1
  } tlul_cmd_e;

  // Response type
  typedef enum bit {
    TLUL_RESP_OK    = 1'b0,
    TLUL_RESP_ERROR = 1'b1
  } tlul_resp_e;

endpackage

`endif
