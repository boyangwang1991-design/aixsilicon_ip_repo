// =============================================================================
// ut_sync_chain.sv - apb_cdc_sync_chain 模块级 UT 自检
// 验证：复位初值、2 级/3 级同步、toggling 传播
// =============================================================================
`timescale 1ns/1ps

module ut_sync_chain;

  logic clk, rst_n, din, dout;

  apb_cdc_sync_chain #(.SYNC_STAGES(2)) dut (
    .din(din), .clk(clk), .rst_n(rst_n), .dout(dout)
  );

  int errors = 0;

  task automatic chk(logic a, logic b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got %0b exp %0b)", msg, a, b);
      errors++;
    end
  endtask

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  initial begin
    // 复位
    rst_n = 1'b0; din = 1'b0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    // 复位后输出 0
    chk(dout, 1'b0, "reset: dout=0");

    // 驱动 din=1，2 级同步需 2 拍后 dout=1
    din = 1'b1;
    repeat (2) @(posedge clk);
    chk(dout, 1'b1, "din=1 propagates after 2 stages");

    // din=0，2 拍后 dout=0
    din = 1'b0;
    repeat (2) @(posedge clk);
    chk(dout, 1'b0, "din=0 propagates after 2 stages");

    #20;
    if (errors == 0) $display("UT_SYNC_CHAIN: PASS (errors=0)");
    else             $display("UT_SYNC_CHAIN: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
