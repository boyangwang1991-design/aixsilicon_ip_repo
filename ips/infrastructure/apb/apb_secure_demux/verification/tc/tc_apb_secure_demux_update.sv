`ifndef TC_APB_SECURE_DEMUX_UPDATE__SV
`define TC_APB_SECURE_DEMUX_UPDATE__SV
// TC.APB_SECURE_DEMUX.UPDATE.001
class tc_apb_secure_demux_update_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_update_sequence)
  extern function new(string name="tc_apb_secure_demux_update_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_update_sequence::new(string name="tc_apb_secure_demux_update_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_update_sequence::body();
  int unsigned mask;
  mask=(ASD_NP==32)?'1:((32'b1<<ASD_NP)-1);
  foreach(C_PORT_BASE[p]) begin
    enqueue(address_of(K_CFG_SHADOW,p),1,3);
    for(int m=0;m<ASD_NM;m++)
      enqueue(address_of(K_PERM_SHADOW,p,m),1,32'((p*17+m*3)&255));
    enqueue(C_PORT_BASE[p]);
  end
  enqueue(address_of(K_COMMIT_MASK),1,mask);
  foreach(C_PORT_BASE[p]) begin
    enqueue(C_PORT_BASE[p]);
    enqueue(address_of(K_CFG_ACTIVE,p));
    for(int m=0;m<ASD_NM;m++) enqueue(address_of(K_PERM_ACTIVE,p,m));
  end
  enqueue(address_of(K_POLICY_VERSION));
  enqueue(address_of(K_COMMIT_MASK),1,mask);
  enqueue(address_of(K_POLICY_VERSION));run_burst();
  csr_write(K_COMMIT_MASK,0);transfer(address_of(K_COMMIT_STATUS));
  if(ASD_NP<32) begin csr_write(K_COMMIT_MASK,32'b1<<ASD_NP);transfer(address_of(K_COMMIT_STATUS));end
  csr_write(K_CFG_SHADOW,0,0);csr_write(K_SHADOW_RELOAD,mask);
  transfer(address_of(K_CFG_SHADOW,0));transfer(address_of(K_POLICY_VERSION));
  csr_write(K_PORT_LOCK,1,0);csr_write(K_COMMIT_MASK,mask);
  transfer(address_of(K_COMMIT_STATUS));csr_write(K_SHADOW_RELOAD,mask);
  foreach(C_PORT_BASE[p]) transfer(address_of(K_CFG_ACTIVE,p));
  csr_write(K_PORT_LOCK,0,0);transfer(address_of(K_PORT_LOCK,0));
  csr_write(K_GLOBAL_LOCK,1);csr_write(K_GLOBAL_LOCK,0);
  csr_write(K_COMMIT_MASK,0);transfer(address_of(K_COMMIT_STATUS));
  csr_write(K_INTR_ENABLE,'h1ff);transfer(address_of(K_INTR_ENABLE));
endtask
class tc_apb_secure_demux_update extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_update)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_update::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_update::stimulus();
  tc_apb_secure_demux_update_sequence seq;
  seq=tc_apb_secure_demux_update_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_UPDATE__SV
