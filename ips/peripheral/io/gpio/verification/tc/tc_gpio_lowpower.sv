`include "tc_base.sv"
class tc_gpio_lowpower extends tc_base;
 `uvm_component_utils(tc_gpio_lowpower)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_lowpower::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_lowpower::scenario();

 for(int mode=0;mode<4;mode++) begin
  reset();wr('h1000,mode<<10);wr('h118,1);wr('h130,1);
  ctrl.sleep_req=1;ctrl.ticks(2);expect_true(ctrl.sleep_ack,"sleep ack");
  wr('h118,0);wr('h1000,((mode+1)%4)<<10,1);
  expect_true(ctrl.out[0]==(mode==0||mode==2),"sleep output mode");expect_true(ctrl.oe[0]==(mode!=3),"sleep OE mode");
  ctrl.main_run=0;#500;expect_true(ctrl.sleep_ack,"ack held with main clock stopped");
  expect_true(ctrl.out[0]==(mode==0||mode==2),"output held with main clock stopped");
  ctrl.safe_req=1;#20;expect_true(ctrl.safe_active&&!ctrl.oe[0]&&!ctrl.out[0],"safe override during stopped main clock");
  ctrl.safe_req=0;ctrl.main_run=1;ctrl.ticks(3);ctrl.sleep_req=0;ctrl.ticks(2);
  expect_true(!ctrl.sleep_ack&&!ctrl.out[0],"exit restores updated output");
 end

endtask
