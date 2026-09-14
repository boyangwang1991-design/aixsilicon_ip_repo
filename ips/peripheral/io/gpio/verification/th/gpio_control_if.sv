`timescale 1ns/1ps
interface gpio_control_if(input logic clk,input logic aon_clk);
 logic por_n=0,main_n=0,aon_n=0,main_run=1,aon_run=1;
 logic [127:0] pad=0,available='1,owned='1,out,oe,irq,events,aon_pad=0,aon_available='1;
 logic sleep_req=0,safe_req=0,snapshot=0,strap=0;
 logic sleep_ack,safe_active,fault,dma,wake,irq_summary;
 logic [3:0] groups;
 int width,parity_enabled;
 task automatic ticks(int n=1); repeat(n) @(negedge clk); endtask
 task automatic reset(bit warm=0);
  main_run=1;aon_run=1;
  @(negedge clk);main_n=0;
  if(!warm) begin por_n=0;aon_n=0;pad=0;aon_pad=0;available='1;owned='1;sleep_req=0;safe_req=0; end
  ticks(5);por_n=1;main_n=1;aon_n=1;ticks(16);
 endtask
endinterface
