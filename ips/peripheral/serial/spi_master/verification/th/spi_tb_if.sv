`timescale 1ns/1ps
`ifndef SPI_NUM_CS
`define SPI_NUM_CS 4
`endif
`ifndef SPI_TX_DEPTH
`define SPI_TX_DEPTH 32
`endif
`ifndef SPI_RX_DEPTH
`define SPI_RX_DEPTH 32
`endif
`ifndef SPI_CMD_DEPTH
`define SPI_CMD_DEPTH 4
`endif
interface spi_tb_if(input logic pclk);
    localparam int N=`SPI_NUM_CS, TD=`SPI_TX_DEPTH, RD=`SPI_RX_DEPTH, CD=`SPI_CMD_DEPTH;
    logic preset_n=0,psel=0,penable=0,pwrite=0;
    logic [11:0] paddr=0;
    logic [31:0] pwdata=0,prdata;
    logic [3:0] pstrb=0;
    logic [2:0] pprot=0;
    logic pready,pslverr,sclk,mosi,miso=0,irq;
    logic [N-1:0] cs_n;
    int errors=0, checks=0, edges=0, samples=0, cycle=0;
    int mode[8],divisor[8],setup_cycles[8],hold_cycles[8],gap_cycles[8];
    bit expected_mosi[$],response_bits[$];
    bit monitor_enabled=0, timing_enabled=0;
    logic old_sclk=0;
    logic [N-1:0] old_cs='1;
    int selected=0,last_edge_cycle=0,assert_cycle=0;
    int bits_in_frame=8, sample_in_frame=0;
    realtime miso_delay=0.2;
    string group_name;
    int mode_seen[4],width_seen[33],order_seen[2],op_seen[5];
    bit lsb_order[8];
    covergroup serial_coverage with function sample(int md,int width,bit order);
        option.per_instance=1;
        cp_mode: coverpoint md { bins modes[]={[0:3]}; }
        cp_width: coverpoint width { bins widths[]={1,2,7,8,9,16,24,31,32}; }
        cp_order: coverpoint order;
        mode_width_order: cross cp_mode,cp_width,cp_order;
    endgroup
    covergroup command_coverage with function sample(int op,bit keep,bit stall);
        option.per_instance=1;
        cp_op: coverpoint op { bins operations[]={[0:4]}; }
        cp_keep: coverpoint keep;
        cp_stall: coverpoint stall;
    endgroup
    serial_coverage serial_cov=new;
    command_coverage command_cov=new;

    task automatic check(input bit condition,input string message);
        checks++;
        if (!condition) begin errors++; $error("CHECK %s: %s",group_name,message); end
    endtask

    // Independent pin observer: linear bit queues prepared by the test, not DUT internals.
    // External slave changes MISO after a configurable clock-to-out delay.
    always @(posedge pclk) begin : pin_monitor
        bit throwaway;
        bit leading,sampling;
        cycle++;
        #0.001;
        if (!preset_n) begin old_sclk=sclk; old_cs=cs_n; sample_in_frame=0; end
        else begin
            check($countones(~cs_n)<=1,"at most one active CS");
            if (cs_n!=old_cs && cs_n!={N{1'b1}}) begin
                for(int i=0;i<N;i++) if(!cs_n[i]) selected=i;
                assert_cycle=cycle; last_edge_cycle=0; sample_in_frame=0;
                if (!mode[selected][1] && response_bits.size()!=0) miso<=#(miso_delay) response_bits[0];
            end
            if (cs_n!={N{1'b1}} && sclk!==old_sclk) begin
                edges++;
                leading=(sclk!=mode[selected][0]);
                sampling=(leading!=mode[selected][1]);
                if(timing_enabled) begin
                    if(last_edge_cycle==0) check(cycle-assert_cycle==setup_cycles[selected]+1,"exact CS setup");
                    else check(cycle-last_edge_cycle==divisor[selected]+1+
                        ((leading && sample_in_frame==0)?gap_cycles[selected]:0),"exact half period including frame gap");
                end
                last_edge_cycle=cycle;
                if(monitor_enabled && sampling) begin
                    samples++;
                    if(sample_in_frame==0) serial_cov.sample(mode[selected],bits_in_frame,lsb_order[selected]);
                    check(expected_mosi.size()!=0,"no unexpected serial sample");
                    if(expected_mosi.size()!=0) begin
                        throwaway=expected_mosi.pop_front();
                        check(mosi===throwaway,$sformatf("MOSI sample %0d expected %b got %b",samples,throwaway,mosi));
                    end
                    if(response_bits.size()!=0) throwaway=response_bits.pop_front();
                    sample_in_frame=(sample_in_frame+1)%bits_in_frame;
                end
                if(!sampling && response_bits.size()!=0) miso<=#(miso_delay) response_bits[0];
            end
            if(cs_n=={N{1'b1}} && old_cs!={N{1'b1}} && timing_enabled && last_edge_cycle!=0)
                check(cycle-last_edge_cycle==hold_cycles[selected]+1,"exact CS hold");
            old_sclk=sclk; old_cs=cs_n;
        end
    end

    task automatic apb(input bit wr,input int addr,input logic[31:0] data,input int strobes,
                       output logic[31:0] result,input bit expect_error=0);
        @(negedge pclk); psel=1; penable=0; pwrite=wr; paddr=12'(addr); pwdata=data; pstrb=4'(strobes);
        @(negedge pclk); penable=1;
        #0.1;
        check(pready===1'b1,"APB first ACCESS ready");
        check(pslverr===expect_error,$sformatf("APB %s @%03x error expected %b got %b",wr?"write":"read",addr,expect_error,pslverr));
        result=prdata;
        if(expect_error && !wr) check(result===0,"failed read returns zero");
        @(posedge pclk); #0.1;
        @(negedge pclk); psel=0;penable=0;pstrb=0;
    endtask
    task automatic wr(input int addr,input logic[31:0] value,input int strobes=15,input bit err=0);
        logic[31:0] ignored; apb(1,addr,value,strobes,ignored,err);
    endtask
    task automatic rd(input int addr,output logic[31:0] value,input bit err=0);
        apb(0,addr,0,0,value,err);
    endtask
    task automatic expect_reg(input int addr,input logic[31:0] expected,input logic[31:0] mask='1);
        logic[31:0] v;rd(addr,v);check((v&mask)===(expected&mask),$sformatf("CSR %03x expected %08x got %08x mask %08x",addr,expected,v,mask));
    endtask
    task automatic reset_dut;
        monitor_enabled=0;timing_enabled=0; expected_mosi.delete();response_bits.delete();
        @(negedge pclk);preset_n=0;psel=0;penable=0;pstrb=0;
        repeat(3) @(negedge pclk);
        preset_n=1;
        repeat(2) @(negedge pclk);
        for(int i=0;i<8;i++) begin mode[i]=0;divisor[i]=1;setup_cycles[i]=0;hold_cycles[i]=0;gap_cycles[i]=0;end
        edges=0;samples=0;bits_in_frame=8;
    endtask
    task automatic configure(input int cs,input int md,input bit lsb,input int div=0,input bit loopback=0,
                             input int setup_n=1,input int hold_n=1,input int gap_n=0);
        lsb_order[cs]=lsb;mode[cs]=md;divisor[cs]=div;setup_cycles[cs]=setup_n;hold_cycles[cs]=hold_n;gap_cycles[cs]=gap_n;
        // mode encoding is conventional CPOL*2+CPHA, while CSR is CPHA*2+CPOL.
        mode[cs]={30'd0,md[0],md[1]};
        wr('h100+cs*32,(int'(loopback)<<3)|(int'(lsb)<<2)|(md[0]<<1)|md[1]);
        wr('h104+cs*32,div);
        wr('h108+cs*32,(hold_n<<16)|setup_n);
        wr('h10c+cs*32,(gap_n<<16)|1);
    endtask
    task automatic push_cmd(input int op,input int width,input int len,input bit keep=0,input bit stall=0,input int cs=0,input int tag=1,input bit err=0);
        wr('h038,cs|(op<<4)|(width<<8)|(int'(keep)<<16)|(int'(stall)<<17));
        wr('h03c,len);wr('h040,tag);wr('h044,1,15,err);
        if(!err) command_cov.sample(op,keep,stall);
    endtask
    task automatic plan_frame(input logic[31:0] tx,input logic[31:0] rx,input int width,input bit lsb);
        for(int b=0;b<width;b++) begin
            expected_mosi.push_back(tx[lsb?b:width-1-b]);
            response_bits.push_back(rx[lsb?b:width-1-b]);
        end
    endtask
    task automatic idle_wait(input int limit=200000);
        logic[31:0] v;
        for(int i=0;i<limit;i++) begin rd('h010,v);if(!v[0]) return;end
        check(0,"bounded wait BUSY timeout");
    endtask
    task automatic wait_mask(input int addr,input logic[31:0] mask,input logic[31:0] value,input int limit=2000);
        logic[31:0] v;
        for(int i=0;i<limit;i++) begin rd(addr,v);if((v&mask)==value) return;end
        check(0,$sformatf("bounded wait @%x mask %x value %x",addr,mask,value));
    endtask

    task automatic test_apb;
        logic[31:0] v,old,merged;
        reset_dut();expect_reg(0,'h10000);expect_reg('h018,'h200);expect_reg('h038,'h800);expect_reg('h03c,1);
        expect_reg('h004,N|($clog2(TD)<<4)|($clog2(RD)<<8)|($clog2(CD)<<12)|(32<<16)|(3<<22));
        for(int s=0;s<16;s++) begin
            wr('h040,'h1234);wr('h040,'habcd,s);
            merged='h1234; if(s&1)merged[7:0]='hcd;if(s&2)merged[15:8]='hab;
            expect_reg('h040,merged);
        end
        for(int p=0;p<8;p++) begin pprot=3'(p);wr('h040,p);expect_reg('h040,p);end
        for(int a='h05c;a<'h100;a+=4) rd(a,v,1);
        for(int a=1;a<4;a++) begin wr(a,1,15,1);rd(a,v,1);end
        wr(0,1,0,1);rd('h030,v,1);wr('h034,1,15,1);rd('h00c,v,1);rd('h044,v,1);
        for(int s=1;s<15;s++) begin wr('h030,1,s,1);wr('h044,1,s,1);wr('h00c,1,s,1);end
        wr('h030,1,0);expect_reg('h014,0);
        wr('h018,0,15,1);wr('h018,((RD+1)<<9),15,1);wr('h018,'h200|TD);expect_reg('h018,'h200|TD);
        wr('h01c,'h12345678);wr(8,1);wr('h01c,1,15,1);expect_reg('h01c,'h12345678);
        wr('h100,15,15,1);wr('h100,15,0);expect_reg('h100,0);
        wr(8,1);wr('h00c,3,15,1);wr('h00c,32,15,1);
        wr('h02c,'1);expect_reg('h02c,0);
        for(int i=N;i<8;i++) begin rd('h100+i*32,v,1);wr('h100+i*32,0,0,1);end
        // SETUP alone cannot push; back-to-back transfers under one PSEL each push once.
        @(negedge pclk);psel=1;penable=0;pwrite=1;paddr='h030;pwdata='h55;pstrb=15;
        repeat(4) @(negedge pclk);
        psel=0;expect_reg('h014,0);
        @(negedge pclk);psel=1;penable=0;pwrite=1;paddr='h030;pwdata='h11;pstrb=15;
        @(negedge pclk);penable=1;
        @(negedge pclk);penable=0;pwdata='h22;
        @(negedge pclk);penable=1;
        @(negedge pclk);psel=0;penable=0;
        expect_reg('h014,2,511);
    endtask

    task automatic test_modes;
        int widths[9]='{1,2,7,8,9,16,24,31,32};
        logic[31:0] tx,rx,mask;
        for(int md=0;md<4;md++) for(int l=0;l<2;l++) for(int w=0;w<9;w++) begin
            reset_dut();bits_in_frame=widths[w];
            configure(0,md,1'(l),w%2);wr(8,1);
            mask=32'hffffffff>>(32-widths[w]);
            for(int f=0;f<3;f++) begin
                tx=32'ha5963cc3 ^ (32'h10204081*f);rx=32'hd35a8769 ^ (32'h01020408*f);
                wr('h030,tx);plan_frame(tx,rx,widths[w],1'(l));
            end
            monitor_enabled=1;timing_enabled=1;
            push_cmd(2,widths[w],3,0,0,0,md*100+w);
            idle_wait();
            check(edges==6*widths[w],"exact data clock count");check(expected_mosi.size()==0,"all MOSI bits observed");
            for(int f=0;f<3;f++) begin rx=(32'hd35a8769 ^ (32'h01020408*f))&mask;expect_reg('h034,rx);end
            expect_reg('h054,1);expect_reg('h050,md*100+w);expect_reg('h02c,0);expect_reg('h020,3);
            mode_seen[md]++;width_seen[widths[w]]++;order_seen[l]++;op_seen[2]++;
        end
    endtask

    task automatic test_commands;
        logic[31:0] v;
        reset_dut();configure(0,0,0,1);wr(8,1);wr('h030,'h9f);
        plan_frame('h9f,0,8,0);for(int i=0;i<5;i++)plan_frame(1,0,1,0);
        plan_frame('hff,'ha5,8,0);plan_frame('hff,'h5a,8,0);
        monitor_enabled=1;
        push_cmd(0,8,1,1,1,0,11);push_cmd(3,0,5,1,1,0,12);push_cmd(1,8,2,0,1,0,13);
        idle_wait();expect_reg('h054,3);expect_reg('h050,13);expect_reg('h034,'ha5);expect_reg('h034,'h5a);
        check(edges==58,"TX+dummy+RX edge count");check(expected_mosi.size()==0,"segmented serial plan consumed");
        op_seen[0]++;op_seen[1]++;op_seen[3]++;
        push_cmd(4,0,0,0,0,0,14);idle_wait();expect_reg('h054,4);check(edges==58,"idle RELEASE has no clock");op_seen[4]++;
        // Shadow snapshot remains unchanged after queued submission.
        reset_dut();configure(0,1,1,1);wr(8,1);
        push_cmd(0,8,1,1,1,0,77);wait_mask('h010,4,4);
        push_cmd(4,0,0,0,0,0,88);wr('h038,'hffffffff);wr('h040,999);
        plan_frame('h81,0,8,1);monitor_enabled=1;wr('h030,'h81);
        idle_wait();expect_reg('h050,88);expect_reg('h054,2);expect_reg('h02c,0);
        // Invalid descriptors rejected atomically, then valid queue still works.
        push_cmd(0,0,1,0,0,0,1,1);push_cmd(0,33,1,0,0,0,1,1);push_cmd(0,8,0,0,0,0,1,1);
        push_cmd(3,1,1,0,0,0,1,1);push_cmd(4,0,1,0,0,0,1,1);push_cmd(7,8,1,0,0,0,1,1);
        if(N<8)push_cmd(0,8,1,0,0,N,1,1);
        expect_reg('h054,2);
    endtask

    task automatic test_fifo_stall;
        logic[31:0] v;
        reset_dut();configure(0,0,0,0);wr(8,1);
        push_cmd(2,8,TD+RD+5,0,1,0,42);
        wait_mask('h010,4,4);check(cs_n=={N{1'b1}},"first resource wait leaves CS inactive");
        for(int i=0;i<TD+RD+5;i++) plan_frame(i,8'(i^'h5a),8,0);
        monitor_enabled=1;
        // Software interleaves feed/drain; length exceeds both FIFOs.
        for(int i=0;i<TD+RD+5;i++) begin
            wr('h030,i);wait_mask('h014,'h3fe00,'h200);
            expect_reg('h034,8'(i^'h5a));
        end
        idle_wait();expect_reg('h054,1);expect_reg('h02c,0);check(expected_mosi.size()==0,"long streamed transfer complete");
        reset_dut();for(int i=0;i<TD;i++)wr('h030,i);
        wr('h030,'hff,15,1);expect_reg('h014,TD,511);wr('h00c,2);expect_reg('h014,0,511);
        rd('h034,v,1);expect_reg('h02c,6,6);
        // Hold an active descriptor waiting TX so command queue can be filled exactly.
        wr(8,1);push_cmd(0,8,1,0,1);wait_mask('h010,4,4);
        for(int i=0;i<CD;i++)push_cmd(0,8,1,0,1,0,i);
        push_cmd(0,8,1,0,1,0,99,1);expect_reg('h014,CD<<18,'h7c0000);
        wr('h00c,1);idle_wait();expect_reg('h014,0);expect_reg('h010,64,64);
    endtask

    task automatic test_recovery;
        logic[31:0] v;
        reset_dut();configure(0,0,0,0);wr('h01c,1);wr(8,1);push_cmd(0,8,1,0,1);
        idle_wait();expect_reg('h02c,256,256);expect_reg('h010,64,64);expect_reg('h054,0);
        push_cmd(0,8,1,0,1,0,1,1);
        wr(8,0);wr('h02c,'1);wr('h00c,16);expect_reg('h010,0,64);wr('h01c,0);wr(8,1);
        push_cmd(0,8,1,0,0);idle_wait();expect_reg('h02c,64,64);
        // ABORT an active frame; completed RX remains but no normal completion.
        reset_dut();configure(0,3,0,10);wr(8,1);wr('h030,'h12345678);
        plan_frame('h12345678,'habcdef01,32,0);monitor_enabled=1;
        push_cmd(2,32,1,0,0,0,55);wait_mask('h010,2,2);
        repeat(30)@(negedge pclk);wr('h00c,1);idle_wait();
        expect_reg('h054,0);expect_reg('h050,0);expect_reg('h020,4);expect_reg('h034,'habcdef01);
        check(edges==64,"ABORT finishes full frame");expect_reg('h04c,1);expect_reg('h048,55);
        wr(8,0);wr('h00c,32);expect_reg('h038,'h800);expect_reg('h104,1);expect_reg('h018,'h200);expect_reg('h054,0);
        if(N>1) begin
            reset_dut();configure(0,0,0);configure(1,2,0);wr(8,1);
            push_cmd(3,0,1,1,1,0);wait_mask('h010,16,16);
            push_cmd(3,0,1,0,1,1);idle_wait();expect_reg('h02c,512,512);expect_reg('h054,1);
        end
    endtask

    task automatic test_irq;
        reset_dut();wr('h024,'h10);check(!irq,"TX WM disabled while ENABLE=0");wr(8,1);
        check(irq,"TX WM live when enabled and empty");wr('h020,'1);check(irq,"W1C cannot clear level");
        wr('h030,'h55);check(!irq,"TX fill clears watermark condition");wr('h024,8);
        wr(0,1,15,1);check(irq,"APB error asserts error level");wr('h020,'1);check(irq,"event clear does not clear ERROR");
        wr('h02c,1);check(!irq,"ERROR_STATUS clear deasserts level");
        wr('h024,3);push_cmd(0,8,1);idle_wait();check(irq,"completion interrupt");
        expect_reg('h020,3);wr('h020,0);expect_reg('h020,3);
        wr('h020,7,2);expect_reg('h020,3);wr('h020,1);expect_reg('h020,2);
        check(irq,"XFER_DONE still set");wr('h020,2);check(!irq,"all completions cleared");
        wr('h024,0);push_cmd(4,0,0);idle_wait();check(!irq,"masked event retained without IRQ");
        wr('h024,1);check(irq,"unmask retained event");
    endtask

    task automatic test_extended;
        logic[31:0] v;
        int before_edges;
        // RX capacity pre-reservation: RX-only fills, then waits before the extra frame.
        reset_dut();configure(0,0,0);wr(8,1);
        for(int i=0;i<RD+1;i++)plan_frame('hff,i,8,0);
        monitor_enabled=1;push_cmd(1,8,RD+1,0,1);
        wait_mask('h010,8,8,20000);expect_reg('h014,RD<<9,'h3fe00);
        before_edges=edges;repeat(10)@(negedge pclk);check(edges==before_edges,"RX full pauses between frames");
        expect_reg('h034,0);idle_wait();
        for(int i=1;i<RD+1;i++)expect_reg('h034,i&255);
        expect_reg('h02c,0);check(edges==16*(RD+1),"RX reservation no extra frame");
        // Non-stall RX exhaustion must fault, retaining all completed words.
        reset_dut();configure(0,0,0);wr(8,1);push_cmd(1,1,RD+1,0,0);
        idle_wait();expect_reg('h02c,128,128);expect_reg('h014,RD<<9,'h3fe00);expect_reg('h054,0);
        // Frame gap/CS timing with boundary encodings and external delay.
        reset_dut();bits_in_frame=7;configure(0,2,1,2,0,4,7,5);wr(8,1);
        for(int i=0;i<3;i++)begin wr('h030,'h55+i);plan_frame('h55+i,'h31+i,7,1);end
        miso_delay=3.0;monitor_enabled=1;timing_enabled=1;push_cmd(2,7,3);idle_wait();
        for(int i=0;i<3;i++)expect_reg('h034,'h31+i);
        check(edges==42,"FRAME_GAP has no extra clocks");miso_delay=0.2;
        // Maximum divider and timing fields must not wrap at 16 bits.
        reset_dut();configure(0,0,0,65535,0,65535,65535);wr(8,1);
        plan_frame(1,1,1,0);wr('h030,1);bits_in_frame=1;monitor_enabled=1;timing_enabled=1;
        push_cmd(2,1,1);idle_wait();expect_reg('h034,1);check(edges==2,"maximum divider two edges");
        // Loopback supplements the external BFM; no assumption that a slave ACKs.
        reset_dut();configure(0,1,1,0,1);wr(8,1);wr('h030,'h15ab);
        push_cmd(2,13,1);idle_wait();expect_reg('h034,'h15ab);
        // Consecutive independent devices with opposite CPOL and unequal timing.
        if(N>1)begin
            reset_dut();configure(0,0,0,1);configure(N-1,3,0,1);wr(8,1);
            wr('h030,'ha5);wr('h030,'h5a);plan_frame('ha5,'h12,8,0);plan_frame('h5a,'h34,8,0);
            monitor_enabled=1;push_cmd(2,8,1,0,0,0,9);push_cmd(2,8,1,0,0,N-1,9);
            idle_wait();expect_reg('h054,2);expect_reg('h050,9);expect_reg('h034,'h12);expect_reg('h034,'h34);
        end
        // Timeout zero permits long KEEP_CS wait; explicit RELEASE supplies progress.
        reset_dut();wr(8,1);push_cmd(3,0,1,1,1);wait_mask('h010,16,16);
        repeat(100)@(negedge pclk);expect_reg('h02c,0);push_cmd(4,0,0);idle_wait();expect_reg('h054,2);
        // Abort while waiting a command must never depend on a future command.
        push_cmd(3,0,1,1,1);wait_mask('h010,16,16);wr('h00c,1);idle_wait(20);expect_reg('h010,64,64);
    endtask

    task automatic test_random;
        int md,l,w,cs,count,div;
        logic[31:0] tx,rx,mask;
        logic[31:0] expected[$];
        for(int trial=0;trial<32;trial++)begin
            reset_dut();expected.delete();md=$urandom_range(0,3);l=$urandom_range(0,1);
            w=$urandom_range(1,32);cs=$urandom_range(0,N-1);count=$urandom_range(1,TD<RD?TD:RD);
            if(count>12)count=12;
            div=$urandom_range(0,7);bits_in_frame=w;mask=32'hffffffff>>(32-w);
            configure(cs,md,1'(l),div,0,$urandom_range(0,4),$urandom_range(0,4));wr(8,1);
            for(int i=0;i<count;i++)begin
                tx=$urandom;rx=$urandom;expected.push_back(rx&mask);wr('h030,tx);plan_frame(tx,rx,w,1'(l));
            end
            monitor_enabled=1;timing_enabled=1;push_cmd(2,w,count,0,0,cs,trial);
            idle_wait();foreach(expected[i])expect_reg('h034,expected[i]);
            check(edges==2*w*count,"random exact edge count");expect_reg('h02c,0);expect_reg('h050,trial);
        end
    endtask

    task automatic test_races;
        logic[31:0] v;
        int n;
        // W1C SEG_DONE on exact completion of an idle RELEASE: hardware set wins.
        reset_dut();wr(8,1);wr('h038,4<<4);wr('h03c,0);wr('h040,1);
        // PUSH completes at t0; descriptor pops t0+1, FETCH completes t0+2.
        @(negedge pclk);psel=1;penable=0;pwrite=1;paddr='h044;pwdata=1;pstrb=15;
        @(negedge pclk);penable=1;
        @(negedge pclk);penable=0;paddr='h020;pwdata=1;
        @(negedge pclk);penable=1;
        @(negedge pclk);psel=0;penable=0;
        expect_reg('h020,1);expect_reg('h054,1);
        // Clear before timeout; the later hardware event must still be recorded.
        reset_dut();wr('h01c,100);wr(8,1);push_cmd(0,8,1,0,1);
        wait_mask('h010,4,4);wr('h02c,'1);idle_wait();expect_reg('h02c,256,256);
        // Reset representative active, waiting, held-CS and idle states.
        for(int phase=0;phase<5;phase++)begin
            reset_dut();configure(0,phase%4,0,7);wr(8,1);
            if(phase!=1)wr('h030,'h55);
            push_cmd(0,8,1,1,1);
            case(phase)
                0: repeat(1)@(negedge pclk);
                1: wait_mask('h010,4,4);
                2: begin wait_mask('h010,2,2);repeat(6)@(negedge pclk);end
                3: wait_mask('h010,16,16);
                4: begin wr('h00c,1);idle_wait();end
            endcase
            reset_dut();expect_reg('h014,0);expect_reg('h054,0);expect_reg('h020,0);expect_reg('h02c,0);
            check(cs_n=={N{1'b1}} && sclk==0 && mosi==0 && !irq,"hard reset pin state");
        end
    endtask

    task automatic run_group(input string name);
        group_name=name;
        case(name)
            "apb":test_apb();
            "modes":test_modes();
            "commands":test_commands();
            "fifo_stall":test_fifo_stall();
            "recovery":test_recovery();
            "irq":test_irq();
            "extended":test_extended();
            "random":test_random();
            "races":test_races();
            default:check(0,"unknown test group");
        endcase
        $display("SPI_GROUP %s errors=%0d checks=%0d",name,errors,checks);
    endtask
endinterface
