// x2p_pkg.sv - X2P 参数与常量包（先于所有模块编译）
package x2p_pkg;

  // ---- profiles / policies / modes ----
  localparam int unsigned AXI4_PROFILE      = 1;
  localparam int unsigned AXI4LITE_PROFILE  = 0;
  localparam int unsigned APB4_PROFILE      = 1;
  localparam int unsigned APB3_PROFILE      = 0;
  localparam int unsigned ARB_ROUND_ROBIN   = 0;
  localparam int unsigned ARB_READ_PRIORITY = 1;
  localparam int unsigned ARB_WRITE_PRIORITY= 2;
  localparam int unsigned GRAN_BEAT         = 0;
  localparam int unsigned GRAN_TRANSACTION  = 1;
  localparam int unsigned CLK_SYNC          = 0;
  localparam int unsigned CLK_ASYNC         = 1;

  // ---- AXI burst encoding ----
  localparam logic [1:0] BURST_FIXED = 2'b00;
  localparam logic [1:0] BURST_INCR  = 2'b01;
  localparam logic [1:0] BURST_WRAP  = 2'b10;

  // ---- AXI responses ----
  localparam logic [1:0] RESP_OKAY   = 2'b00;
  localparam logic [1:0] RESP_SLVERR = 2'b10;

  // ---- internal request payload tag widths (beats/subbeats) ----
  localparam int unsigned MAX_BEATS   = 16;      // AXI 最大 16 beats
  localparam int unsigned BEAT_IDX_W  = 4;       // log2(16)
  localparam int unsigned SUB_IDX_W   = 4;       // 单个 beat 最大 8 个子传输(128->16 不允许, 取 4)

endpackage : x2p_pkg