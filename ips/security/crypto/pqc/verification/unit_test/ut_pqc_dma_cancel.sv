`timescale 1ns/1ps
module ut_pqc_dma_cancel;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0,req=0,we=0,z=0,zd,done,err;
 logic arv,arr=0,rv=0,rr,rl=0,awv,awr=0,wv,wr=0,wl,bv=0,br;
 logic[39:0] ara,awa;logic[7:0] arlen,awlen;logic[2:0] arp,awp;
 logic[127:0] wd,rd=0;logic[15:0] ws;
 logic breq,bwe;logic[15:0] ba;logic[31:0] bwd;
 pqc_dma dut(.clk(clk),.rst_n(rst_n),.xfer_req(req),.xfer_we(we),.xfer_addr(40'h1000),.xfer_len(64'd48),
  .xfer_secure(1'b0),.xfer_priv(1'b1),.xfer_done(done),.xfer_error(err),
  .buf_req(breq),.buf_we(bwe),.buf_addr(ba),.buf_wdata(bwd),.buf_rdata(32'h12345678),.buf_ready(1'b1),
  .m_ar_valid(arv),.m_ar_ready(arr),.m_ar_addr(ara),.m_ar_len(arlen),.m_ar_prot(arp),
  .m_r_valid(rv),.m_r_ready(rr),.m_r_data(rd),.m_r_resp(2'b00),.m_r_last(rl),
  .m_aw_valid(awv),.m_aw_ready(awr),.m_aw_addr(awa),.m_aw_len(awlen),.m_aw_prot(awp),
  .m_w_valid(wv),.m_w_ready(wr),.m_w_data(wd),.m_w_strb(ws),.m_w_last(wl),
  .m_b_valid(bv),.m_b_ready(br),.m_b_resp(2'b00),.zeroize_req(z),.zeroize_done(zd));
 task automatic reset_dut();
  rst_n=0;req=0;z=0;arr=0;awr=0;wr=0;rv=0;bv=0;
  repeat(3) @(negedge clk);rst_n=1;
 endtask
 task automatic until_zero();
  int g;g=0;while(!zd && g<20) begin @(negedge clk);g++;end
  if(!zd || done || err) $fatal(1,"cancel completion incorrect");
  if(breq || arv || awv || wv || rr || br || wd!=='0 || ara!=='0 || awa!=='0 || ba!=='0 || bwd!=='0)
    $fatal(1,"clear acknowledged before interface state erased");
  if(dut.total_left!=='0 || dut.burst_left!=='0 || dut.cur_beat_bytes!=='0 ||
     dut.beat_cnt!=='0 || dut.nbeats!=='0 || dut.rx_pos!=='0 || dut.rx_bytes!=='0 ||
     dut.rx_hold!=='0 || dut.stage_cnt!=='0 || dut.we_q || dut.secure_q || dut.priv_q)
    $fatal(1,"clear acknowledged before command and staging state erased");
 endtask
 initial begin
  reset_dut();we=0;req=1;
  wait(arv);@(negedge clk);z=1;req=0;
  repeat(3) begin @(negedge clk);if(!arv || zd || ara!=40'h1000 || arlen!=2) $fatal(1,"AR withdrawn during cancel");end
  arr=1;@(negedge clk);arr=0;
  for(int i=0;i<3;i++) begin
   if(!rr || breq || zd) $fatal(1,"read drain not ready");
   rv=1;rl=(i==2);@(negedge clk);rv=0;
  end
  until_zero();
  reset_dut();we=1;req=1;
  wait(awv);@(negedge clk);awr=1;@(negedge clk);awr=0;
  wait(wv);@(negedge clk);
  begin logic[127:0] saved;logic[15:0] strobes;
   saved=wd;strobes=ws;z=1;req=0;
   repeat(4) begin @(negedge clk);if(!wv || wd!==saved || ws!==strobes || zd) $fatal(1,"W payload changed under backpressure");end
  end
  wr=1;@(negedge clk);wr=0;
  for(int i=1;i<3;i++) begin
   if(!wv || ws!=0 || wl!=(i==2) || breq) $fatal(1,"cancel tail not drained with zero strobes");
   wr=1;@(negedge clk);wr=0;
  end
  repeat(3) begin @(negedge clk);if(zd || !br) $fatal(1,"cancel completed before B");end
  bv=1;@(negedge clk);bv=0;until_zero();
  $display("UT_pqc_dma_cancel: PASS (errors=0)");$finish;
 end
 initial begin #100000;$fatal(1,"watchdog");end
endmodule
