`timescale 1ns/1ps
module watchdog_harness;
  import uvm_pkg::*;import watchdog_pkg::*;import watchdog_env_pkg::*;
  parameter int NUM_CHANNELS=1,NUM_CLIENTS=1,COUNTER_WIDTH=32,PRESCALE_WIDTH=16,SOURCE_WIDTH=4,SYNC_STAGES=2;
  parameter bit SUPPORT_TOKEN_QA=0,SUPPORT_SUPERVISION=0,SUPPORT_HW_EVENT=0,SAFETY_EN=0,ALLOW_RUNTIME_UPDATE=0,DIAG_INJECT_EN=0;
  parameter bit[NUM_CHANNELS-1:0] AUTO_START_MASK=0,NO_STOP_MASK='1,HARD_CFG_LOCK_MASK=0;
  parameter int PCLK_HALF=5,WDT_HALF=7;
  watchdog_control_if control();
  apb_if apb(control.pclk,control.por_n && control.preset_n,1'b0);
  always begin #(PCLK_HALF);if(control.pclk_enable) control.pclk=~control.pclk;end
  always begin #(WDT_HALF);if(control.wdt_enable) control.wdt_clk=~control.wdt_clk;end
  watchdog_top #(.NUM_CHANNELS(NUM_CHANNELS),.NUM_CLIENTS(NUM_CLIENTS),.COUNTER_WIDTH(COUNTER_WIDTH),
    .PRESCALE_WIDTH(PRESCALE_WIDTH),.SOURCE_WIDTH(SOURCE_WIDTH),.SYNC_STAGES(SYNC_STAGES),
    .SUPPORT_TOKEN_QA(SUPPORT_TOKEN_QA),.SUPPORT_SUPERVISION(SUPPORT_SUPERVISION),.SUPPORT_HW_EVENT(SUPPORT_HW_EVENT),
    .SAFETY_EN(SAFETY_EN),.ALLOW_RUNTIME_UPDATE(ALLOW_RUNTIME_UPDATE),.DIAG_INJECT_EN(DIAG_INJECT_EN),
    .AUTO_START_MASK(AUTO_START_MASK),.NO_STOP_MASK(NO_STOP_MASK),.HARD_CFG_LOCK_MASK(HARD_CFG_LOCK_MASK)) dut (
    .pclk(control.pclk),.wdt_clk(control.wdt_clk),.por_n(control.por_n),.preset_n(control.preset_n),
    .PSEL(apb.psel[0]),.PENABLE(apb.penable),.PWRITE(apb.pwrite),.PADDR(apb.paddr[14:0]),.PWDATA(apb.pwdata),
    .PSTRB(apb.pstrb_w),.PPROT(apb.pprot_w),.PRDATA(apb.prdata),.PREADY(apb.pready),.PSLVERR(apb.pslverr),
    .access_source_i(control.source_id[SOURCE_WIDTH-1:0]),.cfg_auth_i(control.cfg_auth),.service_auth_i(control.service_auth),.diag_auth_i(control.diag_auth),
    .sleep_req_i(control.sleep_req),.debug_req_i(control.debug_req),.debug_auth_i(control.debug_auth),
    .warm_reset_evt_i(control.warm),.test_auth_i(control.test_auth),.recovery_done_i(control.recovery_done[NUM_CHANNELS-1:0]),
    .pause_ack_o(control.pause_ack[NUM_CHANNELS-1:0]),.recovery_ack_o(control.recovery_ack[NUM_CHANNELS-1:0]),
    .irq_o(control.irq[NUM_CHANNELS-1:0]),.nmi_req_o(control.nmi[NUM_CHANNELS-1:0]),.local_reset_req_o(control.local_req[NUM_CHANNELS-1:0]),
    .system_reset_req_o(control.final_req),.safety_alert_o(control.safety_alert),.safe_state_req_o(control.safe_req),.wake_req_o(control.wake),
    .hw_evt_valid(control.hw_valid),.hw_evt_ready(control.hw_ready),.hw_evt_channel(control.hw_channel),.hw_evt_client(control.hw_client),
    .hw_evt_type(control.hw_type),.hw_evt_data(control.hw_data),.hw_evt_source(control.hw_source[SOURCE_WIDTH-1:0]));
  if(NUM_CHANNELS<16) begin
    assign control.irq[15:NUM_CHANNELS]='0;assign control.nmi[15:NUM_CHANNELS]='0;
    assign control.local_req[15:NUM_CHANNELS]='0;assign control.pause_ack[15:NUM_CHANNELS]='0;
    assign control.recovery_ack[15:NUM_CHANNELS]='0;
  end
  assign control.execute_mailbox=dut.execute_mailbox;
  assign control.cancel_mailbox=dut.cancel_mailbox;assign control.mailbox_integrity=dut.mailbox_integrity;
  assign control.observed_command=dut.selected_cmd;assign control.observed_config=dut.mailbox_config;
  assign control.channel_command_valid=16'(dut.cmd_v);
  assign control.execution_result=dut.cancel_mailbox?8'd9: dut.mailbox_integrity?8'd10:dut.channel_result[dut.selected_cmd.channel];
  for(genvar c=0;c<16;c++) begin
    if(c<NUM_CHANNELS) begin
      assign control.access_error[c]=dut.err_req_sync[SYNC_STAGES-1][c] && !dut.err_ack[c];
      assign control.cdc_error[c]=dut.mailbox_integrity;
    end else begin assign control.access_error[c]=0;assign control.cdc_error[c]=0;end
  end
  initial begin
    control.channels=NUM_CHANNELS;control.clients=NUM_CLIENTS;control.width=COUNTER_WIDTH;
    control.prescale_width=PRESCALE_WIDTH;control.source_width=SOURCE_WIDTH;control.sync_stages=SYNC_STAGES;
    control.token_support=SUPPORT_TOKEN_QA;control.supervision_support=SUPPORT_SUPERVISION;control.hw_support=SUPPORT_HW_EVENT;
    control.safety=SAFETY_EN;control.runtime_update=ALLOW_RUNTIME_UPDATE;control.inject_enable=DIAG_INJECT_EN;
    control.autostart=16'(AUTO_START_MASK);control.no_stop=16'(NO_STOP_MASK);control.hard_lock=16'(HARD_CFG_LOCK_MASK);
    uvm_config_db#(virtual watchdog_control_if)::set(null,"*","vif",control);
    uvm_config_db#(virtual apb_if)::set(null,"*","vif",apb);
    run_test();
  end
  initial begin #10000000;$fatal(1,"watchdog UVM global timeout");end
  always @(posedge control.pclk) if(control.por_n && control.preset_n && apb.psel[0])
    assert(apb.paddr[31:15]==0) else $fatal(1,"APB VIP adapter address exceeds physical 15-bit aperture");
  `include "watchdog_assertions.sv"
endmodule
