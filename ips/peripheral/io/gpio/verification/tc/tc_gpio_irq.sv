`include "tc_base.sv"
class tc_gpio_irq extends tc_base;
 `uvm_component_utils(tc_gpio_irq)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_irq::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_irq::scenario();

 for(int mode=1;mode<=5;mode++) begin
  reset();wr('h1000,mode<<5);wr('h144,1);wr('h148,1);ctrl.ticks(10);
  ctrl.pad[0]=(mode==2||mode==5)?1:0;ctrl.ticks(12);wr('h14c,1);wr('h158,1);wr('h15c,1);
  ctrl.pad[0]=(mode==2||mode==5)?0:1;ctrl.ticks(12);rd('h14c,1,1);expect_true(ctrl.irq[0]&&ctrl.irq_summary,"IRQ pin and summary");
  wr('h148,0);ctrl.ticks(2);expect_true(!ctrl.irq[0],"IRQ mask retains pending");rd('h14c,1,1);
 end

endtask
