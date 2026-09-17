`timescale 1ns/1ps
module ut_pqc_apb_if;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0;
 logic s_apb_psel=0,s_apb_penable=0,s_apb_pwrite=0;
 logic [2:0] s_apb_pprot=1;
 logic [9:0] s_apb_paddr=0;
 logic [31:0] s_apb_pwdata=0;
 logic [3:0] s_apb_pstrb=15;
 wire s_apb_pready,s_apb_pslverr,csr_psel,csr_penable,csr_pwrite,busy_write_error;
 wire [31:0] s_apb_prdata,csr_pwdata;
 wire [2:0] csr_pprot;
 wire [9:0] csr_paddr;
 wire [3:0] csr_pstrb;
 logic csr_pready=0,csr_pslverr=0;
 logic [31:0] csr_prdata=32'hfedcba98;
 logic busy=0,privileged=1;
 pqc_apb_if dut(.*);
 task automatic access(input int addr,input bit wr,input bit blocked);
   @(negedge clk);s_apb_psel=1;s_apb_penable=0;s_apb_paddr=10'(addr);s_apb_pwrite=wr;
   #1;
   if(blocked&&(csr_psel||csr_penable||csr_pstrb!=0||s_apb_prdata!=0))$fatal(1,"FAIL blocked setup leak");
   if(s_apb_pready||s_apb_pslverr)$fatal(1,"FAIL setup completion");
   @(negedge clk);s_apb_penable=1;csr_pready=0;#1;
   if(blocked)begin
     if(!s_apb_pready||!s_apb_pslverr||csr_psel||csr_penable||csr_pstrb||s_apb_prdata)
       $fatal(1,"FAIL rejected access addr=%h pprot=%b",addr,s_apb_pprot);
   end else begin
     if(s_apb_pready||s_apb_pslverr||!csr_psel||!csr_penable||csr_paddr!=addr||csr_pwrite!=wr||csr_pstrb!=s_apb_pstrb)
       $fatal(1,"FAIL legal wait phase");
     repeat(3)@(negedge clk);csr_pready=1;#1;
     if(!s_apb_pready||s_apb_pslverr!=csr_pslverr||s_apb_prdata!==csr_prdata)$fatal(1,"FAIL legal completion");
   end
   @(negedge clk);s_apb_psel=0;s_apb_penable=0;csr_pready=0;
 endtask
 initial begin
   repeat(3)@(negedge clk);rst_n=1;
   for(int p=0;p<8;p++)for(int trusted=0;trusted<2;trusted++)begin
     s_apb_pprot=3'(p);privileged=1'(trusted);
     access('h204,0,!(trusted&&(p&1)&&!(p&2)));
     access('h200,1,!(trusted&&(p&1)&&!(p&2)));
     // Public ID remains readable for every bus attribute combination.
     access(0,0,0);
     s_apb_pwdata=4;access('h10,1,!(trusted&&(p&1)&&!(p&2)));s_apb_pwdata=0;
   end
   s_apb_pprot=1;privileged=1;busy=1;
   access('h18,1,1);access('h80,1,1);access('h1d0,1,1);access('h1d4,1,1);access('h1d8,1,1);
   for(int a='h20;a<='h78;a+=4)access(a,1,1);
   access('h18,0,0);access('h94,1,0);
   // Byte lanes use PSTRB; unaligned aliases are never accepted.
   busy=0;access('h19,1,1);access('h206,0,1);
   csr_pslverr=1;access('h1fc,0,0);csr_pslverr=0;
   @(negedge clk);rst_n=0;s_apb_psel=1;s_apb_penable=1;#1;
   if(csr_psel||csr_penable||csr_pstrb||s_apb_prdata||s_apb_pready||s_apb_pslverr)$fatal(1,"FAIL reset side effect");
   $display("UT_pqc_apb_if: PASS (errors=0)");$finish;
 end
 initial begin #100000;$fatal(1,"TIMEOUT");end
endmodule
