`timescale 1ns/1ps
module ut_watchdog_parameters;
  import watchdog_pkg::*;
  import watchdog_parameter_config::*;
  logic pclk=0, wdt_clk=0, por_n=0;
  always #5ns pclk=~pclk;
  always #7ns wdt_clk=~wdt_clk;
  logic psel=0, penable=0;
  logic [14:0] addr=0;
  wire [31:0] data;
  wire ready, error;
  watchdog_top #(
    .NUM_CHANNELS(NUM_CHANNELS),.COUNTER_WIDTH(COUNTER_WIDTH),.PRESCALE_WIDTH(PRESCALE_WIDTH),
    .NUM_CLIENTS(NUM_CLIENTS),.SOURCE_WIDTH(SOURCE_WIDTH),.SYNC_STAGES(SYNC_STAGES),
    .SUPPORT_TOKEN_QA(SUPPORT_TOKEN_QA),.SUPPORT_SUPERVISION(SUPPORT_SUPERVISION),
    .SUPPORT_HW_EVENT(SUPPORT_HW_EVENT),.SAFETY_EN(SAFETY_EN),.ALLOW_RUNTIME_UPDATE(ALLOW_RUNTIME_UPDATE),
    .DIAG_INJECT_EN(DIAG_INJECT_EN),.AUTO_START_MASK(AUTO_START_MASK),.NO_STOP_MASK(NO_STOP_MASK),
    .HARD_CFG_LOCK_MASK(HARD_CFG_LOCK_MASK),.DEFAULT_CFG(DEFAULT_CFG)
  ) dut (
    .pclk(pclk),.wdt_clk(wdt_clk),.por_n(por_n),.preset_n(por_n),
    .PSEL(psel),.PENABLE(penable),.PWRITE(1'b0),.PADDR(addr),.PWDATA(32'b0),.PSTRB(4'b0),.PPROT(3'b0),
    .PRDATA(data),.PREADY(ready),.PSLVERR(error),.access_source_i({SOURCE_WIDTH{1'b0}}),
    .cfg_auth_i(1'b1),.service_auth_i(1'b1),.diag_auth_i(1'b1),.sleep_req_i(1'b0),
    .debug_req_i(1'b0),.debug_auth_i(1'b0),.warm_reset_evt_i(1'b0),.test_auth_i(1'b0),
    .recovery_done_i({NUM_CHANNELS{1'b0}}),.hw_evt_valid(1'b0),.hw_evt_channel(4'b0),
    .hw_evt_client(5'b0),.hw_evt_type(3'b0),.hw_evt_data(32'b0),.hw_evt_source({SOURCE_WIDTH{1'b0}})
  );
  task automatic check_read(input logic[14:0] address, input logic[31:0] expected);
    @(negedge pclk);addr=address;psel=1;
    @(negedge pclk);penable=1;
    for(int cycles=0;cycles<3;cycles++) begin
      @(posedge pclk);
      if(ready) begin
        if(error || data!==expected) $fatal(1,"PV read %h expected %h got %h error=%b",address,expected,data,error);
        @(negedge pclk);psel=0;penable=0;return;
      end
    end
    $fatal(1,"PV APB timeout");
  endtask
  initial begin
    repeat(10) @(negedge pclk);por_n=1;
    repeat(20) @(negedge pclk);
    check_read('h000,32'h57445431);
    check_read('h008,(NUM_CHANNELS-1) | ((NUM_CLIENTS-1)<<5) | (COUNTER_WIDTH<<11) | (PRESCALE_WIDTH<<18));
    check_read('h00c,SUPPORT_TOKEN_QA | (SUPPORT_SUPERVISION<<1) | (SUPPORT_HW_EVENT<<2) |
      (SAFETY_EN<<3) | (ALLOW_RUNTIME_UPDATE<<4) | (DIAG_INJECT_EN<<5) | ((SYNC_STAGES-2)<<8));
    for(int ch=0;ch<NUM_CHANNELS;ch++)
      for(int word_index=0;word_index<16;word_index++)
        check_read(15'('h1000+ch*'h400+4*word_index),DEFAULT_CFG[ch].word[word_index]);
    $display("WATCHDOG_PARAMETER_CHECK PASS");$finish;
  end
  initial begin #1ms;$fatal(1,"PV global timeout");end
endmodule
