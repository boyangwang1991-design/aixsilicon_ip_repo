`timescale 1ns/1ps
module ut_apb_secure_demux_register_bridge;
    import apb_secure_demux_instance_pkg::*;
    logic clk=0,rst_n=0,sel=0,en=0,wr=0;
    always #5 clk=~clk;
    logic [31:0] address=0,wdata=0;
    logic [31:0] values[REG_COUNT];
    wire [REG_COUNT-1:0] rd_select,wr_select;
    wire ready,error;wire [31:0] rdata;
    int errors=0,checks=0;
    apb_secure_demux_register_bridge dut(.pclk(clk),.preset_n(rst_n),.psel(sel),.penable(en),.pwrite(wr),
        .address,.write_data(wdata),.strb(4'hf),.prot(3'b001),.read_data_i(values),
        .read_select_o(rd_select),.write_select_o(wr_select),.ready,.error,.read_data(rdata));
    task automatic transfer(input int index,input bit write_access,input bit expected_error);
        logic [REG_COUNT-1:0] expected_select;
        expected_select='0;if(!expected_error) expected_select[index]=1;
        @(negedge clk);address=REG_ADDR[index];sel=1;en=0;wr=write_access;wdata=32'h9a5ac3f0;
        @(negedge clk);en=1;#1;checks++;
        if(ready!==1'b1 || error!==expected_error || (write_access ? wr_select : rd_select)!==expected_select ||
           (write_access ? rd_select : wr_select)!=='0 || (!write_access && !expected_error && rdata!==(values[index]&REG_MASK[index]))) begin
            errors++;if(errors<10)$display("BRIDGE mismatch reg=%0d addr=%h",index,address);
        end
        @(posedge clk);#1;
    endtask
    initial begin
        for(int r=0;r<REG_COUNT;r++) values[r]=32'h5a96c3f0 ^ REG_ADDR[r];
        repeat(2) @(negedge clk);rst_n=1;
        for(int r=0;r<REG_COUNT;r++) begin
            transfer(r,0,!REG_READABLE[r]);transfer(r,1,!REG_WRITABLE[r]);
        end
        if(errors)$fatal(1,"UT_APB_SECURE_DEMUX_REGISTER_BRIDGE: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_REGISTER_BRIDGE: METRICS (errors=0 checks=%0d)",checks);$display("UT_APB_SECURE_DEMUX_REGISTER_BRIDGE: PASS (errors=0)");$finish;
    end
    initial begin #300000;$fatal(1,"bridge timeout");end
endmodule
