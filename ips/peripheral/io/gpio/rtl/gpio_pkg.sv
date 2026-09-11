// Fixed maximum-width internal wiring; active geometry is selected by N_GPIO.
package gpio_pkg;
  typedef struct packed {
    logic [127:0] out_data, out_oe, in_enable, irq_detect, irq_enable, event_enable, diag_enable;
    logic [127:0][11:0] pin_cfg;
    logic [127:0][7:0] filter_cfg, debounce_cfg;
    logic [127:0][23:0] diag_cfg;
    logic [3:0][15:0] bank_div;
    logic [1:0] fifo_ctrl;
    logic [6:0] watermark;
    logic [23:0] aon_timeout;
    logic [7:0] fault_irq_enable;
    logic [3:0][6:0][31:0] aon_stage;
  } gpio_config_t;
  typedef struct packed {
    logic [127:0] input_restart, irq_restart, irq_clear, rising_clear, falling_clear, irq_test;
    logic [127:0] diag_clear, diag_test, cfg_set, data_set;
    logic [3:0] divider_write, parity_inject;
    logic global_set, access_write;
    logic [1:0] access_value;
    logic fifo_pop, fifo_flush, clear_lost, clear_overflow, timestamp_read;
    logic snapshot, clear_strap_early, aon_command, clear_aon_timeout, clear_aon_error;
    logic [223:0] aon_request;
    logic [1:0] aon_bank;
  } gpio_command_t;
  typedef struct packed {
    logic [127:0] input_available, output_owned, sync_data, sync_valid, input_data, input_valid;
    logic [127:0] irq_pending, rising_pending, falling_pending;
    logic [127:0] snapshot_data, snapshot_valid, strap_data, diag_pending;
    logic [31:0] snapshot_sequence;
    logic strap_valid, strap_early, parity_safe, sleep_ack, safe_active;
    logic [127:0] fifo_head;
    logic [6:0] fifo_level;
    logic [31:0] fifo_lost, timestamp_low, timestamp_high;
    logic fifo_overflow, fifo_watermark;
    logic [127:0] cfg_lock, data_lock;
    logic global_lock;
    logic [1:0] access_cfg;
    logic aon_ready, aon_busy, aon_done, aon_timeout, aon_error, aon_timeout_fault, aon_error_fault;
    logic [1:0] aon_bank;
    logic aon_response_valid;
    logic [351:0] aon_response;
  } gpio_status_t;
endpackage
