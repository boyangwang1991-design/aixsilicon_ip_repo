`ifndef TC_ALIVE__SV
`define TC_ALIVE__SV
// VPLAN: TC.WATCHDOG.ALIVE.001
class tc_alive extends tc_base;
  `uvm_component_utils(tc_alive)
  extern function new(string name="tc_alive",uvm_component parent=null);
endclass
function tc_alive::new(string name="tc_alive",uvm_component parent=null);
  super.new(name,parent);group_name="alive";feature_number=7;
endfunction
`endif
