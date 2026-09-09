// apb_cdc_handshake.sv - HANDSHAKE CDC 实现（bundled-data 握手）
// 满足 LRS.FUNC.APB_CDC_BRIDGE.03.001 / 03.002 / 04.002
// 架构:
//   源域: 锁存 req_payload + req_toggle 翻转 -> 2FF sync
//   目的域: 检测 req_toggle 变化 -> 读 payload -> 执行 APB -> 锁存 rsp_payload + rsp_toggle
//   源域: 检测 rsp_toggle 变化 -> 读 payload -> 返回
// 本模块封装 Request 与 Response 两个 bundled-data handshake，对 SOURCE/DEST 暴露
// 一致的 req_channel / rsp_channel 接口契约（payload + toggle + ack）。
module apb_cdc_handshake #(
  parameter int unsigned ADDR_WIDTH   = 32,
  parameter int unsigned DATA_WIDTH   = 32,
  parameter int unsigned SYNC_STAGES  = 2,   // >= 2
  parameter int unsigned APB_PROFILE  = 1    // 1=APB4 (含 PSTRB/PPROT), 0=APB3
) (
  // ===== Source domain =====
  input  logic                       s_clk,
  input  logic                       s_rst_n,
  // req 通道（源 -> 目的）
  input  logic                       s_req_push,       // 源域发起请求（载荷已就绪）
  input  logic [ADDR_WIDTH-1:0]      s_req_addr,
  input  logic                       s_req_write,
  input  logic [DATA_WIDTH-1:0]      s_req_wdata,
  input  logic [DATA_WIDTH/8-1:0]    s_req_strb,       // APB4
  input  logic [2:0]                 s_req_prot,       // APB4
  output logic                       s_req_ready,      // 目的域 ack 已回（可接受新请求）
  // rsp 通道（目的 -> 源）
  output logic                       s_rsp_valid,      // 源域已收到响应（单周期）
  output logic [DATA_WIDTH-1:0]      s_rsp_rdata,
  output logic                       s_rsp_slverr,

  // ===== Destination domain =====
  input  logic                       m_clk,
  input  logic                       m_rst_n,
  // req 通道（源 -> 目的）
  output logic                       m_req_valid,      // 目的域检测到新请求（保持至 ack）
  output logic [ADDR_WIDTH-1:0]      m_req_addr,
  output logic                       m_req_write,
  output logic [DATA_WIDTH-1:0]      m_req_wdata,
  output logic [DATA_WIDTH/8-1:0]    m_req_strb,
  output logic [2:0]                 m_req_prot,
  input  logic                       m_req_ack,        // 目的域已读 payload（执行完成）
  // rsp 通道（目的 -> 源）
  input  logic                       m_rsp_push,       // 目的域发起响应（载荷已就绪，单周期）
  input  logic [DATA_WIDTH-1:0]      m_rsp_rdata,
  input  logic                       m_rsp_slverr,
  output logic                       m_rsp_ready       // 源域 ack 已回（可接受新响应）
);

  // ---------------------------------------------------------------------------
  // 全部信号声明（先声明后使用）
  // ---------------------------------------------------------------------------

  // Request 通道
  logic                        req_toggle;
  logic                        req_toggle_sync;
  logic                        req_toggle_sync_d;
  logic                        req_ack_toggle;
  logic                        req_ack_toggle_sync;
  logic                        req_ack_toggle_sync_d;
  logic                        req_busy;                 // 源域请求进行中
  logic                        m_req_pending;            // 目的域待读请求

  // 源域 request payload 锁存
  logic [ADDR_WIDTH-1:0]       req_payload_addr;
  logic                        req_payload_write;
  logic [DATA_WIDTH-1:0]       req_payload_wdata;
  logic [DATA_WIDTH/8-1:0]     req_payload_strb;
  logic [2:0]                  req_payload_prot;

  // 目的域读出的 request payload
  logic [ADDR_WIDTH-1:0]       m_req_addr_q;
  logic                        m_req_write_q;
  logic [DATA_WIDTH-1:0]       m_req_wdata_q;
  logic [DATA_WIDTH/8-1:0]     m_req_strb_q;
  logic [2:0]                  m_req_prot_q;

  // Response 通道
  logic                        rsp_toggle;
  logic                        rsp_toggle_sync;
  logic                        rsp_toggle_sync_d;
  logic                        rsp_ack_toggle;
  logic                        rsp_ack_toggle_sync;
  logic                        rsp_ack_toggle_sync_d;
  logic                        rsp_busy;                 // 目的域响应进行中

  // 目的域 response payload 锁存
  logic [DATA_WIDTH-1:0]       rsp_payload_rdata;
  logic                        rsp_payload_slverr;

  // 源域读出的 response payload
  logic [DATA_WIDTH-1:0]       s_rsp_rdata_q;
  logic                        s_rsp_slverr_q;
  logic                        s_rsp_valid_q;

  // ===========================================================================
  // Request 通道
  // ===========================================================================

  // 源域: 锁存 request payload + 翻转 toggle（s_req_push 为单周期脉冲）
  always_ff @(posedge s_clk or negedge s_rst_n) begin
    if (!s_rst_n) begin
      req_toggle         <= 1'b0;
      req_payload_addr   <= '0;
      req_payload_write  <= 1'b0;
      req_payload_wdata  <= '0;
      req_payload_strb   <= '0;
      req_payload_prot   <= '0;
      req_busy           <= 1'b0;
      req_ack_toggle_sync_d <= 1'b0;
    end else begin
      req_ack_toggle_sync_d <= req_ack_toggle_sync;
      if (s_req_push && !req_busy) begin
        req_toggle        <= ~req_toggle;
        req_payload_addr  <= s_req_addr;
        req_payload_write <= s_req_write;
        req_payload_wdata <= s_req_wdata;
        req_payload_strb  <= s_req_strb;
        req_payload_prot  <= s_req_prot;
        req_busy          <= 1'b1;
      end
      // 目的域 ack 已回（req_ack_toggle 同步到源域后变化）-> 释放 busy
      if (req_busy && (req_ack_toggle_sync != req_ack_toggle_sync_d)) begin
        req_busy <= 1'b0;
      end
    end
  end

  // 目的域: 同步 req_toggle + 检测翻转
  apb_cdc_sync_chain #(.SYNC_STAGES(SYNC_STAGES)) u_req_sync (
    .din   (req_toggle),
    .clk   (m_clk),
    .rst_n (m_rst_n),
    .dout  (req_toggle_sync)
  );

  always_ff @(posedge m_clk or negedge m_rst_n) begin
    if (!m_rst_n) begin
      req_toggle_sync_d <= 1'b0;
      m_req_pending     <= 1'b0;
      m_req_addr_q      <= '0;
      m_req_write_q     <= 1'b0;
      m_req_wdata_q     <= '0;
      m_req_strb_q      <= '0;
      m_req_prot_q      <= '0;
    end else begin
      req_toggle_sync_d <= req_toggle_sync;
      // 翻转检测
      if (req_toggle_sync != req_toggle_sync_d) begin
        // 读入 payload（bundled-data: 目的域看到 toggle 变化时 payload 已稳定）
        m_req_addr_q   <= req_payload_addr;
        m_req_write_q  <= req_payload_write;
        m_req_wdata_q  <= req_payload_wdata;
        m_req_strb_q   <= req_payload_strb;
        m_req_prot_q   <= req_payload_prot;
        m_req_pending  <= 1'b1;
      end
      // 目的域已读（m_req_ack）-> 清 pending
      if (m_req_ack) begin
        m_req_pending <= 1'b0;
      end
    end
  end

  assign s_req_ready = ~req_busy;

  assign m_req_valid = m_req_pending;
  assign m_req_addr  = m_req_addr_q;
  assign m_req_write = m_req_write_q;
  assign m_req_wdata = m_req_wdata_q;
  assign m_req_strb  = m_req_strb_q;
  assign m_req_prot  = m_req_prot_q;

  // 目的域在 m_req_ack 时翻转 req_ack_toggle 回源
  always_ff @(posedge m_clk or negedge m_rst_n) begin
    if (!m_rst_n) begin
      req_ack_toggle <= 1'b0;
    end else if (m_req_ack) begin
      req_ack_toggle <= ~req_ack_toggle;
    end
  end

  apb_cdc_sync_chain #(.SYNC_STAGES(SYNC_STAGES)) u_req_ack_sync (
    .din   (req_ack_toggle),
    .clk   (s_clk),
    .rst_n (s_rst_n),
    .dout  (req_ack_toggle_sync)
  );

  // ===========================================================================
  // Response 通道
  // ===========================================================================

  // 目的域: 锁存 response payload + 翻转 toggle
  always_ff @(posedge m_clk or negedge m_rst_n) begin
    if (!m_rst_n) begin
      rsp_toggle         <= 1'b0;
      rsp_payload_rdata  <= '0;
      rsp_payload_slverr <= 1'b0;
      rsp_busy           <= 1'b0;
      rsp_ack_toggle_sync_d <= 1'b0;
    end else begin
      rsp_ack_toggle_sync_d <= rsp_ack_toggle_sync;
      if (m_rsp_push && !rsp_busy) begin
        rsp_toggle         <= ~rsp_toggle;
        rsp_payload_rdata  <= m_rsp_rdata;
        rsp_payload_slverr <= m_rsp_slverr;
        rsp_busy           <= 1'b1;
      end
      // 源域 ack 已回 -> 释放 busy
      if (rsp_busy && (rsp_ack_toggle_sync != rsp_ack_toggle_sync_d)) begin
        rsp_busy <= 1'b0;
      end
    end
  end
  assign m_rsp_ready = ~rsp_busy;

  // 源域: 同步 rsp_toggle + 检测翻转
  apb_cdc_sync_chain #(.SYNC_STAGES(SYNC_STAGES)) u_rsp_sync (
    .din   (rsp_toggle),
    .clk   (s_clk),
    .rst_n (s_rst_n),
    .dout  (rsp_toggle_sync)
  );

  always_ff @(posedge s_clk or negedge s_rst_n) begin
    if (!s_rst_n) begin
      rsp_toggle_sync_d <= 1'b0;
      s_rsp_valid_q     <= 1'b0;
      s_rsp_rdata_q     <= '0;
      s_rsp_slverr_q    <= 1'b0;
    end else begin
      rsp_toggle_sync_d <= rsp_toggle_sync;
      if (rsp_toggle_sync != rsp_toggle_sync_d) begin
        // 读入 response payload（bundled-data）
        s_rsp_rdata_q  <= rsp_payload_rdata;
        s_rsp_slverr_q <= rsp_payload_slverr;
        s_rsp_valid_q  <= 1'b1;
      end
      // 源域完成消费（单周期有效）
      if (s_rsp_valid_q) begin
        s_rsp_valid_q <= 1'b0;
      end
    end
  end

  assign s_rsp_valid  = s_rsp_valid_q;
  assign s_rsp_rdata  = s_rsp_rdata_q;
  assign s_rsp_slverr = s_rsp_slverr_q;

  // 源域在 s_rsp_valid（单周期）时翻转 rsp_ack_toggle 回目的
  always_ff @(posedge s_clk or negedge s_rst_n) begin
    if (!s_rst_n) begin
      rsp_ack_toggle <= 1'b0;
    end else if (s_rsp_valid_q) begin
      rsp_ack_toggle <= ~rsp_ack_toggle;
    end
  end

  apb_cdc_sync_chain #(.SYNC_STAGES(SYNC_STAGES)) u_rsp_ack_sync (
    .din   (rsp_ack_toggle),
    .clk   (m_clk),
    .rst_n (m_rst_n),
    .dout  (rsp_ack_toggle_sync)
  );

endmodule : apb_cdc_handshake
