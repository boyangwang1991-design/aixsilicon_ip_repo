`include "tc_base.sv"
class tc_gpio_security extends tc_base;
 `uvm_component_utils(tc_gpio_security)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_security::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_security::scenario();

 wr('h118,'h55);wr('h164,1);wr('h11c,3,1);rd('h118,'h55);
 reset(1);rd('h164,1);wr('h118,1,1);rd('h118,0);
 reset();rd('h164,0);wr('h160,1);wr('h1000,4,1);rd('h1000,0);
 wr('h10,1);wr('h14,0,1);rd('h14,3);

endtask
