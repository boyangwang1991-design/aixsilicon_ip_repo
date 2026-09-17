`timescale 1ns/1ps
module desc_fetch_case #(parameter int W=128)(output logic finished=0);
  localparam int BYTES=W/8, BEATS=128/BYTES;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,start=0,busy,done,error,av,ar=0,rv=0,rr,rl=0,z=0,zd;
  logic[39:0] addr, request_addr=40'h1800;
  logic[7:0] len,data,idx;
  logic[2:0] prot;
  logic[W-1:0] rd=0;
  logic[1:0] resp=0;
  logic valid;
  int seen=0;
  pqc_desc_fetch #(.DATA_WIDTH(W),.WIN_BASE(40'h1000),.WIN_LIMIT(40'h00ffffffbf)) dut(.clk(clk),.rst_n(rst_n),.start(start),
    .addr(request_addr),.busy(busy),.done(done),.error(error),.m_ar_valid(av),.m_ar_ready(ar),
    .m_ar_addr(addr),.m_ar_len(len),.m_ar_prot(prot),.m_r_valid(rv),.m_r_ready(rr),
    .m_r_data(rd),.m_r_resp(resp),.m_r_last(rl),.desc_data(data),.desc_data_idx(idx),
    .desc_data_valid(valid),.zeroize_req(z),.zeroize_done(zd));
  always @(posedge clk) if(rst_n && valid) begin
    if(z || seen>=128 || idx!==8'(seen) || data!==8'(seen))
      $fatal(1,"W=%0d descriptor byte %0d wrong or leaked during cancel",W,seen);
    seen++;
  end
  task automatic reset_dut;
    @(negedge clk);rst_n=0;start=0;rv=0;ar=0;z=0;resp=0;seen=0;request_addr=40'h1800;
    repeat(3) @(negedge clk);rst_n=1;
  endtask
  task automatic launch;
    @(negedge clk);start=1;
    @(negedge clk);
    if(!av || addr!=40'h1800 || len!=BEATS-1) $fatal(1,"descriptor AR geometry");
    repeat(3) @(negedge clk);
    ar=1;@(negedge clk);ar=0;
  endtask
  task automatic send_beat(input int n,input bit last_beat);
    int guard;
    @(negedge clk);
    for(int j=0;j<BYTES;j++) rd[j*8+:8]=8'(n*BYTES+j);
    rv=1;rl=last_beat;
    guard=0;
    do begin @(posedge clk);guard++;end while(!rr && guard<200);
    if(!rr) $fatal(1,"descriptor R stalled forever");
    @(negedge clk);rv=0;
  endtask
  initial begin
    reset_dut();launch();
    for(int i=0;i<BEATS;i++) send_beat(i,i==BEATS-1);
    repeat(BYTES+3) @(negedge clk);
    if(!done || error || seen!=128) $fatal(1,"descriptor normal completion");
    start=0;repeat(3) @(negedge clk);
    if(busy || done || error) $fatal(1,"descriptor terminal state not retired");
    reset_dut();launch();resp=2'b10;send_beat(0,1);
    if(!error || done || seen) $fatal(1,"bad RRESP emitted data");
    reset_dut();launch();send_beat(0,1);
    if(!error || done || seen) $fatal(1,"early RLAST accepted");
    reset_dut();
    @(negedge clk);start=1;
    @(negedge clk);z=1;start=0;
    repeat(3) begin
      @(negedge clk);
      if(!av || addr!=40'h1800 || zd) $fatal(1,"cancel withdrew AR");
    end
    ar=1;@(negedge clk);ar=0;
    for(int i=0;i<BEATS;i++) begin
      if(zd) $fatal(1,"premature cancel acknowledgement");
      send_beat(i,i==BEATS-1);
    end
    repeat(2) @(negedge clk);
    if(!zd || seen || done || dut.hold!=='0 || dut.addr_q!=='0 || dut.beat_cnt!=='0)
      $fatal(1,"descriptor cancellation did not drain and wipe");
    // Reject the whole range before exposing AR, including high address bits.
    for(int bad=0;bad<5;bad++)begin
      reset_dut();
      case(bad)
        0:request_addr=40'h1801;
        1:request_addr=40'h0f80;
        2:request_addr=40'h0100000000;
        3:request_addr=40'h00ffffff80;
        4:request_addr=40'hffffffff80;
      endcase
      @(negedge clk);start=1;ar=1;
      repeat(4)begin
        @(negedge clk);
        if(av || valid || done || !error || seen) $fatal(1,"invalid descriptor address issued AR W=%0d case=%0d",W,bad);
      end
      start=0;@(negedge clk);
      if(error || busy) $fatal(1,"invalid address did not retire");
    end
    // Last complete aligned descriptor inside the configured upper boundary.
    reset_dut();request_addr=40'h00ffffff00;
    @(negedge clk);start=1;
    @(negedge clk);
    if(!av || addr!=request_addr) $fatal(1,"valid upper range rejected");
    ar=1;@(negedge clk);ar=0;
    for(int i=0;i<BEATS;i++)send_beat(i,i==BEATS-1);
    repeat(BYTES+3) @(negedge clk);
    if(!done || error || seen!=128) $fatal(1,"valid upper range completion");
    finished=1;
  end
  initial begin #100000;$fatal(1,"descriptor watchdog W=%0d",W);end
endmodule
module ut_pqc_desc_fetch;
  wire a,b,c;
  desc_fetch_case #(.W(64)) d64(a);
  desc_fetch_case #(.W(128)) d128(b);
  desc_fetch_case #(.W(256)) d256(c);
  initial begin wait(a&&b&&c);$display("UT_pqc_desc_fetch: PASS (errors=0)");$finish;end
endmodule
