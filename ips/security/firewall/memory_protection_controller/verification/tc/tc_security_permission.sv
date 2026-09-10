// ============================================================================
// TC.AXI_MPU.SECURITY.001 - tc_security_permission
// Secure/Non-secure Region 权限；Master Security Attribution（forged Secure 拒绝）
// ============================================================================
`include "tc_base.sv"

class tc_security_permission extends tc_base;

    `uvm_component_utils(tc_security_permission)

    function new(string name = "tc_security_permission", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp;

        `uvm_info("TC", "== security_permission ==", UVM_NONE)

        rm_sync_default();

        // master0: 仅 Non-secure capable（改写 MASTER_ATTR[0]）
        apb_wr(32'h100, 32'h2);   // nonsecure_capable=1, secure_capable=0
        env.rm.master_attr[0].secure_capable = 0;
        env.rm.master_attr[0].nonsecure_capable = 1;

        // Region0: 0x1000-0x1FFF, master0, Secure-only
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,0, 1,1, 1,1,1);   // secure_allow=1, nonsecure_allow=0
        rm_enable_region(0);

        // 1. Non-secure 访问 secure-only Region -> deny（SECURITY_DENY）
        //    ARPROT = 3'b010: [0]=0 unpriv, [1]=1 non-secure, [2]=0 data
        axi_rd_single(48'h0000_0000_1500, 3'b010, 4'd0, rresp);
        chk("nonsecure_to_secure_region_denied", rresp == 2'b11);

        // 2. forged Secure：master0 无 Secure capability 却声明 Secure -> deny（MASTER_SECURITY_DENY）
        //    ARPROT = 3'b100: [1]=0 secure, [2]=1 data+instr
        axi_rd_single(48'h0000_0000_1500, 3'b100, 4'd0, rresp);
        chk("forged_secure_denied", rresp == 2'b11);

        // 3. 恢复 master0 Secure+Non-secure capable
        apb_wr(32'h100, 32'h3);
        env.rm.master_attr[0].secure_capable = 1;
        env.rm.master_attr[0].nonsecure_capable = 1;

        // 4. Secure 访问（有 capability）-> allow
        axi_rd_single(48'h0000_0000_1500, 3'b100, 4'd0, rresp);
        chk("secure_allowed_with_capability", rresp == 2'b00);

        // 5. 只允许 Non-secure 的 Region：master1 声明 Secure 访问 -> deny
        //    Region1: 0x2000-0x2FFF, master1, nonsecure-only
        apb_wr(32'h104, 32'h2);   // master1: nonsecure capable only
        env.rm.master_attr[1].secure_capable = 0;
        env.rm.master_attr[1].nonsecure_capable = 1;
        rm_cfg_region(1, 48'h0000_0000_2000, 48'h0000_0000_2FFF,
                      64'h2, 0,1, 1,1, 1,1,1);   // secure_allow=0, nonsecure_allow=1
        rm_enable_region(1);
        axi_rd_single(48'h0000_0000_2500, 3'b100, 4'd1, rresp);  // Secure (ARPROT[1]=0)
        chk("secure_to_nonsecure_region_denied", rresp == 2'b11);
        // Non-secure -> allow (ARPROT = 3'b010)
        axi_rd_single(48'h0000_0000_2500, 3'b010, 4'd1, rresp);
        chk("nonsecure_to_nonsecure_region_allowed", rresp == 2'b00);
    endtask

endclass
