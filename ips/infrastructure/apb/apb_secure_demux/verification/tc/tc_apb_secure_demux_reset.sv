`ifndef TC_APB_SECURE_DEMUX_RESET__SV
`define TC_APB_SECURE_DEMUX_RESET__SV
// TC.APB_SECURE_DEMUX.RESET.001; repeat this test for every named configuration.
class tc_apb_secure_demux_reset_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_reset_sequence)
  extern function new(string name="tc_apb_secure_demux_reset_sequence");
  extern task pulse_reset();
  extern task check_reset_registers();
  extern task body();
endclass
function tc_apb_secure_demux_reset_sequence::new(string name="tc_apb_secure_demux_reset_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_reset_sequence::pulse_reset();
  @(negedge p_sequencer.control.pclk);
  p_sequencer.control.reset_n=0;
  #1ns;
  if(p_sequencer.control.m_sel!==0 || p_sequencer.control.s_ready!==0 ||
     p_sequencer.control.s_error!==0 || p_sequencer.control.s_rdata!==0 ||
     p_sequencer.control.irq!==0 || p_sequencer.control.alert!==0)
    `uvm_error("ASYNC_RESET","Outputs did not isolate asynchronously")
  repeat(3) @(negedge p_sequencer.control.pclk);
  p_sequencer.control.reset_n=1;
  repeat(2) @(negedge p_sequencer.control.pclk);
endtask
task tc_apb_secure_demux_reset_sequence::check_reset_registers();
  transfer(address_of(K_STATUS));transfer(address_of(K_POLICY_VERSION));
  transfer(address_of(K_INTR_RAW));transfer(address_of(K_INTR_ENABLE));
  transfer(address_of(K_ALERT_ENABLE));transfer(address_of(K_FIFO_STATUS));
  foreach(C_RESET_PORT_CFG[p]) begin
    transfer(address_of(K_PORT_LOCK,p));transfer(address_of(K_CFG_ACTIVE,p));
    transfer(address_of(K_CFG_SHADOW,p));
    for(int m=0;m<ASD_NM;m++) begin
      transfer(address_of(K_PERM_ACTIVE,p,m));transfer(address_of(K_PERM_SHADOW,p,m));
    end
  end
endtask
task tc_apb_secure_demux_reset_sequence::body();
  check_reset_registers();
  allow_port(0,0);
  csr_write(K_GLOBAL_LOCK,1);
  for(int n=0;n<int'(C_EVENT_FIFO_DEPTH)+2;n++) transfer(C_PORT_BASE[0],0,0,0,0);
  if(C_DFX_EN) begin csr_write(K_INJECT_TARGET,0);csr_write(K_INJECT_CMD,2);end
  // A peripheral-only reset must not reset the demux locks or policy.
  @(negedge p_sequencer.control.pclk);p_sequencer.control.peripheral_reset_n[0]=0;
  repeat(2) @(negedge p_sequencer.control.pclk);
  p_sequencer.control.peripheral_reset_n[0]=1;
  transfer(address_of(K_GLOBAL_LOCK));transfer(address_of(K_CFG_ACTIVE,0));
  pulse_reset();check_reset_registers();
  // Abort local SETUP and LOCAL ACCESS independently.
  for(int phase_index=0;phase_index<2;phase_index++) begin
    fork
      transfer(address_of(K_IP_ID));
      begin
        wait(p_sequencer.control.s_sel && p_sequencer.control.s_en==phase_index);
        pulse_reset();
      end
    join
    check_reset_registers();
  end
  // Abort forwarded SETUP, ACCESS and a long wait window.
  for(int phase_index=0;phase_index<3;phase_index++) begin
    allow_port(0,0);
    p_sequencer.cfg.downstream[0].slave_response_mode=APB_FIXED_WAIT;
    p_sequencer.cfg.downstream[0].default_wait_cycles=20;
    fork
      transfer(C_PORT_BASE[0],1,32'h01234567);
      begin
        wait(p_sequencer.control.m_sel[0] && p_sequencer.control.m_en[0]==(phase_index!=0));
        if(phase_index==2) repeat(5) @(negedge p_sequencer.control.pclk);
        pulse_reset();
      end
    join
    check_reset_registers();
  end
  if(C_DFX_EN && C_POLICY_PARITY_EN) begin
    allow_port(0,0);csr_write(K_INJECT_TARGET,0);csr_write(K_INJECT_CMD,4);
    transfer(C_PORT_BASE[0]);transfer(address_of(K_INTEGRITY_STATUS));
    pulse_reset();check_reset_registers();
  end
endtask
class tc_apb_secure_demux_reset extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_reset)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_reset::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_reset::stimulus();
  tc_apb_secure_demux_reset_sequence seq;
  seq=tc_apb_secure_demux_reset_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask

`endif // TC_APB_SECURE_DEMUX_RESET__SV
