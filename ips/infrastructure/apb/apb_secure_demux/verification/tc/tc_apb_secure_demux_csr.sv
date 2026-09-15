`ifndef TC_APB_SECURE_DEMUX_CSR__SV
`define TC_APB_SECURE_DEMUX_CSR__SV
// TC.APB_SECURE_DEMUX.CSR.001
class tc_apb_secure_demux_csr_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_csr_sequence)
  extern function new(string name="tc_apb_secure_demux_csr_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_csr_sequence::new(string name="tc_apb_secure_demux_csr_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_csr_sequence::body();
  // Generated structure is used only for addresses/access shape; RM owns behavior.
  foreach(REG_ADDR[i]) begin
    enqueue(32'(C_CSR_BASE)+REG_ADDR[i]);
    if(!REG_WRITABLE[i]) enqueue(32'(C_CSR_BASE)+REG_ADDR[i],1,'1);
    enqueue(32'(C_CSR_BASE)+REG_ADDR[i],0,0,0,1,3'b010);
    enqueue(32'(C_CSR_BASE)+REG_ADDR[i],1,'1,0,1,3'b010);
  end
  run_burst();
  for(int strobe=0;strobe<16;strobe++)
    for(int low=0;low<4;low++)
      transfer(address_of(K_INTR_ENABLE)+low,1,'1,0,1,3'b001,4'(strobe));
  transfer(address_of(K_INTR_ENABLE));
  foreach(C_PORT_BASE[p]) for(int m=0;m<ASD_NM;m++) begin
    enqueue(address_of(K_PERM_SHADOW,p,m),1,'1);
    enqueue(address_of(K_PERM_SHADOW,p,m));
  end
  run_burst();
  for(int prot=0;prot<8;prot++) for(int valid=0;valid<2;valid++) begin
    transfer(address_of(K_IP_ID),0,0,0,valid,3'(prot));
    transfer(32'(C_CSR_BASE)+'h68,0,0,0,valid,3'(prot));
  end
  @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=0;
  transfer(32'(C_CSR_BASE)+'h100);transfer(32'(C_CSR_BASE)+'h114);
  @(negedge p_sequencer.control.pclk);p_sequencer.control.authorized=1;
endtask
class tc_apb_secure_demux_csr extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_csr)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_csr::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_csr::stimulus();
  tc_apb_secure_demux_csr_sequence seq;
  seq=tc_apb_secure_demux_csr_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_CSR__SV
