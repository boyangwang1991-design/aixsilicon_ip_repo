class gpio_ral_adapter extends uvm_reg_adapter;
 `uvm_object_utils(gpio_ral_adapter)
 extern function new(string name="gpio_ral_adapter");
 extern virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
 extern virtual function void bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
endclass
function gpio_ral_adapter::new(string name="gpio_ral_adapter");super.new(name);supports_byte_enable=1;provides_responses=0;endfunction
function uvm_sequence_item gpio_ral_adapter::reg2bus(const ref uvm_reg_bus_op rw);
 apb_xaction t=new("ral_access");t.addr=rw.addr;t.write=rw.kind==UVM_WRITE;t.data=rw.data;t.strb=rw.byte_en;return t;
endfunction
function void gpio_ral_adapter::bus2reg(uvm_sequence_item bus_item,ref uvm_reg_bus_op rw);
 apb_xaction t;if(!$cast(t,bus_item)) `uvm_fatal("RAL","wrong bus item")
 rw.kind=t.write?UVM_WRITE:UVM_READ;rw.addr=t.addr;rw.data=t.data;rw.byte_en=t.strb;rw.status=t.error?UVM_NOT_OK:UVM_IS_OK;
endfunction
