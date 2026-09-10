`timescale 1ns/1ps
module spi_engine_ut;
  logic pclk=0,rst_n=0,enable_i=1,abort_i=0,clear_fault_i=0;
  always #5 pclk=~pclk;
  logic [31:0] timeout_i=0;
  logic [7:0][3:0] cs_cfg_i='0;
  logic [7:0][15:0] divider_i='0,setup_i='0,hold_i='0,idle_i='0,gap_i='0;
  logic [7:0][31:0] dummy_i='0;
  logic cmd_empty_i=1,tx_empty_i=1,miso_i=0;
  logic [63:0] cmd_data_i=0;
  logic [31:0] tx_data_i='ha5,rx_data_o,done_count_o;
  logic [8:0] rx_count_i=0;
  wire cmd_pop_o,tx_pop_o,rx_push_o,flush_o,busy_o,active_o,aborting_o,faulted_o;
  wire wait_tx_o,wait_rx_o,wait_cmd_o,sclk_o,mosi_o;
  wire [15:0] tag_o,progress_o,last_tag_o;
  wire [2:0] csid_o,op_o,event_o;
  wire [9:0] error_o;
  wire [0:0] cs_n_o;
  int errors=0,done_events=0,abort_events=0,timeout_events=0,rx_events=0,wait_cycles=0;
  spi_master_engine #(.NUM_CS(1),.RX_FIFO_DEPTH(4)) dut(.*);
  always @(posedge pclk) if(rst_n)begin
    if(cmd_pop_o) cmd_empty_i<=1;
    if(event_o[0])done_events++;
    if(event_o[2])abort_events++;
    if(error_o[8])timeout_events++;
    if(rx_push_o)rx_events++;
    if(wait_tx_o||wait_rx_o)wait_cycles++;
  end
  task automatic tick; @(negedge pclk);endtask
  task automatic check(bit ok,string message); if(!ok)begin errors++;$error("UT %s",message);end endtask
  task automatic reset;
    tick();rst_n=0;abort_i=0;cmd_empty_i=1;tx_empty_i=1;rx_count_i=0;timeout_i=0;
    repeat(2)tick();rst_n=1;tick();done_events=0;abort_events=0;timeout_events=0;rx_events=0;wait_cycles=0;
  endtask
  task automatic submit(logic[31:0] cfg);
    tick();cmd_data_i={16'h1234,16'd1,cfg};cmd_empty_i=0;
    tick();while(!cmd_empty_i)tick();
  endtask
  task automatic wait_idle;
    for(int i=0;i<200;i++)begin tick();if(!busy_o)return;end
    check(0,"bounded recovery");
  endtask
  initial begin
    // Both resources absent; reason changes without resetting the same wait interval.
    reset();timeout_i=4;rx_count_i=4;submit('h20820);
    while(!wait_tx_o)tick();
    check(wait_rx_o,"both resources reported");
    tick();tx_empty_i=0;
    tick();check(wait_rx_o && !wait_tx_o,"reason changed to RX");
    wait_idle();check(timeout_events==1 && wait_cycles==4 && faulted_o,"reason change did not extend timeout");
    // Progress at the exact threshold wins, and both reservations occur atomically.
    reset();timeout_i=3;submit('h20820);
    while(!wait_tx_o)tick();
    while(dut.q.wait_count!=2)tick();
    tx_empty_i=0;tick();check(tx_pop_o==0 && !wait_tx_o,"TX accepted on threshold edge");
    wait_idle();check(timeout_events==0 && done_events==1 && !faulted_o,"progress beats timeout");
    // Abort on final trailing edge suppresses SEG_DONE but retains committed RX.
    reset();tx_empty_i=0;submit('h00120);
    while(!(dut.q.state==5 && dut.q.edge_idx==1 && dut.q.timer==0))tick();
    abort_i=1;tick();abort_i=0;wait_idle();
    check(done_events==0 && abort_events==1 && rx_events==1 && progress_o==1 && faulted_o,"final-edge abort priority");
    // Assert reset directly in every reachable engine state, including short-lived FETCH.
    for(int target=0;target<=9;target++)begin
      if(target==6)continue; // no GAP state: gap is a timer extension in SHIFT
      reset();tx_empty_i=(target==2);setup_i='1;hold_i='1;idle_i='1;
      // Keep setup/hold long enough to observe; NEW_IDLE waits use short idle value.
      setup_i[0]=2;hold_i[0]=2;idle_i[0]=1;
      submit(target==7 ? 32'h30800 : 32'h20800);
      for(int n=0;n<200;n++)begin
        if(dut.q.state==target)break;
        tick();
      end
      check(dut.q.state==target,$sformatf("reach reset state %0d",target));
      rst_n=0;#0.01;check(!busy_o && cs_n_o==1 && !sclk_o && !mosi_o,"asynchronous reset all states");
    end
    // Counter rollover through the real completion datapath; seed a rare boundary only.
    reset();force dut.q.done_count=32'hffffffff;tick();release dut.q.done_count;
    submit('h40);wait_idle();check(done_count_o==0 && last_tag_o=='h1234,"DONE_COUNT modulo 2^32");
    if(errors) $fatal(1,"ENGINE_UT fail %0d",errors);
    $display("ENGINE_UT PASS");$display("UT_SPI_ENGINE: PASS (errors=0)");$finish;
  end
  initial begin #100000;$fatal(1,"ENGINE_UT watchdog");end
endmodule
