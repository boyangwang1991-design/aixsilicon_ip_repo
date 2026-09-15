`ifndef TC_APB_SECURE_DEMUX_DFX__SV
`define TC_APB_SECURE_DEMUX_DFX__SV
// TC.APB_SECURE_DEMUX.DFX.001
class tc_apb_secure_demux_dfx_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_dfx_sequence)
  extern function new(string name="tc_apb_secure_demux_dfx_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_dfx_sequence::new(string name="tc_apb_secure_demux_dfx_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_dfx_sequence::body();
  if(!C_DFX_EN) begin
    transfer(32'(C_CSR_BASE)+'h100);transfer(32'(C_CSR_BASE)+'h110,1,2);
  end else begin
    allow_port(0,0);
    csr_write(K_INJECT_TARGET,(ASD_NM<<8));csr_write(K_INJECT_TARGET,ASD_NP);
    csr_write(K_INJECT_TARGET,0);csr_write(K_INJECT_CMD,0);csr_write(K_INJECT_CMD,3);
    csr_write(K_INJECT_CMD,2);csr_write(K_INJECT_CMD,2);csr_write(K_INJECT_TARGET,0);
    transfer(C_PORT_BASE[0],0,0,0,0);transfer(address_of(K_DFX_STATUS));
    transfer(C_PORT_BASE[0]);transfer(C_PORT_BASE[0]);transfer(address_of(K_DENY_COUNT));
    csr_write(K_INJECT_CMD,2);
    @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=0;
    transfer(C_PORT_BASE[0]);transfer(address_of(K_DFX_STATUS));
    @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=1;
    transfer(address_of(K_DFX_STATUS));
    p_sequencer.cfg.downstream[0].slave_response_mode=APB_FIXED_WAIT;
    p_sequencer.cfg.downstream[0].default_wait_cycles=5;
    for(int t=0;t<4;t++) begin
      csr_write(K_WAIT_THRESHOLD,t);csr_write(K_DFX_CLEAR,1);
      transfer(C_PORT_BASE[0]);transfer(address_of(K_DFX_STATUS));
      transfer(address_of(K_WAIT_TOTAL));transfer(address_of(K_WAIT_MAX));
    end
    csr_write(K_DFX_COUNTER_CLEAR,'h1f);transfer(address_of(K_WAIT_TOTAL));
    csr_write(K_INJECT_CMD,1);transfer(address_of(K_LAST_FAULT));
    for(int w=1;w<8;w++) transfer(address_of(K_LAST_FAULT,0,0,w));
    csr_write(K_INJECT_CMD,4);
    if(C_POLICY_PARITY_EN) begin transfer(C_PORT_BASE[0]);transfer(address_of(K_INTEGRITY_STATUS));end
  end
endtask
class tc_apb_secure_demux_dfx extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_dfx)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_dfx::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_dfx::stimulus();
  tc_apb_secure_demux_dfx_sequence seq;
  seq=tc_apb_secure_demux_dfx_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_DFX__SV
