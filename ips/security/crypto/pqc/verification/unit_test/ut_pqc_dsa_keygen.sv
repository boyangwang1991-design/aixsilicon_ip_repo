`timescale 1ns/1ps
module ut_pqc_dsa_keygen;
  logic clk=0,rst_n=0,start=0,clear=0;logic[3:0] pset=0;
  logic busy,done,error;logic mem_req,poly_start,codec_start,sampler_start,hash_start,hash_in_valid,sampler_valid,entropy_ready,generated_valid;
  int errors=0;
  always #5 clk=~clk;
  pqc_dsa_keygen #(.MAX_CYCLES(64)) dut(.clk(clk),.rst_n(rst_n),.start(start),.clear(clear),.pset(pset),.mem_ready('0),.mem_rdata('0),.entropy_valid('0),.entropy_health_ok('0),.entropy_tag('0),.entropy_data('0),.poly_done('0),.codec_done('0),.sampler_done('0),.sampler_error('0),.sampler_ready('0),.hash_in_ready('0),.hash_out_valid('0),.hash_done('0),.hash_out_data('0),.generated_ready('0),.busy(busy),.done(done),.error(error),.mem_req(mem_req),.poly_start(poly_start),.codec_start(codec_start),.sampler_start(sampler_start),.hash_start(hash_start),.hash_in_valid(hash_in_valid),.sampler_valid(sampler_valid),.entropy_ready(entropy_ready),.generated_valid(generated_valid));
  task check(input bit ok,input string msg);if(!ok) begin errors++;$display("FAIL %s",msg);end endtask
  task launch(input logic[3:0] ps);@(negedge clk);pset=ps;start=1;@(negedge clk);start=0;endtask
  task wipe();@(negedge clk);clear=1;#1;
    check(!done && !error && !(mem_req|poly_start|codec_start|sampler_start|hash_start|hash_in_valid|sampler_valid|entropy_ready|generated_valid),"clear must immediately mask requests and result");
    @(negedge clk);clear=0;repeat(2) @(negedge clk);check(!busy && !done && !error,"clear returns idle");
  endtask
  initial begin
    repeat(3) @(negedge clk);rst_n=1;repeat(2) @(negedge clk);
    check(!busy && !done && !error,"reset idle");
    launch(0);repeat(5) @(negedge clk);check(error && !done,"invalid parameter fails closed");wipe();
    launch(4);repeat(8) @(negedge clk);check(busy && !done && !error,"pending dependency remains busy");wipe();
    launch(6);repeat(80) @(negedge clk);check(error && !done,"stalled dependency has bounded failure");
    repeat(3) @(negedge clk);check(error && !done,"failure never becomes success");wipe();
    if(errors==0) $display("UT_pqc_dsa_keygen: PASS (errors=0)");else $display("UT_pqc_dsa_keygen: FAIL (errors=%0d)",errors);
    $finish;
  end
  initial begin #20000;$fatal(1,"control test watchdog");end
endmodule
