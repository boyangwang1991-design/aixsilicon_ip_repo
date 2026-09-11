`ifndef WATCHDOG_CONTROL_IF__SV
`define WATCHDOG_CONTROL_IF__SV
interface watchdog_control_if;
  import watchdog_pkg::*;
  logic pclk=0,wdt_clk=0,por_n=0,preset_n=0;
  bit pclk_enable=1,wdt_enable=1;
  logic [15:0] source_id=0;
  logic cfg_auth=1,service_auth=1,diag_auth=1,test_auth=1;
  logic sleep_req=0,debug_req=0,debug_auth=0,warm=0;
  logic [15:0] recovery_done=0;
  logic hw_valid=0,hw_ready;
  logic [3:0] hw_channel=0;
  logic [4:0] hw_client=0;
  logic [2:0] hw_type=0;
  logic [31:0] hw_data=0;
  logic [15:0] hw_source=0;
  logic [15:0] irq,pause_ack,recovery_ack,nmi,local_req;
  logic final_req,safety_alert,safe_req,wake;
  logic execute_mailbox,cancel_mailbox,mailbox_integrity;
  command_t observed_command;
  config_t observed_config;
  logic [15:0] channel_command_valid,access_error,cdc_error;
  logic [7:0] execution_result;
  int channels=1,clients=1,width=32,prescale_width=16,source_width=4,sync_stages=2;
  bit token_support=0,supervision_support=0,hw_support=0,safety=0,runtime_update=0,inject_enable=0;
  logic [15:0] autostart=0,no_stop='1,hard_lock=0;
  longint unsigned wdt_cycle=0,pclk_cycle=0;
  always @(posedge wdt_clk) wdt_cycle<=wdt_cycle+1;
  always @(posedge pclk) pclk_cycle<=pclk_cycle+1;
endinterface
`endif
