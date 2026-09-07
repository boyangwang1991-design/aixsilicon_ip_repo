// x2p_scheduler.sv - 读写仲裁器
// 支持三种策略（RR / READ_PRI / WRITE_PRI）与两种粒度（BEAT / TRANSACTION）。
// 仲裁只在"当前 grant 空闲"时选边；TRANSACTION 粒度下 grant 保持到 txn_last，
// BEAT 粒度下 grant 保持到 beat_last（由 transfer engine 反馈）。
// 输出 grant_rd / grant_wr 任一有效互斥。
module x2p_scheduler #(
  parameter int unsigned ARB_POLICY       = 0,    // 0:RR 1:READ_PRI 2:WRITE_PRI
  parameter int unsigned ARB_GRANULARITY  = 0     // 0:BEAT 1:TRANSACTION
) (
  input  logic clk,
  input  logic rst_n,

  input  logic rd_avail,   // 读队列非空
  input  logic wr_avail,   // 写请求可用（AW 已配对或 W 就绪）
  input  logic sched_busy, // 当前是否正在执行（transfer engine busy）
  input  logic beat_done,  // 当前 beat 完成（BEAT 粒度用）
  input  logic txn_done,   // 当前事务完成（TRANSACTION 粒度用）

  output logic grant_rd,
  output logic grant_wr
);

  // 记录最近授权边，用于 RR 轮转与 pri 决策
  logic prev_rd;   // 1: 上次授权给读
  logic cur_rd;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      prev_rd <= 1'b0;
    else if (grant_rd || grant_wr)
      prev_rd <= grant_rd;
  end

  // 栅栏：仅在空闲可切换
  logic switch_ok;
  assign switch_ok = !sched_busy ||
                     (ARB_GRANULARITY == 0 ? beat_done : txn_done);

  logic sel_rd;
  always_comb begin
    sel_rd = 1'b0;
    case (ARB_POLICY)
      0: begin // ROUND_ROBIN
        if (!rd_avail)            sel_rd = 1'b0;
        else if (!wr_avail)       sel_rd = 1'b1;
        else                      sel_rd = !prev_rd;   // 轮转
      end
      1: begin // READ_PRIORITY
        sel_rd = rd_avail;
      end
      2: begin // WRITE_PRIORITY
        sel_rd = wr_avail ? 1'b0 : rd_avail;
      end
      default: sel_rd = rd_avail;
    endcase
  end

  assign grant_rd = switch_ok && sel_rd && rd_avail;
  assign grant_wr = switch_ok && !sel_rd && wr_avail;

endmodule : x2p_scheduler