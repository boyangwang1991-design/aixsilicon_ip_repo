`ifndef APB_SECURE_DEMUX_VIRTUAL_SEQUENCER__SV
`define APB_SECURE_DEMUX_VIRTUAL_SEQUENCER__SV
class apb_secure_demux_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(apb_secure_demux_virtual_sequencer)
  apb_master_sequencer upstream;
  apb_slave_sequencer downstream[ASD_NP];
  virtual apb_secure_demux_control_if control;
  apb_secure_demux_env_cfg cfg;
  extern function new(string name,uvm_component parent);
endclass
function apb_secure_demux_virtual_sequencer::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction


`endif // APB_SECURE_DEMUX_VIRTUAL_SEQUENCER__SV
