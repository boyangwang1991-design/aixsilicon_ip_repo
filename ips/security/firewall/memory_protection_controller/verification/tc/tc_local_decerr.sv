// ============================================================================
// TC.AXI_MPU.ERR_RESP.001 - tc_local_decerr
// 非法 read/write 本地 DECERR 完整响应；W beat 被 consume；无 hang、无部分写入
// ============================================================================
`include "tc_base.sv"

class tc_local_decerr extends tc_base;

    `uvm_component_utils(tc_local_decerr)

    function new(string name = "tc_local_decerr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp, bresp;
        logic [31:0] rd32;
        int r_beat_count;

        `uvm_info("TC", "== local_decerr ==", UVM_NONE)

        rm_sync_default();

        // Region0: 0x1000-0x1FFF, master0, all allow
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,1, 1,1,1);
        rm_enable_region(0);

        // 1. 非法 read burst（len=3, 跨 LIMIT）-> 4 个 DECERR beat + RLAST
        //    统计 R beat 数并检查全 DECERR
        r_beat_count = 0;
        fork
            begin : r_mon
                forever begin
                    @(posedge vif.clk);
                    if (vif.s_axi_rvalid && vif.s_axi_rready) begin
                        r_beat_count++;
                        if (vif.s_axi_rresp !== 2'b11)
                            $display("FAIL: non-DECERR R beat resp=%b", vif.s_axi_rresp);
                        if (vif.s_axi_rlast) disable r_mon;
                    end
                end
            end
        join_none
        axi_rd_burst(48'h0000_0000_1FF8, 3'b000, 4'd0, 8'd3, 2'b01, 3'd3, rresp);
        disable r_mon;
        chk("decerr_burst_first_resp", rresp == 2'b11);
        chk("decerr_burst_beat_count", r_beat_count == 4);

        // 2. 非法 write（0x2000 无 Region 匹配）-> B DECERR，W 被 consume
        //    （原 0x1FF8 single-beat 0x1FF8-0x1FFF 恰在 Region0 内，非跨界）
        axi_wr_single(48'h0000_0000_2000, 3'b000, 4'd0, bresp);
        chk("decerr_write_bresp", bresp == 2'b11);

        // 3. M_AXI 上无部分写入（m_axi_awvalid 不应为 1）
        chk("decerr_no_m_axi_aw", $root.harness.u_dut.m_axi_awvalid == 1'b0);

        // 4. 后续合法事务不受影响
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("decerr_followup_legal_ok", rresp == 2'b00);

        // 5. VIOL_COUNT 递增（2 次 violation）
        apb_rd(32'h034, rd32);
        chk("decerr_viol_count", rd32[15:0] >= 16'd2);
    endtask

endclass
