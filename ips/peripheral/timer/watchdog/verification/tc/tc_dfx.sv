`ifndef TC_DFX__SV
`define TC_DFX__SV
// VPLAN: TC.WATCHDOG.DFX.001
class tc_dfx extends tc_base;
  `uvm_component_utils(tc_dfx)
  extern function new(string name="tc_dfx",uvm_component parent=null);
endclass
function tc_dfx::new(string name="tc_dfx",uvm_component parent=null);
  super.new(name,parent);group_name="dfx";feature_number=18;
endfunction
`endif
