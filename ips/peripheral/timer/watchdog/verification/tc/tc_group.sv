`ifndef TC_GROUP__SV
`define TC_GROUP__SV
// VPLAN: TC.WATCHDOG.GROUP.001
class tc_group extends tc_base;
  `uvm_component_utils(tc_group)
  extern function new(string name="tc_group",uvm_component parent=null);
endclass
function tc_group::new(string name="tc_group",uvm_component parent=null);
  super.new(name,parent);group_name="group";feature_number=6;
endfunction
`endif
