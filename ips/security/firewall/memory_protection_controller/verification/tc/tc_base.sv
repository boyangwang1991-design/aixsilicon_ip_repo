// ============================================================================
// AXI MPU - UVM Base Testcase
// ============================================================================
// 提供：
//  - env 句柄（rm/checker/fcov）与 vif
//  - APB 读写任务（驱动 CSR）
//  - AXI read/write 任务（单 beat / burst）
//  - RM 配置同步辅助
//  - 结果汇总（PASS/FAIL 统计 + UVM_ERROR 上报 + TEST_DONE）
// 所有 testcase 继承本类并实现 run_testcase()。
// ============================================================================

`ifndef TC_BASE_SV
`define TC_BASE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import axi_mpu_env_pkg::*;

class tc_base extends uvm_test;

    `uvm_component_utils(tc_base)

    axi_mpu_env env;
    virtual axi_mpu_if vif;

    int unsigned npass = 0;
    int unsigned nfail = 0;

    function new(string name = "tc_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_mpu_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual axi_mpu_if)::get(this, "", "vif", vif))
            `uvm_fatal("TC_BASE", "vif not found")
    endfunction

    // --------------------------------------------------------------------------
    // 检查辅助
    // --------------------------------------------------------------------------
    function void chk(string name, bit cond);
        if (cond) begin
            npass++;
            `uvm_info("CHK", $sformatf("PASS: %s", name), UVM_NONE)
        end else begin
            nfail++;
            `uvm_error("CHK", $sformatf("FAIL: %s", name))
        end
    endfunction

    // --------------------------------------------------------------------------
    // APB 读写任务
    // --------------------------------------------------------------------------
    // 所有激励在 negedge 驱动（避免与 RTL posedge 采样的竞态）
    task automatic apb_wr(input logic [31:0] addr, input logic [31:0] data);
        @(negedge vif.clk);
        vif.s_apb_psel   = 1;
        vif.s_apb_pwrite = 1;
        vif.s_apb_penable = 0;
        vif.s_apb_paddr  = addr;
        vif.s_apb_pwdata = data;
        vif.s_apb_pstrb  = 4'hF;
        @(negedge vif.clk);
        vif.s_apb_penable = 1;
        do @(negedge vif.clk); while (!vif.s_apb_pready);
        @(negedge vif.clk);
        vif.s_apb_psel = 0;
        vif.s_apb_penable = 0;
    endtask

    task automatic apb_rd(input logic [31:0] addr, output logic [31:0] data);
        @(negedge vif.clk);
        vif.s_apb_psel   = 1;
        vif.s_apb_pwrite = 0;
        vif.s_apb_penable = 0;
        vif.s_apb_paddr  = addr;
        @(negedge vif.clk);
        vif.s_apb_penable = 1;
        do @(negedge vif.clk); while (!vif.s_apb_pready);
        data = vif.s_apb_prdata;
        @(negedge vif.clk);
        vif.s_apb_psel = 0;
        vif.s_apb_penable = 0;
    endtask

    // --------------------------------------------------------------------------
    // AXI read 任务（len=0 单 beat；返回 RRESP）
    // --------------------------------------------------------------------------
    task automatic axi_rd_single(
        input  logic [47:0] addr,
        input  logic [2:0]  prot,
        input  logic [3:0]  master_id,
        output logic [1:0]  resp
    );
        // 竞态免役驱动：sideband 与 valid 在 negedge 设置，ready 在 posedge 检查
        vif.s_axi_arid = 8'h01;
        vif.s_axi_araddr = addr;
        vif.s_axi_arlen = 8'd0;
        vif.s_axi_arsize = 3'd3;
        vif.s_axi_arburst = 2'b01;
        vif.s_axi_arprot = prot;
        vif.s_axi_ar_master_id = master_id;
        @(negedge vif.clk);
        vif.s_axi_arvalid = 1;
        // rready 在 run_phase 复位释放后恒 1（防 LOCAL_R 残留与跨事务误配）
        // 等 DUT 在 posedge 采样并 accept（arready 仅在 IDLE 为 1，一个 negedge 后必然已完成）
        @(posedge vif.clk);
        @(negedge vif.clk);
        vif.s_axi_arvalid = 0;
        resp = 2'b00;
        // 事务以 RLAST 收尾。在 negedge 采样（握手发生于 posedge，negedge 时
        // state/rvalid 尚未因 NBA 更新而失效），避免同拍退出导致的 beat 丢失。
        while (1) begin
            @(posedge vif.clk);
            if (vif.s_axi_rvalid && vif.s_axi_rready) begin
                resp = vif.s_axi_rresp;
                if (vif.s_axi_rlast) begin
                    break;
                end
            end
        end
    endtask

    // AXI read burst（len 拍；返回首个 RRESP）
    task automatic axi_rd_burst(
        input  logic [47:0] addr,
        input  logic [2:0]  prot,
        input  logic [3:0]  master_id,
        input  logic [7:0]  len,
        input  logic [1:0]  burst,
        input  logic [2:0]  size,
        output logic [1:0]  resp
    );
        vif.s_axi_arid = 8'h05;
        vif.s_axi_araddr = addr;
        vif.s_axi_arlen = len;
        vif.s_axi_arsize = size;
        vif.s_axi_arburst = burst;
        vif.s_axi_arprot = prot;
        vif.s_axi_ar_master_id = master_id;
        @(negedge vif.clk);
        vif.s_axi_arvalid = 1;
        @(posedge vif.clk);
        @(negedge vif.clk);
        vif.s_axi_arvalid = 0;
        resp = 2'b00;
        while (1) begin
            @(posedge vif.clk);
            if (vif.s_axi_rvalid && vif.s_axi_rready) begin
                resp = vif.s_axi_rresp;
                if (vif.s_axi_rlast) break;
            end
        end
    endtask

    // --------------------------------------------------------------------------
    // AXI write 任务（len=0 单 beat；返回 BRESP）
    // --------------------------------------------------------------------------
    task automatic axi_wr_single(
        input  logic [47:0] addr,
        input  logic [2:0]  prot,
        input  logic [3:0]  master_id,
        output logic [1:0]  resp
    );
        vif.s_axi_awid = 8'h02;
        vif.s_axi_awaddr = addr;
        vif.s_axi_awlen = 8'd0;
        vif.s_axi_awsize = 3'd3;
        vif.s_axi_awburst = 2'b01;
        vif.s_axi_awprot = prot;
        vif.s_axi_aw_master_id = master_id;
        @(negedge vif.clk);
        vif.s_axi_awvalid = 1;
        // bready 恒 1（run_phase 中已置）
        @(posedge vif.clk);   // DUT 在此 posedge accept AW
        @(negedge vif.clk);
        vif.s_axi_awvalid = 0;
        vif.s_axi_wid = 8'h02;
        vif.s_axi_wdata = 128'hDEAD_BEEF_1234_5678_CAFE_F00D_0000_ABCD;
        vif.s_axi_wstrb = '1;
        vif.s_axi_wlast = 1;
        vif.s_axi_wvalid = 1;
        // W ready：合法走 FWD_W（等下游），非法走 LOCAL_W（恒 1）；每 posedge 检查
        do @(posedge vif.clk); while (!vif.s_axi_wready);
        @(negedge vif.clk);
        vif.s_axi_wvalid = 0;
        resp = 2'b00;
        while (1) begin
            @(posedge vif.clk);
            if (vif.s_axi_bvalid && vif.s_axi_bready) begin
                resp = vif.s_axi_bresp;
                break;
            end
        end
    endtask

    // --------------------------------------------------------------------------
    // RM 配置同步辅助
    // --------------------------------------------------------------------------
    task automatic rm_sync_default();
        env.rm.reset_cfg();
        env.rm.region_num = 16;
        env.rm.master_num = 8;
        // 默认所有 master 具 Secure+Non-secure capability
        for (int m = 0; m < 8; m++) begin
            env.rm.master_attr[m].secure_capable = 1;
            env.rm.master_attr[m].nonsecure_capable = 1;
        end
        // 通过 APB 配置 MASTER_ATTR
        for (int m = 0; m < 8; m++) begin
            apb_wr(32'h100 + m*4, 32'h3);   // secure_capable | nonsecure_capable
        end
    endtask

    task automatic rm_cfg_region(
        input int idx,
        input logic [63:0] base,
        input logic [63:0] limit,
        input logic [63:0] mask,
        input bit secure_allow, input bit nonsecure_allow,
        input bit priv_allow,   input bit unpriv_allow,
        input bit read_allow,   input bit write_allow, input bit exec_allow
    );
        logic [31:0] lo, hi;
        env.rm.regions[idx].enable = 1;
        env.rm.regions[idx].base   = base;
        env.rm.regions[idx].limit  = limit;
        env.rm.regions[idx].master_mask = mask;
        env.rm.regions[idx].secure_allow = secure_allow;
        env.rm.regions[idx].nonsecure_allow = nonsecure_allow;
        env.rm.regions[idx].priv_allow = priv_allow;
        env.rm.regions[idx].unpriv_allow = unpriv_allow;
        env.rm.regions[idx].read_allow = read_allow;
        env.rm.regions[idx].write_allow = write_allow;
        env.rm.regions[idx].exec_allow = exec_allow;
        lo = base[31:0]; hi = base[63:32];
        apb_wr(ADDR_REGION0_BASE_HI + idx*ADDR_REGION_STRIDE, hi);
        apb_wr(ADDR_REGION0_BASE_LO + idx*ADDR_REGION_STRIDE, lo);
        lo = limit[31:0]; hi = limit[63:32];
        apb_wr(ADDR_REGION0_LIMIT_HI + idx*ADDR_REGION_STRIDE, hi);
        apb_wr(ADDR_REGION0_LIMIT_LO + idx*ADDR_REGION_STRIDE, lo);
        apb_wr(ADDR_REGION0_MASK + idx*ADDR_REGION_STRIDE, mask[31:0]);
        apb_wr(ADDR_REGION0_PERM + idx*ADDR_REGION_STRIDE,
               {exec_allow, write_allow, read_allow, unpriv_allow, priv_allow,
                nonsecure_allow, secure_allow});
    endtask

    task automatic rm_enable_region(input int idx);
        env.rm.regions[idx].enable = 1;
        apb_wr(ADDR_REGION0_CTRL + idx*ADDR_REGION_STRIDE, 32'h1); // enable
    endtask

    // --------------------------------------------------------------------------
    // run_phase：UVM 握手 + 调用具体 testcase 逻辑 + 结果汇总
    // --------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        // 等待复位释放
        do @(posedge vif.clk); while (!vif.arst_n);

        // 响应 ready 恒 1（rready/bready 全程有效，避免 LOCAL_R 残留与跨事务误配）
        vif.s_axi_rready = 1;
        vif.s_axi_bready = 1;

        run_testcase();

        if (nfail == 0) begin
            `uvm_info("TC", $sformatf("%s: ALL PASS (%0d checks)", get_type_name(), npass), UVM_NONE)
        end else begin
            `uvm_error("TC", $sformatf("%s: %0d FAIL / %0d PASS", get_type_name(), nfail, npass))
        end

        `uvm_info("TC", "TEST_DONE", UVM_NONE)
        `uvm_info("TC", $sformatf("SUMMARY: PASS=%0d FAIL=%0d", npass, nfail), UVM_NONE)
        phase.drop_objection(this);
    endtask

    // 子类实现
    virtual task run_testcase();
        `uvm_error("TC_BASE", "run_testcase() not implemented")
    endtask

endclass

`endif // TC_BASE_SV
