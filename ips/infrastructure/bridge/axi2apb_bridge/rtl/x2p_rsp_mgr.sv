// =============================================================================
// x2p_rsp_mgr.sv - AXI 响应管理（Read Assembly / Error Aggregation / R/B 输出）
// 简化健壮版：读写响应独立缓冲，同步读组装。
// =============================================================================

`ifndef X2P_RSP_MGR__SV
`define X2P_RSP_MGR__SV

import x2p_pkg::*;

module x2p_rsp_mgr #(
  parameter int unsigned AXI_DATA_WIDTH = 64,
  parameter int unsigned AXI_ID_WIDTH   = 4,
  parameter int unsigned APB_DATA_WIDTH = 32
) (
  input  logic clk,
  input  logic rst_n,
  // APB 响应输入（含方向）
  input  logic                        rsp_valid,
  output logic                        rsp_ready,
  input  logic                        rsp_write,
  input  logic [APB_DATA_WIDTH-1:0]   rsp_data,
  input  logic                        rsp_error,
  input  logic [AXI_ID_WIDTH-1:0]     rsp_id,
  input  logic [3:0]                  rsp_sub,
  input  logic                        rsp_beat_last,
  input  logic                        rsp_txn_last,
  // AXI 读响应
  output logic                        rvalid,
  input  logic                        rready,
  output logic [AXI_DATA_WIDTH-1:0]   rdata,
  output logic [1:0]                  rresp,
  output logic [AXI_ID_WIDTH-1:0]     rid,
  output logic                        rlast,
  // AXI 写响应
  output logic                        bvalid,
  input  logic                        bready,
  output logic [1:0]                  bresp,
  output logic [AXI_ID_WIDTH-1:0]     bid
);

  localparam int unsigned APB_BYTES = APB_DATA_WIDTH / 8;

  // ---- 读组装（每拍将子传输数据写入累加，beat 完成时输出） ----
  logic [AXI_DATA_WIDTH-1:0] rdata_accum_q;
  logic [AXI_DATA_WIDTH-1:0] rdata_out_q;
  logic [1:0]                rresp_out_q;
  logic [AXI_ID_WIDTH-1:0]   rid_out_q;
  logic                      rlast_out_q;
  logic                      r_pending_q;
  logic                      r_beat_err_q;

  // ---- 写聚合 ----
  logic [1:0]                bresp_out_q;
  logic [AXI_ID_WIDTH-1:0]   bid_out_q;
  logic                      b_pending_q;
  logic                      b_error_q;

  // 接受条件：读路径允许在输出让行时接受；写路径总是接受（聚合）
  assign rsp_ready = !r_pending_q || (rvalid && rready);

  logic rsp_accept;
  assign rsp_accept = rsp_valid && rsp_ready;

  // 读累加：写入 sub 偏移（仅读方向）
  logic [AXI_DATA_WIDTH-1:0] rdata_accum_next;
  always_comb begin
    rdata_accum_next = rdata_accum_q;
    if (rsp_accept && !rsp_write) begin
      for (int b = 0; b < APB_DATA_WIDTH/8; b++) begin
        if ((rsp_sub * APB_BYTES + b) < AXI_DATA_WIDTH/8)
          rdata_accum_next[(rsp_sub * APB_BYTES + b)*8 +: 8] = rsp_data[b*8 +: 8];
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rdata_accum_q <= '0;
      rdata_out_q   <= '0;
      rresp_out_q   <= RESP_OKAY;
      rid_out_q     <= '0;
      rlast_out_q   <= 1'b0;
      r_pending_q   <= 1'b0;
      r_beat_err_q  <= 1'b0;
      // 写侧寄存器复位（缺失会导致 B 通道 x，破坏读/写响应链路）
      bresp_out_q   <= RESP_OKAY;
      bid_out_q     <= '0;
      b_pending_q   <= 1'b0;
      b_error_q     <= 1'b0;
    end else begin
      // 先推进累加（读方向）
      if (rsp_accept && !rsp_write)
        rdata_accum_q <= rdata_accum_next;
      if (rsp_accept && !rsp_write && rsp_error)
        r_beat_err_q  <= 1'b1;

      // 让行清除
      if (r_pending_q && rvalid && rready)
        r_pending_q   <= 1'b0;

      // read beat 完成：输出 R（用累加后的结果）
      if (rsp_accept && !rsp_write && rsp_beat_last) begin
        r_pending_q   <= 1'b1;
        rdata_out_q   <= rdata_accum_next;
        rresp_out_q   <= (r_beat_err_q || rsp_error) ? RESP_SLVERR : RESP_OKAY;
        rid_out_q     <= rsp_id;
        rlast_out_q   <= rsp_txn_last;
        r_beat_err_q  <= 1'b0;
        // 清累加器：本 beat 未覆盖的高 lane 不得携带上一 beat 的陈旧数据
        // （窄读 / 位宽转换场景要求未访问 lane 输出 0）
        rdata_accum_q <= '0;
      end

      // 写方向：聚合错误，txn_last 输出 B
      if (rsp_accept && rsp_write)
        b_error_q     <= b_error_q || rsp_error;
      if (rsp_accept && rsp_write && rsp_txn_last) begin
        b_pending_q   <= 1'b1;
        bresp_out_q   <= (b_error_q || rsp_error) ? RESP_SLVERR : RESP_OKAY;
        bid_out_q     <= rsp_id;
        b_error_q     <= 1'b0;
      end
      if (b_pending_q && bvalid && bready)
        b_pending_q   <= 1'b0;
    end
  end

  assign rvalid = r_pending_q;
  assign rdata  = rdata_out_q;
  assign rresp  = rresp_out_q;
  assign rid    = rid_out_q;
  assign rlast  = rlast_out_q;

  assign bvalid = b_pending_q;
  assign bresp  = bresp_out_q;
  assign bid    = bid_out_q;

endmodule : x2p_rsp_mgr

`endif