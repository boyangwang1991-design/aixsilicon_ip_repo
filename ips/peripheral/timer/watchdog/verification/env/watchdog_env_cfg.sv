`ifndef WATCHDOG_ENV_CFG__SV
`define WATCHDOG_ENV_CFG__SV
class watchdog_env_cfg extends uvm_object;
  `uvm_object_utils(watchdog_env_cfg)
  watchdog_dut_cfg dut; apb_config apb; bit enable_rm=1,enable_checker=1,enable_cov=1; int timeout_cycles=1000000;
  extern function new(string name="watchdog_env_cfg");
endclass
function watchdog_env_cfg::new(string name="watchdog_env_cfg");super.new(name);endfunction
`endif
