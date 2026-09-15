`ifndef APB_SECURE_DEMUX_CHECKER_CFG__SV
`define APB_SECURE_DEMUX_CHECKER_CFG__SV
class apb_secure_demux_checker_cfg extends uvm_object;
  `uvm_object_utils(apb_secure_demux_checker_cfg)
  int timeout_cycles=200000;
  extern function new(string name="apb_secure_demux_checker_cfg");
endclass
function apb_secure_demux_checker_cfg::new(string name="apb_secure_demux_checker_cfg");
  super.new(name);
endfunction

`endif // APB_SECURE_DEMUX_CHECKER_CFG__SV
