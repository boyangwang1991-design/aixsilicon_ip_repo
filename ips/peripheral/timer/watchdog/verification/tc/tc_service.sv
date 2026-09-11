`ifndef TC_SERVICE__SV
`define TC_SERVICE__SV
// VPLAN: TC.WATCHDOG.SERVICE.001
class tc_service extends tc_base;
  `uvm_component_utils(tc_service)
  extern function new(string name="tc_service",uvm_component parent=null);
endclass
function tc_service::new(string name="tc_service",uvm_component parent=null);
  super.new(name,parent);group_name="service";feature_number=3;
endfunction
`endif
