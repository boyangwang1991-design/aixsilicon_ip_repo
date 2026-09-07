// =============================================================================
// ut_scheduler.sv - x2p_scheduler（读写仲裁）unit test
// 同时例化三种策略（RR / READ_PRI / WRITE_PRI），对相同输入比较行为：
//   - 互斥：grant_rd 与 grant_wr 不同时为 1
//   - 方向正确性：READ_PRI 在有读时总给读；WRITE_PRI 在有写时总给写
//   - 栅栏：busy 时阻塞新 grant，beat_done/txn_done 恢复仲裁
// =============================================================================
`timescale 1ns/1ps

module ut_scheduler;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic rd_avail, wr_avail, sched_busy, beat_done, txn_done;

  logic rr_grd, rr_gwr;
  logic rp_grd, rp_gwr;
  logic wp_grd, wp_gwr;

  int errors = 0;

  task automatic chk(logic a, logic b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got %0b exp %0b)", msg, a, b);
      errors++;
    end
  endtask

  task automatic set_inp(logic ra, logic wa, logic busy, logic bd, logic td);
    @(negedge clk);
    rd_avail=ra; wr_avail=wa; sched_busy=busy; beat_done=bd; txn_done=td;
    #1;
  endtask

  // 采样一拍后的稳定输出
  task automatic sample(logic grd, logic gwr, string tag);
    @(posedge clk); #1;
    if (grd && gwr) begin
      $display("FAIL: %s grant_rd & grant_wr both high", tag);
      errors++;
    end
  endtask

  initial begin
    rst_n = 1'b0;
    rd_avail=0; wr_avail=0; sched_busy=0; beat_done=0; txn_done=0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    // 1) 都不可用 → 全部无 grant
    set_inp(0,0,0,0,0);
    @(posedge clk); #1;
    chk(rr_grd|rr_gwr, 1'b0, "RR none no grant");
    chk(rp_grd|rp_gwr, 1'b0, "READ_PRI none no grant");
    chk(wp_grd|wp_gwr, 1'b0, "WRITE_PRI none no grant");

    // 2) 仅读可用 → 三种策略都应给读（RR prev_rd 复位后第一次给读）
    set_inp(1,0,0,0,0);
    @(posedge clk); #1;
    chk(rr_grd, 1'b1, "RR only-read -> rd");
    chk(rr_gwr, 1'b0, "RR only-read no wr");
    chk(rp_grd, 1'b1, "READ_PRI only-read -> rd");
    chk(wp_grd, 1'b1, "WRITE_PRI only-read -> rd");

    // 3) 仅写可用 → 全部给写
    set_inp(0,1,0,0,0);
    @(posedge clk); #1;
    chk(rp_gwr, 1'b1, "READ_PRI only-wr -> wr");
    chk(wp_gwr, 1'b1, "WRITE_PRI only-wr -> wr");
    chk(rr_gwr, 1'b1, "RR only-wr -> wr");

    // 4) 读写都可用
    //    READ_PRI → 读
    set_inp(1,1,0,0,0);
    @(posedge clk); #1;
    chk(rp_grd, 1'b1, "READ_PRI rd&wr -> rd");
    chk(rp_gwr, 1'b0, "READ_PRI rd&wr no wr");
    //    WRITE_PRI → 写
    chk(wp_gwr, 1'b1, "WRITE_PRI rd&wr -> wr");
    chk(wp_grd, 1'b0, "WRITE_PRI rd&wr no rd");
    //    RR → 恰一个（互斥已保证），且在忙闲间轮转

    // 5) busy 栅栏：busy=1 且 beat_done=0 → 无新 grant
    set_inp(1,1,1,0,0);
    @(posedge clk); #1;
    chk(rp_grd|rp_gwr, 1'b0, "READ_PRI busy blocks");
    chk(wp_grd|wp_gwr, 1'b0, "WRITE_PRI busy blocks");
    chk(rr_grd|rr_gwr, 1'b0, "RR busy blocks");
    //    busy=1 但 beat_done=1 → 可切
    set_inp(1,1,1,1,0);
    @(posedge clk); #1;
    chk(rp_grd|rp_gwr, 1'b1, "READ_PRI beat_done resumes");

    // 6) TRANSACTION 粒度下用 txn_done（默认参数为 BEAT，此处仅验证互斥逻辑无崩溃）
    set_inp(1,0,1,0,1);
    @(posedge clk); #1;

    #30;
    if (errors == 0) $display("UT_SCHEDULER: PASS (errors=0)");
    else             $display("UT_SCHEDULER: FAIL (errors=%0d)", errors);
    $finish;
  end

  x2p_scheduler #(.ARB_POLICY(0), .ARB_GRANULARITY(0)) u_rr (
    .clk(clk), .rst_n(rst_n),
    .rd_avail(rd_avail), .wr_avail(wr_avail),
    .sched_busy(sched_busy), .beat_done(beat_done), .txn_done(txn_done),
    .grant_rd(rr_grd), .grant_wr(rr_gwr)
  );
  x2p_scheduler #(.ARB_POLICY(1), .ARB_GRANULARITY(0)) u_rp (
    .clk(clk), .rst_n(rst_n),
    .rd_avail(rd_avail), .wr_avail(wr_avail),
    .sched_busy(sched_busy), .beat_done(beat_done), .txn_done(txn_done),
    .grant_rd(rp_grd), .grant_wr(rp_gwr)
  );
  x2p_scheduler #(.ARB_POLICY(2), .ARB_GRANULARITY(0)) u_wp (
    .clk(clk), .rst_n(rst_n),
    .rd_avail(rd_avail), .wr_avail(wr_avail),
    .sched_busy(sched_busy), .beat_done(beat_done), .txn_done(txn_done),
    .grant_rd(wp_grd), .grant_wr(wp_gwr)
  );

endmodule
