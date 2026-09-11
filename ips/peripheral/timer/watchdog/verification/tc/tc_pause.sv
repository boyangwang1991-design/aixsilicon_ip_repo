`ifndef TC_PAUSE__SV
`define TC_PAUSE__SV
// VPLAN: TC.WATCHDOG.PAUSE.001
class tc_pause extends tc_base;
  `uvm_component_utils(tc_pause)
  extern function new(string name="tc_pause",uvm_component parent=null);
endclass
function tc_pause::new(string name="tc_pause",uvm_component parent=null);
  super.new(name,parent);group_name="pause";feature_number=16;
endfunction
`endif
