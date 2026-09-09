// apb_cdc_source.sv - 源域 APB 捕获模块
// 上游 APB Slave 接口 + 捕获 FSM + 响应返回
// 满足 LRS.FUNC.APB_CDC_BRIDGE.01.001 / 01.002 / 01.003 / 05.001 / 08.001
module apb_cdc_source #(
  parameter int unsigned ADDR_WIDTH  = 32,
  parameter int unsigned DATA_WIDTH  = 32,
  parameter int unsigned APB_PROFILE = 1    // 1=APB4, 0=APB3
) (
  // ===== 上游 APB Slave =====
  input  logic                       s_pclk,
  input  logic                       s_presetn,
  input  logic                       s_psel,
  input  logic                       s_penable,
  input  logic [ADDR_WIDTH-1:0]      s_paddr,
  input  logic                       s_pwrite,
  input  logic [DATA_WIDTH-1:0]      s_pwdata,
  input  logic [DATA_WIDTH/8-1:0]    s_pstrb,
  input  logic [2:0]                 s_pprot,
  output logic [DATA_WIDTH-1:0]      s_prdata,
  output logic                       s_pready,
  output logic                       s_pslverr,

  // ===== Request 通道（源 -> CDC 实现）=====
  output logic                       s_req_push,
  output logic [ADDR_WIDTH-1:0]      s_req_addr,
  output logic                       s_req_write,
  output logic [DATA_WIDTH-1:0]      s_req_wdata,
  output logic [DATA_WIDTH/8-1:0]    s_req_strb,
  output logic [2:0]                 s_req_prot,
  input  logic                       s_req_ready,

  // ===== Response 通道（CDC 实现 -> 源）=====
  input  logic                       s_rsp_valid,
  input  logic [DATA_WIDTH-1:0]      s_rsp_rdata,
  input  logic                       s_rsp_slverr
);

  // ---------------------------------------------------------------------------
  // 捕获 FSM 状态编码
  // ---------------------------------------------------------------------------
  localparam logic [1:0] ST_IDLE    = 2'b00;
  localparam logic [1:0] ST_CAPTURE = 2'b01;
  localparam logic [1:0] ST_WAIT    = 2'b10;  // 等待跨桥完成
  localparam logic [1:0] ST_RETURN  = 2'b11;  // 返回响应

  logic [1:0] state, state_nxt;

  // 捕获使能（ACCESS 且空闲）
  wire capture_en = s_psel && s_penable && (state == ST_IDLE);

  // ---------------------------------------------------------------------------
  // 状态寄存器（async assert / sync deassert 由外部复位处理）
  // ---------------------------------------------------------------------------
  always_ff @(posedge s_pclk or negedge s_presetn) begin
    if (!s_presetn) begin
      state <= ST_IDLE;
    end else begin
      state <= state_nxt;
    end
  end

  // ---------------------------------------------------------------------------
  // 下一状态逻辑
  // ---------------------------------------------------------------------------
  always_comb begin
    state_nxt = state;
    case (state)
      ST_IDLE:    state_nxt = capture_en ? ST_CAPTURE : ST_IDLE;
      ST_CAPTURE: state_nxt = s_req_ready ? ST_WAIT   : ST_CAPTURE;
      ST_WAIT:    state_nxt = s_rsp_valid ? ST_RETURN : ST_WAIT;
      ST_RETURN:  state_nxt = ST_IDLE;
      default:    state_nxt = ST_IDLE;   // 非法状态恢复
    endcase
  end

  // ---------------------------------------------------------------------------
  // 输出：请求发起（ST_CAPTURE 且 ready 时单周期 push）
  // ---------------------------------------------------------------------------
  assign s_req_push  = (state == ST_CAPTURE) && s_req_ready;
  assign s_req_addr  = s_paddr;
  assign s_req_write = s_pwrite;
  assign s_req_wdata = s_pwdata;
  assign s_req_strb  = (APB_PROFILE == 1) ? s_pstrb : '0;
  assign s_req_prot  = (APB_PROFILE == 1) ? s_pprot : '0;

  // ---------------------------------------------------------------------------
  // 响应返回（ST_RETURN 单周期 PREADY；PRDATA/PSLVERR 来自响应通道）
  // ---------------------------------------------------------------------------
  assign s_pready   = (state == ST_RETURN);
  assign s_prdata   = s_rsp_rdata;
  assign s_pslverr  = s_rsp_slverr;

endmodule : apb_cdc_source
