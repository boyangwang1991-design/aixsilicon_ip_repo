// ============================================================================
// AXI MPU - Read Path (synthesizable)
// ============================================================================
// FSM：IDLE → CHECK → FWD_AR → WAIT_R  /  LOCAL_R（非法，本地 DECERR）
// 对齐 LLD.FSM.AXI_MPU.READ。
// ============================================================================

`include "axi_mpu_defs.svh"

module axi_mpu_read #(
    parameter int ADDR_WIDTH = `AXI_MPU_ADDR_WIDTH_DEFAULT,
    parameter int DATA_WIDTH = `AXI_MPU_DATA_WIDTH_DEFAULT,
    parameter int ID_WIDTH   = `AXI_MPU_ID_WIDTH_DEFAULT,
    parameter int MASTER_ID_WIDTH = `AXI_MPU_MASTER_ID_WIDTH_DEFAULT
) (
    input  logic                            clk,
    input  logic                            arst_n,

    // ---- S_AXI (slave side, upstream master) ----
    input  logic [ID_WIDTH-1:0]             s_axi_arid,
    input  logic [ADDR_WIDTH-1:0]           s_axi_araddr,
    input  logic [7:0]                      s_axi_arlen,
    input  logic [2:0]                      s_axi_arsize,
    input  logic [1:0]                      s_axi_arburst,
    input  logic [2:0]                      s_axi_arprot,
    input  logic                            s_axi_arvalid,
    output logic                            s_axi_arready,
    output logic [ID_WIDTH-1:0]             s_axi_rid,
    output logic [DATA_WIDTH-1:0]           s_axi_rdata,
    output logic [1:0]                      s_axi_rresp,
    output logic                            s_axi_rlast,
    output logic                            s_axi_rvalid,
    input  logic                            s_axi_rready,

    // ---- M_AXI (master side, to protected slave) ----
    output logic [ID_WIDTH-1:0]             m_axi_arid,
    output logic [ADDR_WIDTH-1:0]           m_axi_araddr,
    output logic [7:0]                      m_axi_arlen,
    output logic [2:0]                      m_axi_arsize,
    output logic [1:0]                      m_axi_arburst,
    output logic [2:0]                      m_axi_arprot,
    output logic                            m_axi_arvalid,
    input  logic                            m_axi_arready,
    input  logic [ID_WIDTH-1:0]             m_axi_rid,
    input  logic [DATA_WIDTH-1:0]           m_axi_rdata,
    input  logic [1:0]                      m_axi_rresp,
    input  logic                            m_axi_rlast,
    input  logic                            m_axi_rvalid,
    output logic                            m_axi_rready,

    // ---- Permission engine handshake ----
    // 捕获请求并提供给权限引擎（组合）；获取判定后执行
    output logic [ADDR_WIDTH-1:0]           pe_addr,
    output logic                            pe_is_read,      // 恒 1
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
    output logic                            viol_valid,       // capture 请求（单周期脉冲）
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
    output logic                            read_idle,        // 无 outstanding
    input  logic [MASTER_ID_WIDTH-1:0]      master_id_sideband
);

    // --------------------------------------------------------------------------
    // FSM 状态（对齐 LLD.FSM.AXI_MPU.READ）
    // --------------------------------------------------------------------------
    typedef enum logic [2:0] {
        RST_IDLE   = 3'd0,
        ST_CHECK   = 3'd1,
        ST_FWD_AR  = 3'd2,
        ST_WAIT_R  = 3'd3,
        ST_LOCAL_R = 3'd4
    } read_state_t;

    read_state_t state, next_state;

    // 捕获的请求寄存器
    logic [ID_WIDTH-1:0]       cap_axi_id;
    logic [ADDR_WIDTH-1:0]     cap_addr;
    logic [7:0]                cap_len;
    logic [2:0]                cap_size;
    logic [1:0]                cap_burst;
    logic                      cap_secure;
    logic                      cap_privileged;
    logic                      cap_instruction;
    logic [MASTER_ID_WIDTH-1:0] cap_master_id;

    // 本地 DECERR 计数
    logic [7:0]                local_beat_cnt;
    logic [7:0]                resp_total;   // len+1

    // --------------------------------------------------------------------------
    // 状态寄存器
    // --------------------------------------------------------------------------
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            state <= RST_IDLE;
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
            RST_IDLE: begin
                if (s_axi_arvalid) begin
                    next_state = ST_CHECK;
                end
            end
            ST_CHECK: begin
                if (perm_allow) begin
                    next_state = ST_FWD_AR;
                end else begin
                    next_state = ST_LOCAL_R;
                end
            end
            ST_FWD_AR: begin
                if (m_axi_arready) begin
                    next_state = ST_WAIT_R;
                end
            end
            ST_WAIT_R: begin
                if (m_axi_rvalid && m_axi_rready && m_axi_rlast) begin
                    next_state = RST_IDLE;
                end
            end
            ST_LOCAL_R: begin
                // 与 s_axi_rlast 对齐：最后一个 beat 为 cnt==resp_total-1
                if (s_axi_rready && (local_beat_cnt == resp_total - 8'd1)) begin
                    next_state = RST_IDLE;
                end
            end
            default: next_state = RST_IDLE;
        endcase
    end

    // --------------------------------------------------------------------------
    // 请求捕获（在 IDLE 接受 AR 时）
    // --------------------------------------------------------------------------
    logic ar_accept;
    assign ar_accept = (state == RST_IDLE) && s_axi_arvalid;

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            cap_axi_id      <= '0;
            cap_addr        <= '0;
            cap_len         <= '0;
            cap_size        <= '0;
            cap_burst       <= '0;
            cap_secure      <= 1'b0;
            cap_privileged  <= 1'b0;
            cap_instruction <= 1'b0;
            cap_master_id   <= '0;
        end else if (ar_accept) begin
            cap_axi_id      <= s_axi_arid;
            cap_addr        <= s_axi_araddr;
            cap_len         <= s_axi_arlen;
            cap_size        <= s_axi_arsize;
            cap_burst       <= s_axi_arburst;
            // AXI AxPROT 语义（标准）：[0] Privileged, [1] Non-secure(1)/Secure(0),
            // [2] Instruction。内部 secure=1 表示 Secure 访问。
            cap_secure      <= ~s_axi_arprot[1];
            cap_privileged  <= s_axi_arprot[0];
            cap_instruction <= s_axi_arprot[2];
            cap_master_id   <= master_id_sideband;
        end
    end

    // --------------------------------------------------------------------------
    // 权限引擎输入（CHECK 阶段提供捕获值）
    // --------------------------------------------------------------------------
    always_comb begin
        pe_addr         = (state == ST_CHECK) ? cap_addr         : '0;
        pe_is_read      = 1'b1;
        pe_is_instruction = (state == ST_CHECK) ? cap_instruction : 1'b0;
        pe_secure       = (state == ST_CHECK) ? cap_secure       : 1'b0;
        pe_privileged   = (state == ST_CHECK) ? cap_privileged   : 1'b0;
        pe_master_id    = (state == ST_CHECK) ? cap_master_id    : 16'd0;
        pe_len          = (state == ST_CHECK) ? cap_len          : 8'd0;
        pe_size         = (state == ST_CHECK) ? cap_size         : 3'd0;
        pe_burst        = (state == ST_CHECK) ? cap_burst        : 2'd0;
        pe_req_valid    = (state == ST_CHECK);
    end

    // --------------------------------------------------------------------------
    // S_AXI 握手
    // --------------------------------------------------------------------------
    assign s_axi_arready = (state == RST_IDLE);

    // --------------------------------------------------------------------------
    // M_AXI AR 转发
    // --------------------------------------------------------------------------
    assign m_axi_arid    = (state == ST_FWD_AR) ? cap_axi_id    : '0;
    assign m_axi_araddr  = (state == ST_FWD_AR) ? cap_addr      : '0;
    assign m_axi_arlen   = (state == ST_FWD_AR) ? cap_len       : 8'd0;
    assign m_axi_arsize  = (state == ST_FWD_AR) ? cap_size      : 3'd0;
    assign m_axi_arburst = (state == ST_FWD_AR) ? cap_burst     : 2'd0;
    assign m_axi_arprot  = (state == ST_FWD_AR) ? {cap_instruction, cap_secure, cap_privileged} : 3'd0;
    assign m_axi_arvalid = (state == ST_FWD_AR);

    // M_AXI R: 只在 WAIT_R 时接受下游数据
    assign m_axi_rready  = (state == ST_WAIT_R) ? s_axi_rready : 1'b0;

    // 转发下游 R 到上游
    assign s_axi_rid    = (state == ST_WAIT_R) ? m_axi_rid    : (state == ST_LOCAL_R) ? cap_axi_id  : '0;
    assign s_axi_rdata  = (state == ST_WAIT_R) ? m_axi_rdata  : '0;
    assign s_axi_rresp  = (state == ST_WAIT_R) ? m_axi_rresp  : (state == ST_LOCAL_R) ? 2'b11 /*DECERR*/ : 2'b00;
    // 本地 DECERR：beat 计数从 0 起，最后 beat 为 resp_total-1（RLAST 与第 resp_total 拍对齐）
    assign s_axi_rlast  = (state == ST_WAIT_R) ? m_axi_rlast  : (state == ST_LOCAL_R) ? (local_beat_cnt == resp_total - 8'd1) : 1'b0;
    assign s_axi_rvalid = (state == ST_WAIT_R) ? m_axi_rvalid : (state == ST_LOCAL_R);

    // --------------------------------------------------------------------------
    // 本地 DECERR 计数（ST_LOCAL_R）
    // --------------------------------------------------------------------------
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            local_beat_cnt <= 8'd0;
        end else if (state == ST_CHECK) begin
            local_beat_cnt <= 8'd0;
        end else if (state == ST_LOCAL_R) begin
            if (s_axi_rready) begin
                local_beat_cnt <= local_beat_cnt + 8'd1;
            end
        end
    end

    assign resp_total = cap_len + 8'd1;

    // --------------------------------------------------------------------------
    // Violation capture（CHECK 阶段判定 DENY 时产生）
    // --------------------------------------------------------------------------
    assign viol_valid       = (state == ST_CHECK) && !perm_allow;
    assign viol_is_read     = 1'b1;
    assign viol_is_instruction = cap_instruction;
    assign viol_secure      = cap_secure;
    assign viol_privileged  = cap_privileged;
    assign viol_master_id   = cap_master_id;
    assign viol_axi_id      = cap_axi_id;
    assign viol_addr        = cap_addr;
    assign viol_region_id   = perm_region_id;
    assign viol_reason      = perm_reason;

    assign read_idle        = (state == RST_IDLE);

endmodule
