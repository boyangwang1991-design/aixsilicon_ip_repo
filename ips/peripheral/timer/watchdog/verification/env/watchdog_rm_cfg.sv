`ifndef WATCHDOG_RM_CFG__SV
`define WATCHDOG_RM_CFG__SV
class watchdog_rm_cfg extends uvm_object;
  `uvm_object_utils(watchdog_rm_cfg)
  watchdog_dut_cfg dut;
  extern function new(string name="watchdog_rm_cfg");
endclass
function watchdog_rm_cfg::new(string name="watchdog_rm_cfg");super.new(name);endfunction
`endif
