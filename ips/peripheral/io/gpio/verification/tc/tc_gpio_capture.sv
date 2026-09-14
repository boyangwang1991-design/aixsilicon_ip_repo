`include "tc_base.sv"
class tc_gpio_capture extends tc_base;
 `uvm_component_utils(tc_gpio_capture)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_capture::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_capture::scenario();

 ctrl.pad='h12345678;ctrl.ticks(12);wr('h28,1);rd('h170,'h12345678);rd('h174,'1);rd('h2c,1);
 ctrl.pad='habcdef01;ctrl.ticks(12);ctrl.snapshot=1;ctrl.ticks(1);ctrl.snapshot=0;ctrl.ticks(2);rd('h170,'habcdef01);rd('h2c,2);
 ctrl.strap=1;ctrl.ticks(1);ctrl.strap=0;ctrl.ticks(2);rd('h178,'habcdef01);rd('h30,1);
 ctrl.pad=0;ctrl.ticks(10);ctrl.strap=1;ctrl.ticks(1);ctrl.strap=0;rd('h178,'habcdef01);

endtask
