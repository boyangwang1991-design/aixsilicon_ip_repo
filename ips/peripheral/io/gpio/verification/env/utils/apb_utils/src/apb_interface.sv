`timescale 1ns/1ps
interface apb_interface(input logic clk);
 logic rst_n, sel=0, enable=0, write=0;
 logic [13:0] addr=0;
 logic [31:0] wdata=0, rdata;
 logic [3:0] strb=15;
 logic [2:0] prot=1;
 logic ready,error;
 clocking mon_cb @(posedge clk);
  default input #1step;
  input rst_n,sel,enable,write,addr,wdata,rdata,strb,prot,ready,error;
 endclocking
 clocking drv_cb @(negedge clk);
  default input #1step output #0;
  output sel,enable,write,addr,wdata,strb,prot;
  input ready,error,rdata;
 endclocking
 assert property (@(posedge clk) disable iff(!rst_n) enable |-> sel)
  else $error("APB enable without select");
 assert property (@(posedge clk) disable iff(!rst_n) sel && enable && !ready |=>
  $stable({sel,enable,write,addr,wdata,strb,prot})) else $error("APB wait stability");
endinterface
