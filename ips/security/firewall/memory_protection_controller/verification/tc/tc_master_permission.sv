// ============================================================================
// TC.AXI_MPU.MASTER.001 - tc_master_permission
// MASTER_MASK 判定 allowed/denied Master；非法 Master ID（>=MASTER_NUM）拒绝
// ============================================================================
`include "tc_base.sv"

class tc_master_permission extends tc_base;

    `uvm_component_utils(tc_master_permission)

    function new(string name = "tc_master_permission", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp, bresp;

        `uvm_info("TC", "== master_permission ==", UVM_NONE)

        rm_sync_default();

        // Region0: 0x1000-0x1FFF，MASTER_MASK=0x5（master0 + master2），全权限
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h5, 1,1,1,1,1,1,1);
        rm_enable_region(0);

        // 1. master0 -> allow
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("master_0_allowed", rresp == 2'b00);

        // 2. master2 -> allow
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd2, rresp);
        chk("master_2_allowed", rresp == 2'b00);

        // 3. master1 -> deny (DECERR)
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd1, rresp);
        chk("master_1_denied", rresp == 2'b11);

        // 4. master1 write -> deny
        axi_wr_single(48'h0000_0000_1500, 3'b000, 4'd1, bresp);
        chk("master_1_write_denied", bresp == 2'b11);

        // 5. 非法 master_id (>=8) -> deny（DECERR, INVALID_CONTEXT）
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd8, rresp);
        chk("master_invalid_id_denied", rresp == 2'b11);
    endtask

endclass
