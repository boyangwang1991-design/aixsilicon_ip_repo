// ============================================================================
// TC.AXI_MPU.REGION.001 - tc_region_boundary
// REGION_BASE/LIMIT 边界（等于/±1）、overlap lowest-index-wins、非法 BASE>LIMIT
// ============================================================================
`include "tc_base.sv"

class tc_region_boundary extends tc_base;

    `uvm_component_utils(tc_region_boundary)

    function new(string name = "tc_region_boundary", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp;
        logic [31:0] rd32;

        `uvm_info("TC", "== region_boundary ==", UVM_NONE)

        rm_sync_default();

        // Region0: 0x1000-0x1FFF, master0, all allow
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1,1,1,1,1,1);
        rm_enable_region(0);

        // 1. 等于 BASE (0x1000) -> allow
        axi_rd_single(48'h0000_0000_1000, 3'b000, 4'd0, rresp);
        chk("region_boundary_eq_base_allow", rresp == 2'b00);

        // 2. 等于 LIMIT (0x1FFF) -> allow
        axi_rd_single(48'h0000_0000_1FFF, 3'b000, 4'd0, rresp);
        chk("region_boundary_eq_limit_allow", rresp == 2'b00);

        // 3. BASE-1 (0x0FFF) -> deny
        axi_rd_single(48'h0000_0000_0FFF, 3'b000, 4'd0, rresp);
        chk("region_boundary_base_m1_deny", rresp == 2'b11);

        // 4. LIMIT+1 (0x2000) -> deny
        axi_rd_single(48'h0000_0000_2000, 3'b000, 4'd0, rresp);
        chk("region_boundary_limit_p1_deny", rresp == 2'b11);

        // 5. Region1: 0x1000-0x17FF（overlap 于 Region0），只允许 write，master0
        //    lowest-index-wins -> Region0 的 read 权限优先（allow read）
        rm_cfg_region(1, 48'h0000_0000_1000, 48'h0000_0000_17FF,
                      64'h1, 1,1,1,1, 0,1,0);  // read_allow=0
        rm_enable_region(1);
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("region_overlap_lowest_index_read_allowed", rresp == 2'b00);

        // 6. 非法 Region：BASE>LIMIT 视为 disabled。Region2: 0x3000-0x2000
        //    配置非法 region，master0 read 0x2500 应 deny（无有效 region）
        rm_cfg_region(2, 48'h0000_0000_3000, 48'h0000_0000_2000,
                      64'h1, 1,1,1,1,1,1,1);
        rm_enable_region(2);
        axi_rd_single(48'h0000_0000_2500, 3'b000, 4'd0, rresp);
        chk("region_invalid_base_gt_limit_disabled", rresp == 2'b11);

        // 7. Region 配置读回
        apb_rd(32'h204, rd32);
        chk("region_base_lo_readback", rd32 == 32'h0000_1000);
    endtask

endclass
