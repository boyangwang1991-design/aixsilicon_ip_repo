// =============================================================================
// ut_apb_engine.sv - APB Engine unit test
// 验证：SETUP/ACCESS 相位、读写请求处理、响应 ID/数据/错误回送。
// 自检：rsp_valid/rsp_id/rsp_data/rsp_error 与预期一致。
// =============================================================================
`timescale 1ns/1ps

module ut_apb_engine;

  logic clk;
  logic rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic        req_valid, req_ready;
  logic [31:0] req_addr;
  logic        req_write;
  logic [31:0] req_wdata;
  logic [3:0]  req_strb;
  logic [2:0]  req_prot;
  logic [3:0]  req_id;
  logic [3:0]  req_beat, req_sub;
  logic        req_beat_last, req_txn_last, req_error;

  logic        rsp_valid, rsp_ready;
  logic [31:0] rsp_data;
  logic        rsp_error;
  logic [3:0]  rsp_id;
  logic [3:0]  rsp_beat, rsp_sub;
  logic        rsp_beat_last, rsp_txn_last;

  logic [31:0] paddr;
  logic        psel, penable, pwrite;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;
  logic [2:0]  pprot;
  logic [31:0] prdata;
  logic        pready, pslverr;

  x2p_apb_engine #(
    .APB_ADDR_WIDTH (32),
    .APB_DATA_WIDTH (32),
    .AXI_ID_WIDTH   (4),
    .APB_PROFILE    (1),
    .TIMEOUT_ENABLE (1'b1),
    .TIMEOUT_CYCLES (256),
    .APB_OUTPUT_REG (1'b0)
  ) dut (
    .clk(clk), .rst_n(rst_n),
    .req_valid(req_valid), .req_ready(req_ready),
    .req_addr(req_addr), .req_write(req_write),
    .req_wdata(req_wdata), .req_strb(req_strb), .req_prot(req_prot),
    .req_id(req_id), .req_beat(req_beat), .req_sub(req_sub),
    .req_beat_last(req_beat_last), .req_txn_last(req_txn_last),
    .req_error(req_error),
    .rsp_valid(rsp_valid), .rsp_ready(rsp_ready),
    .rsp_data(rsp_data), .rsp_error(rsp_error), .rsp_id(rsp_id),
    .rsp_beat(rsp_beat), .rsp_sub(rsp_sub),
    .rsp_beat_last(rsp_beat_last), .rsp_txn_last(rsp_txn_last),
    .paddr(paddr), .psel(psel), .penable(penable), .pwrite(pwrite),
    .pwdata(pwdata), .pstrb(pstrb), .pprot(pprot),
    .prdata(prdata), .pready(pready), .pslverr(pslverr)
  );

  int errors = 0;
  logic [31:0] mem [0:1023];

  // 简单 APB 从设备（组合 psel/penable 采样，registered 响应）
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pready <= 1'b0; prdata <= '0; pslverr <= 1'b0;
    end else begin
      if (psel && penable) begin
        pready <= 1'b1;
        if (pwrite) begin
          mem[paddr[11:2]] <= pwdata;
          prdata <= '0;
        end else begin
          prdata <= mem[paddr[11:2]];
        end
      end else begin
        pready <= 1'b0;
      end
    end
  end

  // 发送单笔请求并等待响应
  task automatic send_and_check(bit is_write, logic [31:0] addr, logic [31:0] wd, bit [3:0] id);
    int rc;
    @(posedge clk); #1;
    req_valid  = 1'b1;
    req_addr   = addr;
    req_write  = is_write;
    req_wdata  = wd;
    req_strb   = 4'hF;
    req_prot   = 3'b010;
    req_id     = id;
    req_beat   = 4'd0;
    req_sub    = 4'd0;
    req_beat_last = 1'b1;
    req_txn_last  = 1'b1;
    req_error  = 1'b0;
    // 保持 valid 直到 ready，再过一拍完成握手后释放
    forever begin
      if (req_ready) break;
      @(posedge clk);
    end
    @(posedge clk); #1;
    req_valid = 1'b0;

    rc = 0;
    while (!rsp_valid && rc < 100) begin @(posedge clk); rc++; end
    if (rc >= 100) begin
      $display("FAIL: apb_engine rsp TIMEOUT (id=0x%0h write=%0b)", id, is_write);
      errors++;
      return;
    end
    if (rsp_id !== id) begin
      $display("FAIL: apb_engine rsp_id=0x%0h (expect 0x%0h, write=%0b)", rsp_id, id, is_write);
      errors++;
    end
    if (rsp_error !== 1'b0) begin
      $display("FAIL: apb_engine rsp_error=%0b (expect 0, write=%0b)", rsp_error, is_write);
      errors++;
    end
    if (!is_write && rsp_data !== mem[addr[11:2]]) begin
      $display("FAIL: apb_engine read rsp_data=0x%0h (expect 0x%0h)", rsp_data, mem[addr[11:2]]);
      errors++;
    end
    // 应答 rsp
    @(posedge clk); #1;
    rsp_ready = 1'b1;
    @(posedge clk); #1;
    rsp_ready = 1'b0;
    @(posedge clk);
  endtask

  initial begin
    rsp_ready = 1'b0;
    req_valid = 1'b0;
    req_addr=0; req_write=0; req_wdata=0; req_strb=0; req_prot=0;
    req_id=0; req_beat=0; req_sub=0; req_beat_last=0; req_txn_last=0; req_error=0;
    rst_n = 1'b0;
    repeat (5) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    // 写
    send_and_check(1'b1, 32'h1000, 32'hCAFE_F00D, 4'hA);
    // 读回
    send_and_check(1'b0, 32'h1000, 32'h0, 4'hB);
    // 再写
    send_and_check(1'b1, 32'h2000, 32'hDEAD_BEEF, 4'hC);

    #50;
    if (errors == 0) $display("UT_APB_ENGINE: PASS (errors=0)");
    else             $display("UT_APB_ENGINE: FAIL (errors=%0d)", errors);
    $finish;
  end

endmodule
