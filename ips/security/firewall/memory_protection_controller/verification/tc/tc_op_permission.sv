// ============================================================================
// TC.AXI_MPU.OP.001 - tc_op_permission
// READ_ALLOW / WRITE_ALLOW / EXECUTE_ALLOW 判定；instruction 需 READ+EXECUTE
// ============================================================================
`include "tc_base.sv"

class tc_op_permission extends tc_base;

    `uvm_component_utils(tc_op_permission)

    function new(string name = "tc_op_permission", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp, bresp;

        `uvm_info("TC", "== op_permission ==", UVM_NONE)

        rm_sync_default();

        // Region0: 0x1000-0x1FFF, master0, READ=1 WRITE=0 EXEC=0
        rm_cfg_region(0, 48'h0000_0000_1000, 48'h0000_0000_1FFF,
                      64'h1, 1,1, 1,1, 1,0,0);
        rm_enable_region(0);

        // 1. Read -> allow
        axi_rd_single(48'h0000_0000_1500, 3'b000, 4'd0, rresp);
        chk("read_allowed_readonly_region", rresp == 2'b00);

        // 2. Write -> deny（WRITE_DENY）
        axi_wr_single(48'h0000_0000_1500, 3'b000, 4'd0, bresp);
        chk("write_denied_readonly_region", bresp == 2'b11);

        // 3. Instruction (ARPROT[2]=1) -> deny（NX，EXECUTE_DENY）
        axi_rd_single(48'h0000_0000_1500, 3'b100, 4'd0, rresp);
        chk("instruction_denied_nx_region", rresp == 2'b11);

        // 4. Region1: 0x2000-0x2FFF, master0, READ=0 WRITE=1 EXEC=1
        //    read 需 READ_ALLOW -> deny；instruction 需 READ+EXEC -> deny；write -> allow
        rm_cfg_region(1, 48'h0000_0000_2000, 48'h0000_0000_2FFF,
                      64'h1, 1,1, 1,1, 0,1,1);
        rm_enable_region(1);
        axi_rd_single(48'h0000_0000_2500, 3'b000, 4'd0, rresp);
        chk("read_denied_write_only_region", rresp == 2'b11);
        axi_rd_single(48'h0000_0000_2500, 3'b100, 4'd0, rresp);
        chk("instruction_denied_no_read", rresp == 2'b11);
        axi_wr_single(48'h0000_0000_2500, 3'b000, 4'd0, bresp);
        chk("write_allowed_write_only_region", bresp == 2'b00);
    endtask

endclass
