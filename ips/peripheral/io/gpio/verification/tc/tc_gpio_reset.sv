`include "tc_base.sv"
class tc_gpio_reset extends tc_base;
 `uvm_component_utils(tc_gpio_reset)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_reset::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_reset::scenario();

 wr('h118,'h55);wr('h130,'1);wr('h164,1);reset(1);rd('h118,0);rd('h130,0);rd('h164,1);
 expect_true(ctrl.oe==0,"warm reset defaults OE");reset();rd('h164,0);rd('h118,0);
 for(int i=0;i<5;i++) begin wr('h118,$urandom);reset(i%2);rd('h118,0);expect_true(!ctrl.sleep_ack&&!ctrl.safe_active,"reset LP defaults");end

endtask
