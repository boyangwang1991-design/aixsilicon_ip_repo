// ============================================================================
// TC.AXI_MPU.DEFAULT_DENY.001 - tc_default_deny
// 未配置任何 Region 时 read/write 均返回 DECERR；M_AXI 无事务
// ============================================================================
`include "tc_base.sv"

class tc_default_deny extends tc_base;

    `uvm_component_utils(tc_default_deny)

    function new(string name = "tc_default_deny", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp, bresp;
        logic [31:0] rd32;

        `uvm_info("TC", "== default_deny ==", UVM_NONE)

        // reset 后未配置任何 Region
        // 1. read 到任意地址 -> DECERR
        axi_rd_single(48'h0000_0000_3000, 3'b000, 4'd0, rresp);
        chk("default_deny_read_decerr", rresp == 2'b11);

        // 2. write 到任意地址 -> DECERR
        axi_wr_single(48'h0000_0000_3008, 3'b000, 4'd0, bresp);
        chk("default_deny_write_decerr", bresp == 2'b11);

        // 3. M_AXI 上无事务（arvalid/awvalid 均不应出现）
        chk("default_deny_no_m_axi_ar", $root.harness.u_dut.m_axi_arvalid == 1'b0);
        chk("default_deny_no_m_axi_aw", $root.harness.u_dut.m_axi_awvalid == 1'b0);

        // 4. VIOL_STATUS.valid 置位
        apb_rd(32'h020, rd32);
        chk("default_deny_viol_valid", rd32[0] == 1'b1);

        // 5. VIOL_COUNT == 2
        apb_rd(32'h034, rd32);
        chk("default_deny_viol_count", rd32[15:0] == 16'd2);
    endtask

endclass
