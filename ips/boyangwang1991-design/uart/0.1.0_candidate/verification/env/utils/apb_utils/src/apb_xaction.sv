// =============================================================================
// File Name   : apb_xaction.sv
// Description : APB4 protocol transaction class
// =============================================================================

`ifndef APB_XACTION__SV
`define APB_XACTION__SV

class apb_xaction extends uvm_sequence_item;

  rand apb_cmd_e                cmd;
  rand bit [APB_ADDR_WIDTH-1:0] addr;
  rand bit [APB_DATA_WIDTH-1:0] data;
  rand bit [APB_STRB_WIDTH-1:0] strb;
       apb_resp_e               resp;

  constraint c_default {
    (cmd == APB_WRITE) -> (strb != '0);
    (cmd == APB_READ)  -> (strb == '0);
  }

  `uvm_object_utils_begin(apb_xaction)
    `uvm_field_enum(apb_cmd_e, cmd, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(strb, UVM_ALL_ON)
    `uvm_field_enum(apb_resp_e, resp, UVM_ALL_ON)
  `uvm_object_utils_end

  extern function new(string name = "apb_xaction");
  extern function void pre_randomize();
  extern function void post_randomize();
  extern virtual function void do_pack(uvm_packer packer);
  extern virtual function void do_unpack(uvm_packer packer);

endclass

function apb_xaction::new(string name = "apb_xaction");
  super.new(name);
endfunction

function void apb_xaction::pre_randomize();
  super.pre_randomize();
endfunction

function void apb_xaction::post_randomize();
  super.post_randomize();
endfunction

function void apb_xaction::do_pack(uvm_packer packer);
  super.do_pack(packer);
endfunction

function void apb_xaction::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
endfunction

`endif
