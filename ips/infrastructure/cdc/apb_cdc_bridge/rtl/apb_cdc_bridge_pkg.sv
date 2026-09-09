// apb_cdc_bridge_pkg.sv - APB CDC Bridge 参数与常量包（先于所有模块编译）
package apb_cdc_bridge_pkg;

  // ---- CDC 实现选择 ----
  localparam int unsigned CDC_IMPL_HANDSHAKE  = 0;
  localparam int unsigned CDC_IMPL_ASYNC_FIFO = 1;

  // ---- APB profile ----
  localparam int unsigned APB_PROFILE_APB3 = 0;
  localparam int unsigned APB_PROFILE_APB4 = 1;

  // ---- 复位模式 ----
  localparam int unsigned RESET_MODE_ASYNC = 0;

  // ---- CDC_MODE ----
  localparam int unsigned CDC_MODE_ASYNC_SAFE = 0; // 默认
  localparam int unsigned CDC_MODE_SYNC_RATIO = 1; // 预留（V1.0 不实现）

endpackage : apb_cdc_bridge_pkg
