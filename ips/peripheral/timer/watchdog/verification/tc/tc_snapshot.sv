`ifndef TC_SNAPSHOT__SV
`define TC_SNAPSHOT__SV
// VPLAN: TC.WATCHDOG.SNAPSHOT.001
class tc_snapshot extends tc_base;
  `uvm_component_utils(tc_snapshot)
  extern function new(string name="tc_snapshot",uvm_component parent=null);
endclass
function tc_snapshot::new(string name="tc_snapshot",uvm_component parent=null);
  super.new(name,parent);group_name="snapshot";feature_number=12;
endfunction
`endif
