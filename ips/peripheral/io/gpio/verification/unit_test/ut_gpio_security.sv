`timescale 1ns/1ps
module ut_gpio_security;
  bit clk=0;always #5 clk=~clk;
  bit por=0;bit [3:0] cfg=0,data=0;bit global_set=0,write_access=0;bit [1:0] access=0;
  wire [3:0] cfg_lock,data_lock;wire global_lock;wire [1:0] policy;
  int errors=0;
  gpio_security #(.N_GPIO(4)) dut(.clk_i(clk),.por_ni(por),.cfg_set_i(cfg),.data_set_i(data),
    .global_set_i(global_set),.access_write_i(write_access),.access_value_i(access),
    .cfg_lock_o(cfg_lock),.data_lock_o(data_lock),.global_lock_o(global_lock),.access_cfg_o(policy));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  initial begin
    repeat(2)step();check(cfg_lock===0&&data_lock===0&&!global_lock&&policy===3,"POR reset");por=1;
    cfg=5;data=2;global_set=1;step();cfg=8;data=1;global_set=0;step();
    check(cfg_lock===13&&data_lock===3&&global_lock,"W1S union");cfg=0;data=0;repeat(3)step();
    check(cfg_lock===13&&data_lock===3&&global_lock,"zero writes preserve locks");
    access=2;write_access=1;step();write_access=0;access=0;step();check(policy===2,"policy write and hold");
    por=0;#1;check(cfg_lock===0&&data_lock===0&&!global_lock&&policy===3,"asynchronous POR clears locks");
    if(errors)$fatal(1,"UT_GPIO_SECURITY: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_SECURITY: PASS (errors=0)");$finish;
  end
  initial begin #10000;$fatal(1,"TIMEOUT");end
endmodule
