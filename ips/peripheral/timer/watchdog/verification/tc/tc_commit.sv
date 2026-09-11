`ifndef TC_COMMIT__SV
`define TC_COMMIT__SV
// VPLAN: TC.WATCHDOG.COMMIT.001
class tc_commit extends tc_base;
  `uvm_component_utils(tc_commit)
  extern function new(string name="tc_commit",uvm_component parent=null);
endclass
function tc_commit::new(string name="tc_commit",uvm_component parent=null);
  super.new(name,parent);group_name="commit";feature_number=10;
endfunction
`endif
