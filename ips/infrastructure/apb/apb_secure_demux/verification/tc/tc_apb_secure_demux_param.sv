`ifndef TC_APB_SECURE_DEMUX_PARAM__SV
`define TC_APB_SECURE_DEMUX_PARAM__SV
// TC.APB_SECURE_DEMUX.PARAM.001
class tc_apb_secure_demux_param_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_param_sequence)
  extern function new(string name="tc_apb_secure_demux_param_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_param_sequence::new(string name="tc_apb_secure_demux_param_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_param_sequence::body();
  transfer(address_of(K_IP_ID));transfer(address_of(K_CAP0));transfer(address_of(K_CAP1));
  foreach(C_PORT_BASE[p]) begin
    transfer(address_of(K_MAP_BASE,p));transfer(address_of(K_MAP_LIMIT,p));
    transfer(address_of(K_CFG_ACTIVE,p));
    for(int m=0;m<ASD_NM;m++) transfer(address_of(K_PERM_ACTIVE,p,m));
  end
  // The owning campaign separately requires all 75 checker/elaboration points.
  transfer(32'(C_CSR_BASE)+'h1000+32'(ASD_NP)*'h400);
  if(ASD_NM<64) transfer(32'(C_CSR_BASE)+'h1100+32'(ASD_NM)*4);
endtask
class tc_apb_secure_demux_param extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_param)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_param::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_param::stimulus();
  tc_apb_secure_demux_param_sequence seq;
  seq=tc_apb_secure_demux_param_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask


`endif // TC_APB_SECURE_DEMUX_PARAM__SV
