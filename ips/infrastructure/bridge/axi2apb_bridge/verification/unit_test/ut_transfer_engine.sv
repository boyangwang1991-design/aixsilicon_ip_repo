// =============================================================================
// ut_transfer_engine.sv - x2p_transfer_engine（burst→APB 子传输）unit test
// 验证（AXI64→APB32）：
//   - 读单拍 8B → 2 个 APB 子传输，地址/子序号/beat_last/txn_last 正确
//   - 读 2-beat INCR burst → 地址逐拍推进
//   - FIXED burst：同 beat 内两个子传输覆盖 8B（addr, addr+4）
//   - 写单拍（首拍数据 req_wdata；sub_s 数据 = beat_data[s*32 +: 32]）
//   - 写 2-beat burst：后续 beat 数据经 wdata_valid/wdata_ready 交接
// =============================================================================
`timescale 1ns/1ps

module ut_transfer_engine;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic req_valid, req_ready, req_is_write;
  logic [3:0] req_id;
  logic [31:0] req_addr;
  logic [7:0] req_len;
  logic [2:0] req_size;
  logic [1:0] req_burst;
  logic [2:0] req_prot;
  logic [63:0] req_wdata;
  logic [7:0] req_wstrb;
  logic wdata_valid, wdata_ready;
  logic [63:0] wdata;
  logic [7:0] wstrb;

  logic busy, beat_done, txn_done, grant_is_write;

  logic apb_req_valid, apb_req_ready;
  logic [31:0] apb_addr;
  logic apb_write;
  logic [31:0] apb_wdata;
  logic [3:0] apb_strb;
  logic [2:0] apb_prot;
  logic [3:0] apb_id;
  logic [3:0] apb_axi_beat, apb_subbeat;
  logic apb_beat_last, apb_txn_last, apb_error;

  x2p_transfer_engine #(
    .AXI_ADDR_WIDTH(32), .AXI_DATA_WIDTH(64), .AXI_ID_WIDTH(4),
    .APB_ADDR_WIDTH(32), .APB_DATA_WIDTH(32),
    .AXI_PROFILE(1), .APB_PROFILE(1)
  ) dut (
    .clk(clk), .rst_n(rst_n),
    .req_valid(req_valid), .req_ready(req_ready),
    .req_is_write(req_is_write), .req_id(req_id), .req_addr(req_addr),
    .req_len(req_len), .req_size(req_size), .req_burst(req_burst),
    .req_prot(req_prot), .req_wdata(req_wdata), .req_wstrb(req_wstrb),
    .wdata_valid(wdata_valid), .wdata_ready(wdata_ready),
    .wdata(wdata), .wstrb(wstrb),
    .busy(busy), .beat_done(beat_done), .txn_done(txn_done),
    .grant_is_write(grant_is_write),
    .apb_req_valid(apb_req_valid), .apb_req_ready(apb_req_ready),
    .apb_addr(apb_addr), .apb_write(apb_write), .apb_wdata(apb_wdata),
    .apb_strb(apb_strb), .apb_prot(apb_prot), .apb_id(apb_id),
    .apb_axi_beat(apb_axi_beat), .apb_subbeat(apb_subbeat),
    .apb_beat_last(apb_beat_last), .apb_txn_last(apb_txn_last),
    .apb_error(apb_error)
  );

  int errors = 0;

  task automatic chk32(logic [31:0] a, logic [31:0] b, string msg);
    if (a !== b) begin $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b); errors++; end
  endtask
  task automatic chk(logic [3:0] a, logic [3:0] b, string msg);
    if (a !== b) begin $display("FAIL: %s (got %0d exp %0d)", msg, a, b); errors++; end
  endtask
  task automatic chk1(logic a, logic b, string msg);
    if (a !== b) begin $display("FAIL: %s (got %0b exp %0b)", msg, a, b); errors++; end
  endtask

  // 发起一笔事务请求
  task automatic issue(bit is_wr, logic [31:0] addr, bit [7:0] len, bit [2:0] size,
                       bit [1:0] burst, logic [63:0] wd0, logic [7:0] ws0, bit [3:0] id);
    @(posedge clk); #1;
    req_valid <= 1'b1;
    req_is_write <= is_wr; req_id <= id; req_addr <= addr;
    req_len <= len; req_size <= size; req_burst <= burst; req_prot <= 3'b010;
    req_wdata <= wd0; req_wstrb <= ws0;
    do @(posedge clk); while (!req_ready);
    @(posedge clk); #1;
    req_valid <= 1'b0;
  endtask

  // 接受/校验下一个 APB 请求。beat_data 为本 beat 全宽数据；
  // 子传输 s 的数据期望 = beat_data[s*APB_BITS +: APB_BITS]。
  task automatic expect_sub(bit is_wr, logic [31:0] addr, logic [63:0] beat_data,
                            bit [3:0] beat, bit [3:0] sub, bit bl, bit tl);
    logic [31:0] exp_wd;
    int rc = 0;
    while (!apb_req_valid && rc < 50) begin @(posedge clk); rc++; end
    if (rc >= 50) begin $display("FAIL: expect_sub timeout (addr=0x%0h)", addr); errors++; return; end
    chk1(apb_write, is_wr, "apb_write dir");
    chk32(apb_addr, addr, "apb_addr");
    chk(apb_axi_beat, beat, "apb_beat");
    chk(apb_subbeat, sub, "apb_sub");
    chk1(apb_beat_last, bl, "apb_beat_last");
    chk1(apb_txn_last, tl, "apb_txn_last");
    if (is_wr) begin
      exp_wd = beat_data[sub*32 +: 32];
      chk32(apb_wdata, exp_wd, "apb_wdata(sub slice)");
    end
    // 接受
    @(posedge clk); #1;
    apb_req_ready = 1'b1;
    @(posedge clk); #1;
    apb_req_ready = 1'b0;
  endtask

  // 写多拍：TE 拍末进 WAITDATA，提供下一 beat 数据
  task automatic write_beat_data(logic [63:0] d, logic [7:0] s);
    int rc = 0;
    while (!wdata_ready && rc < 50) begin @(posedge clk); rc++; end
    if (rc >= 50) begin $display("FAIL: wdata_ready timeout"); errors++; return; end
    @(posedge clk); #1;
    wdata_valid = 1'b1; wdata = d; wstrb = s;
    do @(posedge clk); while (!(wdata_ready));
    @(posedge clk); #1;
    wdata_valid = 1'b0;
  endtask

  task automatic wait_idle(int limit = 100);
    int rc = 0;
    while (busy && rc < limit) begin @(posedge clk); rc++; end
    if (rc >= limit) begin $display("FAIL: TE stuck busy"); errors++; end
  endtask

  initial begin
    req_valid=0; req_is_write=0; req_id=0; req_addr=0; req_len=0; req_size=0;
    req_burst=0; req_prot=0; req_wdata=0; req_wstrb=0;
    wdata_valid=0; wdata=0; wstrb=0; apb_req_ready=0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    // === 读单拍 8B（2 sub） ===
    issue(0, 32'h1000, 8'd0, 3'd3, 2'b01, 0, 0, 4'h1);
    expect_sub(0, 32'h1000, 64'h0, 0, 0, 1'b0, 1'b0);
    expect_sub(0, 32'h1004, 64'h0, 0, 1, 1'b1, 1'b1);
    wait_idle();
    $display("TE: single read subs ok (errors=%0d)", errors);

    // === 读 2-beat INCR burst（len=1, 8B/beat） ===
    issue(0, 32'h2000, 8'd1, 3'd3, 2'b01, 0, 0, 4'h2);
    expect_sub(0, 32'h2000, 64'h0, 0, 0, 1'b0, 1'b0);
    expect_sub(0, 32'h2004, 64'h0, 0, 1, 1'b1, 1'b0);
    expect_sub(0, 32'h2008, 64'h0, 1, 0, 1'b0, 1'b0);
    expect_sub(0, 32'h200c, 64'h0, 1, 1, 1'b1, 1'b1);
    wait_idle();
    $display("TE: 2-beat read subs ok (errors=%0d)", errors);

    // === FIXED：beat 内两个子传输覆盖 8B（addr, addr+4），各 beat 同址 ===
    issue(0, 32'h3000, 8'd1, 3'd3, 2'b00, 0, 0, 4'h3);
    expect_sub(0, 32'h3000, 64'h0, 0, 0, 1'b0, 1'b0);
    expect_sub(0, 32'h3004, 64'h0, 0, 1, 1'b1, 1'b0);
    expect_sub(0, 32'h3000, 64'h0, 1, 0, 1'b0, 1'b0);
    expect_sub(0, 32'h3004, 64'h0, 1, 1, 1'b1, 1'b1);
    wait_idle();
    $display("TE: FIXED read subs ok (errors=%0d)", errors);

    // === 写单拍 8B（2 sub，首拍数据 req_wdata） ===
    issue(1, 32'h4000, 8'd0, 3'd3, 2'b01, 64'h1122_3344_5566_7788, 8'hFF, 4'h4);
    expect_sub(1, 32'h4000, 64'h1122_3344_5566_7788, 0, 0, 1'b0, 1'b0);
    expect_sub(1, 32'h4004, 64'h1122_3344_5566_7788, 0, 1, 1'b1, 1'b1);
    wait_idle();
    $display("TE: single write subs ok (errors=%0d)", errors);

    // === 写 2-beat INCR burst（后续 beat 数据经 wdata_valid 交接） ===
    issue(1, 32'h5000, 8'd1, 3'd3, 2'b01, 64'hAAAA_BBBB_CCCC_DDDD, 8'hFF, 4'h5);
    expect_sub(1, 32'h5000, 64'hAAAA_BBBB_CCCC_DDDD, 0, 0, 1'b0, 1'b0);
    expect_sub(1, 32'h5004, 64'hAAAA_BBBB_CCCC_DDDD, 0, 1, 1'b1, 1'b0);
    write_beat_data(64'h1111_2222_3333_4444, 8'hFF);
    expect_sub(1, 32'h5008, 64'h1111_2222_3333_4444, 1, 0, 1'b0, 1'b0);
    expect_sub(1, 32'h500c, 64'h1111_2222_3333_4444, 1, 1, 1'b1, 1'b1);
    wait_idle();
    $display("TE: 2-beat write subs ok (errors=%0d)", errors);

    #30;
    if (errors == 0) $display("UT_TRANSFER_ENGINE: PASS (errors=0)");
    else             $display("UT_TRANSFER_ENGINE: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
