`ifndef APB_SECURE_DEMUX_VIRTUAL_SEQUENCE__SV
`define APB_SECURE_DEMUX_VIRTUAL_SEQUENCE__SV
// One requester sequence owns APB and MASTERID together. Identity is set before
// finish_item hands the item to VIP, and is retained through item_done.
class apb_secure_demux_transfer extends uvm_sequence#(apb_item);
  `uvm_object_utils(apb_secure_demux_transfer)
  virtual apb_secure_demux_control_if control;
  asd_request_t request;
  apb_item response_item;
  extern function new(string name="apb_secure_demux_transfer");
  extern task body();
endclass
function apb_secure_demux_transfer::new(string name="apb_secure_demux_transfer");
  super.new(name);
endfunction
task apb_secure_demux_transfer::body();
  response_item=apb_item::type_id::create("request");
  start_item(response_item);
  @(negedge control.pclk);
  control.master_id=request.master;control.master_valid=request.valid;
  response_item.addr=request.addr;response_item.direction=request.write?APB_WRITE:APB_READ;
  response_item.wdata=request.data;response_item.strb=request.strb;
  response_item.prot=apb_protection'(request.prot);response_item.start_delay=0;
  // VIP clocking outputs use +1 skew relative to a posedge. Delivering at
  // negedge would collapse SETUP and ACCESS into the same scheduled edge.
  @(posedge control.pclk);
  finish_item(response_item);
  #1ns;
endtask
class apb_secure_demux_burst extends uvm_sequence#(apb_item);
  `uvm_object_utils(apb_secure_demux_burst)
  virtual apb_secure_demux_control_if control;
  asd_request_t requests[$];
  extern function new(string name="apb_secure_demux_burst");
  extern task body();
endclass
function apb_secure_demux_burst::new(string name="apb_secure_demux_burst");
  super.new(name);
endfunction
task apb_secure_demux_burst::body();
  apb_item item;
  foreach(requests[n]) begin
    item=apb_item::type_id::create($sformatf("item_%0d",n));
    start_item(item);
    if(n==0) @(posedge control.pclk);
    // Subsequent item_done occurs on the completion edge. Both sideband and
    // VIP APB outputs change at +1ns, after the previous transaction sampling.
    control.drive_cb.master_id<=requests[n].master;
    control.drive_cb.master_valid<=requests[n].valid;
    item.addr=requests[n].addr;item.direction=requests[n].write?APB_WRITE:APB_READ;
    item.wdata=requests[n].data;item.strb=requests[n].strb;
    item.prot=apb_protection'(requests[n].prot);item.start_delay=0;
    finish_item(item);
  end
  #1ns;
