// =============================================================================
// File Name   : uart_xaction.sv
// Description : UART serial transaction class
// =============================================================================

`ifndef UART_XACTION__SV
`define UART_XACTION__SV

class uart_xaction extends uvm_sequence_item;

  rand bit [UART_DATA_WIDTH-1:0] data;      // Serial data byte
  rand bit                       parity_en; // Parity enable
  rand bit                       parity_odd; // Odd/even parity
  rand uart_err_e                err_type;  // Error injection
  rand uart_mode_e               mode;      // Loopback mode
  rand int unsigned              baud_div;  // Baud divider (>=1)

  constraint c_baud {
    baud_div inside {[1:4095]};
  }

  `uvm_object_utils_begin(uart_xaction)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(parity_en, UVM_ALL_ON)
    `uvm_field_int(parity_odd, UVM_ALL_ON)
    `uvm_field_enum(uart_err_e, err_type, UVM_ALL_ON)
    `uvm_field_enum(uart_mode_e, mode, UVM_ALL_ON)
    `uvm_field_int(baud_div, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "uart_xaction");
  extern function void pre_randomize();
  extern function void post_randomize();
  extern virtual function void do_pack(uvm_packer packer);
  extern virtual function void do_unpack(uvm_packer packer);

endclass

function uart_xaction::new(string name = "uart_xaction");
  super.new(name);
endfunction

function void uart_xaction::pre_randomize();
  super.pre_randomize();
endfunction

function void uart_xaction::post_randomize();
  super.post_randomize();
endfunction

function void uart_xaction::do_pack(uvm_packer packer);
  super.do_pack(packer);
endfunction

function void uart_xaction::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
endfunction

`endif
