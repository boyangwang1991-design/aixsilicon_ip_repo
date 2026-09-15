`ifndef TC_APB_SECURE_DEMUX_APB_SMOKE__SV
`define TC_APB_SECURE_DEMUX_APB_SMOKE__SV
// Canonical TC.APB_SECURE_DEMUX.APB.SMOKE
class tc_apb_secure_demux_apb_smoke_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_apb_smoke_sequence)
  extern function new(string name="tc_apb_secure_demux_apb_smoke_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_apb_smoke_sequence::new(string name="tc_apb_secure_demux_apb_smoke_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_apb_smoke_sequence::body();
    allow_port(0,0);
    transfer(C_PORT_BASE[0],1,32'h12345678);
    transfer(C_PORT_BASE[0]);
    p_sequencer.cfg.downstream[0].slave_response_mode=APB_FIXED_WAIT;
    p_sequencer.cfg.downstream[0].default_wait_cycles=3;
    transfer(C_PORT_BASE[0]+4,1,32'hbeef,0,1,3'b001,4'b0011);
    transfer(C_PORT_BASE[0]+4);
    transfer(address_of(K_SUCCESS_COUNT));
    transfer(address_of(K_WAIT_TOTAL));
    transfer(address_of(K_WAIT_MAX));
    p_sequencer.cfg.downstream[0].slave_error_mode=APB_ERR_RANDOM;
    p_sequencer.cfg.downstream[0].slave_err_prob=1.0;
    enqueue(address_of(K_IP_ID));enqueue(C_PORT_BASE[0]);enqueue(address_of(K_INTR_RAW));
    run_burst();
endtask
class tc_apb_secure_demux_apb_smoke extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_apb_smoke)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_apb_smoke::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_apb_smoke::stimulus();
  tc_apb_secure_demux_apb_smoke_sequence seq;
  seq=tc_apb_secure_demux_apb_smoke_sequence::type_id::create("sequence");
  seq.start(env.v_sqr);
endtask

`endif // TC_APB_SECURE_DEMUX_APB_SMOKE__SV
