`include "tc_base.sv"
class tc_gpio_input extends tc_base;
 `uvm_component_utils(tc_gpio_input)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_input::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_input::scenario();

 ctrl.pad='h55aa55aa;ctrl.ticks(12);rd('h108,'h55aa55aa);rd('h10c,'h55aa55aa);rd('h110,'1);
 ctrl.available[0]=0;ctrl.ticks(3);rd('h110,0,1);rd('h10c,0,1);
 ctrl.pad[0]=1;ctrl.available[0]=1;ctrl.ticks(12);rd('h110,1,1);rd('h10c,1,1);
 wr('h114,0);ctrl.ticks(3);rd('h110,0);wr('h114,'1);ctrl.ticks(12);rd('h10c,'h55aa55ab);

endtask
