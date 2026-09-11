`timescale 1ns/1ps
module ut_gpio_irq;
  bit clk=0;always #5 clk=~clk;
  bit rst=0;bit [1:0] data=0,valid=0,detect=3,en=3,restart=0,clear=0,rclear=0,fclear=0,test=0;
  bit [1:0][2:0] mode='{3,3};bit [1:0][1:0] group='{1,0};
  wire [1:0] pending,rising,falling,event_p,edge_now,rise_now,pins,groups;wire summary;
  int errors=0;
  gpio_irq #(.N_GPIO(2),.N_IRQ_GROUPS(2)) dut(.clk_i(clk),.rst_ni(rst),.data_i(data),.valid_i(valid),
    .detect_i(detect),.enable_i(en),.restart_i(restart),.mode_i(mode),.group_i(group),
    .clear_i(clear),.rising_clear_i(rclear),.falling_clear_i(fclear),.test_i(test),
    .pending_o(pending),.rising_o(rising),.falling_o(falling),.event_o(event_p),.edge_now_o(edge_now),
    .rise_now_o(rise_now),.irq_pin_o(pins),.irq_group_o(groups),.irq_summary_o(summary));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  initial begin
    repeat(2)step();rst=1;data=3;valid=3;step();check(pending===0,"first valid establishes baseline");
    data=0;step();check(falling===3&&event_p===3&&groups===3&&summary,"falling both pins/groups");
    clear=3;fclear=3;rclear=3;data=3;step();check(pending===3&&rising===3&&falling===0,"edge set wins W1C");
    step();clear=0;rclear=0;fclear=0;check(pending===0&&event_p===0,"clear without event");
    en=0;test=1;step();test=0;check(pending===1&&pins===0&&!summary,"masked software pending");
    en=1;#1;check(pins===1&&groups===1,"enable exposes pending");
    clear=3;restart=3;data=0;step();check(pending===0&&event_p===0,"restart suppresses edge");
    restart=0;mode[0]=4;data=1;step();check(pending[0],"level set wins clear");
    step();check(pending[0]&&!event_p[0],"level retrigger without FIFO edge");
    data=0;step();check(!pending[0],"level clear when deasserted");
    if(errors)$fatal(1,"UT_GPIO_IRQ: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_IRQ: PASS (errors=0)");$finish;
  end
  initial begin #10000;$fatal(1,"TIMEOUT");end
endmodule
