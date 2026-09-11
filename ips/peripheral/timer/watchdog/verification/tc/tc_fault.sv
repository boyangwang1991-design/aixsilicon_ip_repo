`ifndef TC_FAULT__SV
`define TC_FAULT__SV
// VPLAN: TC.WATCHDOG.FAULT.001
class tc_fault extends tc_base;
  `uvm_component_utils(tc_fault)
  extern function new(string name="tc_fault",uvm_component parent=null);
endclass
function tc_fault::new(string name="tc_fault",uvm_component parent=null);
  super.new(name,parent);group_name="fault";feature_number=13;
endfunction
`endif
