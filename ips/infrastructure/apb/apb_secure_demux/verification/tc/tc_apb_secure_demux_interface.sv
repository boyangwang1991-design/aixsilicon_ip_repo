`ifndef TC_APB_SECURE_DEMUX_INTERFACE__SV
`define TC_APB_SECURE_DEMUX_INTERFACE__SV
// TC.APB_SECURE_DEMUX.INTERFACE.001
class tc_apb_secure_demux_interface_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_interface_sequence)
  extern function new(string name="tc_apb_secure_demux_interface_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_interface_sequence::new(string name="tc_apb_secure_demux_interface_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_interface_sequence::body();
  foreach(C_PORT_BASE[p]) begin
    allow_port(p,ASD_NM-1);
    p_sequencer.cfg.downstream[p].slave_response_mode=APB_FIXED_WAIT;
    p_sequencer.cfg.downstream[p].default_wait_cycles=17;
    transfer(C_PORT_BASE[p],1,32'h89abcdef,ASD_NM-1);
    transfer(C_PORT_BASE[p],0,0,ASD_NM-1);
  end
  @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=0;
  foreach(C_PORT_BASE[p]) enqueue(C_PORT_BASE[p],0,0,ASD_NM-1);
  run_burst();
  @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=1;
  foreach(C_PORT_BASE[p]) begin
    enqueue(C_PORT_BASE[p],0,0,ASD_NM-1);
    enqueue(C_PORT_BASE[p],0,0,0,0);
    enqueue(address_of(K_IP_ID));
  end
  run_burst();
endtask
class tc_apb_secure_demux_interface extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_interface)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_interface::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_interface::stimulus();
  tc_apb_secure_demux_interface_sequence seq;
  seq=tc_apb_secure_demux_interface_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask
`endif

