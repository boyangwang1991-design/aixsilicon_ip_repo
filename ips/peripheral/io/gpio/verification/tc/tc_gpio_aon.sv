`include "tc_base.sv"
class tc_gpio_aon extends tc_base;
 `uvm_component_utils(tc_gpio_aon)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_aon::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_aon::scenario();

 logic[31:0] status;
 wr('h3000,1);wr('h3004,0);wr('h3008,0);wr('h300c,1);wr('h301c,1);
 ctrl.ticks(80);access(0,'h68,0,status);expect_true(status[2]&&!status[1]&&!status[4],"AON commit completed");
 ctrl.aon_pad[0]=1;ctrl.ticks(30);expect_true(ctrl.wake,"AON level wake");
 reset(1);expect_true(ctrl.wake,"AON pending retained through main reset");
 ctrl.main_run=0;ctrl.aon_pad[0]=0;#300;expect_true(ctrl.wake,"AON independent of main clock");ctrl.main_run=1;
 wr('h3018,1);wr('h301c,4);ctrl.ticks(80);expect_true(!ctrl.wake,"AON pending clear");
 wr('h6c,12,1);wr('h6c,16);ctrl.aon_run=0;wr('h301c,2);ctrl.ticks(40);access(0,'h68,0,status);expect_true(status[3],"AON stopped-clock timeout");
 ctrl.aon_run=1;ctrl.ticks(100);access(0,'h68,0,status);expect_true(!status[1],"late ACK drained");

endtask
