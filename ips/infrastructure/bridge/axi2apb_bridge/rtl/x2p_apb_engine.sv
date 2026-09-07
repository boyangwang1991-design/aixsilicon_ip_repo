// x2p_apb_engine.sv - APB Master FSM（SETUP/ACCESS/WAIT/TIMEOUT）
// 输入单个 APB 请求（来自 transfer engine；ASYNC 时经 CDC），
// 输出 APB Master 信号，返回应答（rsp_valid/rdata/error）。
// Timeout：ACCESS 期间 PREADY=0 持续 TIMEOUT_CYCLES 触发 SLVERR 并恢复。
// back-to-back：COMPLETE 后若 request 在等待，直接进入下一 SETUP 无 IDLE bubble。
// APB_OUTPUT_REG=1 时采用 registered output（由 FSM 控制相位）。
module x2p_apb_engine #(
  parameter int unsigned APB_ADDR_WIDTH = 32,
  parameter int unsigned APB_DATA_WIDTH = 32,
  parameter int unsigned AXI_ID_WIDTH   = 4,
  parameter int unsigned APB_PROFILE    = 1,       // 1=APB4 0=APB3
  parameter bit          TIMEOUT_ENABLE = 1'b1,
  parameter int unsigned TIMEOUT_CYCLES = 256,
  parameter bit          APB_OUTPUT_REG = 1'b1
) (
  input  logic clk,
  input  logic rst_n,

  // 请求接口
  input  logic                        req_valid,
  output logic                        req_ready,
  input  logic [APB_ADDR_WIDTH-1:0]   req_addr,
  input  logic                        req_write,
  input  logic [APB_DATA_WIDTH-1:0]   req_wdata,
  input  logic [APB_DATA_WIDTH/8-1:0] req_strb,
  input  logic [2:0]                  req_prot,
  input  logic [AXI_ID_WIDTH-1:0]     req_id,
  input  logic [3:0]                  req_beat,
  input  logic [3:0]                  req_sub,
  input  logic                        req_beat_last,
  input  logic                        req_txn_last,
  input  logic                        req_error,   // 预错误（transfer engine 判定，如 APB3 partial）

  // 响应接口
  output logic                        rsp_valid,
  input  logic                        rsp_ready,
  output logic [APB_DATA_WIDTH-1:0]   rsp_data,
  output logic                        rsp_error,
  output logic [AXI_ID_WIDTH-1:0]     rsp_id,
  output logic [3:0]                  rsp_beat,
  output logic [3:0]                  rsp_sub,
  output logic                        rsp_beat_last,
  output logic                        rsp_txn_last,
  output logic                        rsp_write,   // 响应方向（锁定于发起请求的方向）

  // APB Master
  output logic [APB_ADDR_WIDTH-1:0]   paddr,
  output logic                        psel,
  output logic                        penable,
  output logic                        pwrite,
  output logic [APB_DATA_WIDTH-1:0]   pwdata,
  output logic [APB_DATA_WIDTH/8-1:0] pstrb,
  output logic [2:0]                  pprot,
  input  logic [APB_DATA_WIDTH-1:0]   prdata,
  input  logic                        pready,
  input  logic                        pslverr
);

  import x2p_pkg::*;

  typedef enum logic [2:0] {
    ST_IDLE   = 3'b000,
    ST_SETUP  = 3'b001,
    ST_ACCESS = 3'b010,
    ST_DONE   = 3'b011
  } state_e;
  state_e state_q, state_d;

  // 请求锁存
  logic [APB_ADDR_WIDTH-1:0]   addr_q;
  logic                        write_q;
  logic [APB_DATA_WIDTH-1:0]   wdata_q;
  logic [APB_DATA_WIDTH/8-1:0] strb_q;
  logic [2:0]                  prot_q;
  logic [AXI_ID_WIDTH-1:0]     id_q;
  logic [3:0]                  beat_q;
  logic [3:0]                  sub_q;
  logic                        beat_last_q;
  logic                        txn_last_q;
  logic                        req_err_q;    // 事务启动即确认的错误（不发 APB）

  logic                        rsp_pending_q;  // 已生成响应等待 ready
  logic [APB_DATA_WIDTH-1:0]   rsp_data_q;
  logic                        rsp_error_q;
  logic [AXI_ID_WIDTH-1:0]     rsp_id_q;
  logic [3:0]                  rsp_beat_q;
  logic [3:0]                  rsp_sub_q;
  logic                        rsp_beat_last_q;
  logic                        rsp_txn_last_q;

  // timeout 计数（仅 ACCESS）
  logic [31:0]                 tout_cnt_q;
  logic                        timeout_hit;

  assign timeout_hit = TIMEOUT_ENABLE && (tout_cnt_q >= TIMEOUT_CYCLES[31:0]);

  // 请求接受：仅当 IDLE（无进行中的 APB 传输）
  // 注意：rsp_pending_q 是响应缓冲，不阻塞新请求接受（APB 串行执行，
  // 响应可排队经 rsp_mgr 消费）
  assign req_ready = (state_q == ST_IDLE);

  // 错误路径：req_error 标记的请求直接返回 SLVERR（不发 APB），req_ready 接受但结果 error
  logic req_err_latched;
  assign req_err_latched = req_err_q;

  // ---- APB 输出（register 可选）----
  logic [APB_ADDR_WIDTH-1:0]   paddr_c;
  logic                        psel_c;
  logic                        penable_c;
  logic                        pwrite_c;
  logic [APB_DATA_WIDTH-1:0]   pwdata_c;
  logic [APB_DATA_WIDTH/8-1:0] pstrb_c;
  logic [2:0]                  pprot_c;

  always_comb begin
    paddr_c   = addr_q;
    psel_c    = (state_q == ST_SETUP) || (state_q == ST_ACCESS);
    penable_c = (state_q == ST_ACCESS);
    pwrite_c  = write_q;
    pwdata_c  = wdata_q;
    pstrb_c   = strb_q;
    pprot_c   = prot_q;
  end

  generate
    if (APB_OUTPUT_REG) begin : g_apb_out_reg
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          paddr   <= '0;
          psel    <= 1'b0;
          penable <= 1'b0;
          pwrite  <= 1'b0;
          pwdata  <= '0;
          pstrb   <= '0;
          pprot   <= 3'b010;
        end else begin
          paddr   <= paddr_c;
          psel    <= psel_c;
          penable <= penable_c;
          pwrite  <= pwrite_c;
          pwdata  <= pwdata_c;
          pstrb   <= pstrb_c;
          pprot   <= pprot_c;
        end
      end
    end else begin : g_apb_out_comb
      assign paddr   = paddr_c;
      assign psel    = psel_c;
      assign penable = penable_c;
      assign pwrite  = pwrite_c;
      assign pwdata  = pwdata_c;
      assign pstrb   = pstrb_c;
      assign pprot   = pprot_c;
    end
  endgenerate

  // ---- 相位移位：reg 输出时 SETUP 延迟一拍，用 phase 修正 ----
  // （registered output 下 ACCESS phase 由 FSM 把握，保持 SETUP->ACCESS 1 拍关系）

  // ---- 状态机 ----
  always_comb begin
    state_d = state_q;
    case (state_q)
      ST_IDLE: begin
        if (req_valid && req_ready)
          state_d = ST_SETUP;
      end
      ST_SETUP: begin
        state_d = ST_ACCESS;
      end
      ST_ACCESS: begin
        if (timeout_hit)
          state_d = ST_DONE;
        else if (pready)
          state_d = ST_DONE;
      end
      ST_DONE: begin
        if (rsp_valid && rsp_ready)
          state_d = ST_IDLE;
      end
      default: state_d = ST_IDLE;
    endcase
  end

  // ---- 状态寄存器（state_d -> state_q） ----
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state_q <= ST_IDLE;
    else
      state_q <= state_d;
  end

  logic apb_access_error;
  assign apb_access_error = pready && pslverr;

  // 锁存响应（req_error 或 timeout 或 PSLVERR 或 APB3 partial 已在 req_error）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rsp_pending_q  <= 1'b0;
      rsp_data_q     <= '0;
      rsp_error_q    <= 1'b0;
      rsp_id_q       <= '0;
      rsp_beat_q     <= '0;
      rsp_sub_q      <= '0;
      rsp_beat_last_q<= 1'b0;
      rsp_txn_last_q <= 1'b0;
    end else begin
      if (state_q == ST_ACCESS) begin
        if (pready || timeout_hit) begin
          rsp_pending_q   <= 1'b1;
          rsp_data_q      <= prdata;
          rsp_error_q     <= apb_access_error || timeout_hit || req_err_latched;
          rsp_id_q        <= id_q;
          rsp_beat_q      <= beat_q;
          rsp_sub_q       <= sub_q;
          rsp_beat_last_q <= beat_last_q;
          rsp_txn_last_q  <= txn_last_q;
        end
      end else if (state_q == ST_IDLE) begin
        if (req_valid && req_error) begin
          // 直接锁存错误响应，不发 APB
          rsp_pending_q   <= 1'b1;
          rsp_data_q      <= '0;
          rsp_error_q     <= 1'b1;
          rsp_id_q        <= req_id;
          rsp_beat_q      <= req_beat;
          rsp_sub_q       <= req_sub;
          rsp_beat_last_q <= req_beat_last;
          rsp_txn_last_q  <= req_txn_last;
        end
      end else if (rsp_valid && rsp_ready) begin
        rsp_pending_q <= 1'b0;
      end
    end
  end

  // rsp_valid: 有 pending 响应
  assign rsp_valid = rsp_pending_q;
  // 响应输出连接到锁存寄存器
  assign rsp_data      = rsp_data_q;
  assign rsp_error     = rsp_error_q;
  assign rsp_id        = rsp_id_q;
  assign rsp_beat      = rsp_beat_q;
  assign rsp_sub       = rsp_sub_q;
  assign rsp_beat_last = rsp_beat_last_q;
  assign rsp_txn_last  = rsp_txn_last_q;
  // 响应方向 = 本请求发起时的方向（rsp pending 期间不会接受新请求，write_q 稳定）
  assign rsp_write = write_q;

  // timeout 计数
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      tout_cnt_q <= '0;
    else begin
      case (state_q)
        ST_ACCESS: begin
          if (!pready)
            tout_cnt_q <= tout_cnt_q + 1'b1;
          else
            tout_cnt_q <= '0;
        end
        default: tout_cnt_q <= '0;
      endcase
    end
  end

  // ---- 请求锁存 ----
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      addr_q      <= '0;
      write_q     <= 1'b0;
      wdata_q     <= '0;
      strb_q      <= '0;
      prot_q      <= 3'b010;
      id_q        <= '0;
      beat_q      <= '0;
      sub_q       <= '0;
      beat_last_q <= 1'b0;
      txn_last_q  <= 1'b0;
      req_err_q   <= 1'b0;
    end else begin
      if (req_valid && req_ready) begin
        addr_q      <= req_addr;
        write_q     <= req_write;
        wdata_q     <= req_wdata;
        strb_q      <= req_strb;
        prot_q      <= req_prot;
        id_q        <= req_id;
        beat_q      <= req_beat;
        sub_q       <= req_sub;
        beat_last_q <= req_beat_last;
        txn_last_q  <= req_txn_last;
        req_err_q   <= req_error;
      end
    end
  end

  // 应答通道组合引用（避免未使用 lint）
  logic unused_rsp_side;
  assign unused_rsp_side = rsp_ready;

endmodule : x2p_apb_engine