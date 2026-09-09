// apb_demux_env_pkg.sv - APB Demux UVM 验证环境 package
// 引用 APB VIP（aixsilicon:vip:apb:1.0.0，只读复用），提供 env / scoreboard / RM
package apb_demux_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import apb_pkg::*;
  import apb_types_pkg::*;

  `include "apb_demux_scoreboard.sv"
  `include "apb_demux_env.sv"

endpackage : apb_demux_env_pkg
