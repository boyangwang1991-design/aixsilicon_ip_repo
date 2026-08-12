// =============================================================================
// File Name   : uart_monitor_cov.sv
// Description : XX monitor coverage collector
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef UART_MONITOR_COV__SV
`define UART_MONITOR_COV__SV

/// @class uart_monitor_cov
/// @brief Coverage collector for XX protocol monitor
///        Extends uvm_subscriber to collect functional coverage on transactions
class uart_monitor_cov extends uvm_subscriber #(uart_xaction);

  // =============================================================================
  // Transaction Handle for Coverage Sampling
  // =============================================================================
  uart_xaction tr;  ///< Transaction handle for coverage sampling

  // ---------------------------------------------------------------------------
  // Coverage Groups
  // ---------------------------------------------------------------------------

  /// @brief XX protocol coverage group
  /// NOTE: Replace coverpoint/bin values with your protocol-specific enums.
  ///       Avoid using SystemVerilog keywords (e.g., 'assert') as bin names.
  ///       Use prefixed names like 'uart_read', 'uart_write' instead.
  covergroup uart_cg;
    option.per_instance = 1;

    /// Data byte coverage
    cp_data: coverpoint tr.data {
      bins zero      = {8'h00};
      bins one       = {8'h01};
      bins max       = {8'hFF};
      bins others    = default;
    }

    /// Parity configuration coverage
    cp_parity_en: coverpoint tr.parity_en {
      bins parity_off = {0};
      bins parity_on  = {1};
    }

    /// Operating mode coverage
    cp_mode: coverpoint tr.mode {
      bins mode_normal = {UART_MODE_NORMAL};
      bins mode_slpbk  = {UART_MODE_SLPBK};
      bins mode_llpbk  = {UART_MODE_LLPBK};
      bins mode_nf     = {UART_MODE_NF};
    }

    /// Error injection coverage
    cp_err: coverpoint tr.err_type {
      bins err_none   = {UART_ERR_NONE};
      bins err_frame  = {UART_ERR_FRAME};
      bins err_parity = {UART_ERR_PARITY};
      bins err_break  = {UART_ERR_BREAK};
    }

    /// Cross: data vs parity
    cross_data_parity: cross cp_data, cp_parity_en;

  endgroup

  `uvm_component_utils_begin(uart_monitor_cov)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Coverage component name string
  /// @param parent Parent component handle
  extern function new(string name = "uart_monitor_cov", uvm_component parent = null);

  /// @brief Write function - called by analysis export
  /// @param t Transaction to sample coverage for
  extern virtual function void write(uart_xaction t);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Coverage component name string
/// @param parent Parent component handle
function uart_monitor_cov::new(string name = "uart_monitor_cov", uvm_component parent = null);
  super.new(name, parent);
  uart_cg = new();
endfunction

/// @brief Write function definition
/// @param t Transaction to sample coverage for
function void uart_monitor_cov::write(uart_xaction t);
  tr = t;
  uart_cg.sample();
endfunction

`endif
