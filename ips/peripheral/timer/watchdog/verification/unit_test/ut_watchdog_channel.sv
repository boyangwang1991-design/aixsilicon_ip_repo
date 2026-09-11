`timescale 1ns/1ps
module ut_watchdog_channel;
  import watchdog_pkg::*;
  parameter int W=32;
  logic clk=0,rst_n=0,valid=0;
  always #5 clk=~clk;
  command_t cmd='0;
  config_t config_bus, cfg;
  logic ae=0,ce=0,sleep_req=0,debug_req=0,debug_auth=0,warm=0,done=0,test_auth=1;
  logic [7:0] result;
  snapshot_t snap;
  logic irq,fault,pause_ack,ack,nmi,local_req,final_req,safe,alert,wake;
  int checks=0,tests=0;
  watchdog_channel #(.COUNTER_WIDTH(W),.PRESCALE_WIDTH(4),.NUM_CLIENTS(2),
    .SUPPORT_TOKEN_QA(1),.SUPPORT_SUPERVISION(1),.SUPPORT_HW_EVENT(1),.SAFETY_EN(1),
    .ALLOW_RUNTIME_UPDATE(1),.NO_STOP(0),.DIAG_INJECT_EN(1)) dut(
    .clk(clk),.rst_n(rst_n),.cmd_valid(valid),.cmd(cmd),.cmd_config(config_bus),
    .access_error(ae),.cdc_error(ce),.sleep_req(sleep_req),.debug_req(debug_req),
    .debug_auth(debug_auth),.warm_reset_evt(warm),.recovery_done(done),.test_auth(test_auth),
    .result(result),.snapshot_next(snap),.irq(irq),.active_fault(fault),.pause_ack(pause_ack),
    .recovery_ack(ack),.nmi_req(nmi),.local_reset_req(local_req),.system_reset_req(final_req),
    .safe_state_req(safe),.safety_alert(alert),.wake_req(wake));
  task automatic ck(input bit condition,input string message);
    checks++;
    if(!condition) $fatal(1,"CHECK FAILED: %s (state=%d count=%d result=%d)",message,dut.q.state,dut.q.count,result);
  endtask
  task automatic cycle(input int count=1);
    repeat(count) begin @(posedge clk); #1; end
  endtask
  task automatic reset_dut;
    @(negedge clk); rst_n=0; valid=0; sleep_req=0; debug_req=0; warm=0; done=0; ae=0; ce=0;
    cycle(2); @(negedge clk); rst_n=1; cycle(2);
    cfg=default_config(); cfg.word[0]=0; cfg.word[4]=1000; cfg.word[8]=0; cfg.word[10]=8;
    config_bus=cfg;
  endtask
  task automatic issue(input logic [7:0] op,input logic [31:0] data=0,
      input logic [7:0] want=OK,input int client=0,input int typ=0,input int source=0);
    @(negedge clk); cmd='0; cmd.opcode=op;cmd.data=data;cmd.client=5'(client);
    cmd.event_type=3'(typ);cmd.source=16'(source);cmd.cfg_auth=1;cmd.service_auth=1;cmd.diag_auth=1;
    valid=1; #1; ck(result===want,$sformatf("op %x expected result %d actual %d",op,want,result));
    @(posedge clk); #1; valid=0;
  endtask
  task automatic unlock;
    issue(UNLOCK,UNLOCK1);issue(UNLOCK,UNLOCK2);
  endtask
  task automatic configure;
    config_bus=cfg;unlock();issue(COMMIT);unlock();issue(START);
    ck(dut.q.count==0 && dut.q.divider==0,"START origin");
  endtask
  task automatic mark(input string name);
    tests++; $display("CASE PASS %s",name);
  endtask
  initial begin
    reset_dut();cfg.word[1]=1;cfg.word[4]=5;configure();
    cycle(9);ck(!fault && dut.q.count==4,"exact 9 cycles");
    cycle();ck(final_req && fault,"timeout exactly 10 cycles");
    ck(dut.q.first_count==5 && dut.q.first_cause[1],"first timeout candidate");mark("TIM precise divider boundary");

    reset_dut();cfg.word[0]=1;cfg.word[2]=2;cfg.word[4]=5;cfg.word[1]=1;configure();
    cycle(3);issue(SERVICE,KEY1);ck(dut.q.count==0 && !fault,"WIN_MIN inclusive");mark("WIN_MIN service inclusive");
    reset_dut();cfg.word[0]=1;cfg.word[2]=2;cfg.word[4]=5;configure();
    issue(SERVICE,KEY1,CANCELED_FAULT);ck(fault && dut.q.raw[2],"early service faults");mark("window early");
    reset_dut();cfg.word[4]=5;configure();cycle(4);
    issue(SERVICE,KEY1,CANCELED_FAULT);ck(dut.q.raw[1] && final_req,"timeout beats service");mark("timeout versus service");

    reset_dut();cfg.word[0]=2;cfg.word[6]=3;cfg.word[4]=6;configure();cycle(2);
    issue(SERVICE,KEY1);ck(!dut.q.raw[0],"refresh suppresses same-edge prewarn");
    cycle(3);ck(dut.q.raw[0],"prewarn set");
    issue(IRQ_CLEAR,1);ck(!dut.q.raw[0] && dut.q.prewarn,"clear history retains epoch flag");mark("prewarn and clear");

    reset_dut();cfg.word[0]=8;cfg.word[10]=3;configure();
    issue(SERVICE,KEY1);ck(dut.q.count!=0,"first key cannot refresh");cycle(2);
    issue(SERVICE,KEY2);ck(dut.q.count==0 && !fault,"sequence inclusive limit");mark("dual key limit inclusive");
    issue(SERVICE,KEY1);cycle(3);ck(fault && dut.q.raw[4],"sequence expiry autonomous");mark("sequence expiry");

    reset_dut();cfg.word[0]=16;configure();issue(SERVICE,seed(0,0));
    ck(dut.cq[0].token==next_token(seed(0,0)),"token advance");
    issue(SERVICE,seed(0,0),CANCELED_FAULT);ck(dut.q.raw[3],"token replay rejected");mark("token replay");
    reset_dut();cfg.word[0]=24;configure();issue(SERVICE,response(seed(0,0),0,0));
    ck(!fault && dut.q.count==0,"QA vector");mark("QA known vector");

    reset_dut();cfg.word[0]=32;cfg.word[11]=3;configure();
    issue(SERVICE,KEY1);ck(dut.cq[0].seen && dut.q.count!=0,"group first no refresh");
    issue(SERVICE,KEY1,BAD_SERVICE);ck(dut.q.raw[5] && !fault,"duplicate record only");
    issue(SERVICE,KEY1,OK,1);ck(dut.q.count==0 && !dut.cq[0].seen,"last client refresh");mark("GROUP and duplicate");

    reset_dut();cfg.word[0]=64;cfg.word[11]=3;cfg.word[4]=8;
    cfg.client[0][1]=32'h00020001;cfg.client[1][1]=32'h00020001;configure();
    issue(SERVICE,KEY1);issue(SERVICE,KEY1,OK,1);cycle(5);
    issue(SERVICE,KEY1,EPOCH_BOUNDARY);ck(!fault && dut.q.count==0,"alive healthy boundary");
    cycle(8);ck(fault && dut.q.raw[6],"alive missing boundary");mark("ALIVE fixed epoch");
    reset_dut();cfg.word[0]=64;cfg.client[0][1]=32'h00010001;configure();
    issue(SERVICE,KEY1);issue(SERVICE,KEY1,CANCELED_FAULT);ck(dut.q.raw[7],"alive overflow");mark("ALIVE overflow");

    reset_dut();cfg.word[0]=96;cfg.client[0][2]=2;cfg.client[0][3]=2;cfg.client[0][5]=4;configure();
    issue(SERVICE,0,OK,0,1);issue(SERVICE,1,OK,0,2);issue(SERVICE,2,OK,0,3);
    ck(!fault && dut.q.count==0,"FLOW START STEP END");mark("FLOW success");
    issue(SERVICE,0,OK,0,1);cycle(3);issue(SERVICE,2,CANCELED_FAULT,0,3);
    ck(fault && dut.q.raw[9],"deadline beats END");mark("FLOW deadline");

    reset_dut();cfg.word[0]=512;configure();cycle(4);
    @(negedge clk);sleep_req=1;cycle();ck(pause_ack,"enter pause");
    begin logic [W-1:0] held; held=dut.q.count;cycle(10);ck(dut.q.count==held,"pause freezes");
      issue(SERVICE,KEY1,PAUSED);@(negedge clk);sleep_req=0;cycle();ck(dut.q.count==held,"exit edge freeze");
      cycle();ck(dut.q.count==held+1,"resume increments following edge");end
    mark("pause exact phase");

    reset_dut();cfg.word[0]=128+256;cfg.word[4]=5;cfg.word[13]=0;cfg.word[14]=8;cfg.word[15]=1;configure();
    cycle(5);ck(local_req && !final_req,"local delay zero");
    @(negedge clk);done=1;cycle();ck(ack && !fault && dut.q.recoveries==1,"qualified recovery");
    cycle(5);ck(fault && local_req,"next fault");cycle(2);ck(fault,"old DONE no repeat recovery");
    @(negedge clk);done=0;cycle();@(negedge clk);done=1;cycle();
    ck(final_req && dut.q.raw[16],"recovery limit final");mark("recovery handshake and budget");

    reset_dut();cfg.word[0]=128+256;cfg.word[4]=3;cfg.word[13]=0;cfg.word[14]=4;cfg.word[15]=2;configure();
    cycle(3);cycle(3);@(negedge clk);done=1;cycle();ck(final_req,"final deadline defeats recovery");
    @(negedge clk);warm=1;cycle();warm=0;ck(!fault && dut.q.first_valid,"warm retains first");mark("final priority and warm retention");

    reset_dut();configure();cfg.word[4]=7;config_bus=cfg;unlock();issue(COMMIT,0,PENDING_APPLY);
    ck(dut.q.cfg.word[4]==1000,"pending not active");issue(SERVICE,KEY1);
    ck(dut.q.cfg.word[4]==7 && dut.q.count==0,"atomic pending apply");mark("runtime commit");
    reset_dut();configure();unlock();issue(LOCK_SET,1);unlock();issue(COMMIT,0,LOCKED);
    ck(!dut.q.credit,"failed sensitive consumes credit");mark("lock and credit");

    for(int target=0;target<6;target++) begin
      reset_dut();configure();unlock();issue(INJECT,32'(target));cycle();
      ck(final_req && alert && dut.q.first_test,$sformatf("injection %d real checker",target));
    end
    mark("six safety injections");
    // Independent exact-cycle reference: varied timeout, prescale, and service edge.
    for(int trial=0;trial<80;trial++) begin
      int timeout_ticks,prescale,span,service_edge;
      reset_dut();timeout_ticks=$urandom_range(2,15);prescale=$urandom_range(0,15);
      cfg.word[4]=timeout_ticks;cfg.word[1]=prescale;configure();
      span=timeout_ticks*(prescale+1);service_edge=$urandom_range(1,span-1);
      cycle(service_edge-1);issue(SERVICE,KEY1);
      ck(!fault && dut.q.count==0 && dut.q.divider==0,"random service restarts phase");
      cycle(span-1);ck(!fault,"random no premature timeout");cycle();ck(final_req,"random exact timeout");
    end
    mark("80 randomized timing reference cases");
    $display("UT_WATCHDOG_CHANNEL: PASS (errors=0 tests=%0d checks=%0d W=%0d)",tests,checks,W);$finish;
  end
  initial begin #5000000;$fatal(1,"UT timeout");end
endmodule
