`ifndef WATCHDOG_VIRTUAL_SEQUENCER__SV
`define WATCHDOG_VIRTUAL_SEQUENCER__SV
class watchdog_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(watchdog_virtual_sequencer)
  apb_master_sequencer apb_sqr;
  watchdog_control_sequencer control_sqr;
  watchdog_env_cfg cfg;
  extern function new(string name,uvm_component parent);
endclass
function watchdog_virtual_sequencer::new(string name,uvm_component parent);super.new(name,parent);endfunction
`endif
