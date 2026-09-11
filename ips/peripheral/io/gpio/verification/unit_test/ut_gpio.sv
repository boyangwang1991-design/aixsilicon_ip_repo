`timescale 1ns/1ps
module ut_gpio;
  logic clk=0,aon_clk=0,por_n=0,main_n=0,aon_n=0;
  always #5 clk=~clk;
  always #7 aon_clk=~aon_clk;
  logic [13:0] addr=0;
  logic [31:0] wdata=0,rdata;
  logic [3:0] strb=15;
  logic [2:0] prot=1;
  logic sel=0,enable=0,write=0,ready,error;
  logic [7:0] pad=0,available='1,owned='1,out,oe,irq,event_signal;
  logic [1:0] groups;
  logic irq_summary,sleep_req=0,safe_req=0,snapshot=0,strap=0,sleep_ack,safe_active,fault,dma,wake;
  gpio #(.N_GPIO(8),.N_IRQ_GROUPS(2),.EVENT_FIFO_DEPTH(4)) dut (
    .pclk_i(clk),.por_ni(por_n),.main_rst_ni(main_n),.paddr_i(addr),.pwdata_i(wdata),.pstrb_i(strb),.pprot_i(prot),
    .psel_i(sel),.penable_i(enable),.pwrite_i(write),.pready_o(ready),.pslverr_o(error),.prdata_o(rdata),
    .gpio_in_i(pad),.input_available_i(available),.output_owned_i(owned),.gpio_out_o(out),.gpio_oe_o(oe),.irq_pin_o(irq),.event_o(event_signal),
    .irq_group_o(groups),.irq_summary_o(irq_summary),.sleep_req_i(sleep_req),.safe_req_i(safe_req),.snapshot_req_i(snapshot),.strap_sample_i(strap),
    .sleep_ack_o(sleep_ack),.safe_active_o(safe_active),.fault_irq_o(fault),.dma_req_o(dma),.aon_clk_i(aon_clk),.aon_rst_ni(aon_n),
    .aon_gpio_in_i(pad),.aon_input_available_i(available),.wake_req_o(wake));
  task automatic transfer(input bit wr,input logic[13:0] a,input logic[31:0] value,input logic[3:0] s,input bit expected_error,output logic[31:0] result);
    @(negedge clk); sel=1; enable=0; write=wr; addr=a; wdata=value; strb=s;
    @(negedge clk); enable=1; #1;
    assert(ready===1'b1 && error===expected_error) else $fatal(1,"APB addr=%h expected error=%b actual=%b ready=%b",a,expected_error,error,ready);
    result=rdata;
    if(expected_error) assert(rdata===0) else $fatal(1,"error data nonzero");
    @(negedge clk); sel=0;enable=0;
  endtask
  logic [31:0] value;
  initial begin #100000; $fatal(1,"GPIO watchdog"); end
  initial begin
    repeat(3) @(negedge clk); por_n=1;main_n=1;aon_n=1;
    repeat(12) @(negedge clk);
    transfer(0,14'h0,0,15,0,value); assert(value===32'h4750494f) else $fatal(1,"IP_ID %h",value);
    transfer(0,14'hc,0,15,0,value); assert(value===32'h02020108) else $fatal(1,"GEOMETRY %h",value);
    transfer(1,14'h118,32'h55,15,0,value);
    transfer(0,14'h118,0,15,0,value); assert(value===32'h55) else $fatal(1,"OUT_DATA %h",value);
    transfer(1,14'h130,32'hff,15,0,value); assert(out===8'h55 && oe===8'hff) else $fatal(1,"output path");
    transfer(1,14'h124,32'h0f,1,0,value); assert(out===8'h5a) else $fatal(1,"toggle");
    transfer(1,14'h1000,32'h08,15,1,value);
    transfer(0,14'h1000,0,15,0,value); assert(value===0) else $fatal(1,"error mutated cfg");
    transfer(1,14'h130,0,15,0,value);
    transfer(1,14'h1000,32'h08,15,0,value);
    transfer(1,14'h11c,32'h01,15,0,value);
    transfer(1,14'h130,32'h01,15,0,value); assert(!oe[0] && !out[0]) else $fatal(1,"open-drain release");
    transfer(1,14'h120,32'h01,15,0,value); assert(oe[0] && !out[0]) else $fatal(1,"open-drain low");
    transfer(1,14'h164,32'h01,15,0,value);
    transfer(1,14'h11c,32'h03,15,1,value);
    transfer(0,14'h118,0,15,0,value); assert(value===32'h5a) else $fatal(1,"lock atomicity");
    transfer(0,14'h11c,0,15,0,value); assert(value===0) else $fatal(1,"WO read");
    transfer(0,14'h001,0,15,1,value);
    transfer(0,14'h200,0,15,1,value);
    @(negedge clk); main_n=0; repeat(3) @(negedge clk); main_n=1; repeat(10) @(negedge clk);
    transfer(0,14'h164,0,15,0,value); assert(value===1) else $fatal(1,"warm reset lost lock");
    transfer(0,14'h118,0,15,0,value); assert(value===0) else $fatal(1,"warm reset out default");
    $display("UT_GPIO: PASS (errors=0)"); $finish;
  end
endmodule
