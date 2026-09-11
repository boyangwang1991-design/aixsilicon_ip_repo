`ifndef TC_FLOW__SV
`define TC_FLOW__SV
// VPLAN: TC.WATCHDOG.FLOW.001
class tc_flow extends tc_base;
  `uvm_component_utils(tc_flow)
  extern function new(string name="tc_flow",uvm_component parent=null);
endclass
function tc_flow::new(string name="tc_flow",uvm_component parent=null);
  super.new(name,parent);group_name="flow";feature_number=8;
endfunction
`endif
