`ifndef APB_SECURE_DEMUX_RM_CFG__SV
`define APB_SECURE_DEMUX_RM_CFG__SV
class apb_secure_demux_rm_cfg extends uvm_object;
  `uvm_object_utils(apb_secure_demux_rm_cfg)
  int fifo_depth=int'(C_EVENT_FIFO_DEPTH);
  bit parity_enabled=bit'(C_POLICY_PARITY_EN),dfx_enabled=bit'(C_DFX_EN);
  extern function new(string name="apb_secure_demux_rm_cfg");
endclass
function apb_secure_demux_rm_cfg::new(string name="apb_secure_demux_rm_cfg");
  super.new(name);
endfunction

`endif // APB_SECURE_DEMUX_RM_CFG__SV
