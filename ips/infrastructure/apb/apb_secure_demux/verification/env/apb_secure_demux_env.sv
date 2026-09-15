`ifndef APB_SECURE_DEMUX_ENV__SV
`define APB_SECURE_DEMUX_ENV__SV
class apb_secure_demux_env extends uvm_env;
  `uvm_component_utils(apb_secure_demux_env)
  apb_secure_demux_env_cfg cfg;
  apb_master_agent upstream;
  apb_slave_agent downstream[ASD_NP];
  apb_monitor upstream_monitor,downstream_monitor[ASD_NP];
  apb_secure_demux_rm rm;
  apb_secure_demux_checker scb;
  apb_secure_demux_fcov fcov;
  apb_secure_demux_virtual_sequencer v_sqr;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass
function apb_secure_demux_env::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task apb_secure_demux_env::run_phase(uvm_phase phase);
  // Reset is coordinated at environment level: after drivers abort their
  // current item, flush sequencer arbitration and blocked get_next_item state.
  forever begin
    @(negedge v_sqr.control.reset_n);
    #1ns;
    upstream.sequencer.stop_sequences();
    foreach(downstream[p]) downstream[p].sequencer.stop_sequences();
  end
endtask
function void apb_secure_demux_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(apb_secure_demux_env_cfg)::get(this,"","cfg",cfg))
    cfg=apb_secure_demux_env_cfg::type_id::create("cfg");
  if(!cfg.enable_rm || !cfg.enable_checker)
    `uvm_fatal("CFG","Acceptance runs require both independent RM and checker")
  uvm_config_db#(apb_config)::set(this,"upstream*","config",cfg.upstream);
  upstream=apb_master_agent::type_id::create("upstream",this);
  upstream_monitor=apb_monitor::type_id::create("upstream_monitor",this);
  foreach(downstream[p]) begin
    uvm_config_db#(apb_config)::set(this,$sformatf("downstream_%0d*",p),"config",cfg.downstream[p]);
    uvm_config_db#(apb_config)::set(this,$sformatf("downstream_monitor_%0d",p),"config",cfg.downstream[p]);
    downstream[p]=apb_slave_agent::type_id::create($sformatf("downstream_%0d",p),this);
    downstream_monitor[p]=apb_monitor::type_id::create($sformatf("downstream_monitor_%0d",p),this);
  end
  rm=apb_secure_demux_rm::type_id::create("rm",this);
  scb=apb_secure_demux_checker::type_id::create("scb",this);
  if(cfg.enable_cov) fcov=apb_secure_demux_fcov::type_id::create("fcov",this);
  v_sqr=apb_secure_demux_virtual_sequencer::type_id::create("v_sqr",this);
  if(!uvm_config_db#(virtual apb_secure_demux_control_if)::get(this,"","control",v_sqr.control))
    `uvm_fatal("CONTROL","Missing project control interface")
endfunction
function void apb_secure_demux_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  scb.rm=rm;scb.fcov=fcov;
  v_sqr.upstream=upstream.sequencer;v_sqr.cfg=cfg;
  foreach(downstream[p]) v_sqr.downstream[p]=downstream[p].sequencer;
endfunction

`endif // APB_SECURE_DEMUX_ENV__SV
