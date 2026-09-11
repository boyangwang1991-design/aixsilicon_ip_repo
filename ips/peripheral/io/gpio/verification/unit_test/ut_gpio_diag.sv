`timescale 1ns/1ps
module ut_gpio_diag;
  bit clk=0;always #5 clk=~clk;
  bit rst=0,por=0;bit sync_data=0,valid=1,out=1,oe=1,owned=1,available=1,clear=0,test=0;
  bit [0:0][15:0] blank=2;bit [0:0][7:0] count=1;
  bit sleep=0,safe=0,parity_error=0;wire pending,parity_safe;int errors=0;
  gpio_diag #(.N_GPIO(1),.CFG_PARITY_EN(1)) dut(.clk_i(clk),.rst_ni(rst),.por_ni(por),
    .sync_i(sync_data),.sync_valid_i(valid),.physical_out_i(out),.physical_oe_i(oe),
    .owned_i(owned),.available_i(available),.clear_i(clear),.test_i(test),.blank_i(blank),
    .mismatch_count_i(count),.sleep_i(sleep),.safe_i(safe),.parity_error_i(parity_error),
    .pending_o(pending),.parity_safe_o(parity_safe));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  initial begin
    repeat(2)step();por=1;rst=1;step();repeat(3)step();check(!pending,"blank and mismatch threshold");
    clear=1;step();check(pending,"mismatch set wins clear");sync_data=1;step();check(!pending,"matching sample permits clear");
    test=1;step();check(pending,"software test wins clear");test=0;step();clear=0;
    parity_error=1;step();parity_error=0;check(parity_safe,"parity fault latches");
    rst=0;step();check(parity_safe&&!pending,"warm reset retains parity safe only");rst=1;step();
    por=0;#1;check(!parity_safe,"POR clears parity safe");
    if(errors)$fatal(1,"UT_GPIO_DIAG: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_DIAG: PASS (errors=0)");$finish;
  end
  initial begin #10000;$fatal(1,"TIMEOUT");end
endmodule
