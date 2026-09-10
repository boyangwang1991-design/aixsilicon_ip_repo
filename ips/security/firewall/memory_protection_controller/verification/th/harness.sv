// ============================================================================
// AXI MPU - UVM Harness (Top)
// ============================================================================
// 生成时钟/复位；实例化 axi_mpu_if 与 DUT；配置下游 M_AXI slave 响应模型
// （合法事务回 OKAY，支持 backpressure）；通过 uvm_config_db 下发虚接口并
// 启动 run_test()。
// ============================================================================

`timescale 1ns/1ps

module harness;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int ADDR_WIDTH      = 48;
    localparam int DATA_WIDTH      = 128;
    localparam int ID_WIDTH        = 8;
    localparam int MASTER_NUM      = 8;
    localparam int MASTER_ID_WIDTH = 4;
    localparam int REGION_NUM      = 16;

    logic clk = 0;
    // arst_n 在 axi_mpu_if 内部声明（procedural 驱动：默认序列在 harness，
    // TC 级复位控制在 tc_reset_behavior/tc_config_lock）。

    // --------------------------------------------------------------------------
    // 虚接口
    // --------------------------------------------------------------------------
    axi_mpu_if #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH), .MASTER_ID_WIDTH(MASTER_ID_WIDTH)
    ) u_if (.clk(clk));

    // --------------------------------------------------------------------------
    // DUT
    // --------------------------------------------------------------------------
    axi_mpu #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ID_WIDTH(ID_WIDTH),
        .MASTER_NUM(MASTER_NUM), .MASTER_ID_WIDTH(MASTER_ID_WIDTH),
        .REGION_NUM(REGION_NUM),
        .READ_OUTSTANDING(8), .WRITE_OUTSTANDING(8),
        .HAS_EXECUTE(1), .HAS_MASTER_ATTR(1), .HAS_IRQ(1),
        .HAS_VIOLATION_LOG(1), .PIPELINE(0), .WRAP_SUPPORT(1)
    ) u_dut (
        .clk(clk), .arst_n(u_if.arst_n),
        .s_axi_arid(u_if.s_axi_arid), .s_axi_araddr(u_if.s_axi_araddr),
        .s_axi_arlen(u_if.s_axi_arlen), .s_axi_arsize(u_if.s_axi_arsize),
        .s_axi_arburst(u_if.s_axi_arburst), .s_axi_arprot(u_if.s_axi_arprot),
        .s_axi_arvalid(u_if.s_axi_arvalid), .s_axi_arready(u_if.s_axi_arready),
        .s_axi_rid(u_if.s_axi_rid), .s_axi_rdata(u_if.s_axi_rdata),
        .s_axi_rresp(u_if.s_axi_rresp), .s_axi_rlast(u_if.s_axi_rlast),
        .s_axi_rvalid(u_if.s_axi_rvalid), .s_axi_rready(u_if.s_axi_rready),
        .s_axi_awid(u_if.s_axi_awid), .s_axi_awaddr(u_if.s_axi_awaddr),
        .s_axi_awlen(u_if.s_axi_awlen), .s_axi_awsize(u_if.s_axi_awsize),
        .s_axi_awburst(u_if.s_axi_awburst), .s_axi_awprot(u_if.s_axi_awprot),
        .s_axi_awvalid(u_if.s_axi_awvalid), .s_axi_awready(u_if.s_axi_awready),
        .s_axi_wid(u_if.s_axi_wid), .s_axi_wdata(u_if.s_axi_wdata),
        .s_axi_wstrb(u_if.s_axi_wstrb), .s_axi_wlast(u_if.s_axi_wlast),
        .s_axi_wvalid(u_if.s_axi_wvalid), .s_axi_wready(u_if.s_axi_wready),
        .s_axi_bid(u_if.s_axi_bid), .s_axi_bresp(u_if.s_axi_bresp),
        .s_axi_bvalid(u_if.s_axi_bvalid), .s_axi_bready(u_if.s_axi_bready),
        .m_axi_arid(u_if.m_axi_arid), .m_axi_araddr(u_if.m_axi_araddr),
        .m_axi_arlen(u_if.m_axi_arlen), .m_axi_arsize(u_if.m_axi_arsize),
        .m_axi_arburst(u_if.m_axi_arburst), .m_axi_arprot(u_if.m_axi_arprot),
        .m_axi_arvalid(u_if.m_axi_arvalid), .m_axi_arready(u_if.m_axi_arready),
        .m_axi_rid(u_if.m_axi_rid), .m_axi_rdata(u_if.m_axi_rdata),
        .m_axi_rresp(u_if.m_axi_rresp), .m_axi_rlast(u_if.m_axi_rlast),
        .m_axi_rvalid(u_if.m_axi_rvalid), .m_axi_rready(u_if.m_axi_rready),
        .m_axi_awid(u_if.m_axi_awid), .m_axi_awaddr(u_if.m_axi_awaddr),
        .m_axi_awlen(u_if.m_axi_awlen), .m_axi_awsize(u_if.m_axi_awsize),
        .m_axi_awburst(u_if.m_axi_awburst), .m_axi_awprot(u_if.m_axi_awprot),
        .m_axi_awvalid(u_if.m_axi_awvalid), .m_axi_awready(u_if.m_axi_awready),
        .m_axi_wid(u_if.m_axi_wid), .m_axi_wdata(u_if.m_axi_wdata),
        .m_axi_wstrb(u_if.m_axi_wstrb), .m_axi_wlast(u_if.m_axi_wlast),
        .m_axi_wvalid(u_if.m_axi_wvalid), .m_axi_wready(u_if.m_axi_wready),
        .m_axi_bid(u_if.m_axi_bid), .m_axi_bresp(u_if.m_axi_bresp),
        .m_axi_bvalid(u_if.m_axi_bvalid), .m_axi_bready(u_if.m_axi_bready),
        .s_apb_psel(u_if.s_apb_psel), .s_apb_penable(u_if.s_apb_penable),
        .s_apb_pwrite(u_if.s_apb_pwrite), .s_apb_pprot(u_if.s_apb_pprot),
        .s_apb_paddr(u_if.s_apb_paddr), .s_apb_pwdata(u_if.s_apb_pwdata),
        .s_apb_pstrb(u_if.s_apb_pstrb), .s_apb_pready(u_if.s_apb_pready),
        .s_apb_prdata(u_if.s_apb_prdata), .s_apb_pslverr(u_if.s_apb_pslverr),
        .s_axi_ar_master_id(u_if.s_axi_ar_master_id),
        .s_axi_aw_master_id(u_if.s_axi_aw_master_id),
        .irq(u_if.irq)
    );

    // --------------------------------------------------------------------------
    // 下游 M_AXI slave 响应模型（合法事务回 OKAY）
    // 状态：IDLE -> R_ACTIVE / W_ACTIVE
    // --------------------------------------------------------------------------
    // R 响应状态：IDLE -> R_RESP（按 beat 输出，最后一拍带 rlast）
    typedef enum logic [1:0] {
        R_IDLE = 2'd0,
        R_RESP = 2'd1
    } r_slave_state_t;

    logic           slave_ar_pending;
    logic           slave_aw_pending;
    logic [7:0]     slave_r_beat_cnt;
    logic [7:0]     slave_r_len;
    logic [ID_WIDTH-1:0] slave_rid;
    logic [ID_WIDTH-1:0] slave_bid;
    r_slave_state_t rstate;
    logic           r_beat_last;

    // 是否为最后一拍（当前 beat_cnt == r_len）
    assign r_beat_last = (slave_r_beat_cnt >= slave_r_len);

    always_ff @(posedge clk or negedge u_if.arst_n) begin
        if (!u_if.arst_n) begin
            slave_ar_pending <= 0;
            slave_aw_pending <= 0;
            slave_r_beat_cnt <= 0;
            slave_r_len      <= 0;
            slave_rid        <= 0;
            slave_bid        <= 0;
            rstate           <= R_IDLE;
            u_if.m_axi_arready <= 0;
            u_if.m_axi_awready <= 0;
            u_if.m_axi_wready  <= 0;
            u_if.m_axi_rvalid  <= 0;
            u_if.m_axi_rlast   <= 0;
            u_if.m_axi_rresp   <= 2'b00;
            u_if.m_axi_rdata   <= '0;
            u_if.m_axi_rid     <= '0;
            u_if.m_axi_bvalid  <= 0;
            u_if.m_axi_bresp   <= 2'b00;
            u_if.m_axi_bid     <= '0;
        end else begin
            // ---- AR accept (only when R idle) ----
            if (rstate == R_IDLE && u_if.m_axi_arvalid && u_if.m_axi_arready) begin
                rstate        <= R_RESP;
                slave_r_len   <= u_if.m_axi_arlen;
                slave_rid     <= u_if.m_axi_arid;
                slave_r_beat_cnt <= 0;
            end

            // ---- R channel: drive rvalid in R_RESP ----
            case (rstate)
                R_IDLE: begin
                    u_if.m_axi_rvalid <= 1'b0;
                    u_if.m_axi_rlast  <= 1'b0;
                end
                R_RESP: begin
                    u_if.m_axi_rvalid <= 1'b1;
                    u_if.m_axi_rresp  <= 2'b00;
                    u_if.m_axi_rdata  <= '0;
                    u_if.m_axi_rid    <= slave_rid;
                    u_if.m_axi_rlast  <= r_beat_last;
                    if (u_if.m_axi_rvalid && u_if.m_axi_rready) begin
                        if (r_beat_last) begin
                            rstate <= R_IDLE;
                            slave_r_beat_cnt <= 0;
                        end else begin
                            slave_r_beat_cnt <= slave_r_beat_cnt + 1;
                        end
                    end
                end
                default: rstate <= R_IDLE;
            endcase

            // ---- AW accept ----
            if (u_if.m_axi_awvalid && u_if.m_axi_awready) begin
                slave_aw_pending <= 1;
                slave_bid        <= u_if.m_axi_awid;
            end
            // ---- W accept / B response ----
            u_if.m_axi_wready <= slave_aw_pending ? 1'b1 : 1'b0;
            if (u_if.m_axi_wvalid && u_if.m_axi_wready && slave_aw_pending) begin
                if (u_if.m_axi_wlast) begin
                    slave_aw_pending <= 0;
                    u_if.m_axi_bvalid <= 1'b1;
                    u_if.m_axi_bresp  <= 2'b00;
                    u_if.m_axi_bid    <= slave_bid;
                end
            end
            if (u_if.m_axi_bvalid && u_if.m_axi_bready) begin
                u_if.m_axi_bvalid <= 0;
            end
            // ---- ARREADY / AWREADY ----
            // AWREADY 常高：AW 与 W 独立；pending 只控制 WREADY/B 生成。
            // （原实现 pending 拉低 awready 会与 DUT FWD_AW 等待形成死锁）
            u_if.m_axi_arready <= (rstate == R_IDLE) ? 1'b1 : 1'b0;
            u_if.m_axi_awready <= 1'b1;
        end
    end

    // --------------------------------------------------------------------------
    // 时钟 / 复位
    // --------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;   // 10ns 周期（显式 ns 单位，UVM1.2 时间单位陷阱）
    end

    // 默认复位：0 时刻拉低，10 拍后释放（TC 级复位控制经 vif.arst_n 后续接管）。
    initial begin
        u_if.arst_n = 0;
        repeat (10) @(posedge clk);
        u_if.arst_n = 1;
    end

    // --------------------------------------------------------------------------
    // UVM 配置与启动
    // --------------------------------------------------------------------------
    initial begin
        uvm_config_db#(virtual axi_mpu_if)::set(null, "*", "vif", u_if);
        run_test();
    end

    // 超时保护
    initial begin
        #2ms;
        $display("TIMEOUT: harness 2ms elapsed, forcing finish");
        $finish;
    end


endmodule
