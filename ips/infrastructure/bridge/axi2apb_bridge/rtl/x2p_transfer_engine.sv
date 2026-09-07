// x2p_transfer_engine.sv - 突发跟踪 / 地址生成 / 宽度转换 / APB 子传输生成
//
// 功能要点（对应 LLD.MOD.X2P.TE）：
//   1. 接收整笔 AXI 事务描述符（is_write/id/addr/len/size/burst/prot/wdata/wstrb）
//   2. 内部按 beat 推进（INCR/FIXED/WRAP 地址 + WRAP 回绕 + 4KB 约束）
//   3. 每个 beat 拆为 1..N 个 APB subtransfer（N = beat_bytes / APB_bytes）
//   4. 每个 subtransfer 携带 txn_id/beat/subbeat/beat_last/txn_last/error
//   5. APB3 写 partial → 该 subtransfer 不发起 APB，返回 error（SLVERR 聚合在 rsp_mgr）
module x2p_transfer_engine #(
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 64,
  parameter int unsigned AXI_ID_WIDTH   = 4,
  parameter int unsigned APB_ADDR_WIDTH = 32,
  parameter int unsigned APB_DATA_WIDTH = 32,
  parameter int unsigned AXI_PROFILE    = 1,      // 1=AXI4 0=AXI4-Lite
  parameter int unsigned APB_PROFILE    = 1       // 1=APB4 0=APB3
) (
  input  logic clk,
  input  logic rst_n,

  // 事务请求输入（一次一笔完整事务；beat 数据依次经 wdata 拉取）
  input  logic                        req_valid,
  output logic                        req_ready,
  input  logic                        req_is_write,
  input  logic [AXI_ID_WIDTH-1:0]     req_id,
  input  logic [AXI_ADDR_WIDTH-1:0]   req_addr,
  input  logic [7:0]                  req_len,
  input  logic [2:0]                  req_size,
  input  logic [1:0]                  req_burst,
  input  logic [2:0]                  req_prot,
  input  logic [AXI_DATA_WIDTH-1:0]   req_wdata,   // 写：第一 beat 数据
  input  logic [AXI_DATA_WIDTH/8-1:0] req_wstrb,   // 写：第一 beat 掩码
  // 后续 beat 写数据流（每 beat 拉取一次，若 write）
  input  logic                        wdata_valid,
  output logic                        wdata_ready,
  input  logic [AXI_DATA_WIDTH-1:0]   wdata,
  input  logic [AXI_DATA_WIDTH/8-1:0] wstrb,

  // 状态（供 Scheduler）
  output logic                        busy,
  output logic                        beat_done,
  output logic                        txn_done,
  output logic                        grant_is_write,

  // APB 请求输出
  output logic                        apb_req_valid,
  input  logic                        apb_req_ready,
  output logic [APB_ADDR_WIDTH-1:0]   apb_addr,
  output logic                        apb_write,
  output logic [APB_DATA_WIDTH-1:0]   apb_wdata,
  output logic [APB_DATA_WIDTH/8-1:0] apb_strb,
  output logic [2:0]                  apb_prot,
  output logic [AXI_ID_WIDTH-1:0]     apb_id,
  output logic [3:0]                  apb_axi_beat,
  output logic [3:0]                  apb_subbeat,
  output logic                        apb_beat_last,
  output logic                        apb_txn_last,
  output logic                        apb_error        // 该 subtransfer 需返回错误（无 APB 发起）
);

  import x2p_pkg::*;

  localparam int unsigned APB_BYTES = APB_DATA_WIDTH / 8;

  // ---- 组合辅助 ----
  function automatic [31:0] size_bytes_func(input logic [2:0] sz);
    case (sz)
      3'd0: size_bytes_func = 32'd1;
      3'd1: size_bytes_func = 32'd2;
      3'd2: size_bytes_func = 32'd4;
      3'd3: size_bytes_func = 32'd8;
      3'd4: size_bytes_func = 32'd16;
      3'd5: size_bytes_func = 32'd32;
      3'd6: size_bytes_func = 32'd64;
      3'd7: size_bytes_func = 32'd128;
      default: size_bytes_func = 32'd1;
    endcase
  endfunction

  // wrap_bytes 组合值（供 IDLE 加载使用）
  logic [31:0] req_size_bytes_w;
  always_comb begin
    req_size_bytes_w = size_bytes_func(req_size);
  end
  logic [AXI_ADDR_WIDTH-1:0] wrap_bytes_c;
  always_comb begin
    if (req_burst == BURST_WRAP)
      wrap_bytes_c = req_size_bytes_w * (req_len + 1'b1);
    else
      wrap_bytes_c = '0;
  end

  typedef enum logic [2:0] {
    ST_IDLE      = 3'b000,
    ST_BEAT      = 3'b001,
    ST_WAITDATA  = 3'b010
  } state_e;
  state_e state_q, state_d;

  // 事务上下文
  logic [AXI_ID_WIDTH-1:0]     txn_id_q;
  logic                        txn_write_q;
  logic [AXI_ADDR_WIDTH-1:0]   start_addr_q;
  logic [7:0]                  txn_len_q;
  logic [2:0]                  txn_size_q;
  logic [1:0]                  txn_burst_q;
  logic [2:0]                  txn_prot_q;
  logic [3:0]                  beat_idx_q;
  logic [3:0]                  sub_idx_q;
  logic [AXI_ADDR_WIDTH-1:0]   beat_addr_q;
  logic [AXI_DATA_WIDTH-1:0]   beat_data_q;
  logic [AXI_DATA_WIDTH/8-1:0] beat_strb_q;
  logic [AXI_ADDR_WIDTH-1:0]   wrap_base_q;
  logic [AXI_ADDR_WIDTH-1:0]   wrap_lim_q;

  logic [31:0] size_bytes;
  assign size_bytes = size_bytes_func(txn_size_q);

  // 当前 beat 子传输数
  logic [3:0] sub_total;
  always_comb begin
    if (size_bytes >= APB_BYTES)
      sub_total = size_bytes[3:0] / APB_BYTES[3:0];
    else
      sub_total = 4'd1;
  end

  logic beat_is_last;
  assign beat_is_last = (beat_idx_q == txn_len_q[3:0]);
  logic sub_is_last;
  assign sub_is_last  = (sub_idx_q == (sub_total - 4'd1));
  logic txn_is_last;
  assign txn_is_last  = beat_is_last && sub_is_last;

  // 下一 beat 地址
  logic [AXI_ADDR_WIDTH-1:0] next_beat_addr;
  always_comb begin
    next_beat_addr = beat_addr_q;
    case (txn_burst_q)
      BURST_FIXED: next_beat_addr = beat_addr_q;
      BURST_INCR:  next_beat_addr = beat_addr_q + size_bytes[AXI_ADDR_WIDTH-1:0];
      BURST_WRAP: begin
        if ((beat_addr_q + size_bytes[AXI_ADDR_WIDTH-1:0]) == wrap_lim_q)
          next_beat_addr = wrap_base_q;
        else
          next_beat_addr = beat_addr_q + size_bytes[AXI_ADDR_WIDTH-1:0];
      end
      default:     next_beat_addr = beat_addr_q + size_bytes[AXI_ADDR_WIDTH-1:0];
    endcase
  end

  // 当前 subtransfer 地址
  logic [APB_ADDR_WIDTH-1:0] sub_addr;
  always_comb begin
    sub_addr = beat_addr_q[APB_ADDR_WIDTH-1:0];
    if (sub_total > 4'd1)
      sub_addr = beat_addr_q[APB_ADDR_WIDTH-1:0] + (APB_BYTES[APB_ADDR_WIDTH-1:0] * sub_idx_q);
  end

  // 当前 subtransfer 数据/掩码窗口
  logic [APB_DATA_WIDTH-1:0] sub_wdata;
  logic [APB_DATA_WIDTH/8-1:0] sub_wstrb;
  always_comb begin
    sub_wdata = '0;
    sub_wstrb = '0;
    for (int b = 0; b < APB_DATA_WIDTH/8; b++) begin
      sub_wdata[b*8 +: 8] = beat_data_q[(APB_BYTES*sub_idx_q)*8 + b*8 +: 8];
      sub_wstrb[b]        = beat_strb_q[(APB_BYTES*sub_idx_q) + b];
    end
  end

  // APB3 partial：写方向且本 subtransfer 的 strb 窗口不全 1 → 不发 APB、报错
  logic partial_apb3;
  always_comb begin
    partial_apb3 = 1'b0;
    if ((APB_PROFILE == APB3_PROFILE) && txn_write_q)
      if (sub_wstrb != '1)
        partial_apb3 = 1'b1;
  end

  // 非法请求：AXI4-Lite 不支持 WRAP / 非零 len → 整事务报错返回（不发任何 APB）
  logic illegal_txn;
  always_comb begin
    illegal_txn = 1'b0;
    if (AXI_PROFILE == AXI4LITE_PROFILE) begin
      if ((req_burst == BURST_WRAP) || (req_len != 8'd0))
        illegal_txn = 1'b1;
    end
  end

  // ---- 输出 ----
  assign apb_addr      = sub_addr;
  assign apb_write     = txn_write_q;
  assign apb_wdata     = sub_wdata;
  assign apb_strb      = sub_wstrb;
  assign apb_prot      = txn_prot_q;
  assign apb_id        = txn_id_q;
  assign apb_axi_beat  = beat_idx_q;
  assign apb_subbeat   = sub_idx_q;
  assign apb_beat_last = sub_is_last;
  assign apb_txn_last  = txn_is_last;
  assign apb_error     = partial_apb3;

  assign busy = (state_q != ST_IDLE);
  assign grant_is_write = txn_write_q;
  assign req_ready = (state_q == ST_IDLE);
  assign wdata_ready = (state_q == ST_WAITDATA);

  // APB 请求 valid：ST_BEAT 且非 partial（partial 不发 APB）
  assign apb_req_valid = (state_q == ST_BEAT) && !partial_apb3 && !illegal_txn;

  // 推进条件：APB 完成 或 partial 跳过
  logic sub_fire;
  assign sub_fire = (state_q == ST_BEAT) && !illegal_txn &&
                    ( partial_apb3 || (apb_req_valid && apb_req_ready) );

  assign beat_done = sub_fire && sub_is_last;
  assign txn_done  = sub_fire && txn_is_last;

  // ---- 状态机 ----
  always_comb begin
    state_d = state_q;
    case (state_q)
      ST_IDLE: begin
        if (req_valid && req_ready && !illegal_txn)
          state_d = ST_BEAT;
      end
      ST_BEAT: begin
        if (sub_fire) begin
          if (txn_is_last)
            state_d = ST_IDLE;
          else if (sub_is_last) begin
            if (txn_write_q)
              state_d = ST_WAITDATA;
            else
              state_d = ST_BEAT;   // 读：无需数据，直接进入下一 beat（ST_BEAT 复用）
          end
          // 非 sub_is_last → 保持 ST_BEAT
        end
      end
      ST_WAITDATA: begin
        if (wdata_valid && wdata_ready)
          state_d = ST_BEAT;
      end
      default: state_d = ST_IDLE;
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state_q       <= ST_IDLE;
      txn_id_q      <= '0;
      txn_write_q   <= 1'b0;
      start_addr_q  <= '0;
      txn_len_q     <= '0;
      txn_size_q    <= '0;
      txn_burst_q   <= '0;
      txn_prot_q    <= 3'b010;
      beat_idx_q    <= '0;
      sub_idx_q     <= '0;
      beat_addr_q   <= '0;
      beat_data_q   <= '0;
      beat_strb_q   <= '0;
      wrap_base_q   <= '0;
      wrap_lim_q    <= '0;
    end else begin
      state_q <= state_d;
      case (state_q)
        ST_IDLE: begin
          if (req_valid && req_ready) begin
            txn_id_q      <= req_id;
            txn_write_q   <= req_is_write;
            start_addr_q  <= req_addr;
            txn_len_q     <= req_len;
            txn_size_q    <= req_size;
            txn_burst_q   <= req_burst;
            txn_prot_q    <= req_prot;
            beat_idx_q    <= '0;
            sub_idx_q     <= '0;
            beat_addr_q   <= req_addr;
            beat_data_q   <= req_wdata;
            beat_strb_q   <= req_wstrb;
            begin
              logic [31:0] wb32;
              logic [AXI_ADDR_WIDTH-1:0] wb;
              wb32 = req_size_bytes_w * (req_len + 1'b1);
              wb   = wb32[AXI_ADDR_WIDTH-1:0];
              wrap_base_q <= (req_addr / wb) * wb;
              wrap_lim_q  <= ((req_addr / wb) * wb) + wb;
            end
          end
        end
        ST_BEAT: begin
          if (sub_fire) begin
            if (!txn_is_last && sub_is_last) begin
              // 推进到下一 beat：读方向直接进入该 beat 的 sub0；
              // 写方向需要先取数据（ST_WAITDATA）
              beat_idx_q  <= beat_idx_q + 1'b1;
              sub_idx_q   <= '0;
              beat_addr_q <= next_beat_addr;
              if (txn_write_q)
                state_q   <= ST_WAITDATA;
            end else if (!txn_is_last) begin
              sub_idx_q   <= sub_idx_q + 1'b1;
            end
          end
        end
        ST_WAITDATA: begin
          if (wdata_valid && wdata_ready) begin
            beat_data_q <= wdata;
            beat_strb_q <= wstrb;
            // 进入 ST_BEAT 的 sub0（地址已在 ST_BEAT 推进，这里不再推进地址）
            state_q     <= ST_BEAT;
          end
        end
        default: ;
      endcase
    end
  end

  // 保留寄存器避免 lint 未使用
  logic unused_start;
  assign unused_start = |start_addr_q;

endmodule : x2p_transfer_engine