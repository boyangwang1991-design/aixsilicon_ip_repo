// apb_cdc_bridge_env_pkg.sv - APB CDC Bridge UVM 验证环境 package
// 引用 APB VIP（apb_pkg），提供 env / scoreboard / RM
package apb_cdc_bridge_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import apb_pkg::*;
  import apb_types_pkg::*;

  `include "apb_cdc_bridge_scoreboard.sv"
  `include "apb_cdc_bridge_env.sv"

endpackage : apb_cdc_bridge_env_pkg
