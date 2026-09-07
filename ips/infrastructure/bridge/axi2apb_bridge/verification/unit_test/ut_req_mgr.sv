// =============================================================================
// ut_req_mgr.sv - x2p_req_mgr（参数化 FIFO）unit test
// 验证：push/pop 数据保真、empty/full 标志、回绕（wrap-around）、无溢出/下溢。
// =============================================================================
`timescale 1ns/1ps

module ut_req_mgr;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  localparam int DW = 64;
  logic        push, pop;
  logic [DW-1:0] din, dout;
  logic        empty, full;

  x2p_req_mgr #(.DEPTH_W(2), .DATA_W(DW), .AXI_ID_W(4)) dut (
    .clk(clk), .rst_n(rst_n), .push(push), .din(din),
    .pop(pop), .dout(dout), .empty(empty), .full(full)
  );

  int errors = 0;

  task automatic chk(logic [DW-1:0] a, logic [DW-1:0] b, string msg);
    if (a !== b) begin
      $display("FAIL: %s (got 0x%0h exp 0x%0h)", msg, a, b);
      errors++;
    end
  endtask

  initial begin
    logic [DW-1:0] exp[$];
    int i;
    push = 0; pop = 0; din = 0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    // 初始空
    chk(empty, 1'b1, "empty after reset");
    chk(full,  1'b0, "full after reset");

    // 入队 4 个（深度 4），数据保真
    for (i = 0; i < 4; i++) begin
      @(posedge clk);
      push = 1'b1; din = 64'hA000000000000000 + i;
      exp.push_back(din);
    end
    @(posedge clk);
    push = 0;
    chk(full, 1'b1, "full after 4 pushes");
    chk(empty, 1'b0, "not empty after pushes");

    // 满时 push 被拒（不覆盖、指针不推进）
    @(posedge clk);
    push = 1'b1; din = 64'hFFFF;
    @(posedge clk);
    push = 0;
    // 出队 4 个并校验
    for (i = 0; i < 4; i++) begin
      @(posedge clk);
      pop = 1'b1;
      chk(dout, exp.pop_front(), $sformatf("dout[%0d] data", i));
    end
    @(posedge clk);
    pop = 0;
    chk(empty, 1'b1, "empty after 4 pops");
    // 空时 pop 无效
    @(posedge clk);
    pop = 1'b1;
    @(posedge clk);
    pop = 0;
    chk(empty, 1'b1, "still empty after pop-on-empty");

    // 回绕测试：入 2 出 2 再入 4
    for (i = 0; i < 2; i++) begin
      @(posedge clk); push = 1'b1; din = 64'h1000000000000000 + i; exp.push_back(din);
    end
    @(posedge clk); push = 0;
    for (i = 0; i < 2; i++) begin
      @(posedge clk); pop = 1'b1; chk(dout, exp.pop_front(), $sformatf("wrap pop[%0d]", i));
    end
    @(posedge clk); pop = 0;
    for (i = 0; i < 4; i++) begin
      @(posedge clk); push = 1'b1; din = 64'h2000000000000000 + i; exp.push_back(din);
    end
    @(posedge clk); push = 0;
    chk(full, 1'b1, "full after wrap fill");
    for (i = 0; i < 4; i++) begin
      @(posedge clk); pop = 1'b1; chk(dout, exp.pop_front(), $sformatf("wrap pop2[%0d]", i));
    end
    @(posedge clk); pop = 0;
    chk(empty, 1'b1, "empty at end");

    #30;
    if (errors == 0) $display("UT_REQ_MGR: PASS (errors=0)");
    else             $display("UT_REQ_MGR: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
