// ============================================================================
// TC.AXI_MPU.LOCK.001 - tc_config_lock
// REGION_LOCK 置位后 BASE/LIMIT/ATTR/MASTER_MASK 冻结；
// GLOBAL_LOCK 置位后全配置冻结、1->0 仅 reset
// ============================================================================
`include "tc_base.sv"

class tc_config_lock extends tc_base;

    `uvm_component_utils(tc_config_lock)

    function new(string name = "tc_config_lock", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [31:0] rd32;

        `uvm_info("TC", "== config_lock ==", UVM_NONE)

        rm_sync_default();

        // Region0: 0x1000-0x1FFF, master0, all allow
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,1, 1,1,1);
        rm_enable_region(0);

        // 1. 置 REGION0_CONTROL.lock（写 0b10）
        apb_wr(32'h200, 32'h3);   // enable=1, lock=1
        env.rm.regions[0].lock = 1;

        // 2. lock 后改写 REGION0_BASE_LO 应无效（仍为 0x1000）
        apb_wr(32'h204, 32'h0000_9000);
        apb_rd(32'h204, rd32);
        chk("region_lock_base_frozen", rd32 == 32'h0000_1000);

        // 3. lock 后改写 REGION0_PERMISSION 应无效
        apb_wr(32'h218, 32'h00);
        apb_rd(32'h218, rd32);
        chk("region_lock_perm_frozen", rd32[4] == 1'b1);  // read_allow 仍为 1

        // 4. 置 GLOBAL_LOCK（写 1）
        apb_wr(32'h008, 32'h1);
        env.rm.global_lock = 1;

        // 5. GLOBAL_LOCK 后改写 Region 配置应无效
        apb_wr(32'h204, 32'h0000_7000);
        apb_rd(32'h204, rd32);
        chk("global_lock_base_frozen", rd32 == 32'h0000_1000);

        // 6. GLOBAL_LOCK 不能 1->0（写 0 无效）
        apb_wr(32'h008, 32'h0);
        apb_rd(32'h008, rd32);
        chk("global_lock_1to0_prohibited", rd32[0] == 1'b1);

        // 7. reset 后 lock 清除、配置复位
        vif.arst_n = 0;
        repeat (3) @(posedge vif.clk);
        vif.arst_n = 1;
        repeat (2) @(posedge vif.clk);
        apb_rd(32'h008, rd32);
        chk("global_lock_cleared_after_reset", rd32[0] == 1'b0);
        apb_rd(32'h200, rd32);
        chk("region_enable_cleared_after_reset", rd32[0] == 1'b0);
    endtask

endclass
