`ifndef TC_HW_EVENT__SV
`define TC_HW_EVENT__SV
// VPLAN: TC.WATCHDOG.HW_EVENT.001
class tc_hw_event extends tc_base;
  `uvm_component_utils(tc_hw_event)
  extern function new(string name="tc_hw_event",uvm_component parent=null);
endclass
function tc_hw_event::new(string name="tc_hw_event",uvm_component parent=null);
  super.new(name,parent);group_name="hw_event";feature_number=4;
endfunction
`endif
