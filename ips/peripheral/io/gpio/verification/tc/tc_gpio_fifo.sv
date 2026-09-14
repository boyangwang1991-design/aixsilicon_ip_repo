`include "tc_base.sv"
class tc_gpio_fifo extends tc_base;
 `uvm_component_utils(tc_gpio_fifo)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_fifo::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_fifo::scenario();

 logic[31:0] before_head,after_head,level;
 rd('h48,0);rd('h50,0);wr('h60,1);rd('h48,0);
 wr('h40,3);wr('h44,1);wr('h1000,3<<5);wr('h144,1);wr('h16c,1);ctrl.ticks(10);
 for(int i=0;i<24;i++) begin ctrl.pad[0]=~ctrl.pad[0];ctrl.ticks(10);end
 access(0,'h48,0,level);expect_true(level==16,"FIFO depth saturation");expect_true(ctrl.dma,"FIFO watermark DMA");
 access(0,'h50,0,before_head);access(0,'h50,0,after_head);expect_true(before_head==after_head,"HEAD non-destructive read");
 wr('h60,1);rd('h48,15);wr('h64,3);rd('h48,0);rd('h4c,0);rd('h50,0);

endtask
