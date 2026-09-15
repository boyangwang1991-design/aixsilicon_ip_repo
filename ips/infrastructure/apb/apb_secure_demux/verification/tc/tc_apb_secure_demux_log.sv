`ifndef TC_APB_SECURE_DEMUX_LOG__SV
`define TC_APB_SECURE_DEMUX_LOG__SV
// TC.APB_SECURE_DEMUX.LOG.001
class tc_apb_secure_demux_log_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_log_sequence)
  extern function new(string name="tc_apb_secure_demux_log_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_log_sequence::new(string name="tc_apb_secure_demux_log_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_log_sequence::body();
  for(int n=0;n<int'(C_EVENT_FIFO_DEPTH)+3;n++) begin
    transfer(C_PORT_BASE[0],0,0,0,0);
    if(n==0) transfer(address_of(K_FIRST_FAULT));
  end
  transfer(address_of(K_FIFO_STATUS));transfer(address_of(K_EVENT_LOST_COUNT));
  for(int w=1;w<8;w++) transfer(address_of(K_FIRST_FAULT,0,0,w));
  transfer(address_of(K_LAST_FAULT));
  transfer(0);
  for(int w=1;w<8;w++) transfer(address_of(K_LAST_FAULT,0,0,w));
  if(C_EVENT_FIFO_DEPTH!=0) begin
    for(int n=0;n<int'(C_EVENT_FIFO_DEPTH);n++) begin
      for(int w=0;w<8;w++) transfer(address_of(K_FIFO_HEAD,0,0,w));
      transfer(address_of(K_FIFO_STATUS));csr_write(K_FIFO_POP,0);
      csr_write(K_FIFO_POP,1);
    end
    csr_write(K_FIFO_POP,0);
  end else begin transfer(32'(C_CSR_BASE)+'he0);transfer(32'(C_CSR_BASE)+'h4c,1,1);end
  csr_write(K_FAULT_CLEAR,'hf);transfer(address_of(K_FIRST_FAULT));transfer(address_of(K_LAST_FAULT));
  transfer(address_of(K_FIFO_STATUS));csr_write(K_COUNTER_CLEAR,'hf);
  transfer(address_of(K_ACCESS_DENY_COUNT));transfer(address_of(K_CFG_DENY_COUNT));
  transfer(address_of(K_EVENT_LOST_COUNT));transfer(address_of(K_DOWNSTREAM_ERR_COUNT));
  if(C_DFX_EN) begin
    csr_write(K_INJECT_CMD,1);
    for(int w=0;w<8;w++) transfer(address_of(K_LAST_FAULT,0,0,w));
  end
endtask
class tc_apb_secure_demux_log extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_log)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_log::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_log::stimulus();
  tc_apb_secure_demux_log_sequence seq;
  seq=tc_apb_secure_demux_log_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_LOG__SV
