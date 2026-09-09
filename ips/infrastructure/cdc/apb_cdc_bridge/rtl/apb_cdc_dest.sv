// apb_cdc_dest.sv - 目的域 APB 重新生成模块
// 下游 APB Master 接口 + 生成 FSM（IDLE->SETUP->ACCESS->COMPLETE）+ 响应发起
// 满足 LRS.FUNC.APB_CDC_BRIDGE.02.001 / 02.002 / 02.003
module apb_cdc_dest #(
  parameter int unsigned ADDR_WIDTH  = 32,
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned APB_PROFILE = 1    // 1=APB4, 0=APB3
) (
  // ===== 下游 APB Master =====
  input  logic                       m_pclk,
  input  logic                       m_presetn,
  output logic                       m_psel,
  output logic                       m_penable,
  output logic [ADDR_WIDTH-1:0]      m_paddr,
  output logic                       m_pwrite,
  output logic [DATA_WIDTH-1:0]      m_pwdata,
  output logic [DATA_WIDTH/8-1:0]    m_pstrb,
  output logic [2:0]                 m_pprot,
  input  logic [DATA_WIDTH-1:0]      m_prdata,
  input  logic                       m_pready,
  input  logic                       m_pslverr,

  // ===== Request 通道（CDC 实现 -> 目的）=====
  input  logic                       m_req_valid,
  input  logic [ADDR_WIDTH-1:0]      m_req_addr,
  input  logic                       m_req_write,
  input  logic [DATA_WIDTH-1:0]      m_req_wdata,
  input  logic [DATA_WIDTH/8-1:0]    m_req_strb,
  input  logic [2:0]                 m_req_prot,
  output logic                       m_req_ack,

  // ===== Response 通道（目的 -> CDC 实现）=====
  output logic                       m_rsp_push,
  output logic [DATA_WIDTH-1:0]      m_rsp_rdata,
  output logic                       m_rsp_slverr,
  input  logic                       m_rsp_ready
);

  // ---------------------------------------------------------------------------
  // 生成 FSM 状态编码
  // ---------------------------------------------------------------------------
  localparam logic [1:0] ST_IDLE     = 2'b00;
  localparam logic [1:0] ST_SETUP    = 2'b01;
  localparam logic [1:0] ST_ACCESS   = 2'b10;
  localparam logic [1:0] ST_COMPLETE = 2'b11;

  logic [1:0] state, state_nxt;

  // 捕获的 request payload
  logic [ADDR_WIDTH-1:0]   req_addr_q;
  logic                    req_write_q;
  logic [DATA_WIDTH-1:0]   req_wdata_q;
  logic [DATA_WIDTH/8-1:0] req_strb_q;
  logic [2:0]              req_prot_q;

  // ---------------------------------------------------------------------------
  // 状态寄存器
  // ---------------------------------------------------------------------------
  always_ff @(posedge m_pclk or negedge m_presetn) begin
    if (!m_presetn) begin
      state <= ST_IDLE;
    end else begin
      state <= state_nxt;
    end
  end

  // ---------------------------------------------------------------------------
  // request payload 捕获（IDLE 且 m_req_valid）
  // ---------------------------------------------------------------------------
  always_ff @(posedge m_pclk or negedge m_presetn) begin
    if (!m_presetn) begin
      req_addr_q  <= '0;
      req_write_q <= 1'b0;
      req_wdata_q <= '0;
      req_strb_q  <= '0;
      req_prot_q  <= '0;
    end else if (m_req_valid && (state == ST_IDLE)) begin
      req_addr_q  <= m_req_addr;
      req_write_q <= m_req_write;
      req_wdata_q <= m_req_wdata;
      req_strb_q  <= m_req_strb;
      req_prot_q  <= m_req_prot;
    end
  end

  // ---------------------------------------------------------------------------
  // 下一状态逻辑
  // ---------------------------------------------------------------------------
  always_comb begin
    state_nxt = state;
    case (state)
      ST_IDLE:     state_nxt = m_req_valid ? ST_SETUP : ST_IDLE;
      ST_SETUP:    state_nxt = ST_ACCESS;
      ST_ACCESS:   state_nxt = m_pready  ? ST_COMPLETE : ST_ACCESS;
      ST_COMPLETE: state_nxt = m_rsp_ready ? ST_IDLE : ST_COMPLETE;
      default:     state_nxt = ST_IDLE;   // 非法状态恢复
    endcase
  end

  // ---------------------------------------------------------------------------
  // 下游 APB 输出
  // ---------------------------------------------------------------------------
  assign m_psel    = (state == ST_SETUP) || (state == ST_ACCESS);
  assign m_penable = (state == ST_ACCESS);
  assign m_paddr   = req_addr_q;
  assign m_pwrite  = req_write_q;
  assign m_pwdata  = req_wdata_q;
  assign m_pstrb   = (APB_PROFILE == 1) ? req_strb_q : '0;
  assign m_pprot   = (APB_PROFILE == 1) ? req_prot_q : '0;

  // ---------------------------------------------------------------------------
  // 请求 ack（进入 SETUP 时即确认已读 payload；COMPLETE 后释放）
  // ---------------------------------------------------------------------------
  assign m_req_ack = (state == ST_SETUP);

  // ---------------------------------------------------------------------------
  // 响应发起（COMPLETE 且 rsp_ready 时单周期 push）
  // ---------------------------------------------------------------------------
  assign m_rsp_push   = (state == ST_COMPLETE) && m_rsp_ready;
  assign m_rsp_rdata  = m_prdata;
  assign m_rsp_slverr = m_pslverr;

endmodule : apb_cdc_dest