endtask
class apb_secure_demux_virtual_sequence extends uvm_sequence;
  `uvm_object_utils(apb_secure_demux_virtual_sequence)
  `uvm_declare_p_sequencer(apb_secure_demux_virtual_sequencer)
  asd_request_t queued[$];
  string forced_paths[$];
  uvm_hdl_data_t saved_values[$];
  extern function new(string name="apb_secure_demux_virtual_sequence");
  extern task transfer(int unsigned address,bit write=0,int unsigned data=0,
                       int unsigned master=0,bit valid=1,bit [2:0] prot=3'b001,
                       bit [3:0] strb=4'hf);
  extern task csr_write(register_kind_t kind,int unsigned value,int port=0,int master=0);
  extern function int unsigned address_of(register_kind_t kind,int port=0,int master=0,int word_index=0);
  extern task allow_port(int port,int master,byte permission='hff,bit [1:0] config_value=3);
  extern function void enqueue(int unsigned address,bit write=0,int unsigned data=0,
                              int unsigned master=0,bit valid=1,bit [2:0] prot=3'b001,
                              bit [3:0] strb=4'hf);
  extern task run_burst();
  extern task inject_field(int kind,int port=0,int master=0,bit data_fault=0,int bit_index=0);
  extern task reset_policy();
  extern task release_faults();
endclass
function apb_secure_demux_virtual_sequence::new(string name="apb_secure_demux_virtual_sequence");
  super.new(name);
endfunction
function void apb_secure_demux_virtual_sequence::enqueue(int unsigned address,bit write=0,
    int unsigned data=0,int unsigned master=0,bit valid=1,bit [2:0] prot=3'b001,bit [3:0] strb=4'hf);
  queued.push_back('{addr:address,data:data,strb:strb,prot:prot,write:write,valid:valid,master:master});
endfunction
task apb_secure_demux_virtual_sequence::run_burst();
  apb_secure_demux_burst seq;
  seq=apb_secure_demux_burst::type_id::create("burst");seq.control=p_sequencer.control;
  seq.requests=queued;queued.delete();seq.start(p_sequencer.upstream);
endtask
task apb_secure_demux_virtual_sequence::inject_field(int kind,int port=0,int master=0,
                                                    bit data_fault=0,int bit_index=0);
  string path;
  uvm_hdl_data_t old_value;
  case(kind)
    0:path="g_protected.global_lock_q";
    1:path=$sformatf("g_protected.port_lock_q[%0d]",port);
    2:path=data_fault?$sformatf("active_cfg_o[%0d]",port):$sformatf("g_protected.cfg_active_parity_q[%0d]",port);
    3:path=data_fault?$sformatf("shadow_cfg_o[%0d]",port):$sformatf("g_protected.cfg_shadow_parity_q[%0d]",port);
    4:path=data_fault?$sformatf("active_perm_o[%0d][%0d]",port,master):$sformatf("g_protected.perm_active_parity_q[%0d][%0d]",port,master);
    5:path=data_fault?$sformatf("shadow_perm_o[%0d][%0d]",port,master):$sformatf("g_protected.perm_shadow_parity_q[%0d][%0d]",port,master);
    default:`uvm_fatal("FAULT_LOCATION","Invalid fault kind")
  endcase
  path={"harness.dut.u_csr.u_policy.",path};
  @(negedge p_sequencer.control.pclk);
  if(!uvm_hdl_read(path,old_value)) `uvm_fatal("FAULT_READ",path)
  if(!uvm_hdl_force(path,old_value^(uvm_hdl_data_t'(1)<<bit_index))) `uvm_fatal("FAULT_FORCE",path)
  forced_paths.push_back(path);saved_values.push_back(old_value);
  p_sequencer.control.fault_active=1;p_sequencer.control.fault_data=data_fault;
  p_sequencer.control.fault_kind=kind;p_sequencer.control.fault_port=port;
  p_sequencer.control.fault_master=master;p_sequencer.control.fault_bit=bit_index;
  `uvm_info("FAULT",$sformatf("force %s bit=%0d original=%h",path,bit_index,old_value),UVM_LOW)
endtask
task apb_secure_demux_virtual_sequence::release_faults();
  @(negedge p_sequencer.control.pclk);
  foreach(forced_paths[n]) begin
    if(!uvm_hdl_release(forced_paths[n])) `uvm_fatal("FAULT_RELEASE",forced_paths[n])
    if(!uvm_hdl_deposit(forced_paths[n],saved_values[n])) `uvm_fatal("FAULT_RESTORE",forced_paths[n])
  end
  forced_paths.delete();saved_values.delete();p_sequencer.control.fault_active=0;
endtask
task apb_secure_demux_virtual_sequence::reset_policy();
  @(negedge p_sequencer.control.pclk);p_sequencer.control.reset_n=0;
  repeat(3) @(negedge p_sequencer.control.pclk);
  p_sequencer.control.reset_n=1;
  repeat(2) @(negedge p_sequencer.control.pclk);
endtask
function int unsigned apb_secure_demux_virtual_sequence::address_of(register_kind_t kind,
    int port=0,int master=0,int word_index=0);
  foreach(REG_KIND[i]) if(REG_KIND[i]==kind && REG_PORT[i]==port &&
      REG_MASTER[i]==master && REG_WORD[i]==word_index) return 32'(C_CSR_BASE)+REG_ADDR[i];
  `uvm_fatal("SEQ_STRUCTURE",$sformatf("Missing register %s p=%0d m=%0d",kind.name(),port,master))
  return 0;
endfunction
task apb_secure_demux_virtual_sequence::transfer(int unsigned address,bit write=0,
    int unsigned data=0,int unsigned master=0,bit valid=1,bit [2:0] prot=3'b001,bit [3:0] strb=4'hf);
  apb_secure_demux_transfer seq;
  if(C_ADDR_WIDTH<32 && (64'(address)>>C_ADDR_WIDTH)!=0)
    `uvm_fatal("ADDRESS_WIDTH","Out-of-range address must not be silently truncated")
  if((64'(master)>>C_MASTER_ID_WIDTH)!=0)
    `uvm_fatal("MASTER_WIDTH","Out-of-range identity must not be silently truncated")
  seq=apb_secure_demux_transfer::type_id::create("transfer");
  seq.control=p_sequencer.control;
  seq.request='{addr:address,data:data,strb:strb,prot:prot,write:write,valid:valid,master:master};
  seq.start(p_sequencer.upstream);
endtask
task apb_secure_demux_virtual_sequence::csr_write(register_kind_t kind,int unsigned value,
                                                int port=0,int master=0);
  transfer(address_of(kind,port,master),1,value);
endtask
task apb_secure_demux_virtual_sequence::allow_port(int port,int master,byte permission='hff,
                                                bit [1:0] config_value=3);
  csr_write(K_CFG_SHADOW,32'(config_value),port);
  csr_write(K_PERM_SHADOW,32'(permission),port,master);
  csr_write(K_COMMIT_MASK,32'b1<<port);
endtask

`endif // APB_SECURE_DEMUX_VIRTUAL_SEQUENCE__SV
