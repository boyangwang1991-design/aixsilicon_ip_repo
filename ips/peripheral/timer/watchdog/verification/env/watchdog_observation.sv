`ifndef WATCHDOG_OBSERVATION__SV
`define WATCHDOG_OBSERVATION__SV
class watchdog_observation extends uvm_sequence_item;
  `uvm_object_utils(watchdog_observation)
  watchdog_observation_kind kind;
  time stamp;
  longint unsigned cycle;
  bit por_n,preset_n,warm,sleep_req,debug_req,debug_auth,test_auth;
  bit [15:0] done,access_error,cdc_error;
  bit command_valid,command_canceled,command_integrity;
  command_t command;
  config_t command_config;
  bit [7:0] actual_result;
  logic [15:0] irq,pause_ack,recovery_ack,nmi,local_req;
  logic final_req,safe_req,alert,wake;
  extern function new(string name="watchdog_observation");
endclass
function watchdog_observation::new(string name="watchdog_observation");super.new(name);endfunction

class watchdog_prediction extends uvm_sequence_item;
  `uvm_object_utils(watchdog_prediction)
  string label;
  bit [63:0] expected_value,mask='1;
  logic [63:0] actual_value;
  int feature,scenario,config_class;
  extern function new(string name="watchdog_prediction");
endclass
function watchdog_prediction::new(string name="watchdog_prediction");super.new(name);endfunction

class watchdog_control_item extends uvm_sequence_item;
  `uvm_object_utils(watchdog_control_item)
  watchdog_control_kind kind;
  int cycles=1;
  bit value=0,aux=0;
  bit [31:0] data=0;
  int channel=0,client=0,event_type=0,source=0;
  bit cfg_auth=1,service_auth=1,diag_auth=1,test_auth=1;
  extern function new(string name="watchdog_control_item");
endclass
function watchdog_control_item::new(string name="watchdog_control_item");super.new(name);endfunction
`endif
