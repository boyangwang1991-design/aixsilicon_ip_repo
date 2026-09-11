`ifndef TC_CDC__SV
`define TC_CDC__SV
// VPLAN: TC.WATCHDOG.CDC.001
class tc_cdc extends tc_base;
  `uvm_component_utils(tc_cdc)
  extern function new(string name="tc_cdc",uvm_component parent=null);
endclass
function tc_cdc::new(string name="tc_cdc",uvm_component parent=null);
  super.new(name,parent);group_name="cdc";feature_number=2;
endfunction
`endif
