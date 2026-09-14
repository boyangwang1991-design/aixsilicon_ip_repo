`include "tc_base.sv"
class tc_gpio_filter extends tc_base;
 `uvm_component_utils(tc_gpio_filter)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_filter::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_filter::scenario();

 int bounds[4]='{0,1,254,255};
 foreach(bounds[i]) begin
  reset();wr('h1004,bounds[i]);wr('h1000,1);ctrl.pad[0]=1;
  ctrl.ticks(bounds[i]+16);rd('h10c,1,1);
  ctrl.pad[0]=0;ctrl.ticks(bounds[i]+16);rd('h10c,0,1);
  wr('h1008,bounds[i]);wr('h168,1);wr('h1000,2);ctrl.pad[0]=1;
  ctrl.ticks((bounds[i]+1)*2+20);rd('h10c,1,1);
 end
 reset();wr('h168,65535);wr('h1008,0);wr('h1000,2);ctrl.pad[0]=1;ctrl.ticks(131100);rd('h10c,1,1);

endtask
