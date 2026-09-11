`ifndef WATCHDOG_MONITOR__SV
`define WATCHDOG_MONITOR__SV

class watchdog_monitor extends uvm_monitor;
  `uvm_component_utils(watchdog_monitor)
  virtual watchdog_control_if vif;
  uvm_analysis_port #(watchdog_observation) observation_ap;
  uvm_analysis_port #(watchdog_prediction) actual_ap;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void actual(string label,logic[63:0] value);
  extern task run_phase(uvm_phase phase);
  extern task sample_wdt();
  extern task sample_pclk();
endclass
function watchdog_monitor::new(string name,uvm_component parent);
  super.new(name,parent);observation_ap=new("observation_ap",this);actual_ap=new("actual_ap",this);
endfunction
function void watchdog_monitor::build_phase(uvm_phase phase);
  if(!uvm_config_db#(virtual watchdog_control_if)::get(this,"","vif",vif)) `uvm_fatal("MON","missing interface")
endfunction
function void watchdog_monitor::actual(string label,logic[63:0] value);
  watchdog_prediction p;p=watchdog_prediction::type_id::create("actual");p.label=label;p.actual_value=value;actual_ap.write(p);
endfunction
task watchdog_monitor::run_phase(uvm_phase phase);fork sample_wdt();sample_pclk();join endtask
task watchdog_monitor::sample_wdt();
  watchdog_observation o;
  forever begin
    @(posedge vif.wdt_clk);
    o=watchdog_observation::type_id::create("wdt_edge");o.kind=WDT_EDGE;o.stamp=$time;o.cycle=vif.wdt_cycle+1;
    o.por_n=vif.por_n;o.preset_n=vif.preset_n;o.warm=vif.warm;o.sleep_req=vif.sleep_req;
    o.debug_req=vif.debug_req;o.debug_auth=vif.debug_auth;o.test_auth=vif.test_auth;o.done=vif.recovery_done;
    o.access_error=vif.access_error;o.cdc_error=vif.cdc_error;
    o.command_valid=vif.execute_mailbox || (|vif.channel_command_valid);
    o.command_canceled=vif.cancel_mailbox;o.command_integrity=vif.mailbox_integrity;
    o.command=vif.observed_command;o.command_config=vif.observed_config;o.actual_result=vif.execution_result;
    #1;o.por_n=o.por_n && vif.por_n;o.command_valid=o.command_valid && o.por_n;
    o.nmi=vif.nmi;o.local_req=vif.local_req;o.pause_ack=vif.pause_ack;o.recovery_ack=vif.recovery_ack;
    o.final_req=vif.final_req;o.safe_req=vif.safe_req;o.alert=vif.safety_alert;o.wake=vif.wake;
    observation_ap.write(o);
    if(o.command_valid) actual($sformatf("WDT:%0d:result",o.cycle),64'(o.actual_result));
    actual($sformatf("WDT:%0d:nmi",o.cycle),64'(o.nmi));
    actual($sformatf("WDT:%0d:local",o.cycle),64'(o.local_req));
    actual($sformatf("WDT:%0d:pause",o.cycle),64'(o.pause_ack));
    actual($sformatf("WDT:%0d:recovery",o.cycle),64'(o.recovery_ack));
    actual($sformatf("WDT:%0d:final",o.cycle),64'(o.final_req));
    actual($sformatf("WDT:%0d:safe",o.cycle),64'(o.safe_req));
    actual($sformatf("WDT:%0d:alert",o.cycle),64'(o.alert));
    actual($sformatf("WDT:%0d:wake",o.cycle),64'(o.wake));
  end
endtask
task watchdog_monitor::sample_pclk();
  watchdog_observation o;
  forever begin
    @(posedge vif.pclk);o=watchdog_observation::type_id::create("pclk_edge");
    o.kind=PCLK_EDGE;o.stamp=$time;o.cycle=vif.pclk_cycle+1;o.por_n=vif.por_n;o.preset_n=vif.preset_n;
    #1;o.por_n=o.por_n && vif.por_n;o.preset_n=o.preset_n && vif.preset_n;o.irq=vif.irq;observation_ap.write(o);actual($sformatf("PCLK:%0d:irq",o.cycle),64'(o.irq));
  end
endtask
class watchdog_apb_actual extends uvm_subscriber #(apb_item);
  `uvm_component_utils(watchdog_apb_actual)
  uvm_analysis_port #(watchdog_prediction) actual_ap;
  longint unsigned count;
  extern function new(string name,uvm_component parent);
  extern function void write(apb_item t);
endclass
function watchdog_apb_actual::new(string name,uvm_component parent);super.new(name,parent);actual_ap=new("actual_ap",this);endfunction
function void watchdog_apb_actual::write(apb_item t);
  watchdog_prediction p;if(t.status==APB_ABORTED) return;
  p=watchdog_prediction::type_id::create("apb_actual");p.label=$sformatf("APB:%0d",count++);
  p.actual_value={31'b0,t.slverr,(t.direction==APB_WRITE ? 32'b0 : 32'(t.rdata))};actual_ap.write(p);
endfunction

`endif
