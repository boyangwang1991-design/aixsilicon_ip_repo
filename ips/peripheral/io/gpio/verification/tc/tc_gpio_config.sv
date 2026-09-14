`include "tc_base.sv"
class tc_gpio_config extends tc_base;
 `uvm_component_utils(tc_gpio_config)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_config::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_config::scenario();

 logic[31:0] geometry,value;int banks;bit[31:0] tail;
 access(0,'hc,0,geometry);expect_true(geometry[7:0]==ctrl.width,"geometry pin count");banks=(ctrl.width+31)/32;
 expect_true(geometry[15:8]==banks,"geometry bank count");
 for(int b=0;b<banks;b++) begin
  tail=(ctrl.width-32*b>=32)?32'hffffffff:((64'd1<<(ctrl.width-32*b))-1);
  rd('h100+b*256,tail);rd('h104+b*256,tail);
  wr('h118+b*256,'1);rd('h118+b*256,tail);
 end
 if(banks<4) rd('h100+banks*256,0,'1,1);
 if(ctrl.width<128) rd('h1000+ctrl.width*32,0,'1,1);

endtask
