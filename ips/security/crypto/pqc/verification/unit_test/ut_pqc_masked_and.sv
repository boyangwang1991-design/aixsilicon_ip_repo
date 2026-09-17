`timescale 1ns/1ps
module masked_and_case #(parameter int W=1)(output logic finished=0);
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0, iv=0, ir, ov, ready=0, clear=0, cleared;
  logic [W-1:0] a0, a1, b0, b1, r, s, m, c0, c1;
  logic [31:0] it=0, ot;
  logic [W-1:0] expected[0:4095];
  logic [31:0] tokens[0:4095];
  int wr=0, rd=0, total=0;
  bit stalled=0;
  logic [W-1:0] held0, held1;
  logic [31:0] held_token;
  pqc_masked_and #(.WIDTH(W)) dut(
    .clk(clk),.rst_n(rst_n),.in_valid(iv),.in_ready(ir),
    .a0(a0),.a1(a1),.b0(b0),.b1(b1),.random_r(r),.random_s(s),.random_m(m),
    .in_token(it),.out_valid(ov),.out_ready(ready),.c0(c0),.c1(c1),.out_token(ot),
    .zeroize_req(clear),.zeroize_done(cleared));

  always @(posedge clk) begin
    if (!rst_n || clear) begin
      wr=0; rd=0; stalled=0;
    end else begin
      if (stalled && (ov !== 1'b1 || c0 !== held0 || c1 !== held1 || ot !== held_token))
        $fatal(1,"W=%0d output changed under backpressure",W);
      if (iv && ir) begin
        expected[wr] = (a0 ^ a1) & (b0 ^ b1);
        tokens[wr] = it; wr++;
      end
      if (ov && ready) begin
        if (rd >= wr || (c0 ^ c1) !== expected[rd] || ot !== tokens[rd])
          $fatal(1,"W=%0d wrong product/token at %0d",W,rd);
        rd++; total++;
      end
      stalled = ov && !ready;
      held0=c0; held1=c1; held_token=ot;
    end
  end

  task automatic send(input int v);
    @(negedge clk);
    // WIDTH=1 exhausts all four input-share bits and three fresh bits.
    // Wide instances also exercise nonuniform lanes and parameter widths.
    for(int j=0;j<W;j++) begin
      a0[j]=1'((v+j)>>0); a1[j]=1'((v+j)>>1);
      b0[j]=1'((v+j)>>2); b1[j]=1'((v+j)>>3);
      r[j]=1'((v+j)>>4); s[j]=1'((v+j)>>5); m[j]=1'((v+j)>>6);
    end
    it=32'(v); iv=1;
    @(posedge clk);
    while(!ir) @(posedge clk);
    @(negedge clk); iv=0;
  endtask

  task automatic fill_stalled(input int first_token);
    @(negedge clk);ready=0;iv=1;it=32'(first_token);
    @(negedge clk);it=32'(first_token+1);
    @(negedge clk);iv=0;
  endtask

  initial begin
    a0='0;a1='0;b0='0;b1='0;r='0;s='0;m='0;
    repeat(3) @(negedge clk);rst_n=1;ready=1;
    for(int v=0;v<128;v++) send(v);
    repeat(5) @(negedge clk);
    if(total!=128 || rd!=wr) $fatal(1,"exhaustive products incomplete");
    // Fill both pipeline stages, then hold both stages for many cycles.
    fill_stalled(128);
    repeat(12) @(negedge clk);
    if(ir || !ov) $fatal(1,"full pipeline did not backpressure");
    ready=1;repeat(5) @(negedge clk);
    if(total!=130 || rd!=wr) $fatal(1,"stalled products lost");
    // Cancellation wins over simultaneous input and output handshakes.
    fill_stalled(130);
    @(negedge clk); clear=1; iv=1;ready=1;
    #1;if(ir || ov) $fatal(1,"clear failed to suppress handshake");
    @(negedge clk);
    if(!cleared || c0!=='0 || c1!=='0 || ot!=='0 || dut.v1 || dut.v2)
      $fatal(1,"clear did not wipe pipeline");
    clear=0;iv=0;repeat(3) @(negedge clk);
    if(ov || cleared || total!=130) $fatal(1,"cancelled output resurrected");
    send(132);repeat(4) @(negedge clk);
    if(total!=131 || rd!=wr) $fatal(1,"restart failed");
    // Full-rate traffic: one accepted operand and result per enabled cycle.
    for(int v=0;v<32;v++) begin
      @(negedge clk); iv=1;it=32'(200+v);a0=W'(v);a1=~W'(v);
      b0=W'(v*3);b1=W'(v+1);r=W'(v+7);s=W'(v+9);m=W'(v+11);
    end
    @(negedge clk);iv=0;repeat(5) @(negedge clk);
    if(total!=163 || rd!=wr) $fatal(1,"back-to-back transaction loss");
    finished=1;
  end
  initial begin #1000000;$fatal(1,"masked AND watchdog W=%0d",W);end
endmodule

module ut_pqc_masked_and;
  wire a,b,c;
  masked_and_case #(.W(1)) small_case(a);
  masked_and_case #(.W(13)) odd_case(b);
  masked_and_case #(.W(1600)) keccak_case(c);
  initial begin
    wait(a&&b&&c);
    $display("UT_pqc_masked_and: PASS (errors=0)");$finish;
  end
endmodule
