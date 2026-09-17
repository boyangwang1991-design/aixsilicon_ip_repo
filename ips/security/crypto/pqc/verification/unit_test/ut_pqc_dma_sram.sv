`timescale 1ns/1ps
module pqc_dma_sram_driver #(parameter DW=128)(output bit finished=0);
 localparam B=DW/8;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0,req=0,we=0,done,err;
 logic c_req=0,c_we=0,c_ready;logic[31:0]c_rdata;
 logic[3:0] bstrb;
 logic breq,bwe,by;logic[15:0]ba;logic[31:0]bwd,brd;
 logic arv,arr,rv,rr,rl,awv,awr,wv,wr,wl,bv=0,br;
 logic[39:0]ara,awa;logic[7:0]arlen,awlen;logic[2:0]arp,awp;
 logic[DW-1:0]wd,rd;logic[B-1:0]ws;
 bit reading=0;int rbeat=0,rbeats=0,wbeat=0,bytes_seen=0,cycle=0;
 assign arr=(cycle%5!=0);assign awr=(cycle%7!=0);assign wr=(cycle%3!=0);
 assign rv=reading && cycle%4!=0;assign rl=(rbeat==rbeats-1);
 always_comb for(int i=0;i<B;i++) rd[i*8+:8]=8'((rbeat*B+i)*13+7);
 pqc_dma #(.DATA_WIDTH(DW),.LOCAL_WORDS(2048)) dut(.clk(clk),.rst_n(rst_n),
  .xfer_req(req),.xfer_we(we),.xfer_addr(40'h1000),.xfer_len(64'd70),.xfer_secure(1'b0),.xfer_priv(1'b1),.xfer_done(done),.xfer_error(err),
  .buf_req(breq),.buf_we(bwe),.buf_addr(ba),.buf_wdata(bwd),.buf_wstrb(bstrb),.buf_rdata(brd),.buf_ready(by),
  .m_ar_valid(arv),.m_ar_ready(arr),.m_ar_addr(ara),.m_ar_len(arlen),.m_ar_prot(arp),
  .m_r_valid(rv),.m_r_ready(rr),.m_r_data(rd),.m_r_resp(2'b00),.m_r_last(rl),
  .m_aw_valid(awv),.m_aw_ready(awr),.m_aw_addr(awa),.m_aw_len(awlen),.m_aw_prot(awp),
  .m_w_valid(wv),.m_w_ready(wr),.m_w_data(wd),.m_w_strb(ws),.m_w_last(wl),
  .m_b_valid(bv),.m_b_ready(br),.m_b_resp(2'b00),.zeroize_req(1'b0));
 pqc_secure_sram_ctrl #(.LOCAL_SRAM_KIB(8),.NUM_PAGES(8)) ram(.clk(clk),.rst_n(rst_n),
  .c0_req(c_req),.c0_we(c_we),.c0_addr(16'd17),.c0_wdata(32'ha5a5a5a5),.c0_rdata(c_rdata),.c0_ready(c_ready),
  .c1_req(1'b0),.c1_we(1'b0),.c1_addr(16'd0),.c1_wdata(32'd0),
  .d_req(breq),.d_we(bwe),.d_addr(ba),.d_wdata(bwd),.d_wstrb(bstrb),.d_rdata(brd),.d_ready(by),
  .tag_we(1'b0),.tag_page(8'd0),.tag_rep(4'd0),.tag_algo(4'd0),.tag_pset(4'd0),.tag_secret(1'b0),.tag_valid(1'b0),
  .tag_check_req(1'b0),.tag_check_page(8'd0),.ecc_inject_en(1'b0),.ecc_inject_idx(16'd0),.ecc_inject_mask(39'd0),.zeroize_req(1'b0));
 always @(posedge clk) if(rst_n) begin
  cycle<=cycle+1;
  if(arv && arr) begin reading<=1;rbeat<=0;rbeats<=int'(arlen)+1;end
  if(rv && rr) begin rbeat<=rbeat+1;if(rl) reading<=0;end
  if(awv && awr) begin
   if(awlen!=((70+B-1)/B-1) || awp!=3'b011) $fatal(1,"write descriptor");
   wbeat<=0;
  end
  if(wv && wr) begin
   for(int i=0;i<B;i++) begin
    if(ws[i] !== (wbeat*B+i<70)) $fatal(1,"strobe width=%0d beat=%0d byte=%0d",DW,wbeat,i);
    if(ws[i]) begin
     if(wd[i*8+:8] !== 8'((wbeat*B+i)*13+7)) $fatal(1,"DMA+SRAM payload width=%0d offset=%0d",DW,wbeat*B+i);
     bytes_seen++;
    end
   end
   wbeat<=wbeat+1;if(wl) bv<=1;
  end
  if(bv && br) bv<=0;
 end
 task automatic transfer(input bit write_op);
  int guard;we=write_op;req=1;guard=0;
  @(negedge clk);
  while(!done && !err && guard<3000) begin @(negedge clk);guard++;end
  if(!done || err) $fatal(1,"DMA+SRAM timeout/error");
  req=0;repeat(3) @(negedge clk);
 endtask
 initial begin
  repeat(3) @(negedge clk);rst_n=1;
  c_req=1;c_we=1;
  do @(negedge clk);while(!c_ready);
  @(negedge clk);c_req=0;c_we=0;repeat(2) @(negedge clk);
  transfer(0);
  c_req=1;
  do @(negedge clk);while(!c_ready);
  if(c_rdata!==32'ha5a5887b) $fatal(1,"DMA tail clobbered adjacent bytes W=%0d got=%h",DW,c_rdata);
  @(negedge clk);c_req=0;repeat(2) @(negedge clk);
  transfer(1);
  if(bytes_seen!=70) $fatal(1,"DMA output length");finished=1;
 end
endmodule
module ut_pqc_dma_sram;
 wire a,b,c;
 pqc_dma_sram_driver #(.DW(64)) x(a);
 pqc_dma_sram_driver #(.DW(128)) y(b);
 pqc_dma_sram_driver #(.DW(256)) z(c);
 initial begin wait(a&&b&&c);$display("UT_pqc_dma_sram: PASS (errors=0)");$finish;end
 initial begin #1000000;$fatal(1,"watchdog");end
endmodule
