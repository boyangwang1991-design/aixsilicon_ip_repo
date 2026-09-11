`timescale 1ns/1ps
module ut_gpio_input;
  bit clk=0;always #5 clk=~clk;
  bit rst=0;bit [1:0] pad=0,available=3,en=3,filter_en=0,debounce=0,inv=0,restart=0;
  bit [1:0][7:0] fc=0,dc=0;bit [0:0][15:0] divider=0;bit [0:0] dw=0;
  wire [1:0] sync_data,sync_valid,data,valid;int errors=0;
  gpio_input #(.N_GPIO(2),.SYNC_STAGES(2),.INPUT_CAP_MASK(2'b01)) dut(.clk_i(clk),.rst_ni(rst),
    .pad_i(pad),.available_i(available),.enable_i(en),.filter_enable_i(filter_en),.debounce_enable_i(debounce),
    .invert_i(inv),.restart_i(restart),.filter_count_i(fc),.debounce_count_i(dc),.divider_i(divider),
    .divider_write_i(dw),.sync_o(sync_data),.sync_valid_o(sync_valid),.data_o(data),.valid_o(valid));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  initial begin
    repeat(2)step();rst=1;pad=3;step();check(valid===0,"pipeline fill 1");step();
    check(sync_valid===1&&sync_data===1&&valid===0,"sync fill precedes data register");step();
    check(valid===1&&data===1,"registered valid and capability mask");
    inv=1;step();check(data===0,"input inversion");inv=0;
    restart=1;filter_en=1;fc[0]=2;step();restart=0;repeat(4)step();
    check(!valid[0],"three stable filter samples not yet complete");repeat(2)step();check(valid[0]&&data[0],"filter count plus one");
    pad=0;step();pad=1;repeat(6)step();check(data[0],"short glitch filtered");
    debounce=1;dc[0]=1;divider=1;dw=1;step();dw=0;check(!valid[0],"divider write restarts debounce");
    repeat(20)step();check(valid[0]&&data[0],"filtered/debounced pipeline fills");
    available=0;step();check(valid===0&&data===0,"unavailable clears validity");
    if(errors)$fatal(1,"UT_GPIO_INPUT: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_INPUT: PASS (errors=0)");$finish;
  end
  initial begin #10000;$fatal(1,"TIMEOUT");end
endmodule
