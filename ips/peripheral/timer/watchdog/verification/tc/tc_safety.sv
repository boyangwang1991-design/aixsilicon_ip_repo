`ifndef TC_SAFETY__SV
`define TC_SAFETY__SV
// VPLAN: TC.WATCHDOG.SAFETY.001
class tc_safety extends tc_base;
  `uvm_component_utils(tc_safety)
  extern function new(string name="tc_safety",uvm_component parent=null);
endclass
function tc_safety::new(string name="tc_safety",uvm_component parent=null);
  super.new(name,parent);group_name="safety";feature_number=17;
endfunction
`endif
