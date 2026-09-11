`timescale 1ns/1ps
module ut_apb_secure_demux_events;
    parameter int DEPTH=3;
    logic clk=0,rst_n=0;
    always #5 clk=~clk;
    logic [3:0] candidates=0,clear_fault=0,clear_count=0;
    logic [255:0] data[4];
    logic pop=0,first_read=0,last_read=0,deny=0,cfg_deny=0,slverr=0;
    wire first_valid,last_valid;
    wire [255:0] first_words,last_words,head;
    wire [31:0] status,deny_count,cfg_count,lost_count,err_count;
    wire [2:0] lost_increment;
    int errors=0,checks=0;
    logic [255:0] saved_first,saved_last;
    apb_secure_demux_events #(.EVENT_FIFO_DEPTH(DEPTH)) dut(
        .pclk(clk),.preset_n(rst_n),.candidate_valid_i(candidates),.candidate_data_i(data),
        .fault_clear_i(clear_fault),.counter_clear_i(clear_count),.fifo_pop_i(pop),
        .first_word0_read_i(first_read),.last_word0_read_i(last_read),
        .access_deny_i(deny),.cfg_deny_i(cfg_deny),.downstream_error_i(slverr),
        .first_valid_o(first_valid),.last_valid_o(last_valid),.first_read_o(first_words),.last_read_o(last_words),
        .fifo_head_o(head),.fifo_status_o(status),.access_deny_count_o(deny_count),.cfg_deny_count_o(cfg_count),
        .event_lost_count_o(lost_count),.downstream_error_count_o(err_count),.lost_increment_o(lost_increment));
    task automatic check(input bit ok,input string label_text);
        checks++;if(!ok) begin errors++;$display("EVENTS D=%0d %s status=%h lost=%d",DEPTH,label_text,status,lost_count);end
    endtask
    task automatic tick;
        @(posedge clk);#1;@(negedge clk);
    endtask
    task automatic idle;
        candidates=0;clear_fault=0;clear_count=0;pop=0;first_read=0;last_read=0;deny=0;cfg_deny=0;slverr=0;
    endtask
    initial begin
        for(int c=0;c<4;c++) data[c]='0;
        tick();check(status==32'h100 && !first_valid && !last_valid && head==0,"reset");
        rst_n=1;
        for(int c=0;c<4;c++) begin data[c][31:0]=32'h100+32'(c);data[c][127:96]=32'habc;end
        candidates=4'hf;deny=1;cfg_deny=1;slverr=1;
        #1;check(lost_increment==3,"arbitration counts all non-winners");
        tick();idle();
        check(first_valid && last_valid && first_words[31:0]==32'h100,"integrity wins first");
        check(lost_count==3 && deny_count==1 && cfg_count==1 && err_count==1,"independent counters");
        if(DEPTH==0) check(status==32'h100 && head==0,"depth zero does not drop selected");
        else check(status[5:0]==1 && head[31:0]==32'h100 && head[223:192]==0,"first push and sequence zero");
        // Capture old LAST concurrently with replacement; both snapshots must keep old record.
        first_read=1;last_read=1;candidates=4'b1000;data[3][31:0]=32'h200;data[3][127:96]=32'hdef;
        tick();idle();saved_first=first_words;saved_last=last_words;
        check(first_words[127:96]==32'habc && last_words[127:96]==32'habc && last_words[31:0]==32'h200,"snapshot uses pre-edge record");
        tick();check(first_words==saved_first && last_words==saved_last,"snapshots stable without word zero read");
        last_read=1;tick();idle();check(last_words[127:96]==32'hdef && last_words[223:192]==1,"refresh LAST snapshot");
        // Clear+event creates fresh FIRST/LAST and FIFO; snapshots stay cleared.
        clear_fault=4'hf;clear_count=4'hf;candidates=4'b0010;data[1][31:0]=32'h300;
        tick();idle();
        check(first_words[31:0]==32'h300 && last_words[31:0]==32'h300 && first_words[255:32]==0 && last_words[255:32]==0,"clear before event; snapshot remains clear");
        check(lost_count==0 && deny_count==0 && cfg_count==0 && err_count==0,"clear counters");
        if(DEPTH>0) begin
            for(int i=1;i<DEPTH;i++) begin candidates=1;data[0][31:0]=32'h300+32'(i);tick();idle();end
            check(status[9] && status[5:0]==DEPTH && head[31:0]==32'h300,"fill exact depth");
            candidates=4'hf;#1;check(lost_increment==4,"full plus three arbitration losses");tick();idle();
            check(lost_count==4 && status[10] && head[31:0]==32'h300,"drop new preserves head");
            candidates=1;data[0][31:0]=32'h999;pop=1;#1;check(lost_increment==0,"pop frees full slot");tick();idle();
            check(status[9] && lost_count==4,"simultaneous pop push retains occupancy");
            for(int i=1;i<DEPTH;i++) begin
                check(head[31:0]==32'h300+32'(i),"FIFO ordering after wrap");pop=1;tick();idle();
            end
            check(head[31:0]==32'h999,"replacement is final element");pop=1;tick();idle();
            check(status[8] && head==0,"empty invisible old slots");
        end
        // Saturation is tested by verification-only state seeding, never DUT test hooks.
        force dut.event_lost_count_o=32'hfffffffe;
        tick();release dut.event_lost_count_o;candidates=4'hf;tick();idle();
        check(lost_count==32'hffffffff,"lost saturates on multi-increment");
        clear_count=4'b0100;candidates=4'hf;tick();idle();
        check(lost_count>=3 && lost_count<=4,"counter clear before new losses");
        rst_n=0;tick();check(status==32'h100 && lost_count==0 && !first_valid && !last_valid,"reset clears retained visibility");
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX_EVENTS: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_EVENTS: METRICS (errors=0 depth=%0d checks=%0d)",DEPTH,checks);$display("UT_APB_SECURE_DEMUX_EVENTS: PASS (errors=0)");$finish;
    end
    initial begin #20000;$fatal(1,"events timeout");end
endmodule
