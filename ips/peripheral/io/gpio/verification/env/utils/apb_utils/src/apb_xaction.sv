class apb_xaction extends uvm_sequence_item;
 rand bit write;
 rand bit[13:0] addr;
 rand bit[31:0] data;
 rand bit[3:0] strb=15;
 rand bit[2:0] prot=1;
 int setup_cycles=1;
 bit error;
 `uvm_object_utils_begin(apb_xaction)
 `uvm_field_int(write,UVM_ALL_ON) `uvm_field_int(addr,UVM_ALL_ON)
 `uvm_field_int(data,UVM_ALL_ON) `uvm_field_int(strb,UVM_ALL_ON)
 `uvm_field_int(prot,UVM_ALL_ON) `uvm_field_int(error,UVM_ALL_ON)
 `uvm_object_utils_end
 extern function new(string name="apb_xaction");
endclass
function apb_xaction::new(string name="apb_xaction");super.new(name);endfunction
