`timescale 1ns/1ps
module ut_pqc_work_key_ram;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0,begin_load=0,begin_ready,valid=0,ready,last=0,done,err;
 logic[31:0] handle=32'h12345600,data=0,check_handle=32'h12345600;
 logic[3:0] algo=1,pset=1,check_algo=1,check_pset=1;
 logic[7:0] usage=4,check_usage=4;logic[15:0] bytes=1632;
 logic ok,rreq=0,rv,re,retire=0,z=0,zd;logic[15:0] ra=0;logic[31:0] rd;
 pqc_work_key_ram dut(.clk(clk),.rst_n(rst_n),.load_begin(begin_load),.load_begin_ready(begin_ready),
  .load_handle(handle),.load_algo(algo),.load_pset(pset),.load_usage(usage),.load_bytes(bytes),
  .load_valid(valid),.load_ready(ready),.load_data(data),.load_last(last),.load_done(done),.load_error(err),
  .check_handle(check_handle),.check_algo(check_algo),.check_pset(check_pset),.check_usage(check_usage),.check_ok(ok),
  .read_req(rreq),.read_word(ra),.read_valid(rv),.read_error(re),.read_data(rd),
  .retire(retire),.zeroize_req(z),.zeroize_done(zd));
 function automatic logic[31:0] payload(input int i);return 32'ha5830000 ^ (i*32'h01010101);endfunction
 task automatic wait_empty();
  int g;g=0;while(!begin_ready && g<2500) begin @(negedge clk);g++;end
  if(!begin_ready || !zd || ok || rd!=0) $fatal(1,"key scrub did not finish / material visible");
 endtask
 task automatic begin_key();
  wait_empty();begin_load=1;@(negedge clk);begin_load=0;
 endtask
 task automatic load_key();
  begin_key();
  for(int i=0;i<bytes/4;i++) begin
   if(!ready || ok) $fatal(1,"incomplete private key published");
   valid=1;data=payload(i);last=(i==bytes/4-1);@(negedge clk);valid=0;last=0;
   if(i%7==0 && i!=bytes/4-1) repeat(2) @(negedge clk);
  end
  begin int g;g=0;
    while(!done && g<2000) begin
      if(ok) $fatal(1,"key published before ECC scan completed");
      @(negedge clk);g++;
    end
  end
  if(!done || !ok || ready) $fatal(1,"complete key not published atomically");
  repeat(2) begin @(negedge clk);if(rv || rd!=0) $fatal(1,"unsolicited private material response");end
 endtask
 task automatic read_key(input int a,input bit allowed);
  ra=a;rreq=1;@(negedge clk);rreq=0;
  if(allowed) begin @(negedge clk); if(!rv || re || rd!==payload(a)) $fatal(1,"private read mismatch");end
  else if(rv || !re || rd!=0) $fatal(1,"unauthorized private read");
  @(negedge clk);
 endtask
 initial begin
  repeat(3) @(negedge clk);rst_n=1;wait_empty();
  bytes=8;begin_key();if(!err || ok) $fatal(1,"bad private key length accepted");
  bytes=1632;wait_empty();begin_key();valid=1;last=1;data='1;@(negedge clk);valid=0;last=0;
  if(!err || ok || rd!=0) $fatal(1,"early LAST published partial key");
  wait_empty();load_key();
  read_key(0,1);read_key(407,1);read_key(408,0);
  check_handle=32'h12345601;read_key(0,0);check_handle=handle;
  check_algo=2;read_key(0,0);check_algo=1;
  check_pset=2;read_key(0,0);check_pset=1;
  check_usage=2;read_key(0,0);check_usage=4;
  // No overwrite of the current working key, including while idle.
  begin_load=1;@(negedge clk);begin_load=0;
  if(begin_ready) $fatal(1,"active working key can be overwritten");
  read_key(0,1);
  retire=1;#1;if(ok || rd!=0) $fatal(1,"retirement did not revoke read access");
  @(negedge clk);retire=0;wait_empty();
  for(int i=0;i<2048;i++) if(dut.u_mem.mem[i]!==0) $fatal(1,"retired material not physically cleared");
  load_key();z=1;#1;if(ok || rv || rd!=0) $fatal(1,"zeroize did not revoke access");
  repeat(2200) @(negedge clk);
  if(!zd || begin_ready || ready) $fatal(1,"held zeroize protocol");
  for(int i=0;i<2048;i++) if(dut.u_mem.mem[i]!==0) $fatal(1,"zeroized material remains");
  z=0;@(negedge clk);wait_empty();
  $display("UT_pqc_work_key_ram: PASS (errors=0)");$finish;
 end
 initial begin #1000000;$fatal(1,"watchdog");end
endmodule
