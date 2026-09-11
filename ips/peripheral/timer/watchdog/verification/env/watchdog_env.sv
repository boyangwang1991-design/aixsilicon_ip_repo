`ifndef WATCHDOG_ENV__SV
`define WATCHDOG_ENV__SV

class watchdog_env extends uvm_env;
  `uvm_component_utils(watchdog_env)
  watchdog_env_cfg cfg;
  apb_master_agent apb;
  apb_monitor apb_mon;
  apb_protocol_checker protocol_check;
  apb_coverage protocol_cov;
  apb_reg_predictor predictor;
  apb_reg_adapter adapter;
  watchdog_regs ral;
  watchdog_control_agent control;
  watchdog_virtual_sequencer v_sqr;
  watchdog_monitor mon;
  watchdog_apb_actual apb_actual;
  watchdog_reference_model rm;
  watchdog_checker scoreboard;
  watchdog_fcov fcov;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
endclass
function watchdog_env::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void watchdog_env::build_phase(uvm_phase phase);
  if(!uvm_config_db#(watchdog_env_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("ENV","missing configuration")
  uvm_config_db#(apb_config)::set(this,"*","config",cfg.apb);
  uvm_config_db#(watchdog_dut_cfg)::set(this,"*","dut",cfg.dut);
  apb=apb_master_agent::type_id::create("apb",this);
  apb_mon=apb_monitor::type_id::create("apb_mon",this);
  protocol_check=apb_protocol_checker::type_id::create("protocol_check",this);
  protocol_cov=apb_coverage::type_id::create("protocol_cov",this);
  predictor=apb_reg_predictor::type_id::create("predictor",this);
  adapter=apb_reg_adapter::type_id::create("adapter");adapter.configure(cfg.apb);
  ral=new("ral");ral.build();ral.lock_model();ral.reset();
  control=watchdog_control_agent::type_id::create("control",this);
  v_sqr=watchdog_virtual_sequencer::type_id::create("v_sqr",this);v_sqr.cfg=cfg;
  mon=watchdog_monitor::type_id::create("mon",this);
  apb_actual=watchdog_apb_actual::type_id::create("apb_actual",this);
  rm=watchdog_reference_model::type_id::create("rm",this);
  scoreboard=watchdog_checker::type_id::create("scoreboard",this);
  fcov=watchdog_fcov::type_id::create("fcov",this);
endfunction
function void watchdog_env::connect_phase(uvm_phase phase);
  v_sqr.apb_sqr=apb.sequencer;v_sqr.control_sqr=control.sequencer;
  ral.default_map.set_sequencer(apb.sequencer,adapter);ral.default_map.set_auto_predict(0);
  predictor.reg_predictor.map=ral.default_map;
  apb_mon.transaction_ap.connect(rm.apb_in);
  apb_mon.transaction_ap.connect(apb_actual.analysis_export);
  apb_mon.transaction_ap.connect(protocol_check.analysis_export);
  apb_mon.transaction_ap.connect(protocol_cov.analysis_export);
  apb_mon.transaction_ap.connect(predictor.analysis_export);
  mon.observation_ap.connect(rm.wdt_in);
  mon.actual_ap.connect(scoreboard.actual_in);apb_actual.actual_ap.connect(scoreboard.actual_in);
  rm.expected_ap.connect(scoreboard.expected_in);scoreboard.matched_ap.connect(fcov.analysis_export);
endfunction

`endif
