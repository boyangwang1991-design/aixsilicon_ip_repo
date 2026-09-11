`timescale 1ns/1ps
module ut_gpio_event_fifo;
  logic clk=0, rst_n=0;
  always #5 clk=~clk;
  logic [7:0] events=0, rising=0, enables='1;
  logic pop=0, flush=0, clear_lost=0, clear_overflow=0, ts_read=0;
  logic [127:0] head;
  logic [6:0] level;
  logic [31:0] lost, tslo, tshi;
  logic overflow, watermark, dma;
  gpio_event_fifo #(.N_GPIO(8),.DEPTH(4)) dut (
    .clk_i(clk),.rst_ni(rst_n),.event_i(events),.rising_i(rising),.event_enable_i(enables),
    .record_enable_i(1'b1),.dma_enable_i(1'b1),.pop_i(pop),.flush_i(flush),.clear_lost_i(clear_lost),
    .clear_overflow_i(clear_overflow),.watermark_i(7'd2),.timestamp_low_read_i(ts_read),
    .head_o(head),.level_o(level),.lost_o(lost),.timestamp_low_o(tslo),.timestamp_high_o(tshi),
    .overflow_o(overflow),.watermark_o(watermark),.dma_req_o(dma));
  task automatic cycle(input logic[7:0] e, input logic p, f, c);
    @(negedge clk); events=e; rising=e; pop=p; flush=f; clear_lost=c;
    @(posedge clk); #1;
  endtask
  initial begin
    #100000; $fatal(1,"FIFO watchdog");
  end
  initial begin
    repeat(2) @(negedge clk); rst_n=1;
    cycle(0,0,0,0);
    assert(level===0 && head===0 && lost===0 && !dma) else $fatal(1,"empty reset");
    cycle(8'h09,1,0,0);
    assert(level===1 && head[6:0]===0 && head[8]===1 && lost===1 && overflow) else $fatal(1,"empty pop/multiple events");
    cycle(8'h02,0,0,0); cycle(8'h04,0,0,0); cycle(8'h08,0,0,0);
    assert(level===4 && watermark && dma) else $fatal(1,"full setup");
    cycle(8'h10,1,0,0);
    assert(level===4 && head[6:0]===1 && lost===1) else $fatal(1,"full exchange");
    cycle(8'h20,0,0,0);
    assert(level===4 && lost===2) else $fatal(1,"full drop");
    cycle(8'hc0,1,1,1);
    assert(level===0 && head===0 && lost===2 && overflow) else $fatal(1,"flush/set wins");
    cycle(0,1,0,1);
    assert(level===0 && lost===0 && !overflow) else $fatal(1,"clear loss");
    cycle(8'h80,0,0,0);
    assert(head[6:0]===7 && head[127:96]===0 && head[31:9]===0 && head[7]===0) else $fatal(1,"record format");
    cycle(0,0,0,0);
    assert(level===1 && head[6:0]===7) else $fatal(1,"head stable");
    cycle(0,1,0,0);
    assert(level===0 && head===0) else $fatal(1,"pop last");
    $display("UT_GPIO_EVENT_FIFO: PASS (errors=0)"); $finish;
  end
endmodule
