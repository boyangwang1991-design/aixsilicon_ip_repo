// ============================================================================
// AXI MPU - UVM Environment Package
// ============================================================================
// 提供：axi_mpu_env（集成 RM/Checker/Coverage/Sequencer）、axi_mpu_rm（参考模型，
// transaction 级权限预测）、axi_mpu_checker（断言/不变量）、axi_mpu_fcov（功能
// 覆盖率）。DUT 握手驱动由 testcase 通过 axi_mpu_if 虚接口直接完成（directed
// 驱动更精确），本 package 聚焦观测与判定。
// ============================================================================

package axi_mpu_env_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import axi_mpu_csr_pkg::*;

    // --------------------------------------------------------------------------
    // 寄存器地址常量（与 regs/axi_mpu.rdl 对齐）
    // --------------------------------------------------------------------------
    localparam int unsigned ADDR_GLOBAL_CTRL    = 32'h000;
    localparam int unsigned ADDR_GLOBAL_STATUS   = 32'h004;
    localparam int unsigned ADDR_GLOBAL_LOCK     = 32'h008;
    localparam int unsigned ADDR_IRQ_ENABLE      = 32'h00C;
    localparam int unsigned ADDR_IRQ_STATUS      = 32'h010;
    localparam int unsigned ADDR_IRQ_CLEAR       = 32'h014;
    localparam int unsigned ADDR_VIOL_STATUS     = 32'h020;
    localparam int unsigned ADDR_VIOL_ADDR_LO    = 32'h024;
    localparam int unsigned ADDR_VIOL_ADDR_HI    = 32'h028;
    localparam int unsigned ADDR_VIOL_INFO0      = 32'h02C;
    localparam int unsigned ADDR_VIOL_INFO1      = 32'h030;
    localparam int unsigned ADDR_VIOL_COUNT      = 32'h034;
    localparam int unsigned ADDR_MASTER_ATTR0    = 32'h100;
    localparam int unsigned ADDR_REGION0_CTRL    = 32'h200;
    localparam int unsigned ADDR_REGION0_BASE_LO = 32'h204;
    localparam int unsigned ADDR_REGION0_BASE_HI = 32'h208;
    localparam int unsigned ADDR_REGION0_LIMIT_LO= 32'h20C;
    localparam int unsigned ADDR_REGION0_LIMIT_HI= 32'h210;
    localparam int unsigned ADDR_REGION0_MASK    = 32'h214;
    localparam int unsigned ADDR_REGION0_PERM    = 32'h218;
    localparam int unsigned ADDR_REGION_STRIDE   = 32'h040;

    // deny_reason（与 rtl/include/axi_mpu_defs.svh 对齐）
    typedef enum logic [3:0] {
        DENY_NONE            = 4'd0,
        DENY_NO_REGION       = 4'd1,
        DENY_MASTER          = 4'd2,
        DENY_MASTER_SECURITY = 4'd3,
        DENY_SECURITY        = 4'd4,
        DENY_PRIVILEGE       = 4'd5,
        DENY_READ            = 4'd6,
        DENY_WRITE           = 4'd7,
        DENY_EXECUTE         = 4'd8,
        DENY_BURST_BOUNDARY  = 4'd9,
        DENY_INVALID_CONTEXT = 4'd10
    } axi_mpu_deny_e;

    // --------------------------------------------------------------------------
    // 参考模型：基于 region 配置预测 allow/deny 与 reason
    // --------------------------------------------------------------------------
    class axi_mpu_rm extends uvm_component;

        `uvm_component_utils(axi_mpu_rm)

        // Region 配置镜像（testcase 通过 APB 配置后调用 update_region 同步）
        typedef struct {
            bit            enable;
            bit            lock;
            logic [63:0]   base;
            logic [63:0]   limit;
            logic [63:0]   master_mask;
            bit            secure_allow;
            bit            nonsecure_allow;
            bit            priv_allow;
            bit            unpriv_allow;
            bit            read_allow;
            bit            write_allow;
            bit            exec_allow;
        } region_cfg_t;

        typedef struct {
            bit secure_capable;
            bit nonsecure_capable;
        } master_attr_t;

        region_cfg_t  regions[64];
        master_attr_t master_attr[64];
        int region_num = 16;
        int master_num = 8;
        bit global_lock = 0;
        int ut_checks = 0;
        int ut_fails  = 0;

        function new(string name = "axi_mpu_rm", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void reset_cfg();
            for (int i = 0; i < 64; i++) begin
                regions[i].enable = 0;
                regions[i].lock   = 0;
                regions[i].base   = 0;
                regions[i].limit  = 0;
                regions[i].master_mask = 0;
                regions[i].secure_allow = 0;
                regions[i].nonsecure_allow = 0;
                regions[i].priv_allow = 0;
                regions[i].unpriv_allow = 0;
                regions[i].read_allow = 0;
                regions[i].write_allow = 0;
                regions[i].exec_allow = 0;
                master_attr[i].secure_capable = 0;
                master_attr[i].nonsecure_capable = 0;
            end
            global_lock = 0;
        endfunction

        // 计算 burst 地址范围
        function automatic void calc_burst_range(
            input  logic [63:0] start_addr,
            input  logic [7:0]  len,
            input  logic [2:0]  size,
            input  logic [1:0]  burst,
            output logic [63:0] start,
            output logic [63:0] finish
        );
            logic [63:0] bytes = (64'd1 << size);   // beat 字节数
            logic [63:0] lower;
            start = start_addr;
            case (burst)
                2'b01: finish = start_addr + bytes * (len + 1) - 1;   // INCR
                2'b00: finish = start_addr + bytes - 1;               // FIXED
                2'b10: begin                                           // WRAP
                    // 简化处理：WRAP 按完整包络 (num_beats*bytes) 对齐后计算
                    logic [63:0] total = bytes * (len + 1);
                    logic [63:0] align_mask = total - 1;
                    lower = start_addr & ~align_mask;
                    start = lower;
                    finish = lower + total - 1;
                end
                default: finish = start_addr + bytes - 1;
            endcase
        endfunction

        // 判定：返回 allow/reason/region_id
        function automatic void predict(
            input  logic [63:0] addr,
            input  bit          is_read,
            input  bit          is_instruction,
            input  bit          secure,
            input  bit          privileged,
            input  logic [15:0] master_id,
            input  logic [7:0]  len,
            input  logic [2:0]  size,
            input  logic [1:0]  burst,
            output bit          allow,
            output axi_mpu_deny_e reason,
            output logic [15:0] region_id,
            output bit          valid_check
        );
            logic [63:0] start, finish;
            int sel = -1;
            bit matched;
            allow = 0;
            region_id = 16'hFFFF;
            valid_check = 1;
            reason = DENY_NO_REGION;

            calc_burst_range(addr, len, size, burst, start, finish);

            // 非法 master id
            if (master_id >= master_num) begin
                reason = DENY_INVALID_CONTEXT;
                return;
            end

            // region match: lowest index wins
            for (int i = 0; i < region_num; i++) begin
                if (regions[i].enable && regions[i].base <= regions[i].limit) begin
                    if (start >= regions[i].base && finish <= regions[i].limit) begin
                        sel = i;
                        break;
                    end
                end
            end

            if (sel < 0) begin
                reason = DENY_NO_REGION;
                return;
            end

            region_id = sel;
            // master allowed
            if (!regions[sel].master_mask[master_id]) begin
                reason = DENY_MASTER;
                return;
            end
            // master security attribution
            if (secure && !master_attr[master_id].secure_capable) begin
                reason = DENY_MASTER_SECURITY;
                return;
            end
            if (!secure && !master_attr[master_id].nonsecure_capable) begin
                reason = DENY_MASTER_SECURITY;
                return;
            end
            // security
            if (secure && !regions[sel].secure_allow) begin
                reason = DENY_SECURITY;
                return;
            end
            if (!secure && !regions[sel].nonsecure_allow) begin
                reason = DENY_SECURITY;
                return;
            end
            // privilege
            if (privileged && !regions[sel].priv_allow) begin
                reason = DENY_PRIVILEGE;
                return;
            end
            if (!privileged && !regions[sel].unpriv_allow) begin
                reason = DENY_PRIVILEGE;
                return;
            end
            // operation
            if (is_instruction) begin
                if (!regions[sel].read_allow || !regions[sel].exec_allow) begin
                    reason = regions[sel].exec_allow ? DENY_READ : DENY_EXECUTE;
                    return;
                end
            end else if (is_read) begin
                if (!regions[sel].read_allow) begin
                    reason = DENY_READ;
                    return;
                end
            end else begin
                if (!regions[sel].write_allow) begin
                    reason = DENY_WRITE;
                    return;
                end
            end
            allow = 1;
            reason = DENY_NONE;
        endfunction

        // UT 断言辅助
        function void ut_check(string name, bit cond);
            ut_checks++;
            if (cond) $display("PASS: %s", name);
            else begin
                $display("FAIL: %s", name);
                ut_fails++;
            end
        endfunction
    endclass

    // --------------------------------------------------------------------------
    // Checker：不变量断言（基于虚接口采样；在 run_phase 中由 testcase 驱动的
    // 检查点调用，避免与 DUT 异步行为竞争）
    // --------------------------------------------------------------------------
    class axi_mpu_checker extends uvm_component;

        `uvm_component_utils(axi_mpu_checker)

        virtual axi_mpu_if vif;
        int check_count = 0;
        int check_fail  = 0;

        function new(string name = "axi_mpu_checker", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual axi_mpu_if)::get(this, "", "vif", vif))
                `uvm_fatal("CHECKER", "vif not found")
        endfunction

        // 通用断言辅助（testcase 中调用）
        function void chk(string name, bit cond);
            check_count++;
            if (cond) $display("PASS: %s", name);
            else begin
                $display("FAIL: %s", name);
                check_fail++;
            end
        endfunction
    endclass

    // --------------------------------------------------------------------------
    // 功能覆盖率（简化：Region 命中 / 拒绝原因 / burst 类型）
    // --------------------------------------------------------------------------
    class axi_mpu_fcov extends uvm_component;

        `uvm_component_utils(axi_mpu_fcov)

        covergroup cg_deny;
            cp_reason: coverpoint reason_ev;
        endgroup

        axi_mpu_deny_e reason_ev;
        int deny_events = 0;

        function new(string name = "axi_mpu_fcov", uvm_component parent = null);
            super.new(name, parent);
            cg_deny = new();
        endfunction

        function void sample_deny(axi_mpu_deny_e r);
            reason_ev = r;
            deny_events++;
            cg_deny.sample();
        endfunction
    endclass

    // --------------------------------------------------------------------------
    // Env
    // --------------------------------------------------------------------------
    class axi_mpu_env extends uvm_env;

        `uvm_component_utils(axi_mpu_env)

        axi_mpu_rm      rm;
        axi_mpu_checker checker;
        axi_mpu_fcov    fcov;
        virtual axi_mpu_if vif;

        function new(string name = "axi_mpu_env", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            rm      = axi_mpu_rm::type_id::create("rm", this);
            checker = axi_mpu_checker::type_id::create("checker", this);
            fcov    = axi_mpu_fcov::type_id::create("fcov", this);
            if (!uvm_config_db#(virtual axi_mpu_if)::get(this, "", "vif", vif))
                `uvm_fatal("ENV", "vif not found")
        endfunction
    endclass

endpackage
