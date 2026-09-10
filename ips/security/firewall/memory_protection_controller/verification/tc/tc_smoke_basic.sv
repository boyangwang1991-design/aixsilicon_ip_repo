// ============================================================================
// TC.AXI_MPU.SMOKE.001 - tc_smoke_basic
// Reset + APB 基本访问 + Region 配置 + 合法 read/write
// ============================================================================
`include "tc_base.sv"

class tc_smoke_basic extends tc_base;

    `uvm_component_utils(tc_smoke_basic)

    function new(string name = "tc_smoke_basic", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [31:0] rd32;
        logic [1:0]  rresp, bresp;

        `uvm_info("SMOKE", "== smoke_basic: reset + APB + basic RW ==", UVM_NONE)

        // 1. 复位后默认 deny：未配置 Region 的 read -> DECERR
        axi_rd_single(48'h0000_0000_1000, 3'b000, 4'd0, rresp);
        chk("smoke_default_deny_read_decerr", rresp == 2'b11);

        // 2. APB 读回读（GLOBAL_STATUS）
        apb_rd(32'h004, rd32);
        chk("smoke_apb_read_ok", 1'b1);

        // 3. 配置 Region0: 0x1000-0x1FFF, master0 allowed, all allow
        rm_sync_default();
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h0000_0000_0000_0001,
                      1, 1, 1, 1, 1, 1, 1);
        rm_enable_region(0);

        // 4. 合法 read (0x1500) -> OKAY
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("smoke_legal_read_okay", rresp == 2'b00);

        // 5. 合法 write (0x1600) -> BOKAY
        axi_wr_single(48'h0000_0000_1600, 3'b000, 4'd0, bresp);
        chk("smoke_legal_write_bokay", bresp == 2'b00);

        // 6. 非法 read（master1 不在 mask）-> DECERR
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd1, rresp);
        chk("smoke_master_deny_decerr", rresp == 2'b11);

        // 7. VIOL_STATUS.valid 置位
        apb_rd(32'h020, rd32);
        chk("smoke_viol_status_valid", rd32[0] == 1'b1);

        // 8. 配置回读 REGION0_BASE_LO
        apb_rd(32'h204, rd32);
        chk("smoke_cfg_readback_base", rd32 == 32'h0000_1000);

        // 9. IRQ 置位（viol_en 使能前应因 violation 置 IRQ_STATUS.viol_sticky）
        apb_rd(32'h010, rd32);
        chk("smoke_irq_status_sticky", rd32[0] == 1'b1);
    endtask

endclass
