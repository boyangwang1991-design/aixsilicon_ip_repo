`ifndef TC_APB_SECURE_DEMUX_CSR_SMOKE__SV
`define TC_APB_SECURE_DEMUX_CSR_SMOKE__SV
// Canonical TC.APB_SECURE_DEMUX.CSR.SMOKE
class tc_apb_secure_demux_csr_smoke_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_csr_smoke_sequence)
  extern function new(string name="tc_apb_secure_demux_csr_smoke_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_csr_smoke_sequence::new(string name="tc_apb_secure_demux_csr_smoke_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_csr_smoke_sequence::body();
    transfer(address_of(K_IP_ID));
    transfer(address_of(K_CAP0));transfer(address_of(K_CAP1));
    csr_write(K_CFG_SHADOW,3,0);
    transfer(address_of(K_CFG_SHADOW,0));
    transfer(address_of(K_CFG_SHADOW,0),1,0,0,1,3'b010);
    transfer(address_of(K_CFG_SHADOW,0),0,0,0,1,3'b010);
    transfer(address_of(K_CFG_SHADOW,0));
    transfer(address_of(K_IP_ID),0,0,0,1,3'b010);
    csr_write(K_INTR_ENABLE,'h1ff);
    transfer(address_of(K_INTR_ENABLE));
    csr_write(K_INTR_RAW,'h1ff);
    transfer(address_of(K_INTR_MASKED));
    transfer(32'(C_CSR_BASE)+'h68);
    transfer(address_of(K_CFG_DENY_COUNT));
    transfer(address_of(K_FIRST_FAULT));
    for(int w=1;w<8;w++) transfer(address_of(K_FIRST_FAULT,0,0,w));
    csr_write(K_FAULT_CLEAR,'hf);
    transfer(address_of(K_FIFO_STATUS));
endtask
class tc_apb_secure_demux_csr_smoke extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_csr_smoke)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_csr_smoke::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_csr_smoke::stimulus();
  tc_apb_secure_demux_csr_smoke_sequence seq;
  seq=tc_apb_secure_demux_csr_smoke_sequence::type_id::create("sequence");
  seq.start(env.v_sqr);
endtask

`endif // TC_APB_SECURE_DEMUX_CSR_SMOKE__SV
