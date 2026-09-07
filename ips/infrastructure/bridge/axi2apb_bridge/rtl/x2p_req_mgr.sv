// x2p_req_mgr.sv - 读写请求队列（通用参数化指针 FIFO）
// 深度 2^ADDR_W 槽位，支持 depth=1/2/4/8（通过 ADDR_W=0/1/2/3 生成）。
// 纯净 FIFO：提供满/空标志，AXI READY 反压由顶层基于 full 产生。
module x2p_req_mgr #(
  parameter int unsigned DEPTH_W  = 2,     // log2(READ/WRITE_REQUEST_DEPTH)
  parameter int unsigned DATA_W   = 64,    // payload 宽度
  parameter int unsigned AXI_ID_W = 4      // ID 宽度（与 txn_id 无关，仅 ADDR 槽位）
) (
  input  logic clk,
  input  logic rst_n,
  // write side (capture)
  input  logic                    push,
  input  logic [DATA_W-1:0]       din,
  // read side (consume)
  input  logic                    pop,
  output logic [DATA_W-1:0]       dout,
  // status
  output logic                    empty,
  output logic                    full
);

  localparam int unsigned DEPTH = (1 << DEPTH_W);   // 1,2,4,8

  logic [DATA_W-1:0] mem [DEPTH];

  // 精确满判断：用额外的 flag 位扩展指针（“环形”差一计数）
  logic [DEPTH_W:0] wptr_ext, rptr_ext;
  assign empty = (wptr_ext == rptr_ext);
  assign full  = (wptr_ext[DEPTH_W] != rptr_ext[DEPTH_W]) &&
                 (wptr_ext[DEPTH_W-1:0] == rptr_ext[DEPTH_W-1:0]);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wptr_ext <= '0;
      rptr_ext <= '0;
    end else begin
      if (push && !full) begin
        wptr_ext <= wptr_ext + 1'b1;
      end
      if (pop && !empty) begin
        rptr_ext <= rptr_ext + 1'b1;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (push && !full)
      mem[wptr_ext[DEPTH_W-1:0]] <= din;
  end

  assign dout = mem[rptr_ext[DEPTH_W-1:0]];

endmodule : x2p_req_mgr