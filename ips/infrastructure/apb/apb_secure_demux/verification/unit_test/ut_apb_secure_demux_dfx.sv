`timescale 1ns/1ps
module ut_apb_secure_demux_dfx;
    logic clk=0,rst_n=0,auth=0;
    always #5 clk=~clk;
    logic wt=0,tt=0,cmd=0;
    logic [31:0] wdata=0;
    logic [1:0] clear=0;
    logic [4:0] count_clear[3];
    logic consume=0,start=0,active=0;
    logic [4:0] port=0,deny_port=0;
    logic stall=0,complete=0,error=0,deny=0;
    wire cmd_ok,target_ok;
    wire [31:0] threshold,target,status;
    wire [1:0] mode;
    wire [4:0] armed_port,obs_port;
    wire [5:0] armed_master;
    wire synth,wait_evt,busy,port_valid,wait_hit;
    wire [31:0] success[3],denied[3],slverr[3],total[3],maximum[3];
    int errors=0,checks=0;
    apb_secure_demux_dfx #(.NUM_PORTS(3),.NUM_MASTERS(3)) dut(
        .pclk(clk),.preset_n(rst_n),.authorized_i(auth),.threshold_write_i(wt),.target_write_i(tt),
        .inject_command_i(cmd),.write_data_i(wdata),.clear_i(clear),.counter_clear_i(count_clear),
        .consume_i(consume),.new_transaction_i(start),.activity_valid_i(active),.activity_port_i(port),
        .downstream_wait_i(stall),.downstream_complete_i(complete),.downstream_error_i(error),
        .deny_i(deny),.deny_port_i(deny_port),.command_valid_o(cmd_ok),.target_valid_o(target_ok),
        .threshold_o(threshold),.target_o(target),.status_o(status),.armed_mode_o(mode),
        .armed_port_o(armed_port),.armed_master_o(armed_master),.synthetic_event_o(synth),.wait_event_o(wait_evt),
        .busy_o(busy),.active_port_valid_o(port_valid),.wait_threshold_o(wait_hit),.active_port_o(obs_port),
        .success_count_o(success),.deny_count_o(denied),.slverr_count_o(slverr),.wait_total_o(total),.wait_max_o(maximum));
    task automatic check(input bit ok,input string label_text);
        checks++;if(!ok) begin errors++;$display("DFX mismatch %s",label_text);end
    endtask
    task automatic tick; @(posedge clk);#1;@(negedge clk);endtask
    initial begin
        for(int p=0;p<3;p++) count_clear[p]=0;
        tick();rst_n=1;auth=1;
        wdata=32'h202;tt=1;#1;check(target_ok,"nonpower target valid");tick();tt=0;
        wdata=2;cmd=1;tick();cmd=0;check(mode==1 && armed_port==2 && armed_master==2,"arm captures target");
        wdata=0;#1;check(!target_ok && !cmd_ok,"target locked and zero command invalid");
        wdata=4;#1;check(!cmd_ok,"mutually exclusive arms");
        active=1;port=2;#1;check(busy && port_valid && obs_port==2,"authorized observation");
        auth=0;#1;check(!busy && !port_valid && obs_port==0,"asynchronous revocation gating");
        cmd=1;wdata=2;tick();cmd=0;check(mode==0,"revoke beats simultaneous arm");auth=1;
        wdata=3;tt=1;#1;check(!target_ok,"reject port equal bound");tick();tt=0;check(target==32'h202,"invalid target preserves old");
        wdata=2;wt=1;tick();wt=0;start=1;tick();start=0;
        stall=1;#1;check(!wait_evt,"first wait below threshold");tick();
        #1;check(wait_evt,"second wait reaches threshold");clear=1;tick();clear=0;
        check(wait_hit,"new threshold beats clear");#1;check(!wait_evt,"only one threshold per request");tick();
        stall=0;complete=1;tick();complete=0;
        check(success[2]==1 && slverr[2]==0 && total[2]==3 && maximum[2]==3,"completed wait accounting");
        start=1;tick();start=0;complete=1;error=1;count_clear[2]=5'h1f;tick();
        complete=0;error=0;count_clear[2]=0;
        check(success[2]==0 && slverr[2]==1 && total[2]==0 && maximum[2]==0,"clear before zero wait error completion");
        auth=0;deny=1;deny_port=1;tick();deny=0;check(denied[1]==1,"authorization does not suppress statistics");auth=1;
        wdata=4;cmd=1;tick();cmd=0;check(mode==2,"integrity arm");consume=1;tick();consume=0;check(mode==0,"consume once");
        wdata=32'hfffffff9;cmd=1;#1;check(cmd_ok && synth,"reserved command bits ignored");tick();cmd=0;
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX_DFX: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_DFX: METRICS (errors=0 checks=%0d)",checks);$display("UT_APB_SECURE_DEMUX_DFX: PASS (errors=0)");$finish;
    end
    initial begin #10000;$fatal(1,"DFX timeout");end
endmodule
