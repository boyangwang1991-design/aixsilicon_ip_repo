`include "tc_base.sv"
class tc_gpio_diag extends tc_base;
 `uvm_component_utils(tc_gpio_diag)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_diag::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_diag::scenario();

 wr('h100c,0,1);wr('h100c,4);wr('h118,1);wr('h130,1);ctrl.pad[0]=0;ctrl.ticks(20);rd('h180,1,1);
 ctrl.pad[0]=1;ctrl.ticks(12);wr('h180,1);ctrl.ticks(3);rd('h180,0,1);
 ctrl.available[0]=0;ctrl.pad[0]=0;ctrl.ticks(20);rd('h180,0,1);

endtask
