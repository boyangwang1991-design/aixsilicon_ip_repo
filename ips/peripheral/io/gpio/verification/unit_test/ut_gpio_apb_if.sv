`timescale 1ns/1ps
module ut_gpio_apb_if;
  import gpio_reg_desc_pkg::*;
  bit rst=1,sel=1,en=0,wr=0;bit [13:0] addr=0;bit [2:0] prot=1;
  bit [3:0] strb=5;bit [1:0] policy=3;bit disabled=0,semantic=0;
  wire [31:0] mask,data;wire ready,error,commit,access_error;gpio_reg_desc_t desc;int errors=0;
  gpio_apb_if #(.N_GPIO(33)) dut(.rst_ni(rst),.psel_i(sel),.penable_i(en),.pwrite_i(wr),
    .paddr_i(addr),.pprot_i(prot),.pstrb_i(strb),.access_cfg_i(policy),.optional_disabled_i(disabled),
    .semantic_error_i(semantic),.csr_read_data_i(32'habcd1234),.descriptor_o(desc),.byte_mask_o(mask),
    .pready_o(ready),.pslverr_o(error),.commit_o(commit),.access_error_o(access_error),.prdata_o(data));
  task check(bit ok,string msg);if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task expect_access(input bit bad);#1;check(ready&&error===bad&&commit===!bad&&access_error===bad,"access result");if(bad)check(data===0,"error read data");endtask
  initial begin
    #1;check(ready&&!commit&&!error&&mask===32'h00ff00ff,"setup and byte mask");en=1;expect_access(0);
    wr=1;expect_access(1);wr=0;addr=1;expect_access(1);addr=14'h0200;expect_access(0);
    addr=14'h0300;expect_access(1);addr=14'h1210;expect_access(1);addr=0;
    prot=3;expect_access(1);prot=0;expect_access(1);prot=5;expect_access(1);prot=1;
    semantic=1;expect_access(1);disabled=1;expect_access(0);check(data===0,"disabled optional read zero");
    disabled=0;semantic=0;policy=0;addr=14'h14;wr=1;prot=3;expect_access(1);
    prot=1;expect_access(0);rst=0;#1;check(!commit&&!error,"reset no effects");
    if(errors)$fatal(1,"UT_GPIO_APB_IF: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_APB_IF: PASS (errors=0)");$finish;
  end
  initial begin #10000;$fatal(1,"TIMEOUT");end
endmodule
