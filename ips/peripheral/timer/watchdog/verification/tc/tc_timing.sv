`ifndef TC_TIMING__SV
`define TC_TIMING__SV
// VPLAN: TC.WATCHDOG.TIMING.001
class tc_timing extends tc_base;
  `uvm_component_utils(tc_timing)
  extern function new(string name="tc_timing",uvm_component parent=null);
endclass
function tc_timing::new(string name="tc_timing",uvm_component parent=null);
  super.new(name,parent);group_name="timing";feature_number=9;
endfunction
`endif
