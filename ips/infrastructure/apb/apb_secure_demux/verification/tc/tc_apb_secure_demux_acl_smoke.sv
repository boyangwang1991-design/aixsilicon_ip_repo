`ifndef TC_APB_SECURE_DEMUX_ACL_SMOKE__SV
`define TC_APB_SECURE_DEMUX_ACL_SMOKE__SV
// Canonical TC.APB_SECURE_DEMUX.ACL.SMOKE
class tc_apb_secure_demux_acl_smoke_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_acl_smoke_sequence)
  extern function new(string name="tc_apb_secure_demux_acl_smoke_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_acl_smoke_sequence::new(string name="tc_apb_secure_demux_acl_smoke_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_acl_smoke_sequence::body();
    transfer(C_PORT_BASE[0]);
    allow_port(0,0,8'h02);
    transfer(C_PORT_BASE[0]);
    transfer(C_PORT_BASE[0],1,32'h12345678);
    allow_port(0,0);
    transfer(C_PORT_BASE[0],1,32'h12345678);
    transfer(C_PORT_BASE[0]);
    transfer(C_PORT_BASE[0],0,0,0,0);
    transfer(C_PORT_BASE[0],1,0,0,1,3'b101);
    csr_write(K_PERM_SHADOW,0,0,0);
    transfer(C_PORT_BASE[0]);
    csr_write(K_COMMIT_MASK,1);
    transfer(C_PORT_BASE[0]);
endtask
class tc_apb_secure_demux_acl_smoke extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_acl_smoke)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_acl_smoke::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_acl_smoke::stimulus();
  tc_apb_secure_demux_acl_smoke_sequence seq;
  seq=tc_apb_secure_demux_acl_smoke_sequence::type_id::create("sequence");
  seq.start(env.v_sqr);
endtask

`endif // TC_APB_SECURE_DEMUX_ACL_SMOKE__SV
