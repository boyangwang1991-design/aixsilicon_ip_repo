// =============================================================================
// File Name   : apb_monitor_cov.sv
// Description : XX monitor coverage collector
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef APB_MONITOR_COV__SV
`define APB_MONITOR_COV__SV

/// @class apb_monitor_cov
/// @brief Coverage collector for XX protocol monitor
///        Extends uvm_subscriber to collect functional coverage on transactions
class apb_monitor_cov extends uvm_subscriber #(apb_xaction);

  // =============================================================================
  // Transaction Handle for Coverage Sampling
  // =============================================================================
  apb_xaction tr;  ///< Transaction handle for coverage sampling

  // ---------------------------------------------------------------------------
  // Coverage Groups
  // ---------------------------------------------------------------------------

  /// @brief XX protocol coverage group
  /// NOTE: Replace coverpoint/bin values with your protocol-specific enums.
  ///       Avoid using SystemVerilog keywords (e.g., 'assert') as bin names.
  ///       Use prefixed names like 'apb_read', 'apb_write' instead.
  covergroup apb_cg;
    option.per_instance = 1;

    /// Command coverage - read vs write
    cp_cmd: coverpoint tr.cmd {
      bins apb_read  = {APB_READ};
      bins apb_write = {APB_WRITE};
    }

    /// Address low byte coverage
    cp_addr_low: coverpoint tr.addr[7:0];

    // TODO: Add protocol-specific coverage points:
    //   cp_resp: coverpoint tr.resp {
    //     bins apb_okay  = {APB_RESP_OKAY};
    //     bins apb_error = {APB_RESP_RETRY};
    //   }
    //   cross_cmd_resp: cross cp_cmd, cp_resp;

  endgroup

  `uvm_component_utils_begin(apb_monitor_cov)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Coverage component name string
  /// @param parent Parent component handle
  extern function new(string name = "apb_monitor_cov", uvm_component parent = null);

  /// @brief Write function - called by analysis export
  /// @param t Transaction to sample coverage for
  extern virtual function void write(apb_xaction t);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Coverage component name string
/// @param parent Parent component handle
function apb_monitor_cov::new(string name = "apb_monitor_cov", uvm_component parent = null);
  super.new(name, parent);
  apb_cg = new();
endfunction

/// @brief Write function definition
/// @param t Transaction to sample coverage for
function void apb_monitor_cov::write(apb_xaction t);
  tr = t;
  apb_cg.sample();
endfunction

`endif
