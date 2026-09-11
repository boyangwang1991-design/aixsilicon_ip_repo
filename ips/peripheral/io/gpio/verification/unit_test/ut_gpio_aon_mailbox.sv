`timescale 1ns/1ps
module ut_gpio_aon_mailbox;
  bit clk=0,aon_clk=0;bit main_run=1,aon_run=1;
  time phalf=5ns,ahalf=7ns;
  always begin #(phalf);if(main_run)clk=~clk;else clk=0;end
  initial begin #3ns;forever begin #(ahalf);if(aon_run)aon_clk=~aon_clk;else aon_clk=0;end end
  bit por=0,rst=0,aon_rst=0,command=0;bit [15:0] request=0;bit [1:0] bank=0;
  bit [23:0] timeout_limit=16;bit clear_timeout=0,clear_error=0;
  wire ready,busy,done,timed_out,error,timeout_fault,error_fault;
  wire [1:0] reply_bank;wire [15:0] response,aon_request;wire response_valid,aon_command;
  bit aon_response_valid=0,aon_error=0;bit [15:0] aon_response=0;
  bit responder=1;int delay_count=0,deliveries=0,errors=0;
  gpio_aon_mailbox #(.REQUEST_W(16),.RESPONSE_W(16)) dut(.clk_i(clk),.por_ni(por),.rst_ni(rst),
    .aon_clk_i(aon_clk),.aon_rst_ni(aon_rst),.command_i(command),.request_i(request),.bank_i(bank),
    .timeout_i(timeout_limit),.clear_timeout_fault_i(clear_timeout),.clear_error_fault_i(clear_error),
    .ready_o(ready),.busy_o(busy),.done_o(done),.timeout_o(timed_out),.error_o(error),
    .timeout_fault_o(timeout_fault),.error_fault_o(error_fault),.bank_o(reply_bank),.response_o(response),
    .response_valid_o(response_valid),.aon_command_o(aon_command),.aon_request_o(aon_request),
    .aon_response_valid_i(aon_response_valid),.aon_error_i(aon_error),.aon_response_i(aon_response));
  always @(posedge aon_clk) begin
    if(!aon_rst)begin delay_count<=0;aon_response_valid<=0;end
    else begin
      aon_response_valid<=0;
      if(aon_command)begin
        deliveries<=deliveries+1;delay_count<=3;aon_response<=aon_request^16'h5aa5;
      end else if(responder&&delay_count>0)begin
        delay_count<=delay_count-1;if(delay_count==1)aon_response_valid<=1;
      end
    end
  end
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  task await_ready;
    int n;n=0;while(!ready&&n<200)begin step();n++;end
    check(ready,"mailbox recovery deadline");
  endtask
  task send(input bit [15:0] payload);
    await_ready();request=payload;command=1;step();command=0;
    check(busy&&!ready&&!done,"accept enters busy");
  endtask
  task cold_reset;
    command=0;por=0;rst=0;aon_rst=0;responder=1;aon_run=1;main_run=1;
    repeat(4)step();por=1;rst=1;aon_rst=1;await_ready();
  endtask
  initial begin
    int old_count;
    for(int ratio=0;ratio<3;ratio++)begin
      phalf=ratio==1?11ns:5ns;ahalf=ratio==2?3ns:7ns;
      for(int reset_point=0;reset_point<3;reset_point++)begin
        cold_reset();old_count=deliveries;responder=0;send(16'h1200+16'(ratio*16+reset_point));
        if(reset_point>0)repeat(8)step();
        if(reset_point==2)begin responder=1;repeat(20)step();end
        rst=0;repeat(3)step();rst=1;responder=1;await_ready();repeat(8)step();
        check(deliveries==old_count+1,"warm reset never repeats old command");
        old_count=deliveries;send(16'h34ab);await_ready();
        check(done&&response===16'h6e0e&&deliveries==old_count+1,"new response after recovery");
      end
    end
    cold_reset();@(negedge aon_clk);aon_run=0;old_count=deliveries;send(16'h7788);
    request=16'hffff;repeat(20)step();check(timed_out&&timeout_fault&&busy&&!ready,"stop clock timeout retains slot");
    check(aon_request===16'h7788&&deliveries==old_count,"held payload without destination clock");
    command=1;step();command=0;check(aon_request===16'h7788,"busy command cannot overwrite");
    aon_run=1;await_ready();check(done&&response===(16'h7788^16'h5aa5)&&deliveries==old_count+1,"late ACK exactly once");
    check(timed_out&&timeout_fault,"timeout local and sticky state preserved");
    send(16'h1122);check(!timed_out&&timeout_fault,"next command clears local only");await_ready();
    clear_timeout=1;step();clear_timeout=0;check(!timeout_fault,"explicit sticky clear");
    if(errors)$fatal(1,"UT_GPIO_AON_MAILBOX: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_AON_MAILBOX: PASS (errors=0)");$finish;
  end
  initial begin #200000;$fatal(1,"mailbox wall-clock TIMEOUT");end
endmodule
