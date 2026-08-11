// =============================================================================
// File Name   : tlul_monitor_cov.sv
// Description : XX monitor coverage collector
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef TLUL_MONITOR_COV__SV
`define TLUL_MONITOR_COV__SV

/// @class tlul_monitor_cov
/// @brief Coverage collector for XX protocol monitor
///        Extends uvm_subscriber to collect functional coverage on transactions
class tlul_monitor_cov extends uvm_subscriber #(tlul_xaction);

  // =============================================================================
  // Transaction Handle for Coverage Sampling
  // =============================================================================
  tlul_xaction tr;  ///< Transaction handle for coverage sampling

  // ---------------------------------------------------------------------------
  // Coverage Groups
  // ---------------------------------------------------------------------------

  /// @brief XX protocol coverage group
  /// NOTE: Replace coverpoint/bin values with your protocol-specific enums.
  ///       Avoid using SystemVerilog keywords (e.g., 'assert') as bin names.
  ///       Use prefixed names like 'tlul_read', 'tlul_write' instead.
  covergroup tlul_cg;
    option.per_instance = 1;

    /// Command coverage - read vs write
    cp_cmd: coverpoint tr.cmd {
      bins tlul_read  = {TLUL_READ};
      bins tlul_write = {TLUL_WRITE};
    }

    /// Address low byte coverage
    cp_addr_low: coverpoint tr.addr[7:0];

    // TODO: Add protocol-specific coverage points:
    //   cp_resp: coverpoint tr.resp {
    //     bins tlul_okay  = {TLUL_RESP_OKAY};
    //     bins tlul_error = {TLUL_RESP_RETRY};
    //   }
    //   cross_cmd_resp: cross cp_cmd, cp_resp;

  endgroup

  `uvm_component_utils_begin(tlul_monitor_cov)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Coverage component name string
  /// @param parent Parent component handle
  extern function new(string name = "tlul_monitor_cov", uvm_component parent = null);

  /// @brief Write function - called by analysis export
  /// @param t Transaction to sample coverage for
  extern virtual function void write(tlul_xaction t);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Coverage component name string
/// @param parent Parent component handle
function tlul_monitor_cov::new(string name = "tlul_monitor_cov", uvm_component parent = null);
  super.new(name, parent);
  tlul_cg = new();
endfunction

/// @brief Write function definition
/// @param t Transaction to sample coverage for
function void tlul_monitor_cov::write(tlul_xaction t);
  tr = t;
  tlul_cg.sample();
endfunction

`endif
