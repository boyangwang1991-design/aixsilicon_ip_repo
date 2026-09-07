// =============================================================================
// ut_read_path.sv - X2P 读路径顶层集成 unit test（单时钟 SYNC）
// 验证：AXI 写 → APB 写；AXI 读（单拍/多拍 burst）→ APB 读 → R 通道组装。
// 自检：rdata 与写入数据一致，rresp==OKAY，rlast 正确。
// 所有等待均内联带超时，避免仿真挂死；失败时打印 DUT 关键内部状态。
// =============================================================================
`timescale 1ns/1ps

module ut_read_path;

  logic clk;
  logic rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  // ---- AXI slave 侧 ----
  logic        awvalid, awready;
  logic [3:0]  awid;
  logic [31:0] awaddr;
  logic [7:0]  awlen;
  logic [2:0]  awsize;
  logic [1:0]  awburst;
  logic [2:0]  awprot;
  logic        wvalid, wready;
  logic [63:0] wdata;
  logic [7:0]  wstrb;
  logic        wlast;
  logic        bvalid, bready;
  logic [1:0]  bresp;
  logic [3:0]  bid;
  logic        arvalid, arready;
  logic [3:0]  arid;
  logic [31:0] araddr;
  logic [7:0]  arlen;
  logic [2:0]  arsize;
  logic [1:0]  arburst;
  logic [2:0]  arprot;
  logic        rvalid, rready;
  logic [63:0] rdata;
  logic [1:0]  rresp;
  logic [3:0]  rid;
  logic        rlast;

  // ---- APB master 侧 ----
  logic [31:0] paddr;
  logic        psel, penable, pwrite;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;
  logic [2:0]  pprot;
  logic [31:0] prdata;
  logic        pready, pslverr;

  x2p_top #(
    .AXI_ADDR_WIDTH  (32), .AXI_DATA_WIDTH  (64), .AXI_ID_WIDTH(4),
    .APB_ADDR_WIDTH  (32), .APB_DATA_WIDTH  (32),
    .AXI_PROFILE(1), .APB_PROFILE(1),
    .READ_REQUEST_DEPTH_LOG2 (2), .WRITE_REQUEST_DEPTH_LOG2(2),
    .ARB_POLICY(0), .ARB_GRANULARITY(0),
    .TIMEOUT_ENABLE(1'b1), .TIMEOUT_CYCLES(256),
    .CLOCK_MODE(0), .CDC_REQ_DEPTH_LOG2(2), .CDC_RSP_DEPTH_LOG2(2),
    .AXI_INPUT_REG(1'b0), .AXI_OUTPUT_REG(1'b0), .APB_OUTPUT_REG(1'b0)
  ) dut (
    .aclk(clk), .aresetn(rst_n), .pclk(clk), .presetn(rst_n),
    .awvalid(awvalid), .awready(awready), .awid(awid), .awaddr(awaddr),
    .awlen(awlen), .awsize(awsize), .awburst(awburst), .awprot(awprot),
    .wvalid(wvalid), .wready(wready), .wdata(wdata), .wstrb(wstrb), .wlast(wlast),
    .bvalid(bvalid), .bready(bready), .bresp(bresp), .bid(bid),
    .arvalid(arvalid), .arready(arready), .arid(arid), .araddr(araddr),
    .arlen(arlen), .arsize(arsize), .arburst(arburst), .arprot(arprot),
    .rvalid(rvalid), .rready(rready), .rdata(rdata), .rresp(rresp),
    .rid(rid), .rlast(rlast),
    .paddr(paddr), .psel(psel), .penable(penable), .pwrite(pwrite),
    .pwdata(pwdata), .pstrb(pstrb), .pprot(pprot),
    .prdata(prdata), .pready(pready), .pslverr(pslverr)
  );

  logic [31:0] mem [0:1023];
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pready <= 1'b0; prdata <= '0; pslverr <= 1'b0;
    end else begin
      if (psel && penable) begin
        pready <= 1'b1;
        if (pwrite) begin mem[paddr[11:2]] <= pwdata; prdata <= '0; end
        else            prdata <= mem[paddr[11:2]];
      end else begin
        pready <= 1'b0;
      end
    end
  end

  int errors = 0;

  task automatic dump_dut(string tag);
    $display("DBG[%0t] %s: grd=%0b gwr=%0b busy=%0b te_st=%0d apb_st=%0d apb_v=%0b apb_r=%0b rsp_v=%0b bv=%0b rv=%0b ar_emp=%0b aw_emp=%0b w_emp=%0b rsp_wr=%0b",
             $time, tag,
             dut.grant_rd, dut.grant_wr, dut.sched_busy,
             dut.u_te.state_q, dut.u_apb.state_q,
             dut.apb_req_valid, dut.apb_req_ready,
             dut.rsp_valid_to_mgr, bvalid, rvalid,
             dut.ar_q_empty, dut.aw_q_empty, dut.w_q_empty,
             dut.rsp_write_mgr);
  endtask

  // 写一笔（len+1 beat × 8B，INCR）
  task automatic axi_write(bit [31:0] addr, logic [63:0] q[$], bit [3:0] id);
    int beats = q.size();
    int rc;
    @(posedge clk);
    awvalid <= 1'b1; awid <= id; awaddr <= addr;
    awlen  <= beats-1; awsize <= 3'd3; awburst <= 2'b01; awprot <= 3'b010;
    rc = 0;
    do @(posedge clk); while (!awready && ++rc < 200);
    awvalid <= 1'b0;
    if (rc >= 200) begin $display("FAIL: awready timeout"); errors++; return; end
    for (int i = 0; i < beats; i++) begin
      @(posedge clk);
      wvalid <= 1'b1; wdata <= q[i]; wstrb <= 8'hFF; wlast <= (i == beats-1);
      rc = 0;
      do @(posedge clk); while (!wready && ++rc < 200);
      wvalid <= 1'b0;
      if (rc >= 200) begin $display("FAIL: wready timeout (beat=%0d)", i); errors++; return; end
    end
    wlast <= 1'b0;
    rc = 0;
    while (!bvalid && rc < 5000) begin @(posedge clk); rc++; end
    if (rc >= 5000) begin
      $display("FAIL: write B TIMEOUT (addr=0x%0h)", addr);
      dump_dut("writeB-timeout"); errors++; return;
    end
    if (bresp !== 2'b00) begin $display("FAIL: B bresp=0x%0h (expect OKAY)", bresp); errors++; end
    if (bid !== id)    begin $display("FAIL: B bid=0x%0h (expect 0x%0h)", bid, id); errors++; end
    @(posedge clk);
  endtask

  // 读一笔（len+1 beat × 8B，INCR），逐 beat 校验
  task automatic axi_read(bit [31:0] addr, int beats, logic [63:0] q[$], bit [3:0] id);
    int rc;
    @(posedge clk);
    arvalid <= 1'b1; arid <= id; araddr <= addr;
    arlen  <= beats-1; arsize <= 3'd3; arburst <= 2'b01; arprot <= 3'b010;
    rc = 0;
    do @(posedge clk); while (!arready && ++rc < 200);
    arvalid <= 1'b0;
    if (rc >= 200) begin $display("FAIL: arready timeout"); errors++; return; end
    for (int i = 0; i < beats; i++) begin
      rc = 0;
      while (!rvalid && rc < 5000) begin @(posedge clk); rc++; end
      if (rc >= 5000) begin
        $display("FAIL: read R TIMEOUT (addr=0x%0h beat=%0d)", addr, i);
        dump_dut("readR-timeout"); errors++; return;
      end
      if (rdata !== q[i])  $display("FAIL: rdata=0x%0h (expect 0x%0h, beat=%0d)", rdata, q[i], i);
      if (rresp !== 2'b00) $display("FAIL: rresp=0x%0h (expect OKAY, beat=%0d)", rresp, i);
      if (rid !== id)      $display("FAIL: rid=0x%0h (expect 0x%0h, beat=%0d)", rid, id, i);
      if (rlast !== (i == beats-1)) $display("FAIL: rlast=%0b (expect %0b, beat=%0d)", rlast, (i==beats-1), i);
      @(posedge clk);
    end
  endtask

  initial begin
    logic [63:0] wq[$];
    logic [63:0] rq[$];
    rst_n = 1'b0;
    awvalid=0; wvalid=0; arvalid=0; bready=1; rready=1;
    awid=0; awaddr=0; awlen=0; awsize=0; awburst=0; awprot=0;
    wdata=0; wstrb=0; wlast=0;
    arid=0; araddr=0; arlen=0; arsize=0; arburst=0; arprot=0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    wq = '{64'hDEAD_BEEF_CAFE_F00D};
    rq = '{64'hDEAD_BEEF_CAFE_F00D};
    axi_write(32'h1000, wq, 4'h1);
    axi_read (32'h1000, 1, rq, 4'h1);
    $display("TEST1 single 8B write/read done (errors=%0d)", errors);

    wq = '{64'h0000_0001_0000_0001,
           64'h0000_0002_0000_0002,
           64'h0000_0003_0000_0003,
           64'h0000_0004_0000_0004};
    rq = wq;
    axi_write(32'h2000, wq, 4'h2);
    axi_read (32'h2000, 4, rq, 4'h2);
    $display("TEST2 burst 4x8B write/read done (errors=%0d)", errors);

    wq = '{64'hAAAA_BBBB_CCCC_DDDD};
    axi_write(32'h3000, wq, 4'h3);
    begin
      int rc;
      @(posedge clk);
      arvalid <= 1'b1; arid <= 4'h3; araddr <= 32'h3000;
      arlen  <= 8'd0; arsize <= 3'd2; arburst <= 2'b01; arprot <= 3'b010;
      rc = 0;
      do @(posedge clk); while (!arready && ++rc < 200);
      arvalid <= 1'b0;
      rc = 0;
      while (!rvalid && rc < 5000) begin @(posedge clk); rc++; end
      if (rc >= 5000) begin
        $display("FAIL: narrow read R TIMEOUT");
        dump_dut("narrow-read-timeout"); errors++;
      end else begin
        if (rdata !== 64'h0000_0000_CCCC_DDDD) begin
          $display("FAIL: narrow rdata=0x%0h (expect 0x%0h)", rdata, 64'h0000_0000_CCCC_DDDD);
          errors++;
        end
        @(posedge clk);
      end
    end
    $display("TEST3 narrow 4B read done (errors=%0d)", errors);

    #100;
    if (errors == 0) $display("UT_READ_PATH: PASS (errors=0)");
    else             $display("UT_READ_PATH: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
