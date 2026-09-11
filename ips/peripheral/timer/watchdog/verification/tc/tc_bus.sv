`ifndef TC_BUS__SV
`define TC_BUS__SV
// VPLAN: TC.WATCHDOG.BUS.001
class tc_bus extends tc_base;
  `uvm_component_utils(tc_bus)
  extern function new(string name="tc_bus",uvm_component parent=null);
endclass
function tc_bus::new(string name="tc_bus",uvm_component parent=null);
  super.new(name,parent);group_name="bus";feature_number=1;
endfunction
`endif
