// =============================================================================
// File Name   : apb_dec.sv
// Description : XX protocol declarations and definitions
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
//
// IMPORTANT: All protocol parameters, typedefs, and constants MUST be inside
//            the apb_dec package so they can be imported by apb_package.
//            Do NOT place parameters outside the package - they will not be
//            visible to classes inside apb_package.
// =============================================================================

`ifndef APB_DEC__SV
`define APB_DEC__SV

/// @package apb_dec
/// @brief XX protocol declarations and definitions package
///        Contains protocol parameters, command types, and response types
///
/// IMPORTANT: All protocol-specific parameters and typedefs MUST be inside
///            this package. The apb_package.sv will `import apb_dec::*` to
///            make them visible to all agent classes.
package apb_dec;

  // -----------------------------------------------------------------------------
  // Agent Mode Constants (inside package for visibility to agent classes)
  // -----------------------------------------------------------------------------
  parameter bit APB_MASTER_MODE  = 1'b0;  ///< Master mode
  parameter bit APB_SLAVE_MODE   = 1'b1;  ///< Slave mode
  parameter bit APB_AGENT_ACTIVE = 1'b1;  ///< Active agent mode
  parameter bit APB_AGENT_PASSIVE = 1'b0; ///< Passive agent mode

  // -----------------------------------------------------------------------------
  // Protocol Parameters - Modify these for your specific protocol
  // -----------------------------------------------------------------------------
  // TODO: Define protocol-specific parameters INSIDE the package
  parameter int APB_ADDR_WIDTH = 32;   ///< Address bus width
  parameter int APB_DATA_WIDTH = 32;   ///< Data bus width
  parameter int APB_STRB_WIDTH = APB_DATA_WIDTH / 8;  ///< Byte strobe width

  // -----------------------------------------------------------------------------
  // Command Types - Modify for your specific protocol
  // -----------------------------------------------------------------------------
  // TODO: Define protocol-specific command types
  typedef enum bit {
    APB_READ  = 1'b0,  ///< Read command
    APB_WRITE = 1'b1   ///< Write command
  } apb_cmd_e;

  // -----------------------------------------------------------------------------
  // Response Types - Modify for your specific protocol
  // -----------------------------------------------------------------------------
  // TODO: Define protocol-specific response types
  typedef enum bit [1:0] {
    APB_RESP_OKAY  = 2'b00,  ///< Okay response
    APB_RESP_ERROR = 2'b01,  ///< Error response
    APB_RESP_RETRY = 2'b10   ///< Retry response
  } apb_resp_e;

endpackage

`endif
