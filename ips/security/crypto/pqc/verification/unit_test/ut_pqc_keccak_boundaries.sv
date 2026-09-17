`timescale 1ns/1ps
module pqc_hash_boundary_driver #(parameter ROUNDS=1)(output bit finished=0);
 logic clk=0; always #5 clk=~clk;
 logic rst_n=0,start=0,ctx=0;
 logic [2:0] fid;logic[31:0] olen;
 logic iv=0,ir,il=0,ov,orr=0,ol,done;
 logic[7:0] idata=0,odata;
 logic[7:0] expected[0:511];
 int seen=0,cycle=0;string dir;
 pqc_keccak #(.ROUNDS_PER_CYCLE(ROUNDS)) dut(.clk(clk),.rst_n(rst_n),.start(start),
  .function_id(fid),.ctx_sel(ctx),.out_len(olen),.in_valid(iv),.in_ready(ir),.in_data(idata),.in_last(il),
  .out_valid(ov),.out_ready(orr),.out_data(odata),.out_last(ol),.done(done),.zeroize_req(1'b0));
 always @(posedge clk) if(rst_n && ov && orr) begin
   if(seen>=olen || odata !== expected[seen] || ol !== (seen==olen-1)) $fatal(1,"hash mismatch rounds=%0d fid=%0d byte=%0d",ROUNDS,fid,seen);
   seen++;
 end
 task automatic run_case(input int function_id,input int n,input int length);
  int guard;
  rst_n=0;orr=0;iv=0;il=0;repeat(3) @(negedge clk);
  fid=function_id;olen=length;seen=0;ctx=~ctx;
  $readmemh($sformatf("%s/hash_%0d_%0d.hex",dir,function_id,n),expected,0,length-1);
  rst_n=1;start=1;@(negedge clk);start=0;
  if(n==0) begin il=1;@(negedge clk);il=0;end
  for(int i=0;i<n;i++) begin
   guard=0;
   while(!ir && guard<200) begin @(negedge clk);guard++;end
   if(!ir) $fatal(1,"hash absorb timeout");
   iv=1;idata=i;il=(i==n-1);@(negedge clk);iv=0;il=0;
   if(i%7==0) @(negedge clk);
  end
  guard=0;
  while(!done && guard<4000) begin
    orr=(guard%5!=0);@(negedge clk);guard++;
  end
  if(!done || seen!=length) $fatal(1,"hash output incomplete");
  orr=0;
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",dir)) $fatal(1,"VECTORS required");
  for(int f=0;f<4;f++) begin
   int rate,len;
   rate=(f==1)?72:(f==2)?168:136;len=(f==0)?32:(f==1)?64:400;
   run_case(f,0,len);run_case(f,rate-1,len);run_case(f,rate,len);
   run_case(f,rate+1,len);run_case(f,2*rate,len);run_case(f,2*rate+17,len);
  end
  finished=1;
 end
endmodule
module ut_pqc_keccak_boundaries;
 wire one_done,two_done;
 pqc_hash_boundary_driver #(.ROUNDS(1)) one(one_done);
 pqc_hash_boundary_driver #(.ROUNDS(2)) two(two_done);
 initial begin wait(one_done && two_done);$display("UT_pqc_keccak_boundaries: PASS (errors=0)");$finish;end
 initial begin #5000000;$fatal(1,"watchdog");end
endmodule
