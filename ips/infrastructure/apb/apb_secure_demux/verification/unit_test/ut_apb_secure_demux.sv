`timescale 1ns/1ps
module ut_apb_secure_demux;
    import apb_secure_demux_instance_pkg::*;
    localparam int NP=int'(C_NUM_PORTS),AW=int'(C_ADDR_WIDTH),IW=int'(C_MASTER_ID_WIDTH);
    logic clk=0,rst_n=0;
    always #5 clk=~clk;
    logic [AW-1:0] addr=0;logic sel=0,en=0,wr=0;
    logic [31:0] wdata=0;logic [3:0] strb=4'hf;logic [2:0] prot=3'b001;
    logic [IW-1:0] master=0;logic master_valid=1,auth=1;
    wire [31:0] rdata;wire ready,error,irq,alert,busy,port_valid,wait_hit;wire [4:0] obs_port;
    wire [AW-1:0] maddr[NP];wire [NP-1:0] msel,men,mwrite,mvalid;
    wire [31:0] mwdata[NP];wire [3:0] mstrb[NP];wire [2:0] mprot[NP];wire [IW-1:0] mid[NP];
    logic [31:0] mrdata[NP];logic [NP-1:0] mready='1,merror='0;
    int errors=0,checks=0,transactions=0;
    logic [31:0] returned;
    localparam logic [AW-1:0] CB=AW'(C_CSR_BASE);
    apb_secure_demux dut(.pclk(clk),.preset_ni(rst_n),.s_paddr(addr),.s_psel(sel),.s_penable(en),.s_pwrite(wr),
        .s_pwdata(wdata),.s_pstrb(strb),.s_pprot(prot),.s_prdata(rdata),.s_pready(ready),.s_pslverr(error),
        .master_id_i(master),.master_id_valid_i(master_valid),.m_paddr(maddr),.m_psel(msel),.m_penable(men),
        .m_pwrite(mwrite),.m_pwdata(mwdata),.m_pstrb(mstrb),.m_pprot(mprot),.m_prdata(mrdata),.m_pready(mready),
        .m_pslverr(merror),.m_master_id_o(mid),.m_master_id_valid_o(mvalid),.irq_o(irq),.security_alert_o(alert),
        .dfx_authorized_i(auth),.busy_o(busy),.active_port_valid_o(port_valid),.wait_threshold_o(wait_hit),.active_port_o(obs_port));
    task automatic check(input bit ok,input string label_text);
        checks++;if(!ok) begin errors++;$display("TOP mismatch %s addr=%h data=%h reason=%h",label_text,addr,rdata,dut.completion_reason);end
    endtask
    task automatic transfer(input logic [AW-1:0] address,input bit write_access,input logic [31:0] value,
                            input bit expected_error,input logic [31:0] expected_data,input bit compare_data,
                            input int expected_port=-1,input int target_waits=0,input bit revoke=0);
        int remaining,cycles;
        transactions++;remaining=target_waits;cycles=0;
        @(negedge clk);addr=address;wr=write_access;wdata=value;sel=1;en=0;mready='1;
        #1;
        if(expected_port>=0 && !C_REGISTER_MODE) check(msel==(NP'(1)<<expected_port) && men==0,"direct SETUP only one target");
        else check(msel==0,"no unauthorized/local/registered SETUP selection");
        @(negedge clk);en=1;if(revoke) auth=0;
        for(int limit=0;limit<100;limit++) begin
            if(expected_port>=0) mready[expected_port]=(remaining==0);
            #1;
            if(expected_port>=0 && msel[expected_port]) begin
                check(maddr[expected_port]===address && mwrite[expected_port]===write_access && mwdata[expected_port]===value,"payload retained");
                check(mid[expected_port]===master && mvalid[expected_port],"identity retained");
            end else if(expected_port<0) check(msel==0 && mvalid==0,"denial no downstream side effect");
            if(ready) begin
                returned=rdata;check(error===expected_error,"error result");
                if(compare_data) check(rdata===expected_data,"read data");
                check(cycles==((expected_port>=0)?int'(C_REGISTER_MODE)+target_waits:0),"first ACCESS/local or exact forwarding latency");
                @(posedge clk);#1;return;
            end
            if(expected_port>=0 && msel[expected_port] && men[expected_port] && remaining>0) remaining--;
            cycles++;@(negedge clk);
        end
        $fatal(1,"APB transfer timeout");
    endtask
    initial begin
        $assertoff(0,dut);
        for(int p=0;p<NP;p++) mrdata[p]=32'hcafe0000+32'(p);
        repeat(2) @(negedge clk);rst_n=1;#1;$asserton(0,dut);
        transfer(CB,0,0,0,32'h41534458,1);
        prot=3'b010;transfer(CB,0,0,!C_PUBLIC_ID_EN,C_PUBLIC_ID_EN?32'h41534458:0,1);
        transfer(CB+AW'(32'h34),1,32'h1ff,1,0,1);
        prot=3'b001;transfer(CB+AW'(32'h34),0,0,0,0,1);
        transfer(CB+AW'(1),0,0,1,0,1);
        strb=4'h1;transfer(CB+AW'(32'h34),1,32'h1ff,1,0,1);strb=4'hf;
        transfer(CB+AW'(32'h68),0,0,1,0,1);
        transfer(CB,1,0,1,0,1);
        transfer(CB+AW'(32'h1c),0,0,1,0,1);
        // Reset policy denies by default in the selected test fixture.
        transfer(C_PORT_BASE[0],0,0,1,0,1);
        transfer(CB+AW'(32'h100c),1,3,0,0,0);
        transfer(CB+AW'(32'h1100),1,32'hff,0,0,0);
        transfer(C_PORT_BASE[0],0,0,1,0,1);
        transfer(CB+AW'(32'h1c),1,1,0,0,0);
        transfer(CB+AW'(32'h14),0,0,0,1,1);
        transfer(C_PORT_BASE[0],0,0,0,32'hcafe0000,1,0);
        transfer(C_PORT_BASE[0]+AW'(4),1,32'h12345678,0,0,0,0,3);
        merror[0]=1;transfer(C_PORT_BASE[0],0,0,1,32'hcafe0000,1,0);merror=0;
        master_valid=0;transfer(C_PORT_BASE[0],0,0,1,0,1);master_valid=1;
        prot=3'b101;transfer(C_PORT_BASE[0],1,0,1,0,1);prot=3'b001;
        if(C_DFX_EN) begin
            transfer(CB+AW'(32'h10c),1,0,0,0,0);
            transfer(CB+AW'(32'h110),1,2,0,0,0);
            transfer(C_PORT_BASE[0],0,0,1,0,1);
            transfer(C_PORT_BASE[0],0,0,0,32'hcafe0000,1,0);
            transfer(CB+AW'(32'h104),1,1,1,0,1,-1,0,1);auth=1;
            transfer(CB+AW'(32'h104),0,0,0,0,1);
        end
        transfer(CB+AW'(32'h18),1,1,0,0,0);
        transfer(CB+AW'(32'h1100),1,0,1,0,1);
        transfer(CB+AW'(32'h1c),1,0,1,0,1);
        transfer(CB+AW'(32'h20),0,0,0,32'h12,1);
        transfer(C_PORT_BASE[0],0,0,0,32'hcafe0000,1,0);
        @(negedge clk);sel=0;en=0;rst_n=0;#1;check(msel==0 && !ready && !error && rdata==0,"asynchronous reset isolation");
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX: METRICS (errors=0 checks=%0d transactions=%0d)",checks,transactions);$display("UT_APB_SECURE_DEMUX: PASS (errors=0)");$finish;
    end
    initial begin #100000;$fatal(1,"top timeout");end
endmodule
