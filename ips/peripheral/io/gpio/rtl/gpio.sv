// LLD.MOD.GPIO.TOP: APB4, independent cold-reset AON domain, and parameterized GPIO leaves.
module gpio #(
  parameter int N_GPIO=32, SYNC_STAGES=2,
  parameter logic [N_GPIO-1:0] INPUT_CAP_MASK='1, OUTPUT_CAP_MASK='1,
  parameter logic [N_GPIO-1:0] RESET_OUT='0, RESET_OE='0, RESET_IN_EN=INPUT_CAP_MASK,
  parameter int N_IRQ_GROUPS=1,
  parameter bit OUT_INV_EN=1, AON_WAKE_EN=1, SNAPSHOT_EN=1, STRAP_EN=1,
  parameter int EVENT_FIFO_DEPTH=16,
  parameter bit DIAG_EN=1, ACCESS_CTRL_EN=1, CFG_PARITY_EN=0,
  parameter bit BOOT_SECURE_ONLY=1, BOOT_PRIV_ONLY=1,
  parameter logic [N_GPIO-1:0] HW_SAFE_OUT='0, HW_SAFE_OE='0,
  localparam int N_BANK=(N_GPIO+31)/32
) (
  input logic pclk_i, por_ni, main_rst_ni,
  input logic [13:0] paddr_i,
  input logic [31:0] pwdata_i,
  input logic [3:0] pstrb_i,
  input logic [2:0] pprot_i,
  input logic psel_i, penable_i, pwrite_i,
  output logic pready_o, pslverr_o,
  output logic [31:0] prdata_o,
  input logic [N_GPIO-1:0] gpio_in_i, input_available_i, output_owned_i,
  output logic [N_GPIO-1:0] gpio_out_o, gpio_oe_o, irq_pin_o, event_o,
  output logic [N_IRQ_GROUPS-1:0] irq_group_o,
  output logic irq_summary_o,
  input logic sleep_req_i, safe_req_i, snapshot_req_i, strap_sample_i,
  output logic sleep_ack_o, safe_active_o, fault_irq_o, dma_req_o,
  input logic aon_clk_i, aon_rst_ni,
  input logic [N_GPIO-1:0] aon_gpio_in_i, aon_input_available_i,
  output logic wake_req_o
);
  import gpio_pkg::*;
  import gpio_reg_desc_pkg::*;
  logic main_async_n, aon_async_n, main_n, retained_n, aon_n;
  (* ASYNC_REG="TRUE" *) logic [1:0] main_reset_q, retained_reset_q, aon_reset_q;
  assign main_async_n=por_ni & main_rst_ni;
  assign aon_async_n=por_ni & aon_rst_ni;
  always_ff @(posedge pclk_i or negedge main_async_n) begin
    if (!main_async_n) main_reset_q<='0; else main_reset_q<={main_reset_q[0],1'b1};
  end
  always_ff @(posedge pclk_i or negedge por_ni) begin
    if (!por_ni) retained_reset_q<='0; else retained_reset_q<={retained_reset_q[0],1'b1};
  end
  always_ff @(posedge aon_clk_i or negedge aon_async_n) begin
    if (!aon_async_n) aon_reset_q<='0; else aon_reset_q<={aon_reset_q[0],1'b1};
  end
  assign main_n=main_reset_q[1]; assign retained_n=retained_reset_q[1]; assign aon_n=aon_reset_q[1];
  if (N_GPIO<1 || N_GPIO>128 || SYNC_STAGES<2 || SYNC_STAGES>4 || N_IRQ_GROUPS<1 || N_IRQ_GROUPS>4 ||
      !(EVENT_FIFO_DEPTH==0 || EVENT_FIFO_DEPTH==4 || EVENT_FIFO_DEPTH==8 || EVENT_FIFO_DEPTH==16 || EVENT_FIFO_DEPTH==32 || EVENT_FIFO_DEPTH==64) ||
      |(RESET_OE & ~OUTPUT_CAP_MASK) || |(HW_SAFE_OE & ~OUTPUT_CAP_MASK) || |(RESET_IN_EN & ~INPUT_CAP_MASK)) begin : g_invalid_configuration
    GPIO_CONFIGURATION_IS_INVALID invalid_configuration();
  end
  gpio_config_t cfg;
  gpio_command_t command;
  gpio_status_t status;
  gpio_reg_desc_t desc;
  gpio_csr_pkg::gpio_regs__in_t hwif_in;
  gpio_csr_pkg::gpio_regs__out_t hwif_out;
  logic [31:0] read_words[GPIO_REG_COUNT], byte_mask, csr_read_data;
  logic [GPIO_REG_COUNT-1:0] writes, reads;
  logic optional_disabled, semantic_error, commit, access_error, csr_ready, csr_error, parity_error;
  logic [N_GPIO-1:0] sync_data, sync_valid, input_data, input_valid;
  logic [N_GPIO-1:0] irq_pending, rising_pending, falling_pending, edge_now, rise_now;
  logic [N_GPIO-1:0] cfg_lock, data_lock, snapshot_data, snapshot_valid, strap_data, diag_pending;
  logic [N_GPIO-1:0] filter_enable, debounce_enable, input_invert, output_invert, open_drain;
  logic [N_GPIO-1:0][2:0] irq_mode;
  logic [N_GPIO-1:0][1:0] irq_group, sleep_mode;
  logic [N_GPIO-1:0][15:0] diag_blank;
  logic [N_GPIO-1:0][7:0] diag_count;
  logic [31:0] snapshot_sequence, fifo_lost, timestamp_low, timestamp_high;
  logic [127:0] fifo_head;
  logic [6:0] fifo_level;
  logic strap_valid, strap_early, parity_safe, global_lock, fifo_overflow, fifo_watermark;
  logic [1:0] access_cfg;
  logic aon_ready, aon_busy, aon_done, aon_timeout, aon_error, aon_timeout_fault, aon_error_fault;
  logic [1:0] aon_bank;
  logic aon_response_valid;
  logic [351:0] aon_response;
  for (genvar i=0; i<N_GPIO; i++) begin : g_cfg
    assign filter_enable[i]=cfg.pin_cfg[i][0]; assign debounce_enable[i]=cfg.pin_cfg[i][1];
    assign input_invert[i]=cfg.pin_cfg[i][2]; assign open_drain[i]=cfg.pin_cfg[i][3];
    assign output_invert[i]=OUT_INV_EN && cfg.pin_cfg[i][4]; assign irq_mode[i]=cfg.pin_cfg[i][7:5];
    assign irq_group[i]=cfg.pin_cfg[i][9:8]; assign sleep_mode[i]=cfg.pin_cfg[i][11:10];
    assign diag_blank[i]=cfg.diag_cfg[i][15:0]; assign diag_count[i]=cfg.diag_cfg[i][23:16];
  end
  always_comb begin
    status='0;
    status.input_available[N_GPIO-1:0]=input_available_i; status.output_owned[N_GPIO-1:0]=output_owned_i;
    status.sync_data[N_GPIO-1:0]=sync_data; status.sync_valid[N_GPIO-1:0]=sync_valid;
    status.input_data[N_GPIO-1:0]=input_data; status.input_valid[N_GPIO-1:0]=input_valid;
    status.irq_pending[N_GPIO-1:0]=irq_pending; status.rising_pending[N_GPIO-1:0]=rising_pending;
    status.falling_pending[N_GPIO-1:0]=falling_pending;
    status.cfg_lock[N_GPIO-1:0]=cfg_lock; status.data_lock[N_GPIO-1:0]=data_lock;
    status.global_lock=global_lock; status.access_cfg=access_cfg;
    status.snapshot_data[N_GPIO-1:0]=snapshot_data; status.snapshot_valid[N_GPIO-1:0]=snapshot_valid;
    status.snapshot_sequence=snapshot_sequence; status.strap_data[N_GPIO-1:0]=strap_data;
    status.strap_valid=strap_valid; status.strap_early=strap_early;
    status.diag_pending[N_GPIO-1:0]=diag_pending; status.parity_safe=parity_safe;
    status.sleep_ack=sleep_ack_o; status.safe_active=safe_active_o;
    status.fifo_head=fifo_head; status.fifo_level=fifo_level; status.fifo_lost=fifo_lost;
    status.timestamp_low=timestamp_low; status.timestamp_high=timestamp_high;
    status.fifo_overflow=fifo_overflow; status.fifo_watermark=fifo_watermark;
    status.aon_ready=aon_ready; status.aon_busy=aon_busy; status.aon_done=aon_done;
    status.aon_timeout=aon_timeout; status.aon_error=aon_error; status.aon_timeout_fault=aon_timeout_fault;
    status.aon_error_fault=aon_error_fault; status.aon_bank=aon_bank;
    status.aon_response_valid=aon_response_valid; status.aon_response=aon_response;
  end
  gpio_apb_if #(.N_GPIO(N_GPIO),.ACCESS_CTRL_EN(ACCESS_CTRL_EN)) u_apb (
    .rst_ni(main_n),.psel_i,.penable_i,.pwrite_i,.paddr_i,.pprot_i,.pstrb_i,.access_cfg_i(access_cfg),
    .optional_disabled_i(optional_disabled),.semantic_error_i(semantic_error),.csr_read_data_i(csr_read_data),
    .descriptor_o(desc),.byte_mask_o(byte_mask),.pready_o,.pslverr_o,.commit_o(commit),.access_error_o(access_error),.prdata_o);
  gpio_csr u_csr (.clk(pclk_i),.arst_n(main_n),.s_apb_psel(psel_i),.s_apb_penable(penable_i),
    .s_apb_pwrite(pwrite_i),.s_apb_pprot(pprot_i),.s_apb_paddr(paddr_i),.s_apb_pwdata(pwdata_i),.s_apb_pstrb(pstrb_i),
    .s_apb_pready(csr_ready),.s_apb_prdata(csr_read_data),.s_apb_pslverr(csr_error),.hwif_in,.hwif_out);
  gpio_csr_adapter u_adapter (.commit_i(commit),.write_i(pwrite_i),.read_words_i(read_words),.hwif_out_i(hwif_out),
    .hwif_in_o(hwif_in),.write_strobe_o(writes),.read_strobe_o(reads));
  gpio_regfile #(.N_GPIO(N_GPIO),.SYNC_STAGES(SYNC_STAGES),.N_IRQ_GROUPS(N_IRQ_GROUPS),.EVENT_FIFO_DEPTH(EVENT_FIFO_DEPTH),
    .OUT_INV_EN(OUT_INV_EN),.AON_WAKE_EN(AON_WAKE_EN),.SNAPSHOT_EN(SNAPSHOT_EN),.STRAP_EN(STRAP_EN),.DIAG_EN(DIAG_EN),
    .ACCESS_CTRL_EN(ACCESS_CTRL_EN),.CFG_PARITY_EN(CFG_PARITY_EN),.BOOT_SECURE_ONLY(BOOT_SECURE_ONLY),.BOOT_PRIV_ONLY(BOOT_PRIV_ONLY),
    .INPUT_CAP_MASK(INPUT_CAP_MASK),.OUTPUT_CAP_MASK(OUTPUT_CAP_MASK),.RESET_OUT(RESET_OUT),.RESET_OE(RESET_OE),.RESET_IN_EN(RESET_IN_EN)) u_regfile (
    .clk_i(pclk_i),.rst_ni(main_n),.por_ni(retained_n),.descriptor_i(desc),.pwrite_i,.access_error_i(access_error),.paddr_i,.pprot_i,.pstrb_i,
    .write_data_i(pwdata_i),.byte_mask_i(byte_mask),.write_strobe_i(writes),.read_strobe_i(reads),.status_i(status),
    .config_o(cfg),.command_o(command),.read_words_o(read_words),.optional_disabled_o(optional_disabled),.semantic_error_o(semantic_error),.fault_irq_o,.parity_error_o(parity_error));
  gpio_security #(.N_GPIO(N_GPIO),.ACCESS_CTRL_EN(ACCESS_CTRL_EN),.BOOT_SECURE_ONLY(BOOT_SECURE_ONLY),.BOOT_PRIV_ONLY(BOOT_PRIV_ONLY)) u_security (
    .clk_i(pclk_i),.por_ni(retained_n),.cfg_set_i(command.cfg_set[N_GPIO-1:0]),.data_set_i(command.data_set[N_GPIO-1:0]),
    .global_set_i(command.global_set),.access_write_i(command.access_write),.access_value_i(command.access_value),
    .cfg_lock_o(cfg_lock),.data_lock_o(data_lock),.global_lock_o(global_lock),.access_cfg_o(access_cfg));
  gpio_input #(.N_GPIO(N_GPIO),.SYNC_STAGES(SYNC_STAGES),.INPUT_CAP_MASK(INPUT_CAP_MASK)) u_input (
    .clk_i(pclk_i),.rst_ni(main_n),.pad_i(gpio_in_i),.available_i(input_available_i),.enable_i(cfg.in_enable[N_GPIO-1:0]),
    .filter_enable_i(filter_enable),.debounce_enable_i(debounce_enable),.invert_i(input_invert),.restart_i(command.input_restart[N_GPIO-1:0]),
    .filter_count_i(cfg.filter_cfg[N_GPIO-1:0]),.debounce_count_i(cfg.debounce_cfg[N_GPIO-1:0]),.divider_i(cfg.bank_div[N_BANK-1:0]),
    .divider_write_i(command.divider_write[N_BANK-1:0]),.sync_o(sync_data),.sync_valid_o(sync_valid),.data_o(input_data),.valid_o(input_valid));
  gpio_output #(.N_GPIO(N_GPIO),.OUTPUT_CAP_MASK(OUTPUT_CAP_MASK),.RESET_OUT(RESET_OUT),.RESET_OE(RESET_OE),.HW_SAFE_OUT(HW_SAFE_OUT),.HW_SAFE_OE(HW_SAFE_OE)) u_output (
    .clk_i(pclk_i),.rst_ni(main_n),.data_i(cfg.out_data[N_GPIO-1:0]),.oe_i(cfg.out_oe[N_GPIO-1:0]),.invert_i(output_invert),.open_drain_i(open_drain),
    .owned_i(output_owned_i),.sleep_mode_i(sleep_mode),.sleep_req_i,.safe_req_i,.parity_safe_i(parity_safe),
    .out_o(gpio_out_o),.oe_o(gpio_oe_o),.sleep_ack_o,.safe_active_o);
  gpio_irq #(.N_GPIO(N_GPIO),.N_IRQ_GROUPS(N_IRQ_GROUPS)) u_irq (
    .clk_i(pclk_i),.rst_ni(main_n),.data_i(input_data),.valid_i(input_valid & input_available_i & cfg.in_enable[N_GPIO-1:0]),
    .detect_i(cfg.irq_detect[N_GPIO-1:0]),.enable_i(cfg.irq_enable[N_GPIO-1:0]),.restart_i(command.irq_restart[N_GPIO-1:0]),
    .mode_i(irq_mode),.group_i(irq_group),.clear_i(command.irq_clear[N_GPIO-1:0]),.rising_clear_i(command.rising_clear[N_GPIO-1:0]),
    .falling_clear_i(command.falling_clear[N_GPIO-1:0]),.test_i(command.irq_test[N_GPIO-1:0]),.pending_o(irq_pending),.rising_o(rising_pending),.falling_o(falling_pending),
    .event_o,.edge_now_o(edge_now),.rise_now_o(rise_now),.irq_pin_o,.irq_group_o,.irq_summary_o);
  gpio_capture #(.N_GPIO(N_GPIO),.SNAPSHOT_EN(SNAPSHOT_EN),.STRAP_EN(STRAP_EN),.INPUT_CAP_MASK(INPUT_CAP_MASK)) u_capture (
    .clk_i(pclk_i),.rst_ni(main_n),.data_i(input_data),.valid_i(input_valid),.sync_i(sync_data),.sync_valid_i(sync_valid),
    .snapshot_sw_i(command.snapshot),.snapshot_hw_i(snapshot_req_i),.strap_sample_i,.clear_early_i(command.clear_strap_early),
    .snapshot_data_o(snapshot_data),.snapshot_valid_o(snapshot_valid),.strap_data_o(strap_data),.sequence_o(snapshot_sequence),.strap_valid_o(strap_valid),.strap_early_o(strap_early));
  gpio_event_fifo #(.N_GPIO(N_GPIO),.DEPTH(EVENT_FIFO_DEPTH)) u_fifo (
    .clk_i(pclk_i),.rst_ni(main_n),.event_i(edge_now),.rising_i(rise_now),.event_enable_i(cfg.event_enable[N_GPIO-1:0]),
    .record_enable_i(cfg.fifo_ctrl[0]),.dma_enable_i(cfg.fifo_ctrl[1]),.pop_i(command.fifo_pop),.flush_i(command.fifo_flush),
    .clear_lost_i(command.clear_lost),.clear_overflow_i(command.clear_overflow),.watermark_i(cfg.watermark),.timestamp_low_read_i(command.timestamp_read),
    .head_o(fifo_head),.level_o(fifo_level),.lost_o(fifo_lost),.timestamp_low_o(timestamp_low),.timestamp_high_o(timestamp_high),.overflow_o(fifo_overflow),.watermark_o(fifo_watermark),.dma_req_o);
  gpio_diag #(.N_GPIO(N_GPIO),.DIAG_EN(DIAG_EN),.CFG_PARITY_EN(CFG_PARITY_EN)) u_diag (
    .clk_i(pclk_i),.rst_ni(main_n),.por_ni(retained_n),.sync_i(sync_data),.sync_valid_i(sync_valid),.physical_out_i(gpio_out_o),.physical_oe_i(gpio_oe_o),
    .owned_i(output_owned_i),.available_i(input_available_i),.clear_i(command.diag_clear[N_GPIO-1:0]),.test_i(command.diag_test[N_GPIO-1:0]),
    .blank_i(diag_blank),.mismatch_count_i(diag_count),.sleep_i(sleep_ack_o),.safe_i(safe_active_o),.parity_error_i(parity_error),.pending_o(diag_pending),.parity_safe_o(parity_safe));
  if (AON_WAKE_EN) begin : g_aon
    logic destination_command, destination_response_valid, destination_error;
    logic [223:0] destination_request;
    logic [351:0] destination_response;
    gpio_aon_mailbox u_mailbox (
      .clk_i(pclk_i),.por_ni(retained_n),.rst_ni(main_n),.aon_clk_i,.aon_rst_ni(aon_n),.command_i(command.aon_command),.request_i(command.aon_request),
      .bank_i(command.aon_bank),.timeout_i(cfg.aon_timeout),.clear_timeout_fault_i(command.clear_aon_timeout),.clear_error_fault_i(command.clear_aon_error),
      .ready_o(aon_ready),.busy_o(aon_busy),.done_o(aon_done),.timeout_o(aon_timeout),.error_o(aon_error),.timeout_fault_o(aon_timeout_fault),.error_fault_o(aon_error_fault),
      .bank_o(aon_bank),.response_o(aon_response),.response_valid_o(aon_response_valid),.aon_command_o(destination_command),.aon_request_o(destination_request),
      .aon_response_valid_i(destination_response_valid),.aon_error_i(destination_error),.aon_response_i(destination_response));
    gpio_aon_wake #(.N_GPIO(N_GPIO),.INPUT_CAP_MASK(INPUT_CAP_MASK)) u_wake (
      .clk_i(aon_clk_i),.rst_ni(aon_n),.pad_i(aon_gpio_in_i),.available_i(aon_input_available_i),.command_i(destination_command),.request_i(destination_request),
      .response_valid_o(destination_response_valid),.error_o(destination_error),.response_o(destination_response),.wake_req_o);
  end else begin : g_no_aon
    assign {aon_ready,aon_busy,aon_done,aon_timeout,aon_error,aon_timeout_fault,aon_error_fault,aon_response_valid,wake_req_o}=9'd0;
    assign aon_bank=2'd0; assign aon_response=352'd0;
  end
endmodule
