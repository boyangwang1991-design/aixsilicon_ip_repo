// =============================================================================
// File Name   : uart_dec.sv
// Description : UART protocol declarations and definitions
// =============================================================================

`ifndef UART_DEC__SV
`define UART_DEC__SV

package uart_dec;

  // Agent Mode Constants
  parameter bit UART_MASTER_MODE  = 1'b0;
  parameter bit UART_SLAVE_MODE   = 1'b1;
  parameter bit UART_AGENT_ACTIVE = 1'b1;
  parameter bit UART_AGENT_PASSIVE = 1'b0;

  // Protocol Parameters
  parameter int UART_DATA_WIDTH = 8;
  parameter int UART_NCO_WIDTH  = 16;

  // Operation modes
  typedef enum bit [1:0] {
    UART_MODE_NORMAL = 2'b00,
    UART_MODE_SLPBK  = 2'b01,
    UART_MODE_LLPBK  = 2'b10,
    UART_MODE_NF     = 2'b11
  } uart_mode_e;

  // Error injection types
  typedef enum bit [2:0] {
    UART_ERR_NONE     = 3'b000,
    UART_ERR_FRAME    = 3'b001,
    UART_ERR_PARITY   = 3'b010,
    UART_ERR_BREAK    = 3'b011
  } uart_err_e;

endpackage

`endif
