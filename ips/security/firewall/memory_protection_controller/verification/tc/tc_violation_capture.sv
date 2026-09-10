// ============================================================================
// TC.AXI_MPU.VIOLATION.001 - tc_violation_capture
// FIRST_ERROR_STICKY 捕获、VIOL_COUNT 计数（saturating）、IRQ sticky+W1C
// ============================================================================
`include "tc_base.sv"

class tc_violation_capture extends tc_base;

    `uvm_component_utils(tc_violation_capture)

    function new(string name = "tc_violation_capture", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp;
        logic [31:0] rd32;

        `uvm_info("TC", "== violation_capture ==", UVM_NONE)

        rm_sync_default();

        // 使能 IRQ
        apb_wr(32'h00C, 32'h1);   // IRQ_ENABLE.viol_en=1

        // Region0: 0x1000-0x1FFF, master0, all allow
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,1, 1,1,1);
        rm_enable_region(0);

        // 1. 触发两次 violation（master1 访问 master0-only region）
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd1, rresp);
        chk("viol_master1_deny", rresp == 2'b11);
        axi_rd_single(48'h0000_0000_1600, 3'b000, 4'd1, rresp);
        chk("viol_master1_deny2", rresp == 2'b11);

        // 2. VIOL_STATUS.valid=1，read=1（首次 violation 为 read）
        apb_rd(32'h020, rd32);
        chk("viol_status_valid", rd32[0] == 1'b1);
        chk("viol_status_read_attr", rd32[1] == 1'b1);

        // 3. VIOL_ADDR_LO 记录首错地址（0x1500）
        apb_rd(32'h024, rd32);
        chk("viol_addr_first_error", rd32 == 32'h0000_1500);

        // 4. VIOL_COUNT == 2
        apb_rd(32'h034, rd32);
        chk("viol_count", rd32[15:0] == 16'd2);

        // 5. IRQ_STATUS.viol_sticky=1（IRQ 使能且发生 violation）
        apb_rd(32'h010, rd32);
        chk("irq_status_sticky", rd32[0] == 1'b1);
        chk("irq_pin_asserted", vif.irq == 1'b1);

        // 6. FIRST_ERROR_STICKY：后续不同 violation 不覆盖首错信息
        //    master2 访问（不同 master），首错地址仍为 0x1500
        axi_rd_single(48'h0000_0000_1800, 3'b000, 4'd2, rresp);
        chk("viol_second_deny", rresp == 2'b11);
        apb_rd(32'h024, rd32);
        chk("viol_first_error_sticky", rd32 == 32'h0000_1500);

        // 7. W1C 清除 IRQ_STATUS（写 1 清除）
        apb_wr(32'h010, 32'h1);
        apb_rd(32'h010, rd32);
        chk("irq_w1c_clear", rd32[0] == 1'b0);
        chk("irq_pin_released", vif.irq == 1'b0);

        // 8. W1C 清除 VIOL_STATUS.valid
        apb_wr(32'h020, 32'h1);   // W1C valid
        apb_rd(32'h020, rd32);
        chk("viol_status_w1c_clear", rd32[0] == 1'b0);
    endtask

endclass
