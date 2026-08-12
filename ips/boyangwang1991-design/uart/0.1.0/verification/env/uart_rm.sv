// =============================================================================
// File Name   : uart_rm.sv
// Description : UART reference model (golden model)
//               Predicts UART serial TX output from TL-UL / APB register writes.
//               Models the WDATA -> TX serialization path at transaction level:
//               when software writes the WDATA register (with TX enabled), the
//               DUT transmits the written byte on the serial TX line.
// =============================================================================

`ifndef UART_RM__SV
`define UART_RM__SV

/// @class uart_rm
/// @brief UART reference model
///        Receives TL-UL / APB / UART input transactions and generates expected
///        serial TX output for the checker to compare against the DUT TX.
class uart_rm extends uvm_component;

  uart_rm_cfg cfg;  ///< Reference model configuration handle

  // ===========================================================================
  // Analysis Imports (declared in uart_env_package)
  // ===========================================================================
  uvm_analysis_imp_tlul #(tlul_xaction, uart_rm) tlul_in_export;  ///< TL-UL register access input
  uvm_analysis_imp_apb  #(apb_xaction,  uart_rm) apb_in_export;   ///< APB register access input
  uvm_analysis_imp_uart #(uart_xaction, uart_rm) uart_in_export;  ///< UART serial input (loopback)

  // ===========================================================================
  // Analysis Ports
  // ===========================================================================
  uvm_analysis_port #(uart_xaction) exp_ap;  ///< Expected TX output analysis port

  // ===========================================================================
  // Internal State (register shadow / prediction model)
  // ===========================================================================
  // Software-visible register shadow used to predict behavior.
  bit [31:0] ctrl_shadow;  ///< CTRL register shadow
  bit [31:0] wdata_shadow; ///< WDATA write data latch

  // Register offsets (from uart_reg_pkg, byte addressing)
  localparam bit [5:0] UART_CTRL_OFFSET     = 6'h10;
  localparam bit [5:0] UART_RDATA_OFFSET    = 6'h18;
  localparam bit [5:0] UART_WDATA_OFFSET    = 6'h1c;
  localparam bit [5:0] UART_FIFO_CTRL_OFFSET= 6'h20;
  localparam bit [5:0] UART_OVRD_OFFSET     = 6'h28;

  // Statistics
  int exp_count = 0;  ///< Count of predicted TX transactions

  `uvm_component_utils_begin(uart_rm)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Reference model name string
  /// @param parent Parent component handle
  extern function new(string name = "uart_rm", uvm_component parent = null);

  /// @brief Build phase - get configuration
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Process a TL-UL register transaction and predict TX output
  /// @param tr TL-UL transaction
  extern virtual function void write_tlul(tlul_xaction tr);

  /// @brief Process an APB register transaction and predict TX output
  /// @param tr APB transaction
  extern virtual function void write_apb(apb_xaction tr);

  /// @brief Process a UART serial input transaction (loopback mode)
  /// @param tr UART serial transaction
  extern virtual function void write_uart(uart_xaction tr);

  /// @brief Reset internal prediction state
  extern virtual function void reset_state();

  /// @brief Report phase - print model summary
  /// @param phase Current phase handle
  extern virtual function void report_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Reference model name string
/// @param parent Parent component handle
function uart_rm::new(string name = "uart_rm", uvm_component parent = null);
  super.new(name, parent);
  tlul_in_export = new("tlul_in_export", this);
  apb_in_export  = new("apb_in_export", this);
  uart_in_export = new("uart_in_export", this);
  exp_ap         = new("exp_ap", this);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void uart_rm::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db #(uart_rm_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = uart_rm_cfg::type_id::create("cfg");
  end
endfunction

/// @brief Write TL-UL transaction definition
/// @param tr TL-UL transaction
function void uart_rm::write_tlul(tlul_xaction tr);
  uart_xaction exp;

  // Track CTRL register writes to know TX enable / parity configuration
  if (tr.cmd == TLUL_WRITE) begin
    case (tr.addr[5:0])
      UART_CTRL_OFFSET: begin
        ctrl_shadow = tr.data;
        `uvm_info(get_type_name(), $sformatf(
          "CTRL written = 0x%08h (tx=%0b parity_en=%0b parity_odd=%0b)",
          ctrl_shadow, ctrl_shadow[0], ctrl_shadow[2], ctrl_shadow[3]
        ), UVM_HIGH)
      end
      UART_FIFO_CTRL_OFFSET: begin
        // FIFO reset - clear prediction state
        reset_state();
      end
      UART_WDATA_OFFSET: begin
        wdata_shadow = tr.data;

        // Predict TX output only when TX is enabled (CTRL[0] = TX)
        if (ctrl_shadow[0]) begin
          exp = uart_xaction::type_id::create("exp");
          exp.data      = wdata_shadow[7:0];
          exp.parity_en = ctrl_shadow[2];
          exp.parity_odd = ctrl_shadow[3];
          exp.err_type  = UART_ERR_NONE;
          exp.mode      = UART_MODE_NORMAL;
          exp.baud_div  = 16;  // default 16x oversampling
          exp_count++;
          exp_ap.write(exp);
          `uvm_info(get_type_name(), $sformatf(
            "Predicted TX byte = 0x%02x (tx_en=%0b)", exp.data, ctrl_shadow[0]
          ), UVM_MEDIUM)
        end
      end
      default: begin
        // Other registers do not produce serial output
      end
    endcase
  end
endfunction

/// @brief Write APB transaction definition
/// @param tr APB transaction
function void uart_rm::write_apb(apb_xaction tr);
  uart_xaction exp;

  // APB path mirrors TL-UL register access through the apb2tlul bridge.
  if (tr.cmd == APB_WRITE) begin
    case (tr.addr[5:0])
      UART_CTRL_OFFSET: begin
        ctrl_shadow = tr.data;
      end
      UART_WDATA_OFFSET: begin
        wdata_shadow = tr.data;
        if (ctrl_shadow[0]) begin
          exp = uart_xaction::type_id::create("exp");
          exp.data       = wdata_shadow[7:0];
          exp.parity_en  = ctrl_shadow[2];
          exp.parity_odd = ctrl_shadow[3];
          exp.err_type   = UART_ERR_NONE;
          exp.mode       = UART_MODE_NORMAL;
          exp.baud_div   = 16;
          exp_count++;
          exp_ap.write(exp);
          `uvm_info(get_type_name(), $sformatf(
            "APB predicted TX byte = 0x%02x", exp.data
          ), UVM_MEDIUM)
        end
      end
      default: begin
        // No serial output for other registers
      end
    endcase
  end
endfunction

/// @brief Write UART serial input definition
/// @param tr UART serial transaction
function void uart_rm::write_uart(uart_xaction tr);
  // In loopback modes (SLPBK/LLPBK) the received byte is echoed back on TX.
  if (tr.mode == UART_MODE_SLPBK || tr.mode == UART_MODE_LLPBK) begin
    uart_xaction exp;
    exp = uart_xaction::type_id::create("exp");
    exp.copy(tr);
    exp_count++;
    exp_ap.write(exp);
    `uvm_info(get_type_name(), $sformatf(
      "Loopback predicted TX byte = 0x%02x", exp.data
    ), UVM_MEDIUM)
  end
endfunction

/// @brief Reset internal prediction state definition
function void uart_rm::reset_state();
  ctrl_shadow  = '0;
  wdata_shadow = '0;
  `uvm_info(get_type_name(), "Reference model state reset", UVM_HIGH)
endfunction

/// @brief Report phase definition
/// @param phase Current phase handle
function void uart_rm::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info(get_type_name(), $sformatf(
    "Reference model summary: %0d predicted TX transactions", exp_count
  ), UVM_LOW)
endfunction

`endif
