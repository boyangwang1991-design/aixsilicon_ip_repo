`ifndef TC_RESET__SV
`define TC_RESET__SV
// VPLAN: TC.WATCHDOG.RESET.001
class tc_reset extends tc_base;
  `uvm_component_utils(tc_reset)
  extern function new(string name="tc_reset",uvm_component parent=null);
endclass
function tc_reset::new(string name="tc_reset",uvm_component parent=null);
  super.new(name,parent);group_name="reset";feature_number=15;
endfunction
`endif
