`timescale 1ns/1ps
module ut_watchdog_top;
  import watchdog_pkg::*;
  parameter int PS=7, WS=5;
  logic pclk=0,wdt_clk=0,run_p=1,run_w=1,por_n=0,preset_n=0;
  always #(PS) if(run_p) pclk=~pclk;
  always #(WS) if(run_w) wdt_clk=~wdt_clk;
  logic PSEL=0,PENABLE=0,PWRITE=0;
  logic [14:0] PADDR=0;
  logic [31:0] PWDATA=0,PRDATA;
  logic [3:0] PSTRB=15;
  logic [2:0] PPROT=0;
  logic PREADY,PSLVERR;
  logic [3:0] source=0;
  logic cfg_auth=1,service_auth=1,diag_auth=1;
  logic sleep_req=0,debug_req=0,debug_auth=0,warm=0,test_auth=1;
  logic [1:0] done=0,pause_ack,recovery_ack,irq,nmi,local_req;
  logic final_req,alert,safe,wake,hwvalid=0,hwready;
  logic [31:0] value,seqno;
  int checks=0;
  watchdog_top #(.NUM_CHANNELS(2),.NUM_CLIENTS(2),.SUPPORT_TOKEN_QA(1),
    .SUPPORT_SUPERVISION(1),.SUPPORT_HW_EVENT(1),.SAFETY_EN(1),
    .ALLOW_RUNTIME_UPDATE(1),.DIAG_INJECT_EN(1),.AUTO_START_MASK(2'b10)) dut(
    .pclk(pclk),.preset_n(preset_n),.wdt_clk(wdt_clk),.por_n(por_n),
    .PSEL(PSEL),.PENABLE(PENABLE),.PWRITE(PWRITE),.PADDR(PADDR),.PWDATA(PWDATA),.PSTRB(PSTRB),
    .PPROT(PPROT),.PRDATA(PRDATA),.PREADY(PREADY),.PSLVERR(PSLVERR),
    .access_source_i(source),.cfg_auth_i(cfg_auth),.service_auth_i(service_auth),.diag_auth_i(diag_auth),
    .sleep_req_i(sleep_req),.debug_req_i(debug_req),.debug_auth_i(debug_auth),
    .warm_reset_evt_i(warm),.test_auth_i(test_auth),.recovery_done_i(done),
    .pause_ack_o(pause_ack),.recovery_ack_o(recovery_ack),.irq_o(irq),.nmi_req_o(nmi),
    .local_reset_req_o(local_req),.system_reset_req_o(final_req),.safety_alert_o(alert),
    .safe_state_req_o(safe),.wake_req_o(wake),.hw_evt_valid(hwvalid),.hw_evt_ready(hwready),
    .hw_evt_channel(4'b0),.hw_evt_client(5'b0),.hw_evt_type(3'b0),.hw_evt_data(KEY1),.hw_evt_source(4'b0));
  task automatic ck(input bit c,input string m);
    checks++;if(!c)$fatal(1,"APB CHECK FAILED %s value=%x",m,value);
  endtask
  task automatic bus(input bit wr,input int address,input logic [31:0] data,
    input bit error_expected=0,input logic [3:0] strobe=15);
    @(negedge pclk);PSEL=1;PENABLE=0;PWRITE=wr;PADDR=15'(address);PWDATA=data;PSTRB=strobe;
    @(negedge pclk);PENABLE=1;
    begin int waits;waits=0;
      do begin @(posedge pclk);waits++;if(waits>2)$fatal(1,"APB bounded latency failed");end while(!PREADY);
      ck(PSLVERR===error_expected,$sformatf("address %x error expected %b",address,error_expected));
      if(!wr)value=PRDATA;
    end
    @(negedge pclk);PSEL=0;PENABLE=0;
  endtask
  task automatic finish_cmd(input logic [7:0] result_expected=OK);
    bit finished;finished=0;
    for(int i=0;i<100;i++)begin
      bus(0,'h10,0);
      if(!value[0] && value[1])begin
        ck(value[15:8]==result_expected,"completion result");finished=1;break;
      end
    end
    ck(finished,"bounded command completion");
    bus(0,'h18,0);seqno=value;
  endtask
  task automatic command(input int offset,input logic [31:0] data,input logic [7:0] r=OK);
    bus(1,'h1000+offset,data);finish_cmd(r);
  endtask
  task automatic unlock;
    command('h40,UNLOCK1);command('h40,UNLOCK2);
  endtask
  initial begin
    repeat(5)@(negedge pclk);por_n=1;preset_n=1;repeat(6)@(negedge pclk);
    bus(0,0,0);ck(value==32'h57445431,"identity");
    bus(0,'h8,0);ck(value[4:0]==1 && value[10:5]==1,"capabilities");
    bus(0,'h1078,0);ck(value==0,"invalid snapshot zero");
    bus(1,'h1000,0,1,3);bus(0,'h1000,0);ck(value==12,"partial write no effect");
    bus(1,'h1000,32'h80000000,1);bus(1,0,0,1);bus(0,'h1001,0,1);bus(0,'h5000,0,1);
    cfg_auth=0;bus(1,'h1000,0,1);cfg_auth=1;
    bus(0,'h1040,0);ck(value==0,"WO reads zero");
    bus(1,'h1140,1);bus(1,'h1144,3);bus(1,'h1140,0);bus(0,'h1144,0);ck(value==0,"client0 independent");
    bus(1,'h1140,1);bus(0,'h1144,0);ck(value==3,"client1 retained");bus(1,'h1140,0);
    bus(1,'h1000,0);bus(1,'h1010,2000);bus(1,'h1020,0);
    unlock();command('h44,COMMIT);unlock();command('h44,START);
    command('h50,KEY1);command('h44,SNAPSHOT);
    bus(0,'h1090,0);ck(value==1,"successful service sequence");
    command('h54,32'h7ffff);repeat(5)@(negedge pclk);ck(irq[0],"access errors produce IRQ");
    command('h58,32'h7ffff);repeat(5)@(negedge pclk);ck(!irq[0],"clear IRQ");
    @(negedge wdt_clk);run_w=0;
    bus(1,'h105c,1);bus(0,'h14,0);begin logic [31:0] issued;issued=value;
      bus(1,'h105c,1,1);bus(0,'h14,0);ck(value==issued,"busy reject does not issue");
      preset_n=0;repeat(4)@(negedge pclk);preset_n=1;repeat(5)@(negedge pclk);
      bus(0,'h10,0);ck(value[0],"mailbox survives preset");
      bus(0,'h1000,0);ck(value==12,"staging reset independently");
      run_w=1;finish_cmd();ck(seqno==issued,"retained command exactly once");
      repeat(20)@(negedge pclk);bus(0,'h18,0);ck(value==issued,"no replay after preset");
    end
    command('h44,SNAPSHOT);bus(0,'h1080,0);ck(value[15],"IRQ_TEST after clock restart");
    bus(0,'h1090,0);ck(value==1,"diagnostics do not refresh");
    source=1;command('h50,KEY1,ACCESS_DENIED);source=0;
    command('h44,SNAPSHOT);bus(0,'h1090,0);ck(value==1,"source rejection no service");
    // A command accepted before warm reset but still inside the synchronizer
    // must be canceled, not replayed after the channel restarts.
    @(negedge wdt_clk);run_w=0;bus(1,'h1050,KEY1);
    warm=1;run_w=1;@(negedge wdt_clk);warm=0;finish_cmd(CANCELED_RESET);
    command('h44,SNAPSHOT);bus(0,'h1090,0);ck(value==1,"warm cancels synchronizer-resident command");
    @(negedge pclk);run_p=0;
    repeat(66000)@(posedge wdt_clk);#1;ck(final_req && nmi[1],"AUTO_START independent of pclk");
    run_p=1;repeat(6)@(negedge pclk);
    @(negedge wdt_clk);warm=1;@(negedge wdt_clk);warm=0;
    ck(!final_req,"warm clears final request");
    command('h44,SNAPSHOT);bus(0,'h10a0,0);ck(value[0],"first fault survives warm");
    $display("UT_WATCHDOG_TOP: PASS (errors=0 checks=%0d PS=%0d WS=%0d)",checks,PS,WS);$finish;
  end
  initial begin #10000000;$fatal(1,"APB test timeout");end
endmodule
