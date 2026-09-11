`timescale 1ns/1ps
module ut_apb_secure_demux_csr;
    import apb_secure_demux_instance_pkg::*;
    localparam int NP=int'(C_NUM_PORTS),NM=int'(C_NUM_MASTERS),IW=int'(C_MASTER_ID_WIDTH);
    logic clk=0,rst_n=0,setup=0,access=0;
    always #5 clk=~clk;
    logic [31:0] address=0,wdata=0;logic wr=0;logic [3:0] strb=4'hf;logic [2:0] prot=1;
    logic [IW-1:0] master=0;logic master_valid=1,auth=1;
    wire [31:0] rdata,version;wire [7:0] reason;
    wire [1:0] cfg[NP];wire [7:0] perm[NP][NM];
    wire raw_bad,fatal,irq,alert,busy,port_valid,wait_hit;wire [4:0] port,armed_port;
    wire [1:0] mode;wire [5:0] armed_master;
    int errors=0,checks=0;
    apb_secure_demux_csr dut(.pclk(clk),.preset_n(rst_n),.csr_setup_i(setup),.csr_access_i(access),
        .offset_i(address),.write_data_i(wdata),.write_i(wr),.strb_i(strb),.prot_i(prot),.master_i(master),
        .master_valid_i(master_valid),.dfx_authorized_i(auth),.consume_i(1'b0),.synthetic_integrity_i(1'b0),
        .setup_record_i(256'b0),.transaction_record_i(256'b0),.bus_failure_i(1'b0),.access_deny_i(1'b0),
        .cfg_deny_i(1'b0),.downstream_error_i(1'b0),.deny_port_valid_i(1'b0),.deny_port_i(5'b0),
        .new_transaction_i(1'b0),.activity_valid_i(1'b0),.activity_port_i(5'b0),.downstream_wait_i(1'b0),
        .downstream_complete_i(1'b0),.read_data_o(rdata),.reason_o(reason),.active_cfg_o(cfg),.active_perm_o(perm),
        .raw_bad_o(raw_bad),.fatal_o(fatal),.policy_version_o(version),.armed_mode_o(mode),.armed_port_o(armed_port),
        .armed_master_o(armed_master),.irq_o(irq),.security_alert_o(alert),.busy_o(busy),.active_port_valid_o(port_valid),
        .wait_threshold_o(wait_hit),.active_port_o(port));
    task automatic transfer(input logic [31:0] a,input bit w,input logic [31:0] d,input logic [7:0] e,input logic [31:0] expected);
        @(negedge clk);setup=1;access=0;address=a;wr=w;wdata=d;
        @(negedge clk);setup=0;access=1;#1;checks++;
        if(reason!==e || (!w && rdata!==expected)) begin errors++;$display("CSR addr=%h reason=%h expected=%h data=%h expected_data=%h",a,reason,e,rdata,expected);end
        @(posedge clk);#1;access=0;
    endtask
    initial begin
        $assertoff(0,dut);repeat(2) @(negedge clk);rst_n=1;#1;$asserton(0,dut);
        transfer(0,0,0,0,32'h41534458);
        transfer(32'h3c,0,0,0,32'h9b);
        transfer(32'h34,1,32'hffffffff,0,0);transfer(32'h34,0,0,0,32'h1ff);
        transfer(32'h48,0,0,0,32'h100);
        transfer(32'h4c,1,0,C_EVENT_FIFO_DEPTH?8'h16:8'h13,0);
        transfer(32'h18,0,0,0,0);
        prot=2;transfer(32'h101,0,0,8'h10,0);prot=1;transfer(32'h101,0,0,8'h11,0);
        auth=0;transfer(32'h104,0,0,8'h10,0);auth=1;
        transfer(32'h104,0,0,C_DFX_EN?8'h00:8'h13,0);
        transfer(32'h100c,1,3,0,0);transfer(32'h1010,0,0,0,32'(C_RESET_PORT_CFG[0]));
        transfer(32'h1c,1,1,0,0);transfer(32'h1010,0,0,0,3);
        transfer(32'h18,1,1,0,0);transfer(32'h100c,1,0,8'h15,0);
        transfer(32'h1c,1,0,8'h15,0);transfer(32'h20,0,0,0,32'h12);
        strb=1;transfer(32'h1c,1,1,8'h12,0);strb=4'hf;transfer(32'h20,0,0,0,32'h12);
        transfer(32'h18,1,0,0,0);transfer(32'h18,0,0,0,1);
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX_CSR: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_CSR: METRICS (errors=0 checks=%0d)",checks);$display("UT_APB_SECURE_DEMUX_CSR: PASS (errors=0)");$finish;
    end
    initial begin #100000;$fatal(1,"CSR timeout");end
endmodule
