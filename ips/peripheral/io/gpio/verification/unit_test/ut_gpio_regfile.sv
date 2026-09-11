`timescale 1ns/1ps
module ut_gpio_regfile;
  import gpio_pkg::*;import gpio_reg_desc_pkg::*;
  bit clk=0;always #5 clk=~clk;
  bit rst=0,por=0,wr=0,access_error=0;bit [13:0] addr=0;bit [2:0] prot=1;bit [3:0] strb=15;
  bit [31:0] wdata=0,mask='1;logic [GPIO_REG_COUNT-1:0] ws='0,rs='0;
  gpio_reg_desc_t desc;gpio_status_t status='0;gpio_config_t cfg;gpio_command_t command;
  wire [31:0] words[GPIO_REG_COUNT];wire disabled,semantic,fault,parity;
  int errors=0;
  assign desc=gpio_decode(addr);
  gpio_regfile #(.N_GPIO(33),.N_IRQ_GROUPS(2)) dut(.clk_i(clk),.rst_ni(rst),.por_ni(por),
    .descriptor_i(desc),.pwrite_i(wr),.access_error_i(access_error),.paddr_i(addr),.pprot_i(prot),.pstrb_i(strb),
    .write_data_i(wdata),.byte_mask_i(mask),.write_strobe_i(ws),.read_strobe_i(rs),.status_i(status),
    .config_o(cfg),.command_o(command),.read_words_o(words),.optional_disabled_o(disabled),
    .semantic_error_o(semantic),.fault_irq_o(fault),.parity_error_o(parity));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step;@(posedge clk);#1;@(negedge clk);endtask
  task write_reg(input bit[13:0] a,input bit[31:0] value,input bit[3:0] strobes,input bit bad);
    addr=a;wdata=value;strb=strobes;for(int b=0;b<4;b++)mask[8*b+:8]={8{strobes[b]}};
    wr=1;#1;check(semantic===bad,"semantic write check");if(!semantic)ws[desc.index]=1;
    step();ws='0;wr=0;#1;
  endtask
  initial begin
    repeat(2)step();por=1;rst=1;step();
    check(cfg.in_enable[32:0]==='1&&cfg.out_data===0,"parameterized defaults");
    write_reg(14'h118,32'h11223344,15,0);write_reg(14'h118,32'haabbccdd,2,0);
    check(cfg.out_data[31:0]===32'h1122cc44,"byte merge retains other bytes");
    write_reg(14'h218,32'hffffffff,15,0);check(cfg.out_data[63:32]===1,"tail bank ignores nonexistent pins");
    status.data_lock[0]=1;write_reg(14'h11c,3,15,1);check(cfg.out_data[31:0]===32'h1122cc44,"mixed lock atomic rejection");
    write_reg(14'h11c,2,15,0);check(cfg.out_data[31:0]===32'h1122cc46,"unlocked atomic SET");
    write_reg(14'h128,32'h00020000,1,1);write_reg(14'h128,32'h00020000,15,0);
    check(cfg.out_data[31:0]===32'h1122cc44,"masked low update");
    status.global_lock=1;write_reg(14'h148,0,15,1);status.global_lock=0;
    write_reg(14'h6c,15,15,1);write_reg(14'h6c,16,15,0);check(cfg.aon_timeout===16,"timeout minimum");
    status.aon_busy=1;write_reg(14'h3000,1,15,1);status.aon_busy=0;write_reg(14'h3000,1,15,0);
    status.aon_ready=1;write_reg(14'h301c,3,15,1);
    addr=14'h301c;wdata=1;strb=15;mask='1;wr=1;#1;ws[desc.index]=1;#1;
    check(command.aon_command&&command.aon_request[37:6]===1,"AON atomic payload");step();ws=0;wr=0;
    rst=0;step();check(cfg.out_data===0&&cfg.aon_stage==='0,"warm reset config defaults");
    if(errors)$fatal(1,"UT_GPIO_REGFILE: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_REGFILE: PASS (errors=0)");$finish;
  end
  initial begin #20000;$fatal(1,"TIMEOUT");end
endmodule
