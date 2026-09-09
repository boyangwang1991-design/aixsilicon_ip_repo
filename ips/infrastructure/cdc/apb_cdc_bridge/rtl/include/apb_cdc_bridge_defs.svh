// apb_cdc_bridge_defs.svh
// APB CDC Bridge 内部常量与参数定义（可综合 SystemVerilog 子集）
// 依赖: apb_cdc_bridge_pkg（先于本头文件编译）

// =============================================================================
// CDC 实现选择（CDC_IMPL 参数编码）
// =============================================================================
`ifndef APB_CDC_IMPL_HANDSHAKE
  `define APB_CDC_IMPL_HANDSHAKE 0
`endif
`ifndef APB_CDC_IMPL_ASYNC_FIFO
  `define APB_CDC_IMPL_ASYNC_FIFO 1
`endif

// =============================================================================
// APB Profile（APB_PROFILE 参数编码）
// =============================================================================
`ifndef APB_CDC_APB3
  `define APB_CDC_APB3 0
`endif
`ifndef APB_CDC_APB4
  `define APB_CDC_APB4 1
`endif

// =============================================================================
// 复位模式（RESET_MODE）
// =============================================================================
`ifndef APB_CDC_RST_ASYNC
  `define APB_CDC_RST_ASYNC 0
`endif

// =============================================================================
// CDC_MODE（ASYNC_SAFE 默认；SYNC_RATIO 预留）
// =============================================================================
`ifndef APB_CDC_MODE_ASYNC_SAFE
  `define APB_CDC_MODE_ASYNC_SAFE 0
`endif
