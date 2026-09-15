`ifndef TC_APB_SECURE_DEMUX_ACL__SV
`define TC_APB_SECURE_DEMUX_ACL__SV
// TC.APB_SECURE_DEMUX.ACL.001
class tc_apb_secure_demux_acl_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_acl_sequence)
  extern function new(string name="tc_apb_secure_demux_acl_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_acl_sequence::new(string name="tc_apb_secure_demux_acl_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_acl_sequence::body();
  foreach(C_PORT_BASE[p]) begin
    enqueue(address_of(K_CFG_SHADOW,p),1,3);
    for(int m=0;m<ASD_NM;m++) begin
      for(int bit_index=0;bit_index<8;bit_index++) begin
        enqueue(address_of(K_PERM_SHADOW,p,m),1,32'b1<<bit_index);
        enqueue(address_of(K_COMMIT_MASK),1,32'b1<<p);
        enqueue(C_PORT_BASE[p],bit_index>=4,32'h13579bdf,m,1,3'(bit_index%4));
        enqueue(C_PORT_BASE[p],bit_index<4,32'h2468ace0,m,1,3'(bit_index%4),0);
        enqueue(C_PORT_BASE[p],bit_index>=4,0,m,1,3'(4+bit_index%4));
      end
      enqueue(C_PORT_BASE[p],0,0,m,0);
    end
    run_burst();
    csr_write(K_CFG_SHADOW,0,p);csr_write(K_COMMIT_MASK,32'b1<<p);
    transfer(C_PORT_BASE[p]);
  end
  if(C_MASTER_ID_WIDTH>$clog2(ASD_NM))
    transfer(C_PORT_BASE[0],0,0,ASD_NM);
  else if((64'b1<<C_MASTER_ID_WIDTH)>ASD_NM)
    transfer(C_PORT_BASE[0],0,0,ASD_NM);
endtask
class tc_apb_secure_demux_acl extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_acl)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_acl::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_acl::stimulus();
  tc_apb_secure_demux_acl_sequence seq;
  seq=tc_apb_secure_demux_acl_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_ACL__SV
