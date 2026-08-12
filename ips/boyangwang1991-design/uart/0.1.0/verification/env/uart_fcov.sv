// =============================================================================
// File Name   : uart_fcov.sv
// Description : UART functional coverage implementation
//               Implements the coverage points defined in coverage_plan.md:
//               COV.FUNC.UART.01-04, COV.INTF.UART.01, COV.REG.UART.01.
// =============================================================================

`ifndef UART_FCOV__SV
`define UART_FCOV__SV

/// @class uart_rm_fcov_xaction
/// @brief UART functional coverage transaction
///        Samples TL-UL/APB register accesses and UART serial frames.
class uart_rm_fcov_xaction extends uvm_sequence_item;

  // ===========================================================================
  // Coverage Sample Fields
  // ===========================================================================

  /// UART serial frame fields
  rand bit [7:0] data;         ///< Serial data byte
  rand bit       parity_en;    ///< Parity enable
  rand bit       parity_odd;   ///< Parity odd/even
  rand uart_mode_e mode;       ///< Loopback mode
  rand uart_err_e  err_type;   ///< Error type

  /// Register access fields
  rand bit [7:0] reg_addr;     ///< Register byte address
  rand bit       is_read;      ///< Read (1) / write (0)
  rand bit [15:0] nco_div;     ///< NCO baud divider

  // ===========================================================================
  // Coverage Groups (per coverage_plan.md)
  // ===========================================================================

  /// COV.FUNC.UART.01.BAUD - baud rate configuration combinations
  covergroup baud_rate_cg;
    option.per_instance = 1;
    cp_nco: coverpoint nco_div {
      bins nco_min   = {0};
      bins nco_low   = {[1:100]};
      bins nco_9600  = {1667};   // 16x @ 9600 baud from 100MHz
      bins nco_115200= {54};     // 16x @ 115200 baud
      bins nco_high  = {[1000:65535]};
      bins nco_max   = {65535};
    }
  endgroup

  /// COV.FUNC.UART.02.FRAME - frame format (parity/data bits)
  covergroup frame_cg;
    option.per_instance = 1;
    cp_parity_en: coverpoint parity_en {
      bins parity_off = {0};
      bins parity_on  = {1};
    }
    cp_parity_odd: coverpoint parity_odd {
      bins even = {0};
      bins odd  = {1};
    }
    cp_data: coverpoint data {
      bins d_zero = {8'h00};
      bins d_55   = {8'h55};
      bins d_aa   = {8'hAA};
      bins d_max  = {8'hFF};
      bins d_other = default;
    }
    cross_parity: cross cp_parity_en, cp_parity_odd;
  endgroup

  /// COV.FUNC.UART.03.FIFO - FIFO level / full / empty (modeled via addr)
  covergroup fifo_cg;
    option.per_instance = 1;
    cp_reg: coverpoint reg_addr {
      bins wdata      = {8'h1C};
      bins rdata      = {8'h18};
      bins fifo_ctrl  = {8'h20};
      bins fifo_status= {8'h24};
    }
    cp_op: coverpoint is_read {
      bins read  = {1};
      bins write = {0};
    }
    cross_fifo: cross cp_reg, cp_op;
  endgroup

  /// COV.FUNC.UART.04.ERR - error events
  covergroup error_cg;
    option.per_instance = 1;
    cp_err: coverpoint err_type {
      bins none   = {UART_ERR_NONE};
      bins frame  = {UART_ERR_FRAME};
      bins parity = {UART_ERR_PARITY};
      bins brk    = {UART_ERR_BREAK};
    }
  endgroup

  /// COV.INTF.UART.01.MODE - loopback modes
  covergroup mode_cg;
    option.per_instance = 1;
    cp_mode: coverpoint mode {
      bins normal = {UART_MODE_NORMAL};
      bins slpbk  = {UART_MODE_SLPBK};
      bins llpbk  = {UART_MODE_LLPBK};
      bins nf     = {UART_MODE_NF};
    }
  endgroup

  /// COV.REG.UART.01.ACC - register access types
  covergroup reg_access_cg;
    option.per_instance = 1;
    cp_access: coverpoint is_read {
      bins rd = {1};
      bins wr = {0};
    }
    cp_addr: coverpoint reg_addr {
      bins ctrl   = {8'h10};
      bins status = {8'h14};
      bins wdata  = {8'h1C};
      bins rdata  = {8'h18};
      bins intr   = {[8'h00:8'h0C]};
      bins other  = default;
    }
    cross_access: cross cp_access, cp_addr;
  endgroup

  `uvm_object_utils(uart_rm_fcov_xaction)

  /// @brief Constructor
  /// @param name Coverage transaction name string
  extern function new(string name = "uart_rm_fcov_xaction");

  /// @brief Pre-randomize hook
  extern function void pre_randomize();

  /// @brief Post-randomize hook
  extern function void post_randomize();

  /// @brief Pack transaction fields into a byte stream
  /// @param packer Packer state object
  extern virtual function void do_pack(uvm_packer packer);

  /// @brief Unpack transaction fields from a byte stream
  /// @param packer Packer state object
  extern virtual function void do_unpack(uvm_packer packer);

  /// @brief Sample the coverage groups
  extern virtual function void sample();

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name Coverage transaction name string
function uart_rm_fcov_xaction::new(string name = "uart_rm_fcov_xaction");
  super.new(name);
  baud_rate_cg   = new();
  frame_cg       = new();
  fifo_cg        = new();
  error_cg       = new();
  mode_cg        = new();
  reg_access_cg  = new();
endfunction

/// @brief Pre-randomize hook
function void uart_rm_fcov_xaction::pre_randomize();
  super.pre_randomize();
endfunction

/// @brief Post-randomize hook
function void uart_rm_fcov_xaction::post_randomize();
  super.post_randomize();
endfunction

/// @brief Pack definition
function void uart_rm_fcov_xaction::do_pack(uvm_packer packer);
  super.do_pack(packer);
endfunction

/// @brief Unpack definition
function void uart_rm_fcov_xaction::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
endfunction

/// @brief Sample definition
function void uart_rm_fcov_xaction::sample();
  baud_rate_cg.sample();
  frame_cg.sample();
  fifo_cg.sample();
  error_cg.sample();
  mode_cg.sample();
  reg_access_cg.sample();
endfunction

`endif
