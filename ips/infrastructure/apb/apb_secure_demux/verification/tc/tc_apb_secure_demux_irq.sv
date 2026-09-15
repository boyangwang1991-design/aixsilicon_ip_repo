`ifndef TC_APB_SECURE_DEMUX_IRQ__SV
`define TC_APB_SECURE_DEMUX_IRQ__SV
// TC.APB_SECURE_DEMUX.IRQ.001
class tc_apb_secure_demux_irq_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_irq_sequence)
  extern function new(string name="tc_apb_secure_demux_irq_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_irq_sequence::new(string name="tc_apb_secure_demux_irq_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_irq_sequence::body();
  for(int bit_index=0;bit_index<9;bit_index++) begin
    csr_write(K_INTR_ENABLE,32'b1<<bit_index);
    csr_write(K_ALERT_ENABLE,32'b1<<bit_index);
    transfer(C_PORT_BASE[0],0,0,0,0);
    transfer(32'(C_CSR_BASE)+'h68);
    transfer(0);
    if(C_DFX_EN) csr_write(K_INTR_TEST,'h100);
    transfer(address_of(K_INTR_RAW));transfer(address_of(K_INTR_MASKED));
    csr_write(K_INTR_RAW,0);transfer(address_of(K_INTR_RAW));
    csr_write(K_INTR_RAW,'hffffffff);transfer(address_of(K_INTR_RAW));
  end
  allow_port(0,0);
  p_sequencer.cfg.downstream[0].slave_response_mode=APB_FIXED_WAIT;
  p_sequencer.cfg.downstream[0].default_wait_cycles=3;
  p_sequencer.cfg.downstream[0].slave_error_mode=APB_ERR_RANDOM;
  p_sequencer.cfg.downstream[0].slave_err_prob=1.0;
  if(C_DFX_EN) csr_write(K_WAIT_THRESHOLD,1);
  transfer(C_PORT_BASE[0]);transfer(address_of(K_INTR_RAW));
  if(C_DFX_EN && C_POLICY_PARITY_EN) begin
    p_sequencer.cfg.downstream[0].slave_error_mode=APB_ERR_NEVER;
    csr_write(K_INJECT_TARGET,0);csr_write(K_INJECT_CMD,4);transfer(C_PORT_BASE[0]);
    csr_write(K_INTR_RAW,'h1ff);transfer(address_of(K_INTR_RAW));
  end
endtask
class tc_apb_secure_demux_irq extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_irq)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_irq::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_irq::stimulus();
  tc_apb_secure_demux_irq_sequence seq;
  seq=tc_apb_secure_demux_irq_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_IRQ__SV
