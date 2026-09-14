`include "tc_base.sv"
class tc_gpio_parity extends tc_base;
 `uvm_component_utils(tc_gpio_parity)
 extern function new(string name,uvm_component parent);
 extern task scenario();
endclass
function tc_gpio_parity::new(string name,uvm_component parent);super.new(name,parent);endfunction
task tc_gpio_parity::scenario();

 logic[31:0] features;
 access(0,8,0,features);
 if(ctrl.parity_enabled) begin
  wr('h70,1);ctrl.ticks(10);expect_true(ctrl.safe_active,"injected parity activates safe");
  reset(1);expect_true(ctrl.safe_active,"parity safe retained through warm reset");reset();expect_true(!ctrl.safe_active,"cold reset clears parity safe");
 end else begin wr('h70,1);ctrl.ticks(10);expect_true(!ctrl.safe_active,"disabled parity injection is inert");end

endtask
