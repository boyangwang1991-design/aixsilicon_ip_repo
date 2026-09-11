`timescale 1ns/1ps
module ut_gpio_aon_wake;
  bit clk=0;always #7 clk=~clk;
  bit rst=0,command=0;bit [3:0] pad=0,available=15;bit [223:0] request=0;
  wire response_valid,error,wake;wire [351:0] response;int errors=0;
  gpio_aon_wake #(.N_GPIO(4),.INPUT_CAP_MASK(4'b0111)) dut(.clk_i(clk),.rst_ni(rst),
    .pad_i(pad),.available_i(available),.command_i(command),.request_i(request),
    .response_valid_o(response_valid),.error_o(error),.response_o(response),.wake_req_o(wake));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  task send(input bit [3:0] cmd,input bit expected_error);
    request[3:0]=cmd;command=1;step();check(response_valid&&error===expected_error,"AON response/error");command=0;step();
  endtask
  initial begin
    repeat(2)step();rst=1;request[37:6]=1;request[69:38]=1;send(1,0);
    check(response[127:96]===1,"commit active enable");repeat(10)step();check(!wake,"first sample baseline");
    pad=1;repeat(10)step();check(wake,"rising wake");send(2,0);check(response[31:0]===1,"snapshot pending");
    request[189:158]=1;send(4,0);check(!wake&&response[31:0]===0,"clear pending");send(8,0);
    check(response[95:64]===1,"lock one pin");request[37:6]=0;send(1,1);
    check(response[127:96]===1,"locked commit rejected atomically");request[37:6]=1;request[149:134]=1;send(1,1);
    request[149:134]=0;send(1,0);send(3,1);
    request[37:6]=9;send(1,1);check(response[127:96]===1,"capability violation atomic");
    request[5:4]=1;send(2,1);request[5:4]=0;rst=0;step();check(!wake,"cold reset");
    if(errors)$fatal(1,"UT_GPIO_AON_WAKE: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_AON_WAKE: PASS (errors=0)");$finish;
  end
  initial begin #20000;$fatal(1,"TIMEOUT");end
endmodule
