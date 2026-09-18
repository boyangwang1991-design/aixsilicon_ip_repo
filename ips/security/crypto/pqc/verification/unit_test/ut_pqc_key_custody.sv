`timescale 1ns/1ps
module ut_pqc_key_custody;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,clear=0,start=0;
  logic [31:0] transaction=1,epoch=2,handle=3;
  logic [7:0] owner=4,domain=5;
  logic [3:0] algo=1,pset=1;
  logic [15:0] bytes=32;
  logic busy,done,error,header_valid,header_ready=0;
  logic [31:0] out_transaction,out_epoch,out_handle;
  logic [7:0] out_owner,out_domain;
  logic [3:0] out_algo,out_pset;
  logic [15:0] out_bytes;
  logic word_valid,word_ready=0,word_last;
  logic [31:0] word_data;
  logic ack_valid=0,ack_ready,ack_success=1;
  logic [31:0] ack_transaction=1,ack_epoch=2,ack_handle=3;
  logic [7:0] ack_owner=4,ack_domain=5;
  logic [15:0] ack_bytes=32,read_word;
  logic read_req,read_valid=0,read_error=0;
  logic [31:0] read_data=0;
  logic fail_read=0;
  integer errors=0;
  pqc_key_custody #(.MAX_CYCLES(300)) dut(.*);
  always @(posedge clk) begin
    read_valid<=read_req && !fail_read;
    read_error<=read_req && fail_read;
    read_data<=32'h12340000+read_word;
  end
  task check(input bit condition,input string why);
    if(!condition) begin errors++;$display("FAIL: %s",why);end
  endtask
  task tick;@(posedge clk);#1;endtask
  task pulse_start;
    @(negedge clk);start=1;tick();@(negedge clk);start=0;
  endtask
  task reset_case;
    @(negedge clk);clear=1;ack_valid=0;header_ready=0;word_ready=0;fail_read=0;
    tick();check(!done && !word_valid && !header_valid && word_data==0,"clear suppresses outputs");
    @(negedge clk);clear=0;ack_success=1;
    transaction=1;epoch=2;handle=3;owner=4;domain=5;bytes=32;
    ack_transaction=1;ack_epoch=2;ack_handle=3;ack_owner=4;ack_domain=5;ack_bytes=32;
  endtask
  task transfer;
    int n,waits;
    pulse_start();
    @(negedge clk);transaction=55;epoch=66;handle=77;owner=88;domain=99;bytes=64;
    repeat(5) begin tick();check(header_valid && out_transaction==1 && out_epoch==2 && out_handle==3 && out_bytes==32,"header snapshot/hold");end
    @(negedge clk);header_ready=1;tick();@(negedge clk);header_ready=0;
    for(n=0;n<8;n++) begin
      waits=0;
      while(!word_valid && waits<20) begin tick();waits++;end
      check(word_valid,"bounded read response");
      check(word_data==32'h12340000+n && word_last==(n==7),"word data and last");
      repeat(3) begin tick();check(word_valid && word_data==32'h12340000+n,"word held under stall");end
      @(negedge clk);word_ready=1;tick();@(negedge clk);word_ready=0;
    end
    check(ack_ready && !done,"wait for explicit ACK");
  endtask
  initial begin
    repeat(3) tick();@(negedge clk);rst_n=1;
    reset_case();transfer();
    // Every identity component independently prevents retirement.
    for(int f=0;f<6;f++) begin
      @(negedge clk);ack_valid=1;
      case(f)
        0:ack_transaction=99;1:ack_epoch=99;2:ack_handle=99;
        3:ack_owner=99;4:ack_domain=99;5:ack_bytes=64;
      endcase
      tick();check(ack_ready && !done && !error,"wrong ACK identity rejected");
      @(negedge clk);ack_valid=0;ack_transaction=1;ack_epoch=2;ack_handle=3;ack_owner=4;ack_domain=5;ack_bytes=32;
    end
    @(negedge clk);ack_valid=1;tick();check(done && !error,"matched success completes");
    tick();check(!done,"duplicate ACK does not repeat completion");
    reset_case();transfer();@(negedge clk);ack_valid=1;ack_success=0;tick();check(error && !done,"matched NACK fails");
    reset_case();transfer();@(negedge clk);ack_valid=1;clear=1;tick();check(!done && !error && word_data==0,"clear wins over ACK");
    reset_case();pulse_start();repeat(305) tick();check(error && !done,"header timeout fails");
    reset_case();pulse_start();@(negedge clk);header_ready=1;fail_read=1;
    repeat(8) tick();check(error && !word_valid && word_data==0,"read error suppresses private output");
    reset_case();pulse_start();@(negedge clk);header_ready=1;
    repeat(8) tick();check(word_valid,"stream active before revocation");
    @(negedge clk);word_ready=1;clear=1;#1;check(!word_valid && word_data==0,"clear cancels same-cycle word acceptance");
    tick();check(!done,"revoked stream cannot complete");
    if(errors==0)$display("UT_pqc_key_custody: PASS (errors=0)");
    else $fatal(1,"UT_pqc_key_custody: FAIL errors=%0d",errors);
    $finish;
  end
  initial begin #100000;$fatal(1,"TIMEOUT");end
endmodule
