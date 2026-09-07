// x2p_top.sv - AXI-to-APB Bridge 顶层
// 集成：AXI Frontend → 读写队列 → Scheduler → Transfer Engine → [CDC] → APB Engine → Rsp Mgr
// 参数与 X2P_PLAN.MD / LRS / HLD 一致。
module x2p_top #(
  parameter int unsigned AXI_ADDR_WIDTH   = 32,
  parameter int unsigned AXI_DATA_WIDTH   = 64,
  parameter int unsigned AXI_ID_WIDTH     = 4,
  parameter int unsigned APB_ADDR_WIDTH   = 32,
  parameter int unsigned APB_DATA_WIDTH   = 32,
  parameter int unsigned AXI_PROFILE      = 1,    // 1=AXI4 0=AXI4-Lite
  parameter int unsigned APB_PROFILE      = 1,    // 1=APB4 0=APB3
  parameter int unsigned READ_REQUEST_DEPTH_LOG2 = 2,   // 深度 1/2/4/8
  parameter int unsigned WRITE_REQUEST_DEPTH_LOG2 = 2,
  parameter int unsigned ARB_POLICY       = 0,    // RR / READ_PRI / WRITE_PRI
  parameter int unsigned ARB_GRANULARITY  = 0,    // BEAT / TRANSACTION
  parameter bit          TIMEOUT_ENABLE   = 1'b1,
  parameter int unsigned TIMEOUT_CYCLES   = 256,
  parameter int unsigned CLOCK_MODE       = 0,    // SYNC / ASYNC
  parameter int unsigned CDC_REQ_DEPTH_LOG2 = 2,
  parameter int unsigned CDC_RSP_DEPTH_LOG2 = 2,
  parameter bit          AXI_INPUT_REG    = 1'b0,
  parameter bit          AXI_OUTPUT_REG   = 1'b0,
  parameter bit          APB_OUTPUT_REG   = 1'b1
) (
  input  logic                         aclk,
  input  logic                         aresetn,
  input  logic                         pclk,
  input  logic                         presetn,

  // AXI Slave
  input  logic                            awvalid,
  output logic                            awready,
  input  logic [AXI_ID_WIDTH-1:0]         awid,
  input  logic [AXI_ADDR_WIDTH-1:0]       awaddr,
  input  logic [7:0]                      awlen,
  input  logic [2:0]                      awsize,
  input  logic [1:0]                      awburst,
  input  logic [2:0]                      awprot,
  input  logic                            wvalid,
  output logic                            wready,
  input  logic [AXI_DATA_WIDTH-1:0]       wdata,
  input  logic [AXI_DATA_WIDTH/8-1:0]     wstrb,
  input  logic                            wlast,
  input  logic                            bready,
  output logic                            bvalid,
  output logic [1:0]                      bresp,
  output logic [AXI_ID_WIDTH-1:0]         bid,
  input  logic                            arvalid,
  output logic                            arready,
  input  logic [AXI_ID_WIDTH-1:0]         arid,
  input  logic [AXI_ADDR_WIDTH-1:0]       araddr,
  input  logic [7:0]                      arlen,
  input  logic [2:0]                      arsize,
  input  logic [1:0]                      arburst,
  input  logic [2:0]                      arprot,
  input  logic                            rready,
  output logic                            rvalid,
  output logic [AXI_DATA_WIDTH-1:0]       rdata,
  output logic [1:0]                      rresp,
  output logic [AXI_ID_WIDTH-1:0]         rid,
  output logic                            rlast,

  // APB Master
  output logic [APB_ADDR_WIDTH-1:0]       paddr,
  output logic                            psel,
  output logic                            penable,
  output logic                            pwrite,
  output logic [APB_DATA_WIDTH-1:0]       pwdata,
  output logic [APB_DATA_WIDTH/8-1:0]     pstrb,
  output logic [2:0]                      pprot,
  input  logic [APB_DATA_WIDTH-1:0]       prdata,
  input  logic                            pready,
  input  logic                            pslverr
);

  import x2p_pkg::*;

  // ================= 内部信号 =================
  // 队列 payloads
  localparam int unsigned AW_Q_W = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2 + 3;
  localparam int unsigned AR_Q_W = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2 + 3;
  localparam int unsigned W_Q_W  = AXI_DATA_WIDTH + AXI_DATA_WIDTH/8 + 1;

  // AW/W/AR capture
  logic aw_push, w_push, ar_push;
  logic [AW_Q_W-1:0] aw_payload, ar_payload;
  logic [W_Q_W-1:0]  w_payload;

  // 队列
  logic aw_q_empty, aw_q_full, aw_q_pop, aw_q_ready_imp;
  logic [AW_Q_W-1:0] aw_q_dout;
  logic ar_q_empty, ar_q_full, ar_q_pop;
  logic [AR_Q_W-1:0] ar_q_dout;
  logic w_q_empty, w_q_full, w_q_pop;
  logic [W_Q_W-1:0]  w_q_dout;

  // Scheduler
  logic rd_avail, wr_avail, sched_busy, beat_done, txn_done;
  logic grant_rd, grant_wr;

  // Transfer Engine 输入
  logic te_req_valid, te_req_ready, te_req_write;
  logic [AXI_ID_WIDTH-1:0] te_id;
  logic [AXI_ADDR_WIDTH-1:0] te_addr;
  logic [7:0] te_len;
  logic [2:0] te_size, te_prot;
  logic [1:0] te_burst;
  logic [AXI_DATA_WIDTH-1:0] te_wdata;
  logic [AXI_DATA_WIDTH/8-1:0] te_wstrb;
  logic te_wdata_valid, te_wdata_ready;
  logic [AXI_DATA_WIDTH-1:0] te_wdata_in;
  logic [AXI_DATA_WIDTH/8-1:0] te_wstrb_in;

  // TE -> APB request（SYNC：直连；ASYNC：经 CDC）
  logic te_apb_req_valid, te_apb_req_ready;
  logic [APB_ADDR_WIDTH-1:0] te_apb_addr;
  logic te_apb_write;
  logic [APB_DATA_WIDTH-1:0] te_apb_wdata;
  logic [APB_DATA_WIDTH/8-1:0] te_apb_strb;
  logic [2:0] te_apb_prot;
  logic [AXI_ID_WIDTH-1:0] te_apb_id;
  logic [3:0] te_apb_beat, te_apb_sub;
  logic te_apb_beat_last, te_apb_txn_last, te_apb_error;

  // APB Engine 侧请求（CDC 输出）
  logic apb_req_valid, apb_req_ready;
  logic [APB_ADDR_WIDTH-1:0] apb_addr_x;
  logic apb_write_x;
  logic [APB_DATA_WIDTH-1:0] apb_wdata_x;
  logic [APB_DATA_WIDTH/8-1:0] apb_strb_x;
  logic [2:0] apb_prot_x;
  logic [AXI_ID_WIDTH-1:0] apb_id_x;
  logic [3:0] apb_beat_x, apb_sub_x;
  logic apb_beat_last_x, apb_txn_last_x, apb_error_x;

  // APB rsp -> RSP Mgr
  logic rsp_valid, rsp_ready;
  logic [APB_DATA_WIDTH-1:0] rsp_data_int;
  logic rsp_error, rsp_write;
  logic [AXI_ID_WIDTH-1:0] rsp_id;
  logic [3:0] rsp_sub;
  logic rsp_beat_last, rsp_txn_last;

  // ================= AXI READY（backpressure） =================
  assign awready = !aw_q_full && (AXI_INPUT_REG ? 1'b1 : 1'b1);   // reg 流水在后续扩展
  assign arready = !ar_q_full;
  assign wready  = !w_q_full;

  // ================= AW capture =================
  always_comb begin
    aw_payload = '0;
    aw_payload[AXI_ID_WIDTH-1:0]     = awid;
    aw_payload[AXI_ID_WIDTH +: AXI_ADDR_WIDTH] = awaddr;
    aw_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH +: 8] = awlen;
    aw_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH+8 +: 3] = awsize;
    aw_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH+11 +: 2] = awburst;
    aw_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH+13 +: 3] = awprot;
  end

  // 写描述符队列：仅当（W 数据已就绪或写队列允许）接受 —— 简化：全部排队
  assign aw_push = awvalid && awready;

  x2p_req_mgr #(
    .DEPTH_W (WRITE_REQUEST_DEPTH_LOG2),
    .DATA_W  (AW_Q_W),
    .AXI_ID_W(AXI_ID_WIDTH)
  ) u_aw_q (
    .clk   (aclk),
    .rst_n (aresetn),
    .push  (aw_push),
    .din   (aw_payload),
    .pop   (aw_q_pop),
    .dout  (aw_q_dout),
    .empty (aw_q_empty),
    .full  (aw_q_full)
  );

  // ================= W capture =================
  always_comb begin
    w_payload = '0;
    w_payload[AXI_DATA_WIDTH-1:0] = wdata;
    w_payload[AXI_DATA_WIDTH +: AXI_DATA_WIDTH/8] = wstrb;
    w_payload[AXI_DATA_WIDTH + AXI_DATA_WIDTH/8] = wlast;
  end
  assign w_push = wvalid && wready;

  x2p_req_mgr #(
    .DEPTH_W (WRITE_REQUEST_DEPTH_LOG2),
    .DATA_W  (W_Q_W),
    .AXI_ID_W(AXI_ID_WIDTH)
  ) u_w_q (
    .clk   (aclk),
    .rst_n (aresetn),
    .push  (w_push),
    .din   (w_payload),
    .pop   (w_q_pop),
    .dout  (w_q_dout),
    .empty (w_q_empty),
    .full  (w_q_full)
  );

  // ================= AR capture =================
  always_comb begin
    ar_payload = '0;
    ar_payload[AXI_ID_WIDTH-1:0]     = arid;
    ar_payload[AXI_ID_WIDTH +: AXI_ADDR_WIDTH] = araddr;
    ar_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH +: 8] = arlen;
    ar_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH+8 +: 3] = arsize;
    ar_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH+11 +: 2] = arburst;
    ar_payload[AXI_ID_WIDTH+AXI_ADDR_WIDTH+13 +: 3] = arprot;
  end
  assign ar_push = arvalid && arready;

  x2p_req_mgr #(
    .DEPTH_W (READ_REQUEST_DEPTH_LOG2),
    .DATA_W  (AR_Q_W),
    .AXI_ID_W(AXI_ID_WIDTH)
  ) u_ar_q (
    .clk   (aclk),
    .rst_n (aresetn),
    .push  (ar_push),
    .din   (ar_payload),
    .pop   (ar_q_pop),
    .dout  (ar_q_dout),
    .empty (ar_q_empty),
    .full  (ar_q_full)
  );

  // ================= Scheduler =================
  // 读可用：AR 队列非空；写可用：AW 队列非空且 W 队列有足够数据/描述符已配对。
  // 简化模型：写请求 = AW 已出队且 W 数据队列也非空（保证数据可用）。
  logic aw_q_have_desc;
  assign aw_q_have_desc = !aw_q_empty;
  assign rd_avail = !ar_q_empty;
  assign wr_avail = aw_q_have_desc && !w_q_empty;   // 写方向：已有 AW 且 W 数据在队列

  x2p_scheduler #(
    .ARB_POLICY      (ARB_POLICY),
    .ARB_GRANULARITY (ARB_GRANULARITY)
  ) u_sched (
    .clk       (aclk),
    .rst_n     (aresetn),
    .rd_avail  (rd_avail),
    .wr_avail  (wr_avail),
    .sched_busy(sched_busy),
    .beat_done (beat_done),
    .txn_done  (txn_done),
    .grant_rd  (grant_rd),
    .grant_wr  (grant_wr)
  );

  // ================= Transfer Engine 请求生成 =================
  // 当 Scheduler 授权读 → 从 AR 队列取描述符；授权写 → 从 AW 队列取描述符。
  logic te_active_q, te_ack_q;
  logic te_take_rd, te_take_wr;
  logic te_wdata_ready_int;

  // 取数：授权边 valid 且 TE 空闲（TE busy 已由 scheduler 的 sched_busy 反映）
  assign te_take_rd = grant_rd && !sched_busy;
  assign te_take_wr = grant_wr && !sched_busy;

  // 出队（取数拍，与锁存同步）
  assign ar_q_pop = te_take_rd;
  assign aw_q_pop = te_take_wr;

  // 描述符解码（读为源）
  always_comb begin
    te_req_valid = 1'b0;
    te_req_write = 1'b0;
    te_id   = '0;
    te_addr = '0;
    te_len  = '0;
    te_size = '0;
    te_burst= '0;
    te_prot = 3'b010;
    if (te_take_rd) begin
      te_req_valid = 1'b1;
      te_req_write = 1'b0;
      te_id    = ar_q_dout[AXI_ID_WIDTH-1:0];
      te_addr  = ar_q_dout[AXI_ID_WIDTH +: AXI_ADDR_WIDTH];
      te_len   = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH +: 8];
      te_size  = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+8 +: 3];
      te_burst = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+11 +: 2];
      te_prot  = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+13 +: 3];
    end else if (te_take_wr) begin
      te_req_valid = 1'b1;
      te_req_write = 1'b1;
      te_id    = aw_q_dout[AXI_ID_WIDTH-1:0];
      te_addr  = aw_q_dout[AXI_ID_WIDTH +: AXI_ADDR_WIDTH];
      te_len   = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH +: 8];
      te_size  = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+8 +: 3];
      te_burst = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+11 +: 2];
      te_prot  = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+13 +: 3];
    end else if (te_take_rd) begin
      te_req_valid = 1'b1;
      te_req_write = 1'b0;
      te_id    = ar_q_dout[AXI_ID_WIDTH-1:0];
      te_addr  = ar_q_dout[AXI_ID_WIDTH +: AXI_ADDR_WIDTH];
      te_len   = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH +: 8];
      te_size  = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+8 +: 3];
      te_burst = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+11 +: 2];
      te_prot  = ar_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+13 +: 3];
    end else if (te_take_wr) begin
      te_req_valid = 1'b1;
      te_req_write = 1'b1;
      te_id    = aw_q_dout[AXI_ID_WIDTH-1:0];
      te_addr  = aw_q_dout[AXI_ID_WIDTH +: AXI_ADDR_WIDTH];
      te_len   = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH +: 8];
      te_size  = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+8 +: 3];
      te_burst = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+11 +: 2];
      te_prot  = aw_q_dout[AXI_ID_WIDTH+AXI_ADDR_WIDTH+13 +: 3];
    end
  end

  // TE 数据（第一 beat 来自 W 队列；后续 beat 在 TE 请求时顺序出队）
  assign te_wdata     = w_q_dout[AXI_DATA_WIDTH-1:0];
  assign te_wstrb     = w_q_dout[AXI_DATA_WIDTH +: AXI_DATA_WIDTH/8];
  // 首 beat 在事务取数拍（te_take_wr）出队；
  // 后续 beat 由 TE 的 wdata_ready（ST_WAITDATA）驱动出队（w_q_pop_next）
  assign w_q_pop_next = te_wdata_ready_int && !w_q_empty && !te_take_wr;  // avoid double-pop
  assign w_q_pop      = te_take_wr || w_q_pop_next;
  // 后续 beat 数据流：来自 W 队列（顺序出队）。
  // wdata_valid = 队列非空（TE 仅在 ST_WAITDATA 且 wdata_ready=1 时消费，
  // 故 valid 常拉高不会导致过早消费；空队列时 valid=0 实现背压）
  assign te_wdata_valid = !w_q_empty;
  assign te_wdata_in    = w_q_dout[AXI_DATA_WIDTH-1:0];
  assign te_wstrb_in    = w_q_dout[AXI_DATA_WIDTH +: AXI_DATA_WIDTH/8];

  // 后续 beat 出队：由 TE 提供 wdata_ready（见 w_q_pop_next）
  x2p_transfer_engine #(
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_ID_WIDTH  (AXI_ID_WIDTH),
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
    .APB_DATA_WIDTH(APB_DATA_WIDTH),
    .AXI_PROFILE   (AXI_PROFILE),
    .APB_PROFILE   (APB_PROFILE)
  ) u_te (
    .clk       (aclk),
    .rst_n     (aresetn),
    .req_valid (te_req_valid),
    .req_ready (te_req_ready),
    .req_is_write(te_req_write),
    .req_id    (te_id),
    .req_addr  (te_addr),
    .req_len   (te_len),
    .req_size  (te_size),
    .req_burst (te_burst),
    .req_prot  (te_prot),
    .req_wdata (te_wdata),
    .req_wstrb (te_wstrb),
    .wdata_valid(te_wdata_valid),
    .wdata_ready(te_wdata_ready_int),
    .wdata     (te_wdata_in),
    .wstrb     (te_wstrb_in),
    .busy      (sched_busy),
    .beat_done (beat_done),
    .txn_done  (txn_done),
    .grant_is_write(),
    .apb_req_valid (te_apb_req_valid),
    .apb_req_ready (te_apb_req_ready),
    .apb_addr   (te_apb_addr),
    .apb_write  (te_apb_write),
    .apb_wdata  (te_apb_wdata),
    .apb_strb   (te_apb_strb),
    .apb_prot   (te_apb_prot),
    .apb_id     (te_apb_id),
    .apb_axi_beat(te_apb_beat),
    .apb_subbeat(te_apb_sub),
    .apb_beat_last(te_apb_beat_last),
    .apb_txn_last(te_apb_txn_last),
    .apb_error   (te_apb_error)
  );
  assign te_wdata_ready = te_wdata_ready_int;

  // 状态跟踪：TE 空闲判断（放在 scheduler 前）
  // scheduler 的 sched_busy 已由 TE busy 提供

  // ================= CDC / 直连 =================
  // APB 请求载荷（SYNC：直连；ASYNC：经 x2p_cdc）
  // 载荷位宽
  localparam int unsigned REQ_W = APB_ADDR_WIDTH + 1 + APB_DATA_WIDTH +
                                  APB_DATA_WIDTH/8 + 3 + AXI_ID_WIDTH + 4 + 4 + 1 + 1 + 1;
  logic [REQ_W-1:0] req_bits_from_te, req_bits_to_apb;

  always_comb begin
    req_bits_from_te = '0;
    req_bits_from_te[APB_ADDR_WIDTH-1:0]           = te_apb_addr;
    req_bits_from_te[APB_ADDR_WIDTH]               = te_apb_write;
    req_bits_from_te[APB_ADDR_WIDTH+1 +: APB_DATA_WIDTH] = te_apb_wdata;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH +: APB_DATA_WIDTH/8] = te_apb_strb;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8 +: 3] = te_apb_prot;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3 +: AXI_ID_WIDTH] = te_apb_id;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH +: 4] = te_apb_beat;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+4 +: 4] = te_apb_sub;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+8] = te_apb_beat_last;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+9] = te_apb_txn_last;
    req_bits_from_te[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+10] = te_apb_error;
  end

  generate
    if (CLOCK_MODE == CLK_ASYNC) begin : g_cdc_req
      logic req_wfull, req_rempty;
      logic req_rd_valid;
      x2p_cdc #(
        .DATA_WIDTH (REQ_W),
        .DEPTH_LOG2 (CDC_REQ_DEPTH_LOG2)
      ) u_req_cdc (
        .wclk   (aclk),
        .wrst_n (aresetn),
        .wpush  (te_apb_req_valid && !req_wfull),
        .wdata  (req_bits_from_te),
        .wfull  (req_wfull),
        .rclk   (pclk),
        .rrst_n (presetn),
        .rpop   (apb_req_valid && apb_req_ready),
        .rdata  (req_bits_to_apb),
        .rempty (req_rempty)
      );
      assign te_apb_req_ready = !req_wfull;
      assign apb_req_valid = !req_rempty;
      assign req_rd_valid  = !req_rempty;
    end else begin : g_cdc_bypass_req
      assign req_bits_to_apb   = req_bits_from_te;
      assign apb_req_valid     = te_apb_req_valid;
      assign te_apb_req_ready  = apb_req_ready;
      assign req_rd_valid      = te_apb_req_valid;
    end
  endgenerate

  // 解码 APB 侧请求
  assign apb_addr_x    = req_bits_to_apb[APB_ADDR_WIDTH-1:0];
  assign apb_write_x   = req_bits_to_apb[APB_ADDR_WIDTH];
  assign apb_wdata_x   = req_bits_to_apb[APB_ADDR_WIDTH+1 +: APB_DATA_WIDTH];
  assign apb_strb_x    = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH +: APB_DATA_WIDTH/8];
  assign apb_prot_x    = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8 +: 3];
  assign apb_id_x      = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3 +: AXI_ID_WIDTH];
  assign apb_beat_x    = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH +: 4];
  assign apb_sub_x     = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+4 +: 4];
  assign apb_beat_last_x = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+8];
  assign apb_txn_last_x  = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+9];
  assign apb_error_x     = req_bits_to_apb[APB_ADDR_WIDTH+1+APB_DATA_WIDTH+APB_DATA_WIDTH/8+3+AXI_ID_WIDTH+10];

  // ================= APB Engine =================
  x2p_apb_engine #(
    .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH),
    .AXI_ID_WIDTH   (AXI_ID_WIDTH),
    .APB_PROFILE    (APB_PROFILE),
    .TIMEOUT_ENABLE (TIMEOUT_ENABLE),
    .TIMEOUT_CYCLES (TIMEOUT_CYCLES),
    .APB_OUTPUT_REG (APB_OUTPUT_REG)
  ) u_apb (
    .clk       (pclk),
    .rst_n     (presetn),
    .req_valid (apb_req_valid),
    .req_ready (apb_req_ready),
    .req_addr  (apb_addr_x),
    .req_write (apb_write_x),
    .req_wdata (apb_wdata_x),
    .req_strb  (apb_strb_x),
    .req_prot  (apb_prot_x),
    .req_id    (apb_id_x),
    .req_beat  (apb_beat_x),
    .req_sub   (apb_sub_x),
    .req_beat_last(apb_beat_last_x),
    .req_txn_last (apb_txn_last_x),
    .req_error (apb_error_x),
    .rsp_valid (rsp_valid),
    .rsp_ready (rsp_ready),
    .rsp_data  (rsp_data_int),
    .rsp_error (rsp_error),
    .rsp_id    (rsp_id),
    .rsp_beat  (),
    .rsp_sub   (rsp_sub),
    .rsp_beat_last(rsp_beat_last),
    .rsp_txn_last (rsp_txn_last),
    .rsp_write (rsp_write),
    .paddr   (paddr),
    .psel    (psel),
    .penable (penable),
    .pwrite  (pwrite),
    .pwdata  (pwdata),
    .pstrb   (pstrb),
    .pprot   (pprot),
    .prdata  (prdata),
    .pready  (pready),
    .pslverr (pslverr)
  );

  // ================= CDC 响应（ASYNC） / 直连（SYNC） =================
  wire rsp_valid_to_mgr, rsp_ready_from_mgr;
  wire [APB_DATA_WIDTH-1:0] rsp_data_mgr;
  wire rsp_error_mgr, rsp_write_mgr;
  wire [AXI_ID_WIDTH-1:0] rsp_id_mgr;
  wire [3:0] rsp_sub_mgr;
  wire rsp_beat_last_mgr, rsp_txn_last_mgr;

  // 方向位：使用 APB Engine 输出的 rsp_write（= 发起该响应的请求方向），
  // 而非当前 APB 请求总线方向（apb_write_x）——后者在连续子传输/事务切换
  // 时可能已被更新，导致最后一个子传输的响应被误路由到错误通道。
  localparam int unsigned RSP_W = APB_DATA_WIDTH + 1 + AXI_ID_WIDTH + 4 + 1 + 1 + 1;
  logic [RSP_W-1:0] rsp_bits_from_apb, rsp_bits_to_axi;

  always_comb begin
    rsp_bits_from_apb = '0;
    rsp_bits_from_apb[APB_DATA_WIDTH-1:0] = rsp_data_int;
    rsp_bits_from_apb[APB_DATA_WIDTH]     = rsp_error;
    rsp_bits_from_apb[APB_DATA_WIDTH+1 +: AXI_ID_WIDTH] = rsp_id;
    rsp_bits_from_apb[APB_DATA_WIDTH+1+AXI_ID_WIDTH +: 4] = rsp_sub;
    rsp_bits_from_apb[APB_DATA_WIDTH+1+AXI_ID_WIDTH+4] = rsp_beat_last;
    rsp_bits_from_apb[APB_DATA_WIDTH+1+AXI_ID_WIDTH+5] = rsp_txn_last;
    // 方向来自 APB Engine 响应锁存（rsp_write = write_q）
    rsp_bits_from_apb[APB_DATA_WIDTH+1+AXI_ID_WIDTH+6] = rsp_write;
  end

  generate
    if (CLOCK_MODE == CLK_ASYNC) begin : g_cdc_rsp
      logic rsp_wfull, rsp_rempty;
      x2p_cdc #(
        .DATA_WIDTH (RSP_W),
        .DEPTH_LOG2 (CDC_RSP_DEPTH_LOG2)
      ) u_rsp_cdc (
        .wclk   (pclk),
        .wrst_n (presetn),
        .wpush  (rsp_valid && !rsp_wfull),
        .wdata  (rsp_bits_from_apb),
        .wfull  (rsp_wfull),
        .rclk   (aclk),
        .rrst_n (aresetn),
        .rpop   (rsp_valid_to_mgr && rsp_ready_from_mgr),
        .rdata  (rsp_bits_to_axi),
        .rempty (rsp_rempty)
      );
      assign rsp_ready = !rsp_wfull;
      assign rsp_valid_to_mgr = !rsp_rempty;
    end else begin : g_cdc_bypass_rsp
      assign rsp_bits_to_axi  = rsp_bits_from_apb;
      assign rsp_valid_to_mgr = rsp_valid;
      assign rsp_ready        = rsp_ready_from_mgr;
    end
  endgenerate

  assign rsp_data_mgr   = rsp_bits_to_axi[APB_DATA_WIDTH-1:0];
  assign rsp_error_mgr  = rsp_bits_to_axi[APB_DATA_WIDTH];
  assign rsp_id_mgr     = rsp_bits_to_axi[APB_DATA_WIDTH+1 +: AXI_ID_WIDTH];
  assign rsp_sub_mgr    = rsp_bits_to_axi[APB_DATA_WIDTH+1+AXI_ID_WIDTH +: 4];
  assign rsp_beat_last_mgr = rsp_bits_to_axi[APB_DATA_WIDTH+1+AXI_ID_WIDTH+4];
  assign rsp_txn_last_mgr  = rsp_bits_to_axi[APB_DATA_WIDTH+1+AXI_ID_WIDTH+5];
  assign rsp_write_mgr     = rsp_bits_to_axi[APB_DATA_WIDTH+1+AXI_ID_WIDTH+6];

  // ================= RSP Manager =================
  x2p_rsp_mgr #(
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
    .AXI_ID_WIDTH   (AXI_ID_WIDTH),
    .APB_DATA_WIDTH (APB_DATA_WIDTH)
  ) u_rsp (
    .clk       (aclk),
    .rst_n     (aresetn),
    .rsp_valid (rsp_valid_to_mgr),
    .rsp_ready (rsp_ready_from_mgr),
    .rsp_write (rsp_write_mgr),
    .rsp_data  (rsp_data_mgr),
    .rsp_error (rsp_error_mgr),
    .rsp_id    (rsp_id_mgr),
    .rsp_sub   (rsp_sub_mgr),
    .rsp_beat_last(rsp_beat_last_mgr),
    .rsp_txn_last (rsp_txn_last_mgr),
    .rvalid   (rvalid),
    .rready   (rready),
    .rdata    (rdata),
    .rresp    (rresp),
    .rid      (rid),
    .rlast    (rlast),
    .bvalid   (bvalid),
    .bready   (bready),
    .bresp    (bresp),
    .bid      (bid)
  );

  // 未使用占位
  logic unused_te;
  assign unused_te = te_wdata_ready_int;

endmodule : x2p_top