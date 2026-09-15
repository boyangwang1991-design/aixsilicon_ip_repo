`ifndef APB_SECURE_DEMUX_DUT_CFG__SV
`define APB_SECURE_DEMUX_DUT_CFG__SV
class apb_secure_demux_dut_cfg extends uvm_object;
  `uvm_object_utils(apb_secure_demux_dut_cfg)
  int num_ports=ASD_NP,num_masters=ASD_NM;
  int addr_width=int'(C_ADDR_WIDTH),id_width=int'(C_MASTER_ID_WIDTH);
  bit registered_mode=bit'(C_REGISTER_MODE);
  extern function new(string name="apb_secure_demux_dut_cfg");
endclass
function apb_secure_demux_dut_cfg::new(string name="apb_secure_demux_dut_cfg");
  super.new(name);
endfunction

`endif // APB_SECURE_DEMUX_DUT_CFG__SV
