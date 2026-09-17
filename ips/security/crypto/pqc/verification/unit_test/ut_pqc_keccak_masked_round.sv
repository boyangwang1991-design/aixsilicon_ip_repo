`timescale 1ns/1ps
module ut_pqc_keccak_masked_round;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,in_valid=0,in_ready,random_valid=0,random_ready,random_release;
  logic out_valid,out_ready=0,zeroize_req=0,zeroize_done,fault;
  logic [1599:0] in_share0,in_share1,random_r,random_s,random_m,out_share0,out_share1;
  logic [95:0] in_token=1,random_token=1,release_token,out_token;
  logic [63:0] round_constant;
  logic [1599:0] a,mask,expected,held0,held1;
  logic [7:0] digest[0:31];
  string dir;
  int releases=0,accepted_random=0;
  logic [63:0] rng=64'h197583abcd998877;
  localparam logic [63:0] RC[0:23]='{
    64'h0000000000000001,64'h0000000000008082,64'h800000000000808a,64'h8000000080008000,
    64'h000000000000808b,64'h0000000080000001,64'h8000000080008081,64'h8000000000008009,
    64'h000000000000008a,64'h0000000000000088,64'h0000000080008009,64'h000000008000000a,
    64'h000000008000808b,64'h800000000000008b,64'h8000000000008089,64'h8000000000008003,
    64'h8000000000008002,64'h8000000000000080,64'h000000000000800a,64'h800000008000000a,
    64'h8000000080008081,64'h8000000000008080,64'h0000000080000001,64'h8000000080008008};
  pqc_keccak_masked_round dut(.*);
  // Independent scalar oracle: triangular rotation walk, no DUT rho table.
  function automatic logic [1599:0] reference_round(input logic [1599:0] s,input logic [63:0] rc);
    logic [63:0] lanes[0:24],cols[0:4],b[0:24],v;
    logic [1599:0] result;
    int x,y,nx,ny,r;
    for(int i=0;i<25;i++)lanes[i]=s[64*i+:64];
    for(int i=0;i<5;i++)cols[i]=lanes[i]^lanes[i+5]^lanes[i+10]^lanes[i+15]^lanes[i+20];
    for(int i=0;i<25;i++)begin
      v=cols[(i+1)%5];lanes[i]^=cols[(i+4)%5]^{v[62:0],v[63]};
    end
    b[0]=lanes[0];x=1;y=0;
    for(int t=0;t<24;t++)begin
      nx=y;ny=(2*x+3*y)%5;r=((t+1)*(t+2)/2)%64;v=lanes[x+5*y];
      b[nx+5*ny]=(v<<r)|(v>>(64-r));x=nx;y=ny;
    end
    for(int j=0;j<5;j++)for(int i=0;i<5;i++)
      result[(i+5*j)*64+:64]=b[i+5*j]^((~b[(i+1)%5+5*j])&b[(i+2)%5+5*j]);
    result[63:0]^=rc;return result;
  endfunction
  function automatic logic [63:0] next_rng;
    rng^=rng<<13;rng^=rng>>7;rng^=rng<<17;return rng;
  endfunction
  task automatic fresh_masks;
    for(int i=0;i<25;i++)begin
      random_r[i*64+:64]=next_rng();random_s[i*64+:64]=next_rng();random_m[i*64+:64]=next_rng();
    end
  endtask
  task automatic tick;@(posedge clk);#1;endtask
  always @(posedge clk)begin
    if(random_valid&&random_ready)accepted_random++;
    if(random_release)begin
      if(release_token!=in_token)$fatal(1,"FAIL release identity");
      releases++;
    end
  end
  task automatic do_round(input int r,input int pause_cycles);
    int guard,before_random,before_release;
    expected=reference_round(in_share0^in_share1,RC[r]);
    before_random=accepted_random;before_release=releases;
    @(negedge clk);round_constant=RC[r];in_valid=1;random_valid=0;out_ready=0;
    in_token++;random_token=in_token;fresh_masks();
    if(!in_ready)$fatal(1,"FAIL input not ready");tick();
    @(negedge clk);in_valid=0;
    repeat(pause_cycles)begin tick();if(out_valid||random_release)$fatal(1,"FAIL ran without randomness");end
    @(negedge clk);random_valid=1;#1;
    if(!random_ready)$fatal(1,"FAIL random request");tick();
    @(negedge clk);random_valid=0;random_r='0;random_s='0;random_m='0;
    guard=0;while(!out_valid&&guard<8)begin tick();guard++;end
    if(!out_valid||out_token!=in_token||(out_share0^out_share1)!==expected)$fatal(1,"FAIL masked round %0d",r);
    if(guard!=2||accepted_random!=before_random+1||releases!=before_release+1)
      $fatal(1,"FAIL round schedule or random reuse");
    held0=out_share0;held1=out_share1;
    repeat(5)begin tick();if(!out_valid||out_share0!==held0||out_share1!==held1)$fatal(1,"FAIL stalled result");end
    @(negedge clk);out_ready=1;tick();@(negedge clk);out_ready=0;
    in_share0=held0;in_share1=held1;
  endtask
  task automatic clear_round;
    @(negedge clk);zeroize_req=1;#1;
    if(in_ready||random_ready||random_release||out_valid||out_share0!='0||out_share1!='0)
      $fatal(1,"FAIL immediate revoke");
    tick();if(!zeroize_done||dut.linear0!='0||dut.linear1!='0||dut.result0!='0||dut.result1!='0||dut.chi.a0_q!='0||dut.chi.c0!='0)
      $fatal(1,"FAIL incomplete wipe");
    @(negedge clk);zeroize_req=0;in_valid=0;random_valid=0;tick();
  endtask
  initial begin
    in_share0='0;in_share1='0;random_r='0;random_s='0;random_m='0;round_constant=0;
    if(!$value$plusargs("VECTORS=%s",dir))$fatal(1,"VECTORS required");
    $readmemh($sformatf("%s/hash_0_0.hex",dir),digest,0,31);
    repeat(3)tick();@(negedge clk);rst_n=1;
    // Full SHA3-256 empty-message KAT through 24 masked rounds.
    a='0;a[7:0]=8'h06;a[135*8+:8]=8'h80;
    for(int i=0;i<25;i++)mask[i*64+:64]=next_rng();
    in_share0=mask;in_share1=mask^a;
    for(int r=0;r<24;r++)do_round(r,r%4);
    a=in_share0^in_share1;
    for(int i=0;i<32;i++)if(a[i*8+:8]!==digest[i])$fatal(1,"FAIL SHA3 empty KAT byte %0d",i);
    // Arbitrary complete states exercise all lanes, not only the digest lanes.
    for(int t=0;t<32;t++)begin
      for(int i=0;i<25;i++)begin in_share0[i*64+:64]=next_rng();in_share1[i*64+:64]=next_rng();end
      do_round(t%24,t%3);
    end
    // Cancel before random acceptance, during the gadget, and with held output.
    for(int phase=0;phase<3;phase++)begin
      @(negedge clk);in_valid=1;in_token++;random_token=in_token;fresh_masks();tick();
      @(negedge clk);in_valid=0;
      if(phase>0)begin random_valid=1;tick();@(negedge clk);random_valid=0;end
      if(phase==2)begin tick();tick();end
      clear_round();
    end
    // Wrong random identity must lock and wipe without consuming that chunk.
    @(negedge clk);in_valid=1;in_token++;tick();@(negedge clk);in_valid=0;
    random_token=in_token-1;random_valid=1;#1;
    if(random_ready)$fatal(1,"FAIL stale random accepted");tick();tick();
    if(!fault||!zeroize_done||out_valid||in_ready)$fatal(1,"FAIL stale identity did not lock and clear");
    $display("UT_pqc_keccak_masked_round: PASS (errors=0)");$finish;
  end
  initial begin #200000;$fatal(1,"TIMEOUT");end
endmodule
