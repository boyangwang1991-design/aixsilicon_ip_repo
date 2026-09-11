`timescale 1ns/1ps
module ut_gpio_output;
  bit clk=0;always #5 clk=~clk;
  bit rst=0;bit [3:0] data=0,oe=15,inv=0,od=0,owned=15;bit [3:0][1:0] mode=0;
  bit sleep=0,safe=0,parity=0;wire [3:0] out,drive;wire ack,active;int errors=0;
  gpio_output #(.N_GPIO(4),.OUTPUT_CAP_MASK(4'b0111),.HW_SAFE_OUT(4'b0101),.HW_SAFE_OE(4'b1111)) dut(
    .clk_i(clk),.rst_ni(rst),.data_i(data),.oe_i(oe),.invert_i(inv),.open_drain_i(od),
    .owned_i(owned),.sleep_mode_i(mode),.sleep_req_i(sleep),.safe_req_i(safe),.parity_safe_i(parity),
    .out_o(out),.oe_o(drive),.sleep_ack_o(ack),.safe_active_o(active));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  initial begin
    repeat(2)step();check(out===0&&drive===0&&!ack&&!active,"reset priority");rst=1;
    data=5;inv=3;#1;check(out===6&&drive===7,"xor and capability guard");od=7;#1;
    check(out===0&&drive===1,"open drain release");od=0;inv=0;data=1;
    mode[0]=0;mode[1]=1;mode[2]=2;mode[3]=3;sleep=1;step();data=0;#1;
    check(ack&&out===5&&drive===7,"hold/low/high/hiZ sleep modes");
    owned=6;safe=1;#1;check(active&&out===5&&drive===6,"safe priority and ownership");
    safe=0;parity=1;#1;check(active&&drive===6,"parity safe");rst=0;#1;
    check(!active&&out===0&&drive===0,"reset over safe");
    if(errors)$fatal(1,"UT_GPIO_OUTPUT: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_OUTPUT: PASS (errors=0)");$finish;
  end
  initial begin #10000;$fatal(1,"TIMEOUT");end
endmodule
