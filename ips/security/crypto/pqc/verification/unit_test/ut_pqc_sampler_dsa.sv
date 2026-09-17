`timescale 1ns/1ps
module ut_pqc_sampler_dsa;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,start=0,done,busy;
  logic [2:0] mode;
  logic [3:0] eta;
  logic [4:0] gamma1;
  logic [6:0] tau;
  logic valid,ready,req,we,mem_ready;
  logic [15:0] addr;
  logic [31:0] data;
  logic [7:0] stream[0:8191]; logic [31:0] expected[0:255];
  int pos=0,seen=0,cycle=0;
  string dir;
  assign valid=(cycle%5 != 0) && pos<8192;
  assign mem_ready=(cycle%7 != 0);
  pqc_sampler dut(.clk(clk),.rst_n(rst_n),.start(start),.mode(mode),.domain(1'b1),
    .dst_page(8'd3),.eta(eta),.gamma1_sel(gamma1),.tau(tau),.busy(busy),.done(done),
    .sqz_valid(valid),.sqz_ready(ready),.sqz_data(stream[pos]),.mem_req(req),.mem_we(we),
    .mem_addr(addr),.mem_wdata(data),.mem_ready(mem_ready),.zeroize_req(1'b0));
  always @(posedge clk) if(rst_n) begin
    cycle <= cycle+1;
    if(valid && ready) pos <= pos+1;
    if(req && mem_ready) begin
      if(seen>=256 || addr !== 16'(768+seen) || data !== expected[seen])
        $fatal(1,"sample %0d got %h expected %h",seen,data,expected[seen]);
      seen++;
    end
  end
  initial begin
    if(!$value$plusargs("VECTORS=%s",dir)) $fatal(1,"VECTORS required");
    $readmemh({dir,"/sampler_stream.hex"},stream);
    for(int c=0;c<8;c++) begin
      rst_n=0; repeat(3) @(negedge clk);
      pos=0; seen=0;cycle=0;
      $readmemh($sformatf("%s/sampler_%0d.hex",dir,c),expected);
      mode=(c==0)?2:(c<=2)?3:(c<=4)?4:5;
      eta=(c==1)?2:4; gamma1=(c==3)?17:19; tau=(c==5)?39:(c==6)?49:60;
      rst_n=1;start=1;@(negedge clk);start=0;
      begin int guard; guard=0;
        while(!done && guard<30000) begin @(negedge clk);guard++;end
        if(!done || seen!=256) $fatal(1,"sampler case %0d incomplete seen=%0d",c,seen);
      end
    end
    $display("UT_pqc_sampler_dsa: PASS (errors=0)");$finish;
  end
  initial begin #5000000;$fatal(1,"watchdog");end
endmodule
