class apb_interface_agent extends uvm_agent;
 `uvm_component_utils(apb_interface_agent)
 apb_driver drv; apb_monitor mon;uvm_sequencer#(apb_xaction) sqr;
 extern function new(string name,uvm_component parent);
 extern function void build_phase(uvm_phase phase);
 extern function void connect_phase(uvm_phase phase);
endclass
function apb_interface_agent::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void apb_interface_agent::build_phase(uvm_phase phase);
 super.build_phase(phase);drv=apb_driver::type_id::create("drv",this);mon=apb_monitor::type_id::create("mon",this);sqr=new("sqr",this);
endfunction
function void apb_interface_agent::connect_phase(uvm_phase phase);drv.seq_item_port.connect(sqr.seq_item_export);endfunction
