`ifndef TC_APB_SECURE_DEMUX_APB__SV
`define TC_APB_SECURE_DEMUX_APB__SV
// TC.APB_SECURE_DEMUX.APB.001
class tc_apb_secure_demux_apb_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_apb_sequence)
  extern function new(string name="tc_apb_secure_demux_apb_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_apb_sequence::new(string name="tc_apb_secure_demux_apb_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_apb_sequence::body();
  int waits_set[4]='{0,1,17,257};
  foreach(C_PORT_BASE[p]) allow_port(p,0);
  foreach(waits_set[w]) begin
    foreach(C_PORT_BASE[p]) begin
      p_sequencer.cfg.downstream[p].slave_response_mode=waits_set[w]==0?APB_ZERO_WAIT:APB_FIXED_WAIT;
      p_sequencer.cfg.downstream[p].default_wait_cycles=waits_set[w];
      enqueue(C_PORT_BASE[p],1,32'hcafe0000+p);
      enqueue(address_of(K_IP_ID));enqueue(C_PORT_BASE[p]);
      enqueue(C_PORT_BASE[p],0,0,0,0);
    end
    run_burst();
  end
  foreach(C_PORT_BASE[p]) begin
    p_sequencer.cfg.downstream[p].slave_response_mode=APB_FIXED_WAIT;
    p_sequencer.cfg.downstream[p].default_wait_cycles=1;
    p_sequencer.cfg.downstream[p].slave_error_mode=APB_ERR_RANDOM;
    p_sequencer.cfg.downstream[p].slave_err_prob=1.0;
    enqueue(C_PORT_BASE[p]);enqueue(address_of(K_INTR_RAW));
  end
  run_burst();
  p_sequencer.cfg.downstream[0].slave_error_mode=APB_ERR_NEVER;
  p_sequencer.cfg.downstream[0].default_wait_cycles=17;
  fork
    transfer(C_PORT_BASE[0]);
    begin
      wait(p_sequencer.control.m_sel[0] && p_sequencer.control.m_en[0]);
      @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=0;
    end
  join
  @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=1;
  if(C_POLICY_PARITY_EN) begin
    fork
      transfer(C_PORT_BASE[0]);
      begin
        wait(p_sequencer.control.m_sel[0] && p_sequencer.control.m_en[0]);
        inject_field(4,0,0);
      end
    join
    transfer(C_PORT_BASE[0]);transfer(address_of(K_INTEGRITY_STATUS));
    release_faults();reset_policy();
  end
endtask
class tc_apb_secure_demux_apb extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_apb)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_apb::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_apb::stimulus();
  tc_apb_secure_demux_apb_sequence seq;
  seq=tc_apb_secure_demux_apb_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask
`endif

