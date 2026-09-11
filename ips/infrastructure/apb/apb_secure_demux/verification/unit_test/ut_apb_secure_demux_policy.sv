`timescale 1ns/1ps
module ut_apb_secure_demux_policy;
    logic clk=0,rst_n=0;
    always #5 clk=~clk;
    logic cfg_wr=0,perm_wr=0,global_wr=0,port_wr=0,attempt=0,commit=0,reload=0;
    logic [4:0] port=0;
    logic [5:0] master=0;
    logic [31:0] wdata=0;
    logic synthetic=0;
    wire [1:0] acfg[3],scfg[3];
    wire [7:0] aperm[3][3],sperm[3][3];
    wire global_lock,raw_bad,fatal,new_integrity,test_flag,mask_ok,locked;
    wire [2:0] port_lock;
    wire [4:0] first_locked;
    wire [31:0] version,status,integrity;
    int errors=0,checks=0;
    apb_secure_demux_policy #(.NUM_PORTS(3),.NUM_MASTERS(3),
        .RESET_PORT_CFG('{2'd1,2'd2,2'd3}),
        .RESET_PERM('{'{8'h01,8'h12,8'h23},'{8'h34,8'h45,8'h56},'{8'h67,8'h78,8'h89}})) dut(
        .pclk(clk),.preset_n(rst_n),.cfg_write_i(cfg_wr),.perm_write_i(perm_wr),
        .global_lock_write_i(global_wr),.port_lock_write_i(port_wr),.commit_attempt_i(attempt),
        .commit_accept_i(commit),.reload_accept_i(reload),.port_i(port),.master_i(master),
        .write_data_i(wdata),.synthetic_integrity_i(synthetic),.synthetic_port_i(5'd2),
        .active_cfg_o(acfg),.shadow_cfg_o(scfg),.active_perm_o(aperm),.shadow_perm_o(sperm),
        .global_lock_o(global_lock),.port_lock_o(port_lock),.raw_bad_o(raw_bad),.fatal_o(fatal),
        .new_integrity_o(new_integrity),.integrity_test_o(test_flag),.policy_version_o(version),
        .commit_status_o(status),.integrity_status_o(integrity),.mask_valid_o(mask_ok),
        .selected_locked_o(locked),.first_locked_port_o(first_locked));
    task automatic check(input bit ok,input string label_text);
        checks++;if(!ok) begin errors++;$display("POLICY mismatch %s integrity=%h",label_text,integrity);end
    endtask
    task automatic tick;@(posedge clk);#1;@(negedge clk);endtask
    task automatic idle;cfg_wr=0;perm_wr=0;global_wr=0;port_wr=0;attempt=0;commit=0;reload=0;synthetic=0;endtask
    initial begin
        // CBB ASM-001 excludes unknown inputs. Enable its immediate checkers only
        // after reset has initialized policy storage; DUT functionality is unchanged.
        $assertoff(0, dut);
        tick();rst_n=1;#1;$asserton(0, dut);check(acfg[2]==3 && aperm[1][2]==8'h56 && !fatal && !raw_bad,"nonzero reset and parity");
        cfg_wr=1;port=0;wdata=3;tick();idle();
        perm_wr=1;port=0;master=2;wdata=8'haa;tick();idle();
        check(scfg[0]==3 && sperm[0][2]==8'haa && acfg[0]==1 && aperm[0][2]==8'h23 && !raw_bad,"shadow isolated");
        attempt=1;commit=1;wdata=1;tick();idle();
        check(acfg[0]==3 && aperm[0][2]==8'haa && aperm[1][2]==8'h56 && version==1 && status==1 && !raw_bad,"atomic selected bank");
        attempt=1;commit=1;wdata=1;tick();idle();check(version==2,"same-value commit increments");
        perm_wr=1;wdata=0;tick();idle();reload=1;wdata=1;tick();idle();check(sperm[0][2]==8'haa && version==2 && !raw_bad,"reload no version change");
        port=1;port_wr=1;wdata=1;tick();idle();
        attempt=1;commit=1;wdata=3;tick();idle();check(version==2 && status==32'h2132 && locked && first_locked==1,"one locked target rejects all");
        global_wr=1;wdata=1;tick();idle();attempt=1;commit=1;wdata=0;tick();idle();
        check(status==32'h12 && global_lock && version==2,"mask diagnostic before lock");
        global_wr=1;port_wr=1;port=1;wdata=0;tick();idle();check(global_lock && port_lock[1],"write zero never unlocks");
        // True protection-bit fault, not synthetic event input.
        force dut.g_protected.cfg_active_parity_q[0]=1'b1;
        #1;check(raw_bad && new_integrity && !fatal,"raw parity blocks before FATAL edge");
        tick();release dut.g_protected.cfg_active_parity_q[0];
        check(fatal && integrity[15:13]==2 && integrity[6:2]==0,"latch first location");
        force dut.g_protected.global_lock_q=2'b00;tick();release dut.g_protected.global_lock_q;
        check(fatal && integrity[15:13]==2,"first location sticky");
        rst_n=0;tick();rst_n=1;
        force dut.g_protected.global_lock_q=2'b00;synthetic=1;#1;check(new_integrity && !test_flag,"real fault wins synthetic");tick();
        release dut.g_protected.global_lock_q;idle();check(integrity[15:13]==0 && global_lock,"invalid lock fails closed");
        rst_n=0;tick();rst_n=1;synthetic=1;#1;check(new_integrity && test_flag,"synthetic marked TEST");tick();idle();
        check(fatal && integrity[15:13]==6 && integrity[6:2]==2,"synthetic location");
        cfg_wr=1;wdata=0;port=2;tick();idle();check(scfg[2]==3,"FATAL cannot be repaired by write");
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX_POLICY: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_POLICY: METRICS (errors=0 checks=%0d)",checks);$display("UT_APB_SECURE_DEMUX_POLICY: PASS (errors=0)");$finish;
    end
    initial begin #10000;$fatal(1,"policy timeout");end
endmodule
