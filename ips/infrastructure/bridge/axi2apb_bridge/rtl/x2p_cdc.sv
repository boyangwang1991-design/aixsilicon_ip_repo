// x2p_cdc.sv - 双时钟异步 FIFO（CDC 层，ASYNC 模式）
// 请求侧 FIFO：wclk(写) -> rclk(读)，深度 = 2^DEPTH_LOG2
// 响应侧 FIFO 同理。Gray 指针 + 标准两级同步器。
// SYNC 模式下顶层 generate 不例化本模块（bypass 直连）。
module x2p_cdc #(
  parameter int unsigned DATA_WIDTH = 64,
  parameter int unsigned DEPTH_LOG2 = 2      // 深度 = 2^DEPTH_LOG2
) (
  // 写域
  input  logic                        wclk,
  input  logic                        wrst_n,
  input  logic                        wpush,
  input  logic [DATA_WIDTH-1:0]       wdata,
  output logic                        wfull,
  // 读域
  input  logic                        rclk,
  input  logic                        rrst_n,
  input  logic                        rpop,
  output logic [DATA_WIDTH-1:0]       rdata,
  output logic                        rempty
);

  localparam int unsigned DEPTH = (1 << DEPTH_LOG2);

  // 二进制与 Gray 指针（含扩展位）
  logic [DEPTH_LOG2:0] wptr_bin,  rptr_bin;
  logic [DEPTH_LOG2:0] wptr_gray, rptr_gray;
  // 读侧同步的写指针 / 写侧同步的读指针（标准两级）
  logic [DEPTH_LOG2:0] wptr_sync1, wptr_sync2;
  logic [DEPTH_LOG2:0] rptr_sync1, rptr_sync2;

  logic [DATA_WIDTH-1:0] mem [DEPTH];

  // ---- 写域 ----
  assign wfull = (wptr_gray == {~rptr_sync2[DEPTH_LOG2], rptr_sync2[DEPTH_LOG2-1:0]});

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      wptr_bin  <= '0;
      wptr_gray <= '0;
    end else begin
      if (wpush && !wfull) begin
        wptr_bin  <= wptr_bin + 1'b1;
        wptr_gray <= (wptr_bin + 1'b1) ^ ((wptr_bin + 1'b1) >> 1);
        mem[wptr_bin[DEPTH_LOG2-1:0]] <= wdata;
      end
    end
  end

  // ---- 读域 ----
  assign rempty = (rptr_gray == wptr_sync2);

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      rptr_bin  <= '0;
      rptr_gray <= '0;
    end else begin
      if (rpop && !rempty) begin
        rptr_bin  <= rptr_bin + 1'b1;
        rptr_gray <= (rptr_bin + 1'b1) ^ ((rptr_bin + 1'b1) >> 1);
      end
    end
  end

  assign rdata = mem[rptr_bin[DEPTH_LOG2-1:0]];

  // ---- 指针同步（标准两级） ----
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      wptr_sync1 <= '0;
      wptr_sync2 <= '0;
    end else begin
      wptr_sync1 <= wptr_gray;
      wptr_sync2 <= wptr_sync1;
    end
  end

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      rptr_sync1 <= '0;
      rptr_sync2 <= '0;
    end else begin
      rptr_sync1 <= rptr_gray;
      rptr_sync2 <= rptr_sync1;
    end
  end

endmodule : x2p_cdc