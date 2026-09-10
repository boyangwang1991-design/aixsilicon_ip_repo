// ============================================================================
// AXI MPU - Integration Smoke Testbench (directed)
// reset -> APB 配置 Region -> 合法 read/write 转发 -> 非法 DECERR + violation/IRQ
// ============================================================================
`include "axi_mpu_defs.svh"

module tb_axi_mpu_smoke;
    localparam int ADDR_WIDTH = 48;
    localparam int DATA_WIDTH = 128;
    localparam int ID_WIDTH   = 8;
    localparam int MASTER_ID_WIDTH = 4;

    logic clk = 0;
    logic arst_n = 0;

    logic [ID_WIDTH-1:0]      s_axi_arid, s_axi_awid, s_axi_wid;
    logic [ADDR_WIDTH-1:0]    s_axi_araddr, s_axi_awaddr;
    logic [7:0]               s_axi_arlen, s_axi_awlen;
    logic [2:0]               s_axi_arsize, s_axi_awsize;
    logic [1:0]               s_axi_arburst, s_axi_awburst;
    logic [2:0]               s_axi_arprot, s_axi_awprot;
    logic                     s_axi_arvalid, s_axi_awvalid, s_axi_wvalid, s_axi_wlast;
    logic                     s_axi_rready, s_axi_bready;
    logic [DATA_WIDTH-1:0]    s_axi_wdata;
    logic [DATA_WIDTH/8-1:0]  s_axi_wstrb;
    logic [ID_WIDTH-1:0]      s_axi_rid, s_axi_bid;
    logic [DATA_WIDTH-1:0]    s_axi_rdata;
    logic [1:0]               s_axi_rresp, s_axi_bresp;
    logic                     s_axi_rlast, s_axi_rvalid, s_axi_bvalid;
    logic                     s_axi_arready, s_axi_awready, s_axi_wready;

    logic [ID_WIDTH-1:0]      m_axi_arid, m_axi_awid, m_axi_wid;
    logic [ADDR_WIDTH-1:0]    m_axi_araddr, m_axi_awaddr;
    logic [7:0]               m_axi_arlen, m_axi_awlen;
    logic [2:0]               m_axi_arsize, m_axi_awsize;
    logic [1:0]               m_axi_arburst, m_axi_awburst;
    logic [2:0]               m_axi_arprot, m_axi_awprot;
    logic                     m_axi_arvalid, m_axi_awvalid, m_axi_wvalid, m_axi_wlast;
    logic                     m_axi_rready, m_axi_bready;
    logic [DATA_WIDTH-1:0]    m_axi_wdata, m_axi_rdata;
    logic [DATA_WIDTH/8-1:0]  m_axi_wstrb;
    logic [ID_WIDTH-1:0]      m_axi_rid, m_axi_bid;
    logic [1:0]               m_axi_rresp, m_axi_bresp;
    logic                     m_axi_rlast, m_axi_rvalid, m_axi_bvalid;
    logic                     m_axi_arready, m_axi_awready, m_axi_wready;

    logic                     s_apb_psel, s_apb_penable, s_apb_pwrite;
    logic [2:0]               s_apb_pprot;
    logic [ADDR_WIDTH-1:0]    s_apb_paddr;
    logic [31:0]              s_apb_pwdata;
    logic [3:0]               s_apb_pstrb;
    logic                     s_apb_pready;
    logic [31:0]              s_apb_prdata;
    logic                     s_apb_pslverr;

    logic [MASTER_ID_WIDTH-1:0] s_axi_ar_master_id, s_axi_aw_master_id;
    logic                       irq;

    axi_mpu #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ID_WIDTH(ID_WIDTH),
        .MASTER_NUM(8), .MASTER_ID_WIDTH(MASTER_ID_WIDTH), .REGION_NUM(16)
    ) u_dut (
        .clk(clk), .arst_n(arst_n),
        .s_axi_arid(s_axi_arid), .s_axi_araddr(s_axi_araddr),
        .s_axi_arlen(s_axi_arlen), .s_axi_arsize(s_axi_arsize),
        .s_axi_arburst(s_axi_arburst), .s_axi_arprot(s_axi_arprot),
        .s_axi_arvalid(s_axi_arvalid), .s_axi_arready(s_axi_arready),
        .s_axi_rid(s_axi_rid), .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp), .s_axi_rlast(s_axi_rlast),
        .s_axi_rvalid(s_axi_rvalid), .s_axi_rready(s_axi_rready),
        .s_axi_awid(s_axi_awid), .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awlen(s_axi_awlen), .s_axi_awsize(s_axi_awsize),
        .s_axi_awburst(s_axi_awburst), .s_axi_awprot(s_axi_awprot),
        .s_axi_awvalid(s_axi_awvalid), .s_axi_awready(s_axi_awready),
        .s_axi_wid(s_axi_wid), .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb), .s_axi_wlast(s_axi_wlast),
        .s_axi_wvalid(s_axi_wvalid), .s_axi_wready(s_axi_wready),
        .s_axi_bid(s_axi_bid), .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid), .s_axi_bready(s_axi_bready),
        .m_axi_arid(m_axi_arid), .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen), .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst), .m_axi_arprot(m_axi_arprot),
        .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
        .m_axi_rid(m_axi_rid), .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp), .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready),
        .m_axi_awid(m_axi_awid), .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awlen(m_axi_awlen), .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst), .m_axi_awprot(m_axi_awprot),
        .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
        .m_axi_wid(m_axi_wid), .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb), .m_axi_wlast(m_axi_wlast),
        .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
        .m_axi_bid(m_axi_bid), .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
        .s_apb_psel(s_apb_psel), .s_apb_penable(s_apb_penable),
        .s_apb_pwrite(s_apb_pwrite), .s_apb_pprot(s_apb_pprot),
        .s_apb_paddr(s_apb_paddr), .s_apb_pwdata(s_apb_pwdata),
        .s_apb_pstrb(s_apb_pstrb), .s_apb_pready(s_apb_pready),
        .s_apb_prdata(s_apb_prdata), .s_apb_pslverr(s_apb_pslverr),
        .s_axi_ar_master_id(s_axi_ar_master_id),
        .s_axi_aw_master_id(s_axi_aw_master_id),
        .irq(irq)
    );

    always #5 clk = ~clk;

    int errors = 0;
    logic [31:0] rd32;
    logic [1:0]  rresp, bresp;

    task automatic apb_wr(input logic [31:0] addr, input logic [31:0] data);
        @(posedge clk);
        s_apb_psel = 1; s_apb_pwrite = 1; s_apb_penable = 0;
        s_apb_paddr = addr; s_apb_pwdata = data; s_apb_pstrb = 4'hF;
        @(posedge clk); s_apb_penable = 1;
        do @(posedge clk); while (!s_apb_pready);
        @(posedge clk); s_apb_psel = 0; s_apb_penable = 0;
    endtask

    task automatic apb_rd(input logic [31:0] addr, output logic [31:0] data);
        @(posedge clk);
        s_apb_psel = 1; s_apb_pwrite = 0; s_apb_penable = 0;
        s_apb_paddr = addr;
        @(posedge clk); s_apb_penable = 1;
        do @(posedge clk); while (!s_apb_pready);
        data = s_apb_prdata;
        @(posedge clk); s_apb_psel = 0; s_apb_penable = 0;
    endtask

    task automatic axi_rd(input logic [ADDR_WIDTH-1:0] addr, input logic [2:0] prot,
                          output logic [1:0] resp);
        s_axi_arid = 8'h01; s_axi_araddr = addr; s_axi_arlen = 0;
        s_axi_arsize = 3'd3; s_axi_arburst = 2'b01; s_axi_arprot = prot;
        s_axi_arvalid = 1; s_axi_rready = 1;
        do @(posedge clk); while (!s_axi_arready);
        s_axi_arvalid = 0;
        resp = 2'b00;
        while (1) begin
            @(posedge clk);
            if (s_axi_rvalid && s_axi_rready) begin resp = s_axi_rresp; break; end
        end
        s_axi_rready = 0;
    endtask

    task automatic axi_wr(input logic [ADDR_WIDTH-1:0] addr, input logic [2:0] prot,
                          output logic [1:0] resp);
        s_axi_awid = 8'h02; s_axi_awaddr = addr; s_axi_awlen = 0;
        s_axi_awsize = 3'd3; s_axi_awburst = 2'b01; s_axi_awprot = prot;
        s_axi_awvalid = 1; s_axi_bready = 1;
        do @(posedge clk); while (!s_axi_awready);
        s_axi_awvalid = 0;
        s_axi_wid = 8'h02; s_axi_wdata = 128'hDEAD_BEEF; s_axi_wstrb = '1;
        s_axi_wlast = 1; s_axi_wvalid = 1;
        do @(posedge clk); while (!s_axi_wready);
        s_axi_wvalid = 0;
        resp = 2'b00;
        while (1) begin
            @(posedge clk);
            if (s_axi_bvalid && s_axi_bready) begin resp = s_axi_bresp; break; end
        end
        s_axi_bready = 0;
    endtask

    task automatic check(input string name, input logic cond);
        if (cond) $display("PASS: %s", name);
        else begin $display("FAIL: %s", name); errors++; end
    endtask

    initial begin
        s_axi_arvalid=0; s_axi_awvalid=0; s_axi_wvalid=0; s_axi_rready=0; s_axi_bready=0;
        s_apb_psel=0; s_apb_penable=0; s_apb_pwrite=0; s_apb_pprot=0;
        s_apb_paddr=0; s_apb_pwdata=0; s_apb_pstrb=0;
        s_axi_ar_master_id=0; s_axi_aw_master_id=0;
        m_axi_rready=1; m_axi_bready=1;

        repeat (5) @(posedge clk);
        arst_n = 1;
        @(posedge clk);

        // 1. reset 后 Default Deny：read -> DECERR
        axi_rd(48'h0000_0000_1000, 3'b000, rresp);
        check("smoke_default_deny_read_decerr", rresp == 2'b11);

        // 2. APB 配置 Region0 (0x1000-0x1FFF, master0, all allow)
        apb_wr(32'h208, 32'h0);          // REGION0_BASE_HI
        apb_wr(32'h204, 32'h0000_1000);  // REGION0_BASE_LO
        apb_wr(32'h210, 32'h0);          // REGION0_LIMIT_HI
        apb_wr(32'h20C, 32'h0000_1FFF);  // REGION0_LIMIT_LO
        apb_wr(32'h214, 32'h01);         // REGION0_MASTER_MASK (master0)
        apb_wr(32'h218, 32'hFF);         // REGION0_PERMISSION: all allow
        apb_wr(32'h200, 32'h01);         // REGION0_CONTROL.enable=1

        // 3. 合法 read (0x1500) -> OKAY
        axi_rd(48'h0000_0000_1500, 3'b000, rresp);
        check("smoke_legal_read_okay", rresp == 2'b00);

        // 4. 合法 write (0x1600) -> BOKAY
        axi_wr(48'h0000_0000_1600, 3'b000, bresp);
        check("smoke_legal_write_bokay", bresp == 2'b00);

        // 5. 非法 read（master1 不在 mask）-> DECERR
        s_axi_ar_master_id = 1;
        axi_rd(48'h0000_0000_1500, 3'b000, rresp);
        check("smoke_master_deny_decerr", rresp == 2'b11);
        s_axi_ar_master_id = 0;

        // 6. violation 寄存器：VIOL_STATUS.valid
        apb_rd(32'h20, rd32);
        check("smoke_viol_status_valid", rd32[0] == 1'b1);

        // 7. 配置回读：REGION0_BASE_LO == 0x1000
        apb_rd(32'h204, rd32);
        check("smoke_cfg_readback_base", rd32 == 32'h0000_1000);

        if (errors == 0) $display("SMOKE_RESULT: PASS");
        else $display("SMOKE_RESULT: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
