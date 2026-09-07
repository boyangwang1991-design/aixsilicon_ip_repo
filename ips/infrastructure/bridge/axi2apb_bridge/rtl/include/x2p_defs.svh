// x2p_defs.svh - X2P 共用定义（供 filelist 包含；推荐直接 import x2p_pkg）
// 常量表（与 x2p_pkg 保持一致，用于不支持 package 解析的流程）

`ifndef X2P_DEFS_SVH
`define X2P_DEFS_SVH

// Profiles / policies
`define X2P_AXI4        1
`define X2P_AXI4_LITE   0
`define X2P_APB4        1
`define X2P_APB3        0
`define X2P_ARB_RR          0
`define X2P_ARB_READ_PRI   1
`define X2P_ARB_WRITE_PRI  2
`define X2P_GRAN_BEAT       0
`define X2P_GRAN_TRANSACTION 1
`define X2P_CLK_SYNC  0
`define X2P_CLK_ASYNC 1

// AXI burst encoding
`define X2P_BURST_FIXED 2'b00
`define X2P_BURST_INCR  2'b01
`define X2P_BURST_WRAP  2'b10

// AXI responses
`define X2P_RESP_OKAY   2'b00
`define X2P_RESP_SLVERR 2'b10

`endif // X2P_DEFS_SVH