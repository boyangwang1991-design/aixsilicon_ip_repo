`ifndef WATCHDOG_DUT_CFG__SV
`define WATCHDOG_DUT_CFG__SV
class watchdog_dut_cfg extends uvm_object;
  `uvm_object_utils(watchdog_dut_cfg)
  int channels,clients,width,prescale_width,source_width,sync_stages;
  bit token_support,supervision_support,hw_support,safety,runtime_update,inject_enable;
  bit[15:0] autostart,no_stop,hard_lock;
  extern function new(string name="watchdog_dut_cfg");
  extern function void from_interface(virtual watchdog_control_if vif);
endclass
function watchdog_dut_cfg::new(string name="watchdog_dut_cfg");super.new(name);endfunction
function void watchdog_dut_cfg::from_interface(virtual watchdog_control_if vif);
  channels=vif.channels;clients=vif.clients;width=vif.width;prescale_width=vif.prescale_width;
  source_width=vif.source_width;sync_stages=vif.sync_stages;token_support=vif.token_support;
  supervision_support=vif.supervision_support;hw_support=vif.hw_support;safety=vif.safety;
  runtime_update=vif.runtime_update;inject_enable=vif.inject_enable;
  autostart=vif.autostart;no_stop=vif.no_stop;hard_lock=vif.hard_lock;
endfunction
`endif
