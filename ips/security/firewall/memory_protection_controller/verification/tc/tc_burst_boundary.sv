// ============================================================================
// TC.AXI_MPU.BURST.001 - tc_burst_boundary
// INCR/FIXED/WRAP burst 完整地址范围；跨 Region 边界整事务拒绝
// ============================================================================
`include "tc_base.sv"

class tc_burst_boundary extends tc_base;

    `uvm_component_utils(tc_burst_boundary)

    function new(string name = "tc_burst_boundary", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp;

        `uvm_info("TC", "== burst_boundary ==", UVM_NONE)

        rm_sync_default();

        // Region0: 0x1000-0x1FFF, master0, all allow
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,1, 1,1,1);
        rm_enable_region(0);

        // 1. INCR burst 完全在 Region 内（0x1500, len=3, size=3[8B], 结束 0x151F）-> allow
        axi_rd_burst(48'h0000_0000_1500, 3'b000, 4'd0, 8'd3, 2'b01, 3'd3, rresp);
        chk("burst_incr_inside_allowed", rresp == 2'b00);

        // 2. INCR burst 跨 LIMIT（0x1FF8, len=3, 结束 0x201F > 0x1FFF）-> deny
        axi_rd_burst(48'h0000_0000_1FF8, 3'b000, 4'd0, 8'd3, 2'b01, 3'd3, rresp);
        chk("burst_incr_cross_limit_denied", rresp == 2'b11);

        // 3. INCR burst 跨 BASE（0x0FF8, len=3, 起始 0x0FF8 < 0x1000）-> deny
        axi_rd_burst(48'h0000_0000_0FF8, 3'b000, 4'd0, 8'd3, 2'b01, 3'd3, rresp);
        chk("burst_incr_cross_base_denied", rresp == 2'b11);

        // 4. FIXED burst 完全在内（0x1500, len=3）-> allow（地址固定）
        axi_rd_burst(48'h0000_0000_1500, 3'b000, 4'd0, 8'd3, 2'b00, 3'd3, rresp);
        chk("burst_fixed_inside_allowed", rresp == 2'b00);

        // 5. WRAP burst 完全在内（0x1500, len=7, size=3, 8 beats*8B=64B wrap）-> allow
        axi_rd_burst(48'h0000_0000_1500, 3'b000, 4'd0, 8'd7, 2'b10, 3'd3, rresp);
        chk("burst_wrap_inside_allowed", rresp == 2'b00);

        // 6. WRAP 起始未对齐（0x1FC8, len=7）：wrap 块 0x1FC0-0x1FFF 全在 Region0 内
        //    → 地址绕回正确，allow（wrap 跨界 deny 已由 #2 INCR cross-LIMIT 覆盖）
        axi_rd_burst(48'h0000_0000_1FC8, 3'b000, 4'd0, 8'd7, 2'b10, 3'd3, rresp);
        chk("burst_wrap_misaligned_start_allowed", rresp == 2'b00);
    endtask

endclass
