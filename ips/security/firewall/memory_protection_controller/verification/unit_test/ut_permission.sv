// ============================================================================
// AXI MPU - Permission Engine Module UT (smoke-level directed testbench)
// ============================================================================
// 验证权限引擎：Default Deny、Region match/priority、Master/Security/
// Privilege/Op 判定。Module UT 属于 G3 证据（白盒局部验证）。
// 运行：vcs -sverilog 编译 rtl + 本 tb。
// ============================================================================

`include "axi_mpu_defs.svh"

module axi_mpu_permission_ut;

    localparam int ADDR_WIDTH      = 48;
    localparam int MASTER_NUM      = 8;
    localparam int MASTER_ID_WIDTH = 4;
    localparam int REGION_NUM      = 16;

    // DUT 端口
    logic clk, arst_n;
    logic [ADDR_WIDTH-1:0] req_addr;
    logic req_is_read, req_is_instruction, req_secure, req_privileged;
    logic [MASTER_ID_WIDTH-1:0] req_master_id;
    logic [7:0] req_len;
    logic [2:0] req_size;
    logic [1:0] req_burst;
    logic req_valid;
    logic [REGION_NUM-1:0] region_enable;
    logic [ADDR_WIDTH-1:0] region_base[REGION_NUM];
    logic [ADDR_WIDTH-1:0] region_limit[REGION_NUM];
    logic [MASTER_NUM-1:0] region_master_mask[REGION_NUM];
    logic [REGION_NUM-1:0] region_secure_allow;
    logic [REGION_NUM-1:0] region_nonsecure_allow;
    logic [REGION_NUM-1:0] region_priv_allow;
    logic [REGION_NUM-1:0] region_unpriv_allow;
    logic [REGION_NUM-1:0] region_read_allow;
    logic [REGION_NUM-1:0] region_write_allow;
    logic [REGION_NUM-1:0] region_exec_allow;
    logic [MASTER_NUM-1:0] master_secure_capable;
    logic [MASTER_NUM-1:0] master_nonsecure_capable;
    logic perm_allow;
    logic [3:0] perm_reason;
    logic [15:0] perm_region_id;

    axi_mpu_permission #(
        .ADDR_WIDTH      (ADDR_WIDTH),
        .MASTER_NUM      (MASTER_NUM),
        .MASTER_ID_WIDTH (MASTER_ID_WIDTH),
        .REGION_NUM      (REGION_NUM),
        .HAS_EXECUTE     (1'b1),
        .HAS_MASTER_ATTR (1'b1),
        .WRAP_SUPPORT    (1'b1)
    ) u_dut (
        .clk(clk), .arst_n(arst_n),
        .req_addr(req_addr), .req_is_read(req_is_read),
        .req_is_instruction(req_is_instruction), .req_secure(req_secure),
        .req_privileged(req_privileged), .req_master_id(req_master_id),
        .req_len(req_len), .req_size(req_size), .req_burst(req_burst),
        .req_valid(req_valid),
        .region_enable(region_enable), .region_base(region_base),
        .region_limit(region_limit), .region_master_mask(region_master_mask),
        .region_secure_allow(region_secure_allow),
        .region_nonsecure_allow(region_nonsecure_allow),
        .region_priv_allow(region_priv_allow),
        .region_unpriv_allow(region_unpriv_allow),
        .region_read_allow(region_read_allow),
        .region_write_allow(region_write_allow),
        .region_exec_allow(region_exec_allow),
        .master_secure_capable(master_secure_capable),
        .master_nonsecure_capable(master_nonsecure_capable),
        .perm_allow(perm_allow), .perm_reason(perm_reason),
        .perm_region_id(perm_region_id)
    );

    int errors = 0;

    task automatic check(input string name, input logic got, input logic exp,
                         input logic [3:0] got_reason, input logic [3:0] exp_reason);
        if (got !== exp || (got === 1'b0 && got_reason !== exp_reason)) begin
            $display("FAIL: %s: allow=%0b (exp %0b) reason=%0h (exp %0h)",
                     name, got, exp, got_reason, exp_reason);
            errors++;
        end else begin
            $display("PASS: %s", name);
        end
    endtask

    initial begin
        clk = 0;
        arst_n = 0;
        req_valid = 0;
        region_enable = '0;
        region_secure_allow = '0;
        region_nonsecure_allow = '0;
        region_priv_allow = '0;
        region_unpriv_allow = '0;
        region_read_allow = '0;
        region_write_allow = '0;
        region_exec_allow = '0;
        master_secure_capable = '0;
        master_nonsecure_capable = '0;
        for (int i = 0; i < REGION_NUM; i++) begin
            region_base[i] = '0;
            region_limit[i] = '0;
            region_master_mask[i] = '0;
        end

        repeat (5) @(posedge clk);
        arst_n = 1;
        @(posedge clk);

        // ---- TC1: Default Deny (no region) ----
        req_valid = 1; req_addr = 48'h1000; req_is_read = 1; req_is_instruction = 0;
        req_secure = 0; req_privileged = 1; req_master_id = 0;
        req_len = 0; req_size = 3'd3; req_burst = 2'b01;
        #1;
        check("default_deny_no_region", perm_allow, 1'b0, perm_reason, 4'd1);
        @(posedge clk);

        // ---- TC2: Region match allow ----
        region_enable[0] = 1;
        region_base[0]   = 48'h1000;
        region_limit[0]  = 48'h1FFF;
        region_master_mask[0] = 8'h01;
        region_secure_allow[0] = 1;
        region_nonsecure_allow[0] = 1;
        region_priv_allow[0] = 1;
        region_unpriv_allow[0] = 1;
        region_read_allow[0] = 1;
        region_write_allow[0] = 1;
        region_exec_allow[0] = 1;
        master_secure_capable[0] = 1;
        master_nonsecure_capable[0] = 1;
        #1;
        check("region0_allow_read", perm_allow, 1'b1, perm_reason, 4'd0);
        check("region0_sel_region", (perm_region_id == 16'd0), 1'b1, 4'd0, 4'd0);
        @(posedge clk);

        // ---- TC3: Master deny (master1 not in mask) ----
        req_master_id = 1;
        #1;
        check("master_deny", perm_allow, 1'b0, perm_reason, 4'd2);
        @(posedge clk);
        req_master_id = 0;

        // ---- TC4: invalid master id ----
        req_master_id = 4'd9; // >= MASTER_NUM=8
        #1;
        check("invalid_master_deny", perm_allow, 1'b0, perm_reason, 4'd10);
        @(posedge clk);
        req_master_id = 0;

        // ---- TC5: Security deny (secure-only region, nonsecure request) ----
        region_secure_allow[0] = 1;
        region_nonsecure_allow[0] = 0;
        req_secure = 0;
        #1;
        check("nonsecure_to_secure_only_deny", perm_allow, 1'b0, perm_reason, 4'd4);
        @(posedge clk);

        // ---- TC6: forged secure (master no secure capability) ----
        req_secure = 1;
        master_secure_capable[0] = 0; // master0 not secure-capable
        #1;
        check("forged_secure_deny", perm_allow, 1'b0, perm_reason, 4'd3);
        master_secure_capable[0] = 1;
        @(posedge clk);

        // 恢复 region0 双 security allow（后续 TC 使用）
        region_secure_allow[0] = 1;
        region_nonsecure_allow[0] = 1;
        req_secure = 0;
        #1;

        // ---- TC7: privilege deny ----
        region_priv_allow[0] = 1;
        region_unpriv_allow[0] = 0;
        req_secure = 0; req_privileged = 0;
        #1;
        check("unpriv_deny", perm_allow, 1'b0, perm_reason, 4'd5);
        @(posedge clk);

        // ---- TC8: write deny (read-only region) ----
        region_read_allow[0] = 1;
        region_write_allow[0] = 0;
        req_is_read = 0; req_privileged = 1;
        #1;
        check("write_deny", perm_allow, 1'b0, perm_reason, 4'd7);
        @(posedge clk);

        // ---- TC9: instruction NX deny ----
        req_is_read = 1; req_is_instruction = 1;
        region_exec_allow[0] = 0;
        #1;
        check("instruction_nx_deny", perm_allow, 1'b0, perm_reason, 4'd8);
        @(posedge clk);

        // ---- TC10: priority (region0 allows, region1 denies; lowest index wins) ----
        // 配置 Region0 覆盖并 allow；Region1 覆盖同地址但 deny（master mask 空）
        region_enable[1] = 1;
        region_base[1]   = 48'h1000;
        region_limit[1]  = 48'h1FFF;
        region_master_mask[1] = 8'h00; // deny all masters
        req_is_read = 1; req_is_instruction = 0;
        region_exec_allow[0] = 1;
        #1;
        check("priority_lowest_wins", perm_allow, 1'b1, perm_reason, 4'd0);
        @(posedge clk);

        // ---- TC11: burst cross limit deny ----
        // Region0 covers 0x1000-0x1FFF. burst len=7 size=3 (8 beats*8B=64B) starting 0x1FC0
        req_addr = 48'h1FC0;
        req_len = 7; req_size = 3'd3; req_burst = 2'b01; // INCR
        req_is_read = 1;
        #1;
        // burst_end = align(0x1FC0)=0x1FC0 + 0x40-1 = 0x1FFF 在内 → allow
        check("burst_inside_allow", perm_allow, 1'b1, perm_reason, 4'd0);
        @(posedge clk);
        // start 0x1FC8 → end 0x2007 > limit → deny
        req_addr = 48'h1FC8;
        #1;
        check("burst_cross_limit_deny", perm_allow, 1'b0, perm_reason, 4'd1);

        @(posedge clk);
        if (errors == 0) begin
            $display("UT_PERMISSION: PASS (errors=0)");
        end else begin
            $display("UT_PERMISSION: FAIL (errors=%0d)", errors);
        end
        $finish;
    end

    always #5 clk = ~clk;

endmodule
