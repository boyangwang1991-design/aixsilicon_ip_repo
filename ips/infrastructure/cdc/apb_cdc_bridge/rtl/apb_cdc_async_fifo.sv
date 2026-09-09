// apb_cdc_async_fifo.sv - ASYNC_FIFO CDC 实现
// 满足 LRS.FUNC.APB_CDC_BRIDGE.04.001 / 04.002
// Request payload FIFO（源->目的）+ Response payload FIFO（目的->源）
// Gray 指针 + 标准两级同步器；REQ_DEPTH/RSP_DEPTH = 1/2
// 对 SOURCE/DEST 暴露一致的 req_channel / rsp_channel 接口契约。
module apb_cdc_async_fifo #(
  parameter int unsigned ADDR_WIDTH   = 32,
  parameter int unsigned DATA_WIDTH   = 32,
  parameter int unsigned REQ_DEPTH    = 1,   // 1 或 2
  parameter int unsigned RSP_DEPTH    = 1,   // 1 或 2
  parameter int unsigned APB_PROFILE  = 1    // 1=APB4
) (
  // ===== Source domain =====
  input  logic                       s_clk,
  input  logic                       s_rst_n,
  input  logic                       s_req_push,
  input  logic [ADDR_WIDTH-1:0]      s_req_addr,
  input  logic                       s_req_write,
  input  logic [DATA_WIDTH-1:0]      s_req_wdata,
  input  logic [DATA_WIDTH/8-1:0]    s_req_strb,
  input  logic [2:0]                 s_req_prot,
  output logic                       s_req_ready,
  output logic                       s_rsp_valid,
  output logic [DATA_WIDTH-1:0]      s_rsp_rdata,
  output logic                       s_rsp_slverr,

  // ===== Destination domain =====
  input  logic                       m_clk,
  input  logic                       m_rst_n,
  output logic                       m_req_valid,
  output logic [ADDR_WIDTH-1:0]      m_req_addr,
  output logic                       m_req_write,
  output logic [DATA_WIDTH-1:0]      m_req_wdata,
  output logic [DATA_WIDTH/8-1:0]    m_req_strb,
  output logic [2:0]                 m_req_prot,
  input  logic                       m_req_ack,       // 目的域读取请求
  input  logic                       m_rsp_push,
  input  logic [DATA_WIDTH-1:0]      m_rsp_rdata,
  input  logic                       m_rsp_slverr,
  output logic                       m_rsp_ready
);

  // ---------------------------------------------------------------------------
  // 内部信号声明
  // ---------------------------------------------------------------------------
  localparam int unsigned REQ_W = ADDR_WIDTH + 1 + DATA_WIDTH + DATA_WIDTH/8 + 3;
  localparam int unsigned RSP_W = DATA_WIDTH + 1;

  // 请求 FIFO
  logic [REQ_W-1:0]       req_fifo_wdata;
  logic [REQ_W-1:0]       req_fifo_rdata;
  logic                   req_push, req_pop, req_full, req_empty;
  logic                   req_pop_pulse;

  // 响应 FIFO
  logic [RSP_W-1:0]       rsp_fifo_wdata;
  logic [RSP_W-1:0]       rsp_fifo_rdata;
  logic                   rsp_push, rsp_pop, rsp_full, rsp_empty;
  logic                   rsp_pop_pulse;

  // 目的域锁存（从 req FIFO 读出）
  logic [ADDR_WIDTH-1:0]    m_req_addr_q;
  logic                     m_req_write_q;
  logic [DATA_WIDTH-1:0]    m_req_wdata_q;
  logic [DATA_WIDTH/8-1:0]  m_req_strb_q;
  logic [2:0]               m_req_prot_q;
  logic                     m_req_valid_q;

  // 源域锁存（从 rsp FIFO 读出）
  logic [DATA_WIDTH-1:0]    s_rsp_rdata_q;
  logic                     s_rsp_slverr_q;
  logic                     s_rsp_valid_q;

  // ---------------------------------------------------------------------------
  // 请求 FIFO 打包: {PPROT[2:0], PSTRB, PWDATA, PWRITE, PADDR}
  // ---------------------------------------------------------------------------
  assign req_fifo_wdata = {s_req_prot, s_req_strb, s_req_wdata, s_req_write, s_req_addr};
  assign req_push       = s_req_push && !req_full;
  assign s_req_ready    = !req_full;

  // 请求 FIFO 读取（目的域）
  assign req_pop_pulse  = m_req_valid_q ? m_req_ack : 1'b0;
  assign req_pop        = req_pop_pulse;

  apb_cdc_async_fifo_ram #(
    .DATA_WIDTH(REQ_W),
    .DEPTH     (REQ_DEPTH)
  ) u_req_fifo (
    .wclk    (s_clk),
    .wrst_n  (s_rst_n),
    .wpush   (req_push),
    .wdata   (req_fifo_wdata),
    .wfull   (req_full),
    .rclk    (m_clk),
    .rrst_n  (m_rst_n),
    .rpop    (req_pop),
    .rdata   (req_fifo_rdata),
    .rempty  (req_empty)
  );

  // 目的域: 从 FIFO 读请求 -> 锁存 -> valid
  always_ff @(posedge m_clk or negedge m_rst_n) begin
    if (!m_rst_n) begin
      m_req_addr_q   <= '0;
      m_req_write_q  <= 1'b0;
      m_req_wdata_q  <= '0;
      m_req_strb_q   <= '0;
      m_req_prot_q   <= '0;
      m_req_valid_q  <= 1'b0;
    end else begin
      if (!req_empty && !m_req_valid_q) begin
        // 弹出并锁存
        {m_req_prot_q, m_req_strb_q, m_req_wdata_q, m_req_write_q, m_req_addr_q} <= req_fifo_rdata;
        m_req_valid_q <= 1'b1;
      end
      if (m_req_ack) begin
        m_req_valid_q <= 1'b0;
      end
    end
  end

  assign m_req_valid = m_req_valid_q;
  assign m_req_addr  = m_req_addr_q;
  assign m_req_write = m_req_write_q;
  assign m_req_wdata = m_req_wdata_q;
  assign m_req_strb  = m_req_strb_q;
  assign m_req_prot  = m_req_prot_q;

  // ---------------------------------------------------------------------------
  // 响应 FIFO 打包: {PSLVERR, PRDATA}
  // ---------------------------------------------------------------------------
  assign rsp_fifo_wdata = {m_rsp_slverr, m_rsp_rdata};
  assign rsp_push       = m_rsp_push && !rsp_full;
  assign m_rsp_ready    = !rsp_full;

  // 响应 FIFO 读取（源域）
  assign rsp_pop_pulse  = s_rsp_valid_q ? 1'b0 : !rsp_empty;
  assign rsp_pop        = rsp_pop_pulse;

  apb_cdc_async_fifo_ram #(
    .DATA_WIDTH(RSP_W),
    .DEPTH     (RSP_DEPTH)
  ) u_rsp_fifo (
    .wclk    (m_clk),
    .wrst_n  (m_rst_n),
    .wpush   (rsp_push),
    .wdata   (rsp_fifo_wdata),
    .wfull   (rsp_full),
    .rclk    (s_clk),
    .rrst_n  (s_rst_n),
    .rpop    (rsp_pop),
    .rdata   (rsp_fifo_rdata),
    .rempty  (rsp_empty)
  );

  // 源域: 从 FIFO 读响应 -> 锁存 -> valid（单周期）
  always_ff @(posedge s_clk or negedge s_rst_n) begin
    if (!s_rst_n) begin
      s_rsp_rdata_q  <= '0;
      s_rsp_slverr_q <= 1'b0;
      s_rsp_valid_q  <= 1'b0;
    end else begin
      if (s_rsp_valid_q) begin
        s_rsp_valid_q <= 1'b0;
      end
      if (rsp_pop_pulse) begin
        {s_rsp_slverr_q, s_rsp_rdata_q} <= rsp_fifo_rdata;
        s_rsp_valid_q <= 1'b1;
      end
    end
  end

  assign s_rsp_valid  = s_rsp_valid_q;
  assign s_rsp_rdata  = s_rsp_rdata_q;
  assign s_rsp_slverr = s_rsp_slverr_q;

