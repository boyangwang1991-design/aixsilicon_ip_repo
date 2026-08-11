// =============================================================================
// File Name   : tlul_xaction.sv
// Description : TL-UL protocol transaction class
// =============================================================================

`ifndef TLUL_XACTION__SV
`define TLUL_XACTION__SV

class tlul_xaction extends uvm_sequence_item;

  rand tlul_cmd_e              cmd;    // READ / WRITE
  rand bit [TLUL_ADDR_WIDTH-1:0] addr; // Byte address
  rand bit [TLUL_DATA_WIDTH-1:0] data; // Write data / read data
  rand bit [TLUL_STRB_WIDTH-1:0] strb; // Byte strobe
       tlul_resp_e              resp;  // Response from target

  // Default constraints
  constraint c_default {
    (cmd == TLUL_WRITE) -> (strb != '0);
    (cmd == TLUL_READ)  -> (strb == '0);
    addr[1:0] == 2'b00;  // word-aligned
  }

  `uvm_object_utils_begin(tlul_xaction)
    `uvm_field_enum(tlul_cmd_e, cmd, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(strb, UVM_ALL_ON)
    `uvm_field_enum(tlul_resp_e, resp, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "tlul_xaction");
  extern function void pre_randomize();
  extern function void post_randomize();
  extern virtual function void do_pack(uvm_packer packer);
  extern virtual function void do_unpack(uvm_packer packer);

endclass

function tlul_xaction::new(string name = "tlul_xaction");
  super.new(name);
endfunction

function void tlul_xaction::pre_randomize();
  super.pre_randomize();
endfunction

function void tlul_xaction::post_randomize();
  super.post_randomize();
endfunction

function void tlul_xaction::do_pack(uvm_packer packer);
  super.do_pack(packer);
endfunction

function void tlul_xaction::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
endfunction

`endif
