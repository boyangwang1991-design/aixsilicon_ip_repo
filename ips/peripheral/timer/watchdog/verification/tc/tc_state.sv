`ifndef TC_STATE__SV
`define TC_STATE__SV
// VPLAN: TC.WATCHDOG.STATE.001
class tc_state extends tc_base;
  `uvm_component_utils(tc_state)
  extern function new(string name="tc_state",uvm_component parent=null);
endclass
function tc_state::new(string name="tc_state",uvm_component parent=null);
  super.new(name,parent);group_name="state";feature_number=5;
endfunction
`endif
