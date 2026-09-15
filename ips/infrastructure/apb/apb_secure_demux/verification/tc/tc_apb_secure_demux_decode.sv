`ifndef TC_APB_SECURE_DEMUX_DECODE__SV
`define TC_APB_SECURE_DEMUX_DECODE__SV
// TC.APB_SECURE_DEMUX.DECODE.001
class tc_apb_secure_demux_decode_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_decode_sequence)
  extern function new(string name="tc_apb_secure_demux_decode_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_decode_sequence::new(string name="tc_apb_secure_demux_decode_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_decode_sequence::body();
  foreach(C_PORT_BASE[p]) begin
    allow_port(p,0);
    transfer(C_PORT_BASE[p]);transfer(C_PORT_BASE[p]+32'(C_PORT_SIZE[p])-1);
    if(C_PORT_BASE[p]!=0) transfer(C_PORT_BASE[p]-1);
    if(({1'b0,C_PORT_BASE[p]}+C_PORT_SIZE[p])<(33'b1<<C_ADDR_WIDTH))
      transfer(C_PORT_BASE[p]+32'(C_PORT_SIZE[p]));
    transfer(C_PORT_BASE[p]+1,1,'habcdef,0,1,3'b001,0);
    csr_write(K_CFG_SHADOW,0,p);csr_write(K_COMMIT_MASK,32'b1<<p);transfer(C_PORT_BASE[p]);
  end
  transfer(32'(C_CSR_BASE));transfer(32'(C_CSR_BASE)+'h1000+ASD_NP*'h400-1);
  @(negedge p_sequencer.control.pclk);
  if(!uvm_hdl_force("harness.dut.u_decode.port_hits_o",ASD_NP>1?3:1))
    `uvm_fatal("DECODE_FORCE","Cannot inject range comparator outputs")
  if(!uvm_hdl_force("harness.dut.u_decode.csr_hit_o",ASD_NP==1?1:0))
    `uvm_fatal("DECODE_FORCE","Cannot inject CSR comparator")
  p_sequencer.control.decode_fault=1;
  transfer(C_PORT_BASE[0]);
  @(negedge p_sequencer.control.pclk);
  if(!uvm_hdl_release("harness.dut.u_decode.port_hits_o") ||
     !uvm_hdl_release("harness.dut.u_decode.csr_hit_o")) `uvm_fatal("DECODE_RELEASE","Cannot release")
  p_sequencer.control.decode_fault=0;
  // A CSR+port collision is independent of the two-port collision.
  @(negedge p_sequencer.control.pclk);
  if(!uvm_hdl_force("harness.dut.u_decode.port_hits_o",1) ||
     !uvm_hdl_force("harness.dut.u_decode.csr_hit_o",1)) `uvm_fatal("DECODE_FORCE","CSR+port")
  p_sequencer.control.decode_fault=1;transfer(32'(C_CSR_BASE));
  @(negedge p_sequencer.control.pclk);
  if(!uvm_hdl_release("harness.dut.u_decode.port_hits_o") ||
     !uvm_hdl_release("harness.dut.u_decode.csr_hit_o")) `uvm_fatal("DECODE_RELEASE","CSR+port")
  p_sequencer.control.decode_fault=0;
  transfer(address_of(K_INTR_RAW));
endtask
class tc_apb_secure_demux_decode extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_decode)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_decode::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_decode::stimulus();
  tc_apb_secure_demux_decode_sequence seq;
  seq=tc_apb_secure_demux_decode_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask
`endif