endmodule : apb_cdc_async_fifo


// ---------------------------------------------------------------------------
// 通用异步 FIFO RAM（DEPTH 支持 1 或 2）
// DEPTH=2: Gray 指针 + 两级同步器（标准异步 FIFO）
// DEPTH=1: 单槽寄存器 + 跨域 valid/ack（简化）
// 通过 generate 分支彻底隔离两种深度实现，避免非法位宽索引。
// ---------------------------------------------------------------------------
module apb_cdc_async_fifo_ram #(
  parameter int unsigned DATA_WIDTH = 32,
  parameter int unsigned DEPTH      = 1
) (
  input  logic                       wclk,
  input  logic                       wrst_n,
  input  logic                       wpush,
  input  logic [DATA_WIDTH-1:0]      wdata,
  output logic                       wfull,
  input  logic                       rclk,
  input  logic                       rrst_n,
  input  logic                       rpop,
  output logic [DATA_WIDTH-1:0]      rdata,
  output logic                       rempty
);

  generate
    if (DEPTH == 2) begin : g_depth2
      localparam int unsigned PW = 2; // 2 slot -> 2 bit 指针（1 地址位 + 1 扩展位）

      logic [PW-1:0] wptr_bin,  rptr_bin;
      logic [PW-1:0] wptr_gray, rptr_gray;
      logic [PW-1:0] wptr_sync1, wptr_sync2;
      logic [PW-1:0] rptr_sync1, rptr_sync2;

      logic [DATA_WIDTH-1:0] mem [2];

      // 写域
      assign wfull = (wptr_gray == {~rptr_sync2[1], rptr_sync2[0]});

      always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
          wptr_bin  <= '0;
          wptr_gray <= '0;
        end else begin
          if (wpush && !wfull) begin
            wptr_bin  <= wptr_bin + 1'b1;
            wptr_gray <= (wptr_bin + 1'b1) ^ ((wptr_bin + 1'b1) >> 1);
            mem[wptr_bin[0]] <= wdata;
          end
        end
      end

      // 读域
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

      assign rdata = mem[rptr_bin[0]];

      // 指针同步（标准两级）
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

    end else begin : g_depth1
      // 单槽 FIFO：写满/读空通过跨域 valid/ack 握手
      logic wr_valid;
      logic rd_valid;
      logic rd_ack_sync1, rd_ack_sync2;        // 读侧 valid -> 同步回写侧
      logic wr_valid_sync1, wr_valid_sync2;    // 写侧 valid -> 同步到读侧
      logic [DATA_WIDTH-1:0] data_reg;

      // 写侧：valid 置位（push），读侧 ack 回（已 pop）后清
      always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
          wr_valid <= 1'b0;
          data_reg <= '0;
        end else begin
          if (wpush && !wr_valid) begin
            wr_valid <= 1'b1;
            data_reg <= wdata;
          end
          if (wr_valid && rd_ack_sync2) begin
            wr_valid <= 1'b0;
          end
        end
      end

      // 写侧 valid 同步到读域
      always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
          wr_valid_sync1 <= 1'b0;
          wr_valid_sync2 <= 1'b0;
        end else begin
          wr_valid_sync1 <= wr_valid;
          wr_valid_sync2 <= wr_valid_sync1;
        end
      end

      // 读侧：valid（可 pop），rpop 后清并同步回写侧
      always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
          rd_valid <= 1'b0;
        end else begin
          if (wr_valid_sync2 && !rd_valid) begin
            rd_valid <= 1'b1;
          end
          if (rpop && rd_valid) begin
            rd_valid <= 1'b0;
          end
        end
      end

      // 读侧 valid 同步回写域（作为 ack）
      always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
          rd_ack_sync1 <= 1'b0;
          rd_ack_sync2 <= 1'b0;
        end else begin
          rd_ack_sync1 <= rd_valid;
          rd_ack_sync2 <= rd_ack_sync1;
        end
      end

      assign wfull  = wr_valid;
      assign rempty = !rd_valid;
      assign rdata  = data_reg;

    end
  endgenerate

endmodule : apb_cdc_async_fifo_ram
