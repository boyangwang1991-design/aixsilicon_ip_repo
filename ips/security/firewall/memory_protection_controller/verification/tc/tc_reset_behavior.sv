// ============================================================================
// TC.AXI_MPU.RESET.001 - tc_reset_behavior
// Reset 后所有 Region disabled、Default Deny、lock/violation/IRQ 清除；
// traffic 中 reset 恢复
// ============================================================================
`include "tc_base.sv"

class tc_reset_behavior extends tc_base;

    `uvm_component_utils(tc_reset_behavior)

    function new(string name = "tc_reset_behavior", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp;
        logic [31:0] rd32;

        `uvm_info("TC", "== reset_behavior ==", UVM_NONE)

        rm_sync_default();

        // 配置 Region0 + 触发 violation
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,1, 1,1,1);
        rm_enable_region(0);
        apb_wr(32'h00C, 32'h1);   // IRQ_ENABLE
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd1, rresp);  // violation
        chk("reset_precheck_deny", rresp == 2'b11);
        apb_rd(32'h010, rd32);
        chk("reset_precheck_irq_sticky", rd32[0] == 1'b1);

        // traffic 中 assert reset
        vif.arst_n = 0;
        repeat (5) @(posedge vif.clk);
        vif.arst_n = 1;
        repeat (3) @(posedge vif.clk);

        // 1. reset 后 region enable=0
        apb_rd(32'h200, rd32);
        chk("reset_region_disabled", rd32[0] == 1'b0);

        // 2. reset 后 lock=0
        apb_rd(32'h008, rd32);
        chk("reset_global_lock_cleared", rd32[0] == 1'b0);

        // 3. reset 后 violation 清除
        apb_rd(32'h020, rd32);
        chk("reset_viol_cleared", rd32[0] == 1'b0);

        // 4. reset 后 IRQ 清除
        apb_rd(32'h010, rd32);
        chk("reset_irq_cleared", rd32[0] == 1'b0);

        // 5. reset 后默认 deny：未匹配访问被拒
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("reset_default_deny_after", rresp == 2'b11);

        // 6. 重新配置后恢复正常
        rm_sync_default();
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,1, 1,1,1);
        rm_enable_region(0);
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("reset_reconfigure_ok", rresp == 2'b00);
    endtask

endclass
