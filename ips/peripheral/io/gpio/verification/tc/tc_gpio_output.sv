`include "tc_base.sv"
class tc_gpio_output extends tc_base;
 `uvm_component_utils(tc_gpio_output)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_output::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_output::scenario();

 uvm_status_e status;uvm_reg_data_t data;bit[31:0] expected,mask;
 expected=0;
 for(int i=0;i<160;i++) begin
  int op=$urandom_range(0,3);bit[31:0] val=$urandom;bit[3:0] s=$urandom;
  wr('h118+op*4,val,0,s);access(0,'h118,0,data);
 end
 env.ral.bank[0].OUT_DATA.write(status,32'ha55a5aa5,UVM_FRONTDOOR);expect_true(status==UVM_IS_OK,"RAL frontdoor write");
 env.ral.bank[0].OUT_DATA.mirror(status,UVM_CHECK,UVM_FRONTDOOR);expect_true(status==UVM_IS_OK,"RAL mirror through monitor predictor");
 wr('h130,0);wr('h1000,8);wr('h11c,1);wr('h130,1);ctrl.ticks(2);expect_true(!ctrl.oe[0]&&!ctrl.out[0],"open drain release");
 wr('h120,1);ctrl.ticks(2);expect_true(ctrl.oe[0]&&!ctrl.out[0],"open drain low");
 ctrl.owned[0]=0;ctrl.ticks(2);expect_true(!ctrl.oe[0],"ownership masks OE");

endtask
