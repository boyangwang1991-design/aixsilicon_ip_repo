`ifndef WATCHDOG_CHECKER_CFG__SV
`define WATCHDOG_CHECKER_CFG__SV
class watchdog_checker_cfg extends uvm_object;
  `uvm_object_utils(watchdog_checker_cfg)
  int unsigned minimum_checks=1; bit fail_on_pending=1;
  extern function new(string name="watchdog_checker_cfg");
endclass
function watchdog_checker_cfg::new(string name="watchdog_checker_cfg");super.new(name);endfunction
`endif
