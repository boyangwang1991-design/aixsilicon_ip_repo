`ifndef TC_BASE__SV
`define TC_BASE__SV
class tc_base extends uvm_test;
  `uvm_component_utils(tc_base)
  apb_secure_demux_env env;
  apb_secure_demux_env_cfg cfg;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern virtual task stimulus();
  extern task run_phase(uvm_phase phase);
endclass
function tc_base::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
function void tc_base::build_phase(uvm_phase phase);
  super.build_phase(phase);
  cfg=apb_secure_demux_env_cfg::type_id::create("cfg");
  uvm_config_db#(apb_secure_demux_env_cfg)::set(this,"env","cfg",cfg);
  env=apb_secure_demux_env::type_id::create("env",this);
endfunction
task tc_base::stimulus();
  `uvm_fatal("ABSTRACT_TEST","Select a canonical implemented testcase")
endtask
task tc_base::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  wait(env.v_sqr.control.reset_n===1'b1);
  repeat(2) @(negedge env.v_sqr.control.pclk);
  stimulus();
  repeat(3) @(negedge env.v_sqr.control.pclk);
  `uvm_info("TEST_DONE",get_type_name(),UVM_NONE)
  phase.drop_objection(this);
endtask


`endif // TC_BASE__SV
