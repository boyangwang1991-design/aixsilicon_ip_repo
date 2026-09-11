`ifndef TC_BASE__SV
`define TC_BASE__SV

class tc_base extends uvm_test;
  `uvm_component_utils(tc_base)
  watchdog_env env;watchdog_env_cfg cfg;virtual watchdog_control_if vif;
  string group_name="bus";int feature_number=1;
  extern function new(string name="tc_base",uvm_component parent=null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
endclass
function tc_base::new(string name="tc_base",uvm_component parent=null);super.new(name,parent);endfunction
function void tc_base::build_phase(uvm_phase phase);
  if(!uvm_config_db#(virtual watchdog_control_if)::get(this,"","vif",vif)) `uvm_fatal("TEST","missing interface")
  cfg=watchdog_env_cfg::type_id::create("cfg");cfg.dut=watchdog_dut_cfg::type_id::create("dut");cfg.dut.from_interface(vif);
  cfg.apb=apb_config::type_id::create("apb");cfg.apb.agent_mode=APB_ACTIVE_MASTER;
  uvm_config_db#(watchdog_env_cfg)::set(this,"env","cfg",cfg);env=watchdog_env::type_id::create("env",this);
endfunction
task tc_base::run_phase(uvm_phase phase);
  watchdog_virtual_sequence s;phase.raise_objection(this);
  s=watchdog_virtual_sequence::type_id::create("sequence");s.group_name=group_name;s.vif=vif;
  env.rm.feature=feature_number;s.start(env.v_sqr);repeat(10) @(negedge vif.wdt_clk);#2;
  phase.drop_objection(this);
endtask
function void tc_base::report_phase(uvm_phase phase);
  uvm_report_server server;server=uvm_report_server::get_server();
  if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0 && env.scoreboard.checks>=100)
    `uvm_info("WATCHDOG_TEST_PASS",$sformatf("%s checked=%0d",get_type_name(),env.scoreboard.checks),UVM_NONE)
endfunction

`endif
