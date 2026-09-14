`include "tc_base.sv"
class tc_gpio_apb extends tc_base;
 `uvm_component_utils(tc_gpio_apb)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_apb::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_apb::scenario();

 logic[31:0] value,before_value,mask;bit bad;
 rd('h0,'h4750494f);wr('h118,'h13579bdf);
 for(int prot=0;prot<8;prot++) for(int strb=0;strb<16;strb++) begin
  bad=prot!=1;access(0,'h118,0,before_value);
  access(1,'h118,$urandom,value,bad,4'(strb),3'(prot),1+(strb%3));
  access(0,'h118,0,value,bad,4'(strb),3'(prot));
  if(bad) rd('h118,before_value);
 end
 wr(0,1,1);rd(1,0,'1,1);rd('h3ffc,0,'1,1);rd('h11c,0);
 wr('h118,32'hfedcba98);wr('h118,0,0,0);rd('h118,32'hfedcba98);

endtask
