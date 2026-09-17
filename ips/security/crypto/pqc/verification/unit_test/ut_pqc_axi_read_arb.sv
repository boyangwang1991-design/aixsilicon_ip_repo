`timescale 1ns/1ps
module ut_pqc_axi_read_arb;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0;
  logic[1:0] av=0, ar, rv, rr=0;
  logic[1:0][39:0] addr;
  logic[1:0][7:0] len;
  logic[1:0][2:0] prot;
  logic[127:0] data, md=0;
  logic[1:0] resp, mrp=0;
  logic last, mav, mar=0, mrv=0, mrr, ml=0, fault;
  logic[39:0] ma;
  logic[7:0] mlen;
  logic[2:0] mp;
  pqc_axi_read_arb dut(.clk(clk),.rst_n(rst_n),.s_ar_valid(av),.s_ar_ready(ar),
    .s_ar_addr(addr),.s_ar_len(len),.s_ar_prot(prot),.s_r_valid(rv),.s_r_ready(rr),
    .s_r_data(data),.s_r_resp(resp),.s_r_last(last),.m_ar_valid(mav),.m_ar_ready(mar),
    .m_ar_addr(ma),.m_ar_len(mlen),.m_ar_prot(mp),.m_r_valid(mrv),.m_r_ready(mrr),
    .m_r_data(md),.m_r_resp(mrp),.m_r_last(ml),.fault(fault));
  task automatic beat(input int owner_id,input bit final_beat,input bit stall);
    @(negedge clk);mrv=1;ml=final_beat;md=128'h123456789abcdef;mrp=2'b10;
    rr=stall?2'b00:(2'b01 << owner_id);
    if(stall) repeat(4) begin
      #1;if(mrr || rv!==(2'b01 << owner_id) || data!==md || resp!==mrp || last!==ml || mav)
        $fatal(1,"read stall ownership/payload error");
      @(negedge clk);
    end
    rr=2'b01 << owner_id;
    #1;if(!mrr || rv!==(2'b01 << owner_id) || mav) $fatal(1,"read wrong owner");
    @(negedge clk);mrv=0;ml=0;
  endtask
  initial begin
    addr[0]=40'h1000;addr[1]=40'h2000;len[0]=0;len[1]=2;prot[0]=0;prot[1]=3'b010;
    repeat(3) @(negedge clk);rst_n=1;
    mrv=1;rr=3;#1;if(mrr || rv) $fatal(1,"unsolicited response routed");mrv=0;
    av=2'b10;@(negedge clk);
    if(!mav || ma!=addr[1]) $fatal(1,"DMA not selected");
    av=3; // higher-priority descriptor arrives after DMA AR is offered
    repeat(5) begin
      @(negedge clk);
      if(!mav || ma!=addr[1] || mlen!=2 || mp!=2 || ar) $fatal(1,"AR changed while stalled");
    end
    mar=1;#1;if(ar!==2'b10) $fatal(1,"AR ack wrong owner");
    @(negedge clk);mar=0;av=2'b01;
    beat(1,0,1);beat(1,0,0);beat(1,1,1);
    @(negedge clk);
    if(!mav || ma!=addr[0] || mlen!=0 || mp!=0) $fatal(1,"descriptor not handed over");
    mar=1;#1;if(ar!==2'b01) $fatal(1,"descriptor AR ack wrong owner");
    @(negedge clk);mar=0;av=0;
    beat(0,1,1);
    repeat(3) @(negedge clk);
    if(mav || mrr || rv || fault) $fatal(1,"not idle after last response");
    // A corrupt state must lock, not release an outstanding transaction.
    force dut.state=3'b000;@(negedge clk);release dut.state;
    if(!fault || mav || mrr || rv || ar) $fatal(1,"illegal state not fail-closed");
    $display("UT_pqc_axi_read_arb: PASS (errors=0)");$finish;
  end
  initial begin #100000;$fatal(1,"read arbitration watchdog");end
endmodule
