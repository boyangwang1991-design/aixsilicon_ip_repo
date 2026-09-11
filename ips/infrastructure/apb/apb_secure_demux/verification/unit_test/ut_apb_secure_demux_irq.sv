`timescale 1ns/1ps
module ut_apb_secure_demux_irq;
    logic clk=0,rst_n=0;
    always #5 clk=~clk;
    logic [8:0] events=0;
    logic fatal=0,clear_raw=0,wr_irq=0,wr_alert=0,test_irq=0;
    logic [31:0] clear_data=0,write_data=0;
    wire [31:0] raw,irq_enable,alert_enable;
    wire irq,alert;
    logic [8:0] rm_raw=0,rm_irq=0,rm_alert=9'h09b;
    int errors=0,checks=0;
    apb_secure_demux_irq dut(.pclk(clk),.preset_n(rst_n),.event_bits_i(events),.fatal_i(fatal),
        .raw_clear_i(clear_raw),.raw_clear_data_i(clear_data),.intr_enable_write_i(wr_irq),
        .alert_enable_write_i(wr_alert),.write_data_i(write_data),.intr_test_i(test_irq),
        .intr_raw_o(raw),.intr_enable_o(irq_enable),.alert_enable_o(alert_enable),.irq_o(irq),.security_alert_o(alert));
    task automatic tick;
        @(posedge clk);
        if(!rst_n) begin rm_raw=0;rm_irq=0;rm_alert=9'h09b;end
        else begin
            for(int b=0;b<9;b++) begin
                if(clear_raw && clear_data[b]) rm_raw[b]=0;
                if(events[b]) rm_raw[b]=1;
            end
            if(fatal) rm_raw[4]=1;
            if(test_irq) rm_raw[8]=1;
            if(wr_irq) rm_irq=write_data[8:0];
            if(wr_alert) rm_alert=write_data[8:0];
        end
        #1;checks++;
        if(raw!=={23'b0,rm_raw} || irq_enable!=={23'b0,rm_irq} || alert_enable!=={23'b0,rm_alert} ||
           irq!==(rst_n && |(rm_raw&rm_irq)) || alert!==(rst_n && |(rm_raw&rm_alert))) begin
            errors++;$display("IRQ mismatch raw=%h expected=%h",raw,rm_raw);
        end
        @(negedge clk);
    endtask
    initial begin
        tick();rst_n=1;
        events=9'h1ff;tick();events=0;tick();
        wr_irq=1;write_data=32'hffffffff;tick();wr_irq=0;
        clear_raw=1;clear_data=32'hffffffff;events=9'h011;fatal=1;tick();
        events=0;tick();fatal=0;tick();clear_raw=0;
        test_irq=1;tick();test_irq=0;tick();
        for(int i=0;i<1000;i++) begin
            events=9'($urandom);clear_raw=1'($urandom);clear_data=$urandom;
            fatal=1'($urandom);wr_irq=1'($urandom);wr_alert=1'($urandom);
            write_data=$urandom;test_irq=1'($urandom);tick();
        end
        rst_n=0;#1;if(irq || alert) errors++;tick();
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX_IRQ: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_IRQ: METRICS (errors=0 checks=%0d)",checks);$display("UT_APB_SECURE_DEMUX_IRQ: PASS (errors=0)");$finish;
    end
    initial begin #20000;$fatal(1,"irq timeout");end
endmodule
