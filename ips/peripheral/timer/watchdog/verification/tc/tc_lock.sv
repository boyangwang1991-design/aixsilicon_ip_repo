`ifndef TC_LOCK__SV
`define TC_LOCK__SV
// VPLAN: TC.WATCHDOG.LOCK.001
class tc_lock extends tc_base;
  `uvm_component_utils(tc_lock)
  extern function new(string name="tc_lock",uvm_component parent=null);
endclass
function tc_lock::new(string name="tc_lock",uvm_component parent=null);
  super.new(name,parent);group_name="lock";feature_number=11;
endfunction
`endif
