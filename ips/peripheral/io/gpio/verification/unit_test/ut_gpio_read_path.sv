`timescale 1ns/1ps
module ut_gpio_read_path;
  logic clk=0,aon_clk=0,por_n=0,main_n=0,aon_n=0;
  always #5 clk=~clk;
  always #7 aon_clk=~aon_clk;
  logic [13:0] addr=0;
  logic [31:0] wdata=0,rdata;
  logic [3:0] strb=15;
  logic [2:0] prot=1;
  logic sel=0,enable=0,write=0,ready,error;
  logic [32:0] pad=0,available='1,owned='1,out,oe,irq,event_signal;
  logic [1:0] groups;
  logic irq_summary,sleep_req=0,safe_req=0,snapshot=0,strap=0,sleep_ack,safe_active,fault,dma,wake;
  gpio #(.N_GPIO(33),.N_IRQ_GROUPS(2),.EVENT_FIFO_DEPTH(4)) dut (
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
  logic [31:0] value,expected;
  initial begin #100000;$fatal(1,"read path watchdog");end
  always @(posedge clk) if(dut.main_n&&sel&&enable&&!error)
    assert(dut.csr_ready&&!dut.csr_error) else $fatal(1,"native CSR did not complete legal Access");
  initial begin
    repeat(3)@(negedge clk);por_n=1;main_n=1;aon_n=1;repeat(12)@(negedge clk);
    for(int bank=0;bank<2;bank++)begin
      expected=bank==0?32'h12345678:1;
      transfer(1,14'(14'h118+bank*256),expected,15,0,value);
      transfer(0,14'(14'h118+bank*256),0,15,0,value);
      assert(value===expected)else $fatal(1,"bank decode %0d %h",bank,value);
    end
    for(int byte_lane=0;byte_lane<4;byte_lane++)begin
      transfer(1,14'h118,32'haabbccdd,4'(1<<byte_lane),0,value);
      transfer(0,14'h118,0,15,0,value);
      expected=(32'h12345678&~((32'h1<<(8*(byte_lane+1)))-1)) | (32'haabbccdd&((32'h1<<(8*(byte_lane+1)))-1));
      if(byte_lane==3)expected=32'haabbccdd;
      assert(value===expected)else $fatal(1,"byte readback %0d %h %h",byte_lane,value,expected);
    end
    pad=33'h155aa55aa;repeat(8)@(negedge clk);
    transfer(0,14'h108,0,15,0,value);assert(value===32'h55aa55aa)else $fatal(1,"input bank0 %h",value);
    transfer(0,14'h208,0,15,0,value);assert(value===1)else $fatal(1,"input tail bank %h",value);
    transfer(0,14'h300,0,15,1,value);
    transfer(0,14'h1200,0,15,0,value);transfer(0,14'h1210,0,15,1,value);
    $display("UT_GPIO_READ_PATH: PASS (errors=0)");$finish;
  end
endmodule
