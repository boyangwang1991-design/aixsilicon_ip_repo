`timescale 1ns/1ps
module ut_pqc_random_service;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0;
  logic [31:0] trusted_epoch=1;
  logic [7:0] trusted_domain=8'h12;
  logic req_valid=0,req_ready;
  logic [2:0] req_consumer=0,req_purpose=0;
  logic [31:0] req_epoch=1,req_primitive=7,req_quota_bits=0,req_wait_limit=1000;
  logic [12:0] req_chunk_bits=0;
  logic entropy_valid=0,entropy_ready,entropy_health_ok=1;
  logic [63:0] entropy_data=0;
  logic [7:0] entropy_domain=8'h12;
  logic [4:0] chunk_valid,chunk_ready=0;
  logic [4:0][4799:0] chunk_data;
  logic [31:0] chunk_epoch,chunk_primitive,chunk_lease,chunk_index;
  logic [2:0] chunk_purpose;
  logic [12:0] chunk_bits;
  logic release_valid=0;
  logic [2:0] release_consumer=0;
  logic [31:0] release_epoch=1,release_primitive=7,release_lease=0,release_index=0;
  logic [12:0] next_chunk_bits=0;
  logic clear_req=0;
  logic [31:0] clear_epoch=0;
  logic [4:0] consumer_clear_done=31;
  logic [4:0][31:0] consumer_clear_epoch='0;
  logic clear_done,fault;
  logic [31:0] clear_done_epoch;
  int errors=0;
  logic [4799:0] expected;
  logic [31:0] saved_lease;
  pqc_random_service dut(.*);
  task automatic tick; @(posedge clk); #1; endtask
  task automatic check(input bit ok,input string message);
    if (!ok) begin $display("FAIL: %s at %0t",message,$time);errors++;end
  endtask
  task automatic reset_service;
    @(negedge clk);rst_n=0;req_valid=0;entropy_valid=0;chunk_ready=0;release_valid=0;
    entropy_health_ok=1;entropy_domain=8'h12;trusted_epoch=1;trusted_domain=8'h12;
    req_epoch=1;req_wait_limit=1000;clear_req=0;clear_epoch=0;
    consumer_clear_done=31;consumer_clear_epoch='0;
    tick();@(negedge clk);rst_n=1;repeat(3)tick();
    check(req_ready&&!fault,"reset reaches FREE");
  endtask
  task automatic request_chunk(input int n,input int quota,input int who);
    @(negedge clk);req_valid=1;req_chunk_bits=13'(n);req_quota_bits=32'(quota);req_consumer=3'(who);
    check(req_ready,"request accepted");tick();@(negedge clk);req_valid=0;
  endtask
  task automatic fill_chunk(input int n,input int who);
    expected='0;
    for(int b=0;b<(n+63)/64;b++)begin
      @(negedge clk);entropy_valid=1;entropy_data=64'h87654321abcdef00 ^ 64'(b);
      #1;check(entropy_ready,"entropy handshake");
      for(int j=0;j<64;j++)if(b*64+j<n)expected[b*64+j]=entropy_data[j];
      tick();
    end
    @(negedge clk);entropy_valid=0;#1;
    check(chunk_valid==(5'b1<<who),"exclusive consumer valid");
    check(chunk_bits==n&&chunk_epoch==1&&chunk_primitive==7,"chunk identity");
    for(int k=0;k<5;k++)check(chunk_data[k]==(k==who?expected:4800'd0),"data and isolation");
    repeat(4)begin tick();check(chunk_data[who]==expected&&chunk_valid==(5'b1<<who),"stalled data stable");end
    @(negedge clk);chunk_ready=(5'b1<<who);tick();
    check(chunk_valid==0&&!entropy_ready,"no second consume");
    @(negedge clk);chunk_ready=0;
  endtask
  task automatic release_chunk(input int who,input int next_bits);
    release_consumer=3'(who);release_epoch=chunk_epoch;release_primitive=chunk_primitive;
    release_lease=chunk_lease;release_index=chunk_index;next_chunk_bits=13'(next_bits);
    @(negedge clk);release_valid=1;tick();
    check(chunk_data=='0&&dut.cache=='0,"release physically clears cache");
    @(negedge clk);release_valid=0;
  endtask
  task automatic assert_cleared;
    check(dut.cache=='0&&dut.remaining==0&&dut.collected==0,"fault wipes storage");
    check(chunk_valid==0&&chunk_data=='0&&!entropy_ready&&!req_ready,"fault blocks interfaces");
  endtask
  initial begin
    reset_service();
    for(int k=0;k<6;k++)begin
      int n;
      case(k)0:n=1;1:n=63;2:n=64;3:n=65;4:n=1600;default:n=4800;endcase
      request_chunk(n,n,k%5);fill_chunk(n,k%5);release_chunk(k%5,0);
      check(req_ready&&!fault,"single chunk complete");
    end
    request_chunk(65,130,2);fill_chunk(65,2);saved_lease=chunk_lease;release_chunk(2,65);
    check(chunk_index==1&&chunk_lease==saved_lease,"same lease next chunk");
    fill_chunk(65,2);release_chunk(2,0);check(req_ready&&!fault,"quota exact complete");
    // Revocation suppresses both current result and incoming entropy immediately.
    request_chunk(64,64,3);fill_chunk(64,3);saved_lease=chunk_lease;
    @(negedge clk);clear_req=1;clear_epoch=9;consumer_clear_done=0;#1;
    check(chunk_data=='0&&!clear_done,"clear immediate revoke");tick();assert_cleared();
    consumer_clear_done=31;repeat(2)tick();check(!clear_done,"old ACK rejected");
    for(int k=0;k<5;k++)consumer_clear_epoch[k]=9;
    #1;check(clear_done&&clear_done_epoch==9,"all matching ACK");
    repeat(2)tick();check(dut.lease_counter==saved_lease,"held clear does not reuse identity");
    @(negedge clk);clear_req=0;repeat(2)tick();request_chunk(1,1,0);
    check(chunk_lease==saved_lease+1,"lease monotonic across clear");
    fill_chunk(1,0);release_chunk(0,0);
    // A malformed identity never releases data for another chunk.
    request_chunk(64,128,1);fill_chunk(64,1);
    @(negedge clk);release_valid=1;release_consumer=1;release_epoch=chunk_epoch;
    release_primitive=chunk_primitive;release_lease=chunk_lease-1;release_index=0;next_chunk_bits=64;
    tick();check(fault,"stale release rejected");tick();assert_cleared();
    reset_service();request_chunk(64,64,0);
    @(negedge clk);entropy_valid=1;entropy_domain=8'h13;#1;
    check(!entropy_ready,"wrong domain beat rejected");tick();check(fault,"wrong domain fatal");assert_cleared();
    reset_service();request_chunk(64,64,0);
    @(negedge clk);entropy_health_ok=0;#1;check(!entropy_ready,"health gates entropy");
    tick();check(fault,"health failure fatal");assert_cleared();
    reset_service();req_wait_limit=3;request_chunk(64,64,0);repeat(4)tick();
    check(fault,"bounded entropy wait");assert_cleared();
    reset_service();request_chunk(64,64,0);
    @(negedge clk);trusted_epoch=2;#1;check(!entropy_ready,"context revoke immediate");
    tick();check(fault,"context mutation fatal");assert_cleared();
    reset_service();request_chunk(0,64,0);check(fault,"zero chunk rejected");
    reset_service();request_chunk(4801,4801,0);check(fault,"oversized chunk rejected");
    reset_service();request_chunk(65,64,0);check(fault,"quota overflow rejected");
    if(errors==0)$display("UT_pqc_random_service: PASS (errors=0)");
    else $fatal(1,"UT_pqc_random_service: FAIL errors=%0d",errors);
    $finish;
  end
  initial begin #200000;$fatal(1,"TIMEOUT");end
endmodule
