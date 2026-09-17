`timescale 1ns/1ps
module ut_pqc_codec_sram;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0,start=0,done,busy,canonical,norm_ok;
  logic [3:0] op; logic [4:0] width;
  logic [7:0] src,dst;
  logic req,we,ready; logic [15:0] addr; logic [31:0] wd,rd;
  logic dr=0,dw=0,dy; logic [15:0] da=0;logic [31:0] dd=0,dout;
  logic [31:0] exp_words[0:255];logic [31:0] vals[0:255];
  int widths[0:6]='{1,4,10,12,18,20,23};
  pqc_codec dut(.clk(clk),.rst_n(rst_n),.start(start),.op(op),.domain(1'b1),
    .d_comp(width),.gamma2_sel(2'd0),.src_page(src),.src2_page(8'd1),.dst_page(dst),
    .bound(32'd100),.busy(busy),.done(done),.canonical_ok(canonical),.norm_ok(norm_ok),
    .mem_req(req),.mem_we(we),.mem_addr(addr),.mem_wdata(wd),.mem_rdata(rd),.mem_ready(ready),.zeroize_req(1'b0));
  pqc_secure_sram_ctrl #(.LOCAL_SRAM_KIB(8),.NUM_PAGES(8)) ram(
    .clk(clk),.rst_n(rst_n),.c0_req(req),.c0_we(we),.c0_addr(addr),.c0_wdata(wd),.c0_rdata(rd),.c0_ready(ready),
    .c1_req(1'b0),.c1_we(1'b0),.c1_addr(16'd0),.c1_wdata(32'd0),
    .d_req(dr),.d_we(dw),.d_addr(da),.d_wdata(dd),.d_wstrb(4'hf),.d_rdata(dout),.d_ready(dy),
    .tag_we(1'b0),.tag_page(8'd0),.tag_rep(4'd0),.tag_algo(4'd0),.tag_pset(4'd0),.tag_secret(1'b0),.tag_valid(1'b0),
    .tag_check_req(1'b0),.tag_check_page(8'd0),.ecc_inject_en(1'b0),.ecc_inject_idx(16'd0),.ecc_inject_mask(39'd0),.zeroize_req(1'b0));
  task automatic access_word(input bit wr,input int a,input logic[31:0] v);
    int guard;
    @(negedge clk);dr=1;dw=wr;da=a;dd=v;guard=0;
    @(negedge clk);
    while(!dy && guard<50) begin @(negedge clk);guard++;end
    if(!dy) $fatal(1,"memory timeout");
    if(!wr && dout!==v) $fatal(1,"addr=%0d got=%h expected=%h",a,dout,v);
    @(negedge clk);dr=0;
    @(negedge clk);
  endtask
  task automatic run_codec(input int operation,input int from_page,input int to_page);
    int guard;
    op=operation;src=from_page;dst=to_page;start=1;
    @(negedge clk);start=0;guard=0;
    while(!done && guard<6000) begin @(negedge clk);guard++;end
    if(!done || !canonical) $fatal(1,"codec incomplete / noncanonical");
    repeat(3) @(negedge clk);
  endtask
  initial begin
    repeat(3) @(negedge clk);rst_n=1;
    for(int c=0;c<7;c++) begin
      width=widths[c];
      for(int i=0;i<256;i++) exp_words[i]=0;
      for(int i=0;i<256;i++) begin
        vals[i]=(i*12345+7)&((32'd1<<width)-1);
        for(int b=0;b<width;b++) exp_words[(i*width+b)/32][(i*width+b)%32]=vals[i][b];
        access_word(1,i,vals[i]);
      end
      run_codec(0,0,2);
      for(int i=0;i<8*width;i++) access_word(0,512+i,exp_words[i]);
      run_codec(1,2,4);
      for(int i=0;i<256;i++) access_word(0,1024+i,vals[i]);
    end
    $display("UT_pqc_codec_sram: PASS (errors=0)");$finish;
  end
  initial begin #5000000;$fatal(1,"watchdog");end
endmodule
