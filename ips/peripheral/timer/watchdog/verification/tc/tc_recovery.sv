`ifndef TC_RECOVERY__SV
`define TC_RECOVERY__SV
// VPLAN: TC.WATCHDOG.RECOVERY.001
class tc_recovery extends tc_base;
  `uvm_component_utils(tc_recovery)
  extern function new(string name="tc_recovery",uvm_component parent=null);
endclass
function tc_recovery::new(string name="tc_recovery",uvm_component parent=null);
  super.new(name,parent);group_name="recovery";feature_number=14;
endfunction
`endif
