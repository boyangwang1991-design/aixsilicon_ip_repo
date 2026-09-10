// ============================================================================
// AXI MPU - Permission Engine (combinational, synthesizable)
// ============================================================================
// Region Matcher + Priority Select + Permission Checker + Burst Analyzer。
//
// 输入：请求上下文（地址/属性/master/burst）+ 配置投影（region/master attr）。
// 输出：allow/reason/selected region。
//
// 权限模型（contract §5.2/§18）：
//   ALLOW = region_match && master_allowed && master_security_valid
//           && security_allowed && privilege_allowed && operation_allowed
// ============================================================================

`include "axi_mpu_defs.svh"

module axi_mpu_permission #(
    parameter int ADDR_WIDTH       = `AXI_MPU_ADDR_WIDTH_DEFAULT,
    parameter int MASTER_NUM       = `AXI_MPU_MASTER_NUM_DEFAULT,
    parameter int MASTER_ID_WIDTH  = `AXI_MPU_MASTER_ID_WIDTH_DEFAULT,
    parameter int REGION_NUM       = `AXI_MPU_REGION_NUM_DEFAULT,
    parameter bit HAS_EXECUTE      = `AXI_MPU_HAS_EXECUTE_DEFAULT,
    parameter bit HAS_MASTER_ATTR  = `AXI_MPU_HAS_MASTER_ATTR_DEFAULT,
    parameter bit WRAP_SUPPORT     = `AXI_MPU_WRAP_SUPPORT_DEFAULT
) (
    input  logic                           clk,
    input  logic                           arst_n,

    // ---- Request context (combinational, set by read/write path) ----
    input  logic [ADDR_WIDTH-1:0]          req_addr,
    input  logic                           req_is_read,
    input  logic                           req_is_instruction,
    input  logic                           req_secure,
    input  logic                           req_privileged,
    input  logic [MASTER_ID_WIDTH-1:0]     req_master_id,
    input  logic [7:0]                     req_len,
    input  logic [2:0]                     req_size,
    input  logic [1:0]                     req_burst,
    input  logic                           req_valid,

    // ---- Region configuration ----
    input  logic [REGION_NUM-1:0]          region_enable,
    input  logic [ADDR_WIDTH-1:0]          region_base   [REGION_NUM],
    input  logic [ADDR_WIDTH-1:0]          region_limit  [REGION_NUM],
    input  logic [MASTER_NUM-1:0]          region_master_mask [REGION_NUM],
    input  logic [REGION_NUM-1:0]          region_secure_allow,
    input  logic [REGION_NUM-1:0]          region_nonsecure_allow,
    input  logic [REGION_NUM-1:0]          region_priv_allow,
    input  logic [REGION_NUM-1:0]          region_unpriv_allow,
    input  logic [REGION_NUM-1:0]          region_read_allow,
    input  logic [REGION_NUM-1:0]          region_write_allow,
    input  logic [REGION_NUM-1:0]          region_exec_allow,

    // ---- Master security attribution ----
    input  logic [MASTER_NUM-1:0]          master_secure_capable,
    input  logic [MASTER_NUM-1:0]          master_nonsecure_capable,

    // ---- Result ----
    output logic                           perm_allow,
    output logic [3:0]                     perm_reason,
    output logic [15:0]                    perm_region_id
);

    // ==========================================================================
    // Burst 范围计算
    // ==========================================================================
    function automatic logic [ADDR_WIDTH-1:0] calc_burst_end(
        input logic [ADDR_WIDTH-1:0] start_addr,
        input logic [1:0]  burst,
        input logic [7:0]  len,
        input logic [2:0]  size
    );
        logic [ADDR_WIDTH-1:0] beat_bytes;
        logic [ADDR_WIDTH-1:0] total_bytes;
        logic [ADDR_WIDTH-1:0] aligned;
        logic [ADDR_WIDTH-1:0] wrap_mask;
        begin
            beat_bytes  = (ADDR_WIDTH'(1) << size);
            total_bytes = beat_bytes * (ADDR_WIDTH'(len) + ADDR_WIDTH'(1));
            case (burst)
                2'b00: begin // FIXED
                    calc_burst_end = start_addr + (beat_bytes - 1);
                end
                2'b01: begin // INCR
                    aligned = start_addr & ~(beat_bytes - 1); // align to beat boundary
                    calc_burst_end = aligned + (total_bytes - 1);
                end
                2'b10: begin // WRAP
                    if (WRAP_SUPPORT) begin
                        wrap_mask = (total_bytes - 1);
                        calc_burst_end = (start_addr & ~wrap_mask) |
                                         ((start_addr + total_bytes - 1) & wrap_mask);
                    end else begin
                        calc_burst_end = start_addr + (beat_bytes - 1);
                    end
                end
                default: begin
                    calc_burst_end = start_addr;
                end
            endcase
        end
    endfunction

    // ==========================================================================
    // 内部信号
    // ==========================================================================
    logic [ADDR_WIDTH-1:0]  burst_start;
    logic [ADDR_WIDTH-1:0]  burst_end;
    logic [REGION_NUM-1:0]  region_hit;
    logic                   any_hit;
    logic [15:0]            sel_region_id;

    logic                   master_allowed;
    logic                   master_sec_valid;
    logic                   sec_allowed;
    logic                   priv_allowed;
    logic                   op_allowed;
    logic                   invalid_master;

    // ==========================================================================
    // Burst 范围
    // ==========================================================================
    always_comb begin
        burst_start = req_addr;
        burst_end   = calc_burst_end(req_addr, req_burst, req_len, req_size);
    end

    // ==========================================================================
    // Region Match（含 burst 完整范围） + Priority（lowest index wins）
    // ==========================================================================
    always_comb begin
        region_hit = '0;
        any_hit    = 1'b0;
        for (int r = 0; r < REGION_NUM; r++) begin
            region_hit[r] = region_enable[r] &&
                            (region_base[r] <= region_limit[r]) &&
                            (burst_start >= region_base[r]) &&
                            (burst_end   <= region_limit[r]);
            any_hit = any_hit || region_hit[r];
        end
    end

    always_comb begin
        sel_region_id = 16'hFFFF;
        for (int r = 0; r < REGION_NUM; r++) begin
            if (region_hit[r]) begin
                sel_region_id = 16'(r);
                break;
            end
        end
    end

    // ==========================================================================
    // 权限判定
    // ==========================================================================
    always_comb begin
        // master_allowed：合法 master_id 时查 mask
        invalid_master = (req_master_id >= MASTER_ID_WIDTH'(MASTER_NUM));
        if (req_valid && !invalid_master) begin
            master_allowed = region_master_mask[sel_region_id][req_master_id];
        end else begin
            master_allowed = 1'b0;
        end

        // master_security_valid：master 有声明该 security 状态的资格
        if (!HAS_MASTER_ATTR) begin
            master_sec_valid = 1'b1;
        end else begin
            if (req_secure) begin
                master_sec_valid = master_secure_capable[req_master_id];
            end else begin
                master_sec_valid = master_nonsecure_capable[req_master_id];
            end
        end

        // security_allowed / privilege_allowed / operation_allowed
        if (req_secure) begin
            sec_allowed = region_secure_allow[sel_region_id];
        end else begin
            sec_allowed = region_nonsecure_allow[sel_region_id];
        end

        if (req_privileged) begin
            priv_allowed = region_priv_allow[sel_region_id];
        end else begin
            priv_allowed = region_unpriv_allow[sel_region_id];
        end

        // operation：read 需 READ_ALLOW；instruction 需 READ_ALLOW && EXECUTE_ALLOW（若支持）
        if (req_is_instruction && HAS_EXECUTE) begin
            op_allowed = region_read_allow[sel_region_id] && region_exec_allow[sel_region_id];
        end else if (req_is_read) begin
            op_allowed = region_read_allow[sel_region_id];
        end else begin
            op_allowed = region_write_allow[sel_region_id];
        end
    end

    // ==========================================================================
    // 最终判定 + deny_reason
    // ==========================================================================
    always_comb begin
        perm_region_id = sel_region_id;
        if (!req_valid) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd0; // DENY_NONE
        end else if (!any_hit) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd1; // DENY_NO_REGION
        end else if (invalid_master) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd10; // DENY_INVALID_CONTEXT
        end else if (!master_allowed) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd2; // DENY_MASTER
        end else if (!master_sec_valid) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd3; // DENY_MASTER_SECURITY
        end else if (!sec_allowed) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd4; // DENY_SECURITY
        end else if (!priv_allowed) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd5; // DENY_PRIVILEGE
        end else if (req_is_read && !op_allowed) begin
            perm_allow  = 1'b0;
            perm_reason = req_is_instruction ? 4'd8 /*EXECUTE*/ : 4'd6 /*READ*/;
        end else if (!req_is_read && !op_allowed) begin
            perm_allow  = 1'b0;
            perm_reason = 4'd7; // DENY_WRITE
        end else begin
            perm_allow  = 1'b1;
            perm_reason = 4'd0; // DENY_NONE
        end
    end

endmodule
