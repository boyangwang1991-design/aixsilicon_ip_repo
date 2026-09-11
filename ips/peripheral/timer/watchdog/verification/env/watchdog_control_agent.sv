`ifndef WATCHDOG_CONTROL_AGENT__SV
`define WATCHDOG_CONTROL_AGENT__SV
class watchdog_control_sequencer extends uvm_sequencer #(watchdog_control_item);
  `uvm_component_utils(watchdog_control_sequencer)
  extern function new(string name,uvm_component parent);
endclass
function watchdog_control_sequencer::new(string name,uvm_component parent);super.new(name,parent);endfunction
class watchdog_control_agent extends uvm_agent;
  `uvm_component_utils(watchdog_control_agent)
  watchdog_control_driver driver;
  watchdog_control_sequencer sequencer;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass
function watchdog_control_agent::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void watchdog_control_agent::build_phase(uvm_phase phase);
  driver=watchdog_control_driver::type_id::create("driver",this);
  sequencer=watchdog_control_sequencer::type_id::create("sequencer",this);
endfunction
function void watchdog_control_agent::connect_phase(uvm_phase phase);
  driver.seq_item_port.connect(sequencer.seq_item_export);
endfunction
`endif
