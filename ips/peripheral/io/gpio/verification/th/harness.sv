`timescale 1ns/1ps
module harness #(parameter int N_GPIO=32,parameter bit CFG_PARITY_EN=0);
 import uvm_pkg::*;import tc_package::*;
 logic clk=0,aon_clk=0;
 apb_interface apb(clk);gpio_control_if ctrl(clk,aon_clk);
 always #5 if(ctrl.main_run) clk=~clk;
 always #7 if(ctrl.aon_run) aon_clk=~aon_clk;
 assign apb.rst_n=ctrl.por_n&&ctrl.main_n;
 if(N_GPIO<128) begin
  assign ctrl.out[127:N_GPIO]='0;assign ctrl.oe[127:N_GPIO]='0;
  assign ctrl.irq[127:N_GPIO]='0;assign ctrl.events[127:N_GPIO]='0;
 end
  gpio #(.N_GPIO(N_GPIO),.CFG_PARITY_EN(CFG_PARITY_EN)) dut (
    .pclk_i(clk),.por_ni(ctrl.por_n),.main_rst_ni(ctrl.main_n),.paddr_i(apb.addr),.pwdata_i(apb.wdata),.pstrb_i(apb.strb),.pprot_i(apb.prot),
    .psel_i(apb.sel),.penable_i(apb.enable),.pwrite_i(apb.write),.pready_o(apb.ready),.pslverr_o(apb.error),.prdata_o(apb.rdata),
    .gpio_in_i(ctrl.pad[N_GPIO-1:0]),.input_available_i(ctrl.available[N_GPIO-1:0]),.output_owned_i(ctrl.owned[N_GPIO-1:0]),.gpio_out_o(ctrl.out[N_GPIO-1:0]),.gpio_oe_o(ctrl.oe[N_GPIO-1:0]),.irq_pin_o(ctrl.irq[N_GPIO-1:0]),.event_o(ctrl.events[N_GPIO-1:0]),
    .irq_group_o(ctrl.groups[0:0]),.irq_summary_o(ctrl.irq_summary),.sleep_req_i(ctrl.sleep_req),.safe_req_i(ctrl.safe_req),.snapshot_req_i(ctrl.snapshot),.strap_sample_i(ctrl.strap),
    .sleep_ack_o(ctrl.sleep_ack),.safe_active_o(ctrl.safe_active),.fault_irq_o(ctrl.fault),.dma_req_o(ctrl.dma),.aon_clk_i(aon_clk),.aon_rst_ni(ctrl.aon_n),
    .aon_gpio_in_i(ctrl.aon_pad[N_GPIO-1:0]),.aon_input_available_i(ctrl.aon_available[N_GPIO-1:0]),.wake_req_o(ctrl.wake));

 initial begin
  ctrl.width=N_GPIO;ctrl.parity_enabled=CFG_PARITY_EN;
  uvm_config_db#(virtual apb_interface)::set(null,"*","vif",apb);
  uvm_config_db#(virtual gpio_control_if)::set(null,"*","ctrl",ctrl);
  run_test();
 end
 initial begin #400000000; $fatal(1,"independent simulation watchdog");end
 assert property (@(posedge clk) (ctrl.oe[N_GPIO-1:0]&~ctrl.owned[N_GPIO-1:0])=='0)
  else $error("OE ownership violation");
endmodule
