`ifndef TC_APB_SECURE_DEMUX_ERROR__SV
`define TC_APB_SECURE_DEMUX_ERROR__SV
// TC.APB_SECURE_DEMUX.ERROR.001
class tc_apb_secure_demux_error_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_error_sequence)
  extern function new(string name="tc_apb_secure_demux_error_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_error_sequence::new(string name="tc_apb_secure_demux_error_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_error_sequence::body();
  transfer(0,0,0,0,0);
  transfer(C_PORT_BASE[0],1,0,0,0,3'b101);
  transfer(C_PORT_BASE[0],1,0,0,1,3'b101);
  allow_port(0,0,0);
  transfer(C_PORT_BASE[0],1,0,0,1,3'b101);
  transfer(C_PORT_BASE[0],0,0,0,1,3'b001);
  for(int low=0;low<4;low++) begin
    transfer(32'(C_CSR_BASE)+'h68+low,1,'1,0,1,3'b010,1);
    transfer(32'(C_CSR_BASE)+'h68+low,1,'1,0,1,3'b001,1);
  end
  transfer(address_of(K_IP_ID),1,'1);
  csr_write(K_GLOBAL_LOCK,1);csr_write(K_COMMIT_MASK,0);
  transfer(address_of(K_COMMIT_STATUS));transfer(address_of(K_LAST_FAULT));
  for(int w=1;w<8;w++) transfer(address_of(K_LAST_FAULT,0,0,w));
  csr_write(K_SHADOW_RELOAD,0);csr_write(K_CFG_SHADOW,3,0);
  if(C_DFX_EN && C_POLICY_PARITY_EN) begin
    // Locking does not prohibit authorized diagnostics.
    csr_write(K_INJECT_TARGET,0);csr_write(K_INJECT_CMD,4);
    transfer(C_PORT_BASE[0]);csr_write(K_COMMIT_MASK,0);
    transfer(address_of(K_COMMIT_STATUS));
  end
endtask
class tc_apb_secure_demux_error extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_error)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_error::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_error::stimulus();
  tc_apb_secure_demux_error_sequence seq;
  seq=tc_apb_secure_demux_error_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_ERROR__SV
