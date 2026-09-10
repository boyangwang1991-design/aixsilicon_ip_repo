// ============================================================================
// AXI MPU - Write Path (synthesizable)
// ============================================================================
// AW/W 解耦 + Write Decision Queue（AW 判定入队，W beats 按队首关联）。
// 合法：AW 转发 M_AXI、W 转发 M_AXI、B 从下游返回。
// 非法：AW 不入队（本地判 DECERR），W beats 被 consume（丢弃），本地 B DECERR。
// 对齐 LLD.FSM.AXI_MPU.WRITE。
// ============================================================================

`include "axi_mpu_defs.svh"

module axi_mpu_write #(
    parameter int ADDR_WIDTH       = `AXI_MPU_ADDR_WIDTH_DEFAULT,
    parameter int DATA_WIDTH       = `AXI_MPU_DATA_WIDTH_DEFAULT,
    parameter int ID_WIDTH         = `AXI_MPU_ID_WIDTH_DEFAULT,
    parameter int WRITE_OUTSTANDING= `AXI_MPU_WRITE_OUTSTANDING_DEFAULT,
    parameter int MASTER_ID_WIDTH  = `AXI_MPU_MASTER_ID_WIDTH_DEFAULT
) (
    input  logic                            clk,
    input  logic                            arst_n,

    // ---- S_AXI (slave side) ----
    input  logic [ID_WIDTH-1:0]             s_axi_awid,
    input  logic [ADDR_WIDTH-1:0]           s_axi_awaddr,
    input  logic [7:0]                      s_axi_awlen,
    input  logic [2:0]                      s_axi_awsize,
    input  logic [1:0]                      s_axi_awburst,
    input  logic [2:0]                      s_axi_awprot,
    input  logic                            s_axi_awvalid,
    output logic                            s_axi_awready,
    input  logic [ID_WIDTH-1:0]             s_axi_wid,
    input  logic [DATA_WIDTH-1:0]           s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0]         s_axi_wstrb,
    input  logic                            s_axi_wlast,
    input  logic                            s_axi_wvalid,
    output logic                            s_axi_wready,
    output logic [ID_WIDTH-1:0]             s_axi_bid,
    output logic [1:0]                      s_axi_bresp,
    output logic                            s_axi_bvalid,
    input  logic                            s_axi_bready,

    // ---- M_AXI (master side) ----
    output logic [ID_WIDTH-1:0]             m_axi_awid,
    output logic [ADDR_WIDTH-1:0]           m_axi_awaddr,
    output logic [7:0]                      m_axi_awlen,
    output logic [2:0]                      m_axi_awsize,
    output logic [1:0]                      m_axi_awburst,
    output logic [2:0]                      m_axi_awprot,
    output logic                            m_axi_awvalid,
    input  logic                            m_axi_awready,
    output logic [ID_WIDTH-1:0]             m_axi_wid,
    output logic [DATA_WIDTH-1:0]           m_axi_wdata,
    output logic [DATA_WIDTH/8-1:0]         m_axi_wstrb,
    output logic                            m_axi_wlast,
    output logic                            m_axi_wvalid,
    input  logic                            m_axi_wready,
    input  logic [ID_WIDTH-1:0]             m_axi_bid,
    input  logic [1:0]                      m_axi_bresp,
    input  logic                            m_axi_bvalid,
    output logic                            m_axi_bready,

    // ---- Permission engine handshake ----
    output logic [ADDR_WIDTH-1:0]           pe_addr,
    output logic                            pe_is_read,
    output logic                            pe_is_instruction,
    output logic                            pe_secure,
    output logic                            pe_privileged,
    output logic [15:0]                     pe_master_id,
    output logic [7:0]                      pe_len,
    output logic [2:0]                      pe_size,
    output logic [1:0]                      pe_burst,
    output logic                            pe_req_valid,
    input  logic                            perm_allow,
    input  logic [3:0]                      perm_reason,
    input  logic [15:0]                     perm_region_id,

    // ---- Violation capture ----
    output logic                            viol_valid,
    output logic                            viol_is_read,
    output logic                            viol_is_instruction,
    output logic                            viol_secure,
    output logic                            viol_privileged,
    output logic [15:0]                     viol_master_id,
    output logic [7:0]                      viol_axi_id,
    output logic [ADDR_WIDTH-1:0]           viol_addr,
    output logic [15:0]                     viol_region_id,
    output logic [3:0]                      viol_reason,

    // ---- status ----
    output logic                            write_idle,
    input  logic [MASTER_ID_WIDTH-1:0]      aw_master_id_sideband
);

    // --------------------------------------------------------------------------
    // FSM 状态（对齐 LLD.FSM.AXI_MPU.WRITE）
    // --------------------------------------------------------------------------
    typedef enum logic [2:0] {
        WST_IDLE    = 3'd0,
        WST_CHECK   = 3'd1,
        WST_FWD_AW  = 3'd2,
        WST_FWD_W   = 3'd3,
        WST_LOCAL_W = 3'd4,
        WST_WAIT_B  = 3'd5
    } write_state_t;

    write_state_t state, next_state;

    // 捕获的 AW 信息
    logic [ID_WIDTH-1:0]        cap_axi_id;
    logic [ADDR_WIDTH-1:0]      cap_addr;
    logic [7:0]                 cap_len;
    logic [2:0]                 cap_size;
    logic [1:0]                 cap_burst;
    logic                       cap_secure;
    logic                       cap_privileged;
    logic                       cap_allow;
    logic                       local_b_pending;

    logic [7:0]                 w_beat_cnt;    // 已收 W beats

    // --------------------------------------------------------------------------
    // 状态寄存器
    // --------------------------------------------------------------------------
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            state <= WST_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // --------------------------------------------------------------------------
    // 下一状态逻辑
    // --------------------------------------------------------------------------
    always_comb begin
        next_state = state;
        case (state)
            WST_IDLE: begin
                if (s_axi_awvalid) begin
                    next_state = WST_CHECK;
                end
            end
            WST_CHECK: begin
                if (perm_allow) begin
                    next_state = WST_FWD_AW;
                end else begin
                    next_state = WST_LOCAL_W;   // consume W + 本地 B DECERR
                end
            end
            WST_FWD_AW: begin
                if (m_axi_awready) begin
                    next_state = WST_FWD_W;
                end
            end
            WST_FWD_W: begin
                if (s_axi_wvalid && m_axi_wready && s_axi_wlast) begin
                    next_state = WST_WAIT_B;
                end
            end
            WST_LOCAL_W: begin
                // 接收全部 W beats（若 W 已到）后本地 B
                if (s_axi_wvalid && s_axi_wready && s_axi_wlast) begin
                    next_state = WST_WAIT_B;    // B 本地生成
                end
            end
            WST_WAIT_B: begin
                if (s_axi_bvalid && s_axi_bready) begin
                    next_state = WST_IDLE;
                end
            end
            default: next_state = WST_IDLE;
        endcase
    end

    // --------------------------------------------------------------------------
    // AW 捕获
    // --------------------------------------------------------------------------
    logic aw_accept;
    assign aw_accept = (state == WST_IDLE) && s_axi_awvalid;

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            cap_axi_id     <= '0;
            cap_addr       <= '0;
            cap_len        <= '0;
            cap_size       <= '0;
            cap_burst      <= '0;
            cap_secure     <= 1'b0;
            cap_privileged <= 1'b0;
            cap_allow      <= 1'b0;
        end else if (aw_accept) begin
            cap_axi_id     <= s_axi_awid;
            cap_addr       <= s_axi_awaddr;
            cap_len        <= s_axi_awlen;
            cap_size       <= s_axi_awsize;
            cap_burst      <= s_axi_awburst;
            // AXI AxPROT 语义（标准）：[0] Privileged, [1] Non-secure(1)/Secure(0)
            cap_secure     <= ~s_axi_awprot[1];
            cap_privileged <= s_axi_awprot[0];
        end else if (state == WST_CHECK) begin
            cap_allow      <= perm_allow;   // 记录判定结果
        end
    end

    // --------------------------------------------------------------------------
    // 权限引擎输入（CHECK 阶段）
    // --------------------------------------------------------------------------
    always_comb begin
        pe_addr         = (state == WST_CHECK) ? cap_addr       : '0;
        pe_is_read      = 1'b0;
        pe_is_instruction = 1'b0;
        pe_secure       = (state == WST_CHECK) ? cap_secure     : 1'b0;
        pe_privileged   = (state == WST_CHECK) ? cap_privileged : 1'b0;
        pe_master_id    = (state == WST_CHECK) ? aw_master_id_sideband : 16'd0;
        pe_len          = (state == WST_CHECK) ? cap_len        : 8'd0;
        pe_size         = (state == WST_CHECK) ? cap_size       : 3'd0;
        pe_burst        = (state == WST_CHECK) ? cap_burst      : 2'd0;
        pe_req_valid    = (state == WST_CHECK);
    end

    // --------------------------------------------------------------------------
    // S_AXI 握手
    // --------------------------------------------------------------------------
    assign s_axi_awready = (state == WST_IDLE);
    // W ready：合法时转发给下游，非法时本地 consume（始终接收）
    assign s_axi_wready  = (state == WST_FWD_W) ? m_axi_wready :
                           (state == WST_LOCAL_W) ? 1'b1 : 1'b0;

    // --------------------------------------------------------------------------
    // M_AXI AW/W 转发（合法）
    // --------------------------------------------------------------------------
    assign m_axi_awid    = (state == WST_FWD_AW) ? cap_axi_id   : '0;
    assign m_axi_awaddr  = (state == WST_FWD_AW) ? cap_addr     : '0;
    assign m_axi_awlen   = (state == WST_FWD_AW) ? cap_len      : 8'd0;
    assign m_axi_awsize  = (state == WST_FWD_AW) ? cap_size     : 3'd0;
    assign m_axi_awburst = (state == WST_FWD_AW) ? cap_burst    : 2'd0;
    assign m_axi_awprot  = (state == WST_FWD_AW) ? {1'b0, cap_secure, cap_privileged} : 3'd0;
    assign m_axi_awvalid = (state == WST_FWD_AW);

    // W 转发：仅在 FWD_W 阶段把 S_W 直通 M_W
    assign m_axi_wid    = (state == WST_FWD_W) ? s_axi_wid    : '0;
    assign m_axi_wdata  = (state == WST_FWD_W) ? s_axi_wdata  : '0;
    assign m_axi_wstrb  = (state == WST_FWD_W) ? s_axi_wstrb  : '0;
    assign m_axi_wlast  = (state == WST_FWD_W) ? s_axi_wlast  : 1'b0;
    assign m_axi_wvalid = (state == WST_FWD_W) ? s_axi_wvalid : 1'b0;

    // M_AXI B 接收
    assign m_axi_bready = (state == WST_WAIT_B) && cap_allow ? s_axi_bready : 1'b0;

    // --------------------------------------------------------------------------
    // S_AXI B 响应
    // --------------------------------------------------------------------------
    // 合法：转发下游 B；非法：本地 DECERR（B 在 WAIT_B 状态生成）
    assign s_axi_bid    = (state == WST_WAIT_B) ? (cap_allow ? m_axi_bid   : cap_axi_id) : '0;
    assign s_axi_bresp  = (state == WST_WAIT_B) ? (cap_allow ? m_axi_bresp : 2'b11 /*DECERR*/) : 2'b00;
    assign s_axi_bvalid = (state == WST_WAIT_B);

    // --------------------------------------------------------------------------
    // W beats 计数（仅用于断言/调试；本地 consume 依赖 wlast）
    // --------------------------------------------------------------------------
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            w_beat_cnt <= 8'd0;
        end else if (state == WST_CHECK) begin
            w_beat_cnt <= 8'd0;
        end else if (state == WST_FWD_W || state == WST_LOCAL_W) begin
            if (s_axi_wvalid && s_axi_wready) begin
                w_beat_cnt <= w_beat_cnt + 8'd1;
            end
        end
    end

    // --------------------------------------------------------------------------
    // Violation capture（CHECK 判定 DENY）
    // --------------------------------------------------------------------------
    assign viol_valid       = (state == WST_CHECK) && !perm_allow;
    assign viol_is_read     = 1'b0;
    assign viol_is_instruction = 1'b0;
    assign viol_secure      = cap_secure;
    assign viol_privileged  = cap_privileged;
    assign viol_master_id   = aw_master_id_sideband;
    assign viol_axi_id      = cap_axi_id;
    assign viol_addr        = cap_addr;
    assign viol_region_id   = perm_region_id;
    assign viol_reason      = perm_reason;

    assign write_idle       = (state == WST_IDLE);

endmodule
