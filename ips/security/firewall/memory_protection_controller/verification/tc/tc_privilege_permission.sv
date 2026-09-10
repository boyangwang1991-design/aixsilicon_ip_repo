// ============================================================================
// TC.AXI_MPU.PRIVILEGE.001 - tc_privilege_permission
// PRIVILEGED_ALLOW / UNPRIVILEGED_ALLOW 判定
// ============================================================================
`include "tc_base.sv"

class tc_privilege_permission extends tc_base;

    `uvm_component_utils(tc_privilege_permission)

    function new(string name = "tc_privilege_permission", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp;

        `uvm_info("TC", "== privilege_permission ==", UVM_NONE)

        rm_sync_default();

        // Region0: 0x1000-0x1FFF, master0, Privileged-only（priv_allow=1, unpriv_allow=0）
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,0, 1,1,1);
        rm_enable_region(0);

        // 1. Privileged (ARPROT[0]=1) -> allow
        axi_rd_single(48'h0000_0000_1500, 3'b001, 4'd0, rresp);
        chk("privileged_allowed", rresp == 2'b00);

        // 2. Unprivileged (ARPROT[0]=0) -> deny
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("unprivileged_denied", rresp == 2'b11);

        // 3. Region1: 0x2000-0x2FFF, master0, Unprivileged-only（priv_allow=0, unpriv_allow=1）
        rm_cfg_region(1, 48'h0000_0000_2000, 48'h0000_0000_2FFF,
                      64'h1, 1,1, 0,1, 1,1,1);
        rm_enable_region(1);
        axi_rd_single(48'h0000_0000_2500, 3'b000, 4'd0, rresp);
        chk("unpriv_only_region_unpriv_allowed", rresp == 2'b00);
        axi_rd_single(48'h0000_0000_2500, 3'b001, 4'd0, rresp);
        chk("unpriv_only_region_priv_denied", rresp == 2'b11);
    endtask

endclass
