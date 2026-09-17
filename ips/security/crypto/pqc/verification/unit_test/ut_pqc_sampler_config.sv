`timescale 1ns/1ps
module ut_pqc_sampler_config;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0,start=0,domain=0,done,busy,op_error,clear=0;
 logic [2:0] mode=0;
 logic [3:0] eta=2;
 logic [6:0] tau=39;
 logic [4:0] gamma1_sel=17;
 wire ready,req,we;
 pqc_sampler dut(.clk(clk),.rst_n(rst_n),.start(start),.mode(mode),.domain(domain),
   .dst_page(8'd0),.eta(eta),.tau(tau),.gamma1_sel(gamma1_sel),.busy(busy),.done(done),.op_error(op_error),
   .sqz_valid(1'b1),.sqz_ready(ready),.sqz_data(8'ha5),.mem_req(req),.mem_we(we),
   .mem_ready(1'b1),.zeroize_req(clear));
 task automatic tick;@(posedge clk);#1;endtask
 task automatic check_config(input bit legal);
   @(negedge clk);start=1;tick();@(negedge clk);start=0;
   if(legal)begin
     if(!busy||done||op_error)$fatal(1,"FAIL legal sampler configuration rejected");
   end else begin
     if(!done||!op_error||ready||req||we)$fatal(1,"FAIL illegal sampler configuration accepted mode=%0d domain=%0d eta=%0d tau=%0d gamma=%0d",mode,domain,eta,tau,gamma1_sel);
     repeat(3)begin tick();if(ready||req)$fatal(1,"FAIL rejected request consumed data");end
   end
   @(negedge clk);clear=1;tick();@(negedge clk);clear=0;repeat(2)tick();
   if(op_error||done)$fatal(1,"FAIL clear retained completion");
 endtask
 initial begin
   repeat(3)tick();@(negedge clk);rst_n=1;
   for(int m=0;m<8;m++)for(int d=0;d<2;d++)begin
     mode=3'(m);domain=1'(d);eta=2;tau=39;gamma1_sel=17;
     check_config((m<2&&d==0)||(m>=2&&m<=5&&d==1));
   end
   mode=0;domain=0;
   for(int e=0;e<16;e++)begin eta=4'(e);check_config(e==2||e==3);end
   mode=3;domain=1;
   for(int e=0;e<16;e++)begin eta=4'(e);check_config(e==2||e==4);end
   mode=4;
   for(int g=0;g<32;g++)begin gamma1_sel=5'(g);check_config(g==17||g==19);end
   mode=5;
   for(int t=0;t<128;t++)begin tau=7'(t);check_config(t==39||t==49||t==60);end
   $display("UT_pqc_sampler_config: PASS (errors=0)");$finish;
 end
 initial begin #200000;$fatal(1,"TIMEOUT");end
endmodule
