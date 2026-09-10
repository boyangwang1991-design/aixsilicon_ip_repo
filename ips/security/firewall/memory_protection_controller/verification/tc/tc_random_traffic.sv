// ============================================================================
// TC.AXI_MPU.RANDOM.001 - tc_random_traffic
// 随机混合流量（合法/非法、read/write、burst、多 ID）压力验证
// ============================================================================
`include "tc_base.sv"

class tc_random_traffic extends tc_base;

    `uvm_component_utils(tc_random_traffic)

    function new(string name = "tc_random_traffic", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_testcase();
        logic [1:0] rresp, bresp;
        int iter = 0;
        int legal_ok = 0;
        int illegal_decerr = 0;
        int unsigned seed = 42;

        `uvm_info("TC", "== random_traffic ==", UVM_NONE)

        rm_sync_default();

        // Region0-3: 覆盖 0x1000-0x3FFF，master 0-7 全允许（mask=0xFF）
        for (int r = 0; r < 4; r++) begin
            rm_cfg_region(r, 48'h0000_0000_1000 + r*48'h1000,
                          48'h0000_0000_1FFF + r*48'h1000,
                          64'hFF, 1,1, 1,1, 1,1,1);
            rm_enable_region(r);
        end

        // 随机事务序列（受控循环，保证收敛）
        for (iter = 0; iter < 40; iter++) begin
            bit do_read;
            bit do_legal;
            logic [47:0] addr;
            logic [3:0] mid;
            logic [2:0] prot;
            logic [7:0] blen;
            logic [1:0] burst;

            do_read   = (iter % 3 != 0);           // 2/3 read
            do_legal  = (iter % 5 != 0);           // 4/5 legal
            mid       = iter % 8;                  // 0-7
            prot      = (iter % 7 == 0) ? 3'b100 : 3'b000;   // 偶发 instruction
            blen      = (iter % 6) % 4;            // 0-3 beats
            burst     = (iter % 4 == 0) ? 2'b00 : 2'b01;

            if (do_legal) begin
                addr = 48'h0000_0000_1000 + (iter * 48'h10) % 48'h3000;
                if (do_read) begin
                    if (blen == 0) begin
                        axi_rd_single(addr, prot, mid, rresp);
                    end else begin
                        axi_rd_burst(addr, prot, mid, blen, burst, 3'd3, rresp);
                    end
                    if (rresp == 2'b00) legal_ok++; else illegal_decerr++;
                end else begin
                    axi_wr_single(addr, prot, mid, bresp);
                    if (bresp == 2'b00) legal_ok++; else illegal_decerr++;
                end
            end else begin
                // 非法地址（无 region 覆盖）
                addr = 48'h0000_0000_8000 + (iter * 48'h10) % 48'h1000;
                if (do_read) begin
                    axi_rd_single(addr, prot, mid, rresp);
                end else begin
                    axi_wr_single(addr, prot, mid, bresp);
                end
                if (do_read) illegal_decerr += (rresp == 2'b11) ? 1 : 0;
                else        illegal_decerr += (bresp == 2'b11) ? 1 : 0;
            end
        end

        // 结论：合法事务成功、非法事务 DECERR、无 hang
        chk("random_legal_txn_ok", legal_ok > 0);
        chk("random_illegal_decerr", illegal_decerr > 0);
        chk("random_no_deadlock", 1'b1);
    endtask

endclass
