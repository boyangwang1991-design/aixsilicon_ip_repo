// =============================================================================
// ut_rsp_mgr.sv - x2p_rsp_mgr（读组装 / 写聚合）unit test
// 验证：
//   - 读：2×APB32 → 1×AXI64 组装（lane 按 rsp_sub 摆放），rlast/rresp
//   - 窄读：仅低 32bit 有效，高 lane 必须为 0（回归 BUG-004）
//   - 多 beat 读连续输出
//   - 写：txn_last 聚合出 B，bid/bresp OKAY
//   - 错误：读子传输出错 → rresp SLVERR；写子传输出错 → bresp SLVERR
// =============================================================================
`timescale 1ns/1ps

module ut_rsp_mgr;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic rsp_valid, rsp_ready, rsp_write;
  logic [31:0] rsp_data;
  logic rsp_error;
  logic [3:0] rsp_id;
  logic [3:0] rsp_sub;
  logic rsp_beat_last, rsp_txn_last;

  logic rvalid, rready;
  logic [63:0] rdata;
  logic [1:0] rresp;
  logic [3:0] rid;
  logic rlast;

  logic bvalid, bready;
  logic [1:0] bresp;
  logic [3:0] bid;

  x2p_rsp_mgr #(.AXI_DATA_WIDTH(64), .AXI_ID_WIDTH(4), .APB_DATA_WIDTH(32)) dut (
    .clk(clk), .rst_n(rst_n),
    .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_write(rsp_write),
    .rsp_data(rsp_data), .rsp_error(rsp_error), .rsp_id(rsp_id),
    .rsp_sub(rsp_sub), .rsp_beat_last(rsp_beat_last), .rsp_txn_last(rsp_txn_last),
    .rvalid(rvalid), .rready(rready), .rdata(rdata), .rresp(rresp),
    .rid(rid), .rlast(rlast),
    .bvalid(bvalid), .bready(bready), .bresp(bresp), .bid(bid)
  );

  int errors = 0;

  task automatic chk32(logic [31:0] a, logic [31:0] b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b);
      errors++;
    end
  endtask
  task automatic chk64(logic [63:0] a, logic [63:0] b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b);
      errors++;
    end
  endtask
  task automatic chk(logic a, logic b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got %0b exp %0b)", msg, a, b);
      errors++;
    end
  endtask

  // 馈入一笔 APB 响应并等待其被 rsp_mgr 接收
  task automatic feed(bit wr, logic [31:0] d, bit [3:0] id, bit [3:0] sub,
                      bit bl, bit tl, bit err);
    int rc;
    @(posedge clk); #1;
    rsp_valid = 1'b1; rsp_write = wr; rsp_data = d; rsp_error = err;
    rsp_id = id; rsp_sub = sub; rsp_beat_last = bl; rsp_txn_last = tl;
    rc = 0;
    while (!rsp_ready && rc < 50) begin @(posedge clk); rc++; end
    if (rc >= 50) begin
      $display("FAIL: feed rsp_ready timeout (sub=%0d)", sub);
      errors++;
    end
    @(posedge clk); #1;
    rsp_valid = 1'b0;
    @(posedge clk);
  endtask

  // 等待 R 输出（返回是否超时）
  task automatic wait_r(output int rc);
    rc = 0;
    while (!rvalid && rc < 50) begin @(posedge clk); rc++; end
  endtask

  // 等待 B 输出
  task automatic wait_b(output int rc);
    rc = 0;
    while (!bvalid && rc < 50) begin @(posedge clk); rc++; end
  endtask

  initial begin
    int rc;
    rsp_valid=0; rsp_write=0; rsp_data=0; rsp_error=0; rsp_id=0; rsp_sub=0;
    rsp_beat_last=0; rsp_txn_last=0;
    rready=1'b1; bready=1'b1;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    // === 读：2 sub 组装 ===
    feed(0, 32'h1111_1111, 4'h1, 4'd0, 1'b0, 1'b0, 1'b0);  // sub0, low
    feed(0, 32'h2222_2222, 4'h1, 4'd1, 1'b1, 1'b1, 1'b0);  // sub1, high, beat_last
    wait_r(rc);
    chk(rvalid, 1'b1, "read rvalid");
    chk64(rdata, 64'h2222_2222_1111_1111, "read assembled rdata");
    chk(rlast, 1'b1, "read rlast");
    chk(rresp, 2'b00, "read rresp OKAY");
    chk(rid, 4'h1, "read rid");
    @(posedge clk);  // 让 rvalid 让行
    @(posedge clk);

    // === 窄读：只有 sub0（4B），高 32bit 必须为 0（BUG-004 回归）===
    // 先灌一个 8B 读建立"陈旧高 lane"
    feed(0, 32'hAAAA_0000, 4'h2, 4'd0, 1'b0, 1'b0, 1'b0);
    feed(0, 32'hBBBB_0000, 4'h2, 4'd1, 1'b1, 1'b1, 1'b0);
    wait_r(rc); @(posedge clk); @(posedge clk);
    // 再灌窄读（仅 sub0，beat_last=1）
    feed(0, 32'hCCCC_DDDD, 4'h3, 4'd0, 1'b1, 1'b1, 1'b0);
    wait_r(rc);
    chk64(rdata, 64'h0000_0000_CCCC_DDDD, "narrow read high lane zero");
    @(posedge clk); @(posedge clk);

    // === 写：txn_last → B OKAY ===
    feed(1, 32'h0, 4'h5, 4'd0, 1'b1, 1'b1, 1'b0);
    wait_b(rc);
    chk(bvalid, 1'b1, "write bvalid");
    chk(bresp, 2'b00, "write bresp OKAY");
    chk(bid, 4'h5, "write bid");
    @(posedge clk); @(posedge clk);

    // === 读错误聚合：一个 sub SLVERR → R 整 beat SLVERR ===
    feed(0, 32'hDEAD_0000, 4'h6, 4'd0, 1'b0, 1'b0, 1'b1);  // sub0 error
    feed(0, 32'hBEEF_0000, 4'h6, 4'd1, 1'b1, 1'b1, 1'b0);  // sub1 ok
    wait_r(rc);
    chk(rresp, 2'b10, "read rresp SLVERR on sub error");
    @(posedge clk); @(posedge clk);

    // === 写错误聚合：任一 sub SLVERR → B SLVERR ===
    feed(1, 32'h0, 4'h7, 4'd0, 1'b1, 1'b1, 1'b1);  // write sub error
    wait_b(rc);
    chk(bresp, 2'b10, "write bresp SLVERR on sub error");
    @(posedge clk); @(posedge clk);

    #30;
    if (errors == 0) $display("UT_RSP_MGR: PASS (errors=0)");
    else             $display("UT_RSP_MGR: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
