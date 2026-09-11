// Generated from regs/watchdog.rdl. Do not edit.
module watchdog_reg_adapter(
input logic clk,rst_n,sel,enable,write, input logic [14:0] addr,
input logic [2:0] prot, input logic [3:0] strb,
input logic [31:0] wdata,rdata, output logic ready,error,
output logic [31:0] read_data,write_mask, output logic writable,valid_addr);
watchdog_csr_pkg::watchdog_regs__in_t hin;
watchdog_csr_pkg::watchdog_regs__out_t hout;
watchdog_csr u_csr(.clk(clk),.arst_n(rst_n),
.s_apb_psel(sel),.s_apb_penable(enable),.s_apb_pwrite(write),
.s_apb_paddr(addr),.s_apb_pprot(prot),.s_apb_pstrb(strb),
.s_apb_pwdata(wdata),.s_apb_prdata(read_data),
.s_apb_pready(ready),.s_apb_pslverr(error),
.hwif_in(hin),.hwif_out(hout));
assign hin.IP_ID.rd_ack=hout.IP_ID.req && !hout.IP_ID.req_is_wr;
assign hin.IP_ID.rd_data=rdata & 32'hffffffff;
assign hin.VERSION.rd_ack=hout.VERSION.req && !hout.VERSION.req_is_wr;
assign hin.VERSION.rd_data=rdata & 32'hffffffff;
assign hin.CAPABILITY0.rd_ack=hout.CAPABILITY0.req && !hout.CAPABILITY0.req_is_wr;
assign hin.CAPABILITY0.rd_data=rdata & 32'hffffffff;
assign hin.CAPABILITY1.rd_ack=hout.CAPABILITY1.req && !hout.CAPABILITY1.req_is_wr;
assign hin.CAPABILITY1.rd_data=rdata & 32'hffffffff;
assign hin.CMD_STATUS.rd_ack=hout.CMD_STATUS.req && !hout.CMD_STATUS.req_is_wr;
assign hin.CMD_STATUS.rd_data=rdata & 32'hffffffff;
assign hin.ISSUED_SEQ.rd_ack=hout.ISSUED_SEQ.req && !hout.ISSUED_SEQ.req_is_wr;
assign hin.ISSUED_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.DONE_SEQ.rd_ack=hout.DONE_SEQ.req && !hout.DONE_SEQ.req_is_wr;
assign hin.DONE_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.DONE_INFO.rd_ack=hout.DONE_INFO.req && !hout.DONE_INFO.req_is_wr;
assign hin.DONE_INFO.rd_data=rdata & 32'hffffffff;
assign hin.IRQ_SUMMARY.rd_ack=hout.IRQ_SUMMARY.req && !hout.IRQ_SUMMARY.req_is_wr;
assign hin.IRQ_SUMMARY.rd_data=rdata & 32'hffffffff;
assign hin.FAULT_SUMMARY.rd_ack=hout.FAULT_SUMMARY.req && !hout.FAULT_SUMMARY.req_is_wr;
assign hin.FAULT_SUMMARY.rd_data=rdata & 32'hffffffff;
assign hin.RESET_SUMMARY.rd_ack=hout.RESET_SUMMARY.req && !hout.RESET_SUMMARY.req_is_wr;
assign hin.RESET_SUMMARY.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CTRL_STAGE.rd_ack=hout.ch[0].CTRL_STAGE.req && !hout.ch[0].CTRL_STAGE.req_is_wr;
assign hin.ch[0].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[0].CTRL_STAGE.wr_ack=hout.ch[0].CTRL_STAGE.req && hout.ch[0].CTRL_STAGE.req_is_wr;
assign hin.ch[0].PRESCALE_STAGE.rd_ack=hout.ch[0].PRESCALE_STAGE.req && !hout.ch[0].PRESCALE_STAGE.req_is_wr;
assign hin.ch[0].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].PRESCALE_STAGE.wr_ack=hout.ch[0].PRESCALE_STAGE.req && hout.ch[0].PRESCALE_STAGE.req_is_wr;
assign hin.ch[0].WIN_MIN_LO_STAGE.rd_ack=hout.ch[0].WIN_MIN_LO_STAGE.req && !hout.ch[0].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[0].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].WIN_MIN_LO_STAGE.wr_ack=hout.ch[0].WIN_MIN_LO_STAGE.req && hout.ch[0].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[0].WIN_MIN_HI_STAGE.rd_ack=hout.ch[0].WIN_MIN_HI_STAGE.req && !hout.ch[0].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[0].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].WIN_MIN_HI_STAGE.wr_ack=hout.ch[0].WIN_MIN_HI_STAGE.req && hout.ch[0].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[0].TIMEOUT_LO_STAGE.rd_ack=hout.ch[0].TIMEOUT_LO_STAGE.req && !hout.ch[0].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[0].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].TIMEOUT_LO_STAGE.wr_ack=hout.ch[0].TIMEOUT_LO_STAGE.req && hout.ch[0].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[0].TIMEOUT_HI_STAGE.rd_ack=hout.ch[0].TIMEOUT_HI_STAGE.req && !hout.ch[0].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[0].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].TIMEOUT_HI_STAGE.wr_ack=hout.ch[0].TIMEOUT_HI_STAGE.req && hout.ch[0].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[0].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[0].PRETIMEOUT_LO_STAGE.req && !hout.ch[0].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[0].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[0].PRETIMEOUT_LO_STAGE.req && hout.ch[0].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[0].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[0].PRETIMEOUT_HI_STAGE.req && !hout.ch[0].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[0].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[0].PRETIMEOUT_HI_STAGE.req && hout.ch[0].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[0].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[0].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[0].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[0].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[0].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[0].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[0].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[0].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[0].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[0].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[0].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[0].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[0].SEQ_LIMIT_STAGE.rd_ack=hout.ch[0].SEQ_LIMIT_STAGE.req && !hout.ch[0].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[0].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].SEQ_LIMIT_STAGE.wr_ack=hout.ch[0].SEQ_LIMIT_STAGE.req && hout.ch[0].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[0].REQUIRE_MASK_STAGE.rd_ack=hout.ch[0].REQUIRE_MASK_STAGE.req && !hout.ch[0].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[0].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].REQUIRE_MASK_STAGE.wr_ack=hout.ch[0].REQUIRE_MASK_STAGE.req && hout.ch[0].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[0].FAULT_POLICY_STAGE.rd_ack=hout.ch[0].FAULT_POLICY_STAGE.req && !hout.ch[0].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[0].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[0].FAULT_POLICY_STAGE.wr_ack=hout.ch[0].FAULT_POLICY_STAGE.req && hout.ch[0].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[0].LOCAL_DELAY_STAGE.rd_ack=hout.ch[0].LOCAL_DELAY_STAGE.req && !hout.ch[0].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[0].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].LOCAL_DELAY_STAGE.wr_ack=hout.ch[0].LOCAL_DELAY_STAGE.req && hout.ch[0].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[0].FINAL_DELAY_STAGE.rd_ack=hout.ch[0].FINAL_DELAY_STAGE.req && !hout.ch[0].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[0].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FINAL_DELAY_STAGE.wr_ack=hout.ch[0].FINAL_DELAY_STAGE.req && hout.ch[0].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[0].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[0].RECOVERY_LIMIT_STAGE.req && !hout.ch[0].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[0].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[0].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[0].RECOVERY_LIMIT_STAGE.req && hout.ch[0].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[0].UNLOCK.wr_ack=hout.ch[0].UNLOCK.req && hout.ch[0].UNLOCK.req_is_wr;
assign hin.ch[0].COMMAND.wr_ack=hout.ch[0].COMMAND.req && hout.ch[0].COMMAND.req_is_wr;
assign hin.ch[0].LOCK_SET.wr_ack=hout.ch[0].LOCK_SET.req && hout.ch[0].LOCK_SET.req_is_wr;
assign hin.ch[0].SERVICE_SELECT.rd_ack=hout.ch[0].SERVICE_SELECT.req && !hout.ch[0].SERVICE_SELECT.req_is_wr;
assign hin.ch[0].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[0].SERVICE_SELECT.wr_ack=hout.ch[0].SERVICE_SELECT.req && hout.ch[0].SERVICE_SELECT.req_is_wr;
assign hin.ch[0].SERVICE.wr_ack=hout.ch[0].SERVICE.req && hout.ch[0].SERVICE.req_is_wr;
assign hin.ch[0].IRQ_ENABLE.wr_ack=hout.ch[0].IRQ_ENABLE.req && hout.ch[0].IRQ_ENABLE.req_is_wr;
assign hin.ch[0].IRQ_CLEAR.wr_ack=hout.ch[0].IRQ_CLEAR.req && hout.ch[0].IRQ_CLEAR.req_is_wr;
assign hin.ch[0].IRQ_TEST.wr_ack=hout.ch[0].IRQ_TEST.req && hout.ch[0].IRQ_TEST.req_is_wr;
assign hin.ch[0].DIAG_CLEAR.wr_ack=hout.ch[0].DIAG_CLEAR.req && hout.ch[0].DIAG_CLEAR.req_is_wr;
assign hin.ch[0].FAULT_INJECT.wr_ack=hout.ch[0].FAULT_INJECT.req && hout.ch[0].FAULT_INJECT.req_is_wr;
assign hin.ch[0].SNAP_META.rd_ack=hout.ch[0].SNAP_META.req && !hout.ch[0].SNAP_META.req_is_wr;
assign hin.ch[0].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[0].SNAP_SEQ.rd_ack=hout.ch[0].SNAP_SEQ.req && !hout.ch[0].SNAP_SEQ.req_is_wr;
assign hin.ch[0].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].STATUS_SNAP.rd_ack=hout.ch[0].STATUS_SNAP.req && !hout.ch[0].STATUS_SNAP.req_is_wr;
assign hin.ch[0].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CFG_VERSION_SNAP.rd_ack=hout.ch[0].CFG_VERSION_SNAP.req && !hout.ch[0].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[0].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].COUNT_LO_SNAP.rd_ack=hout.ch[0].COUNT_LO_SNAP.req && !hout.ch[0].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[0].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].COUNT_HI_SNAP.rd_ack=hout.ch[0].COUNT_HI_SNAP.req && !hout.ch[0].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[0].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].EVENT_RAW_SNAP.rd_ack=hout.ch[0].EVENT_RAW_SNAP.req && !hout.ch[0].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[0].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].IRQ_ENABLE_SNAP.rd_ack=hout.ch[0].IRQ_ENABLE_SNAP.req && !hout.ch[0].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[0].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].SEEN_MASK_SNAP.rd_ack=hout.ch[0].SEEN_MASK_SNAP.req && !hout.ch[0].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[0].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].MISSING_MASK_SNAP.rd_ack=hout.ch[0].MISSING_MASK_SNAP.req && !hout.ch[0].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[0].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[0].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[0].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[0].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FAULT_COUNT_SNAP.rd_ack=hout.ch[0].FAULT_COUNT_SNAP.req && !hout.ch[0].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[0].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[0].RECOVERY_COUNT_SNAP.req && !hout.ch[0].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[0].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].ESC_AGE_SNAP.rd_ack=hout.ch[0].ESC_AGE_SNAP.req && !hout.ch[0].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[0].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_FLAGS_SNAP.rd_ack=hout.ch[0].FIRST_FLAGS_SNAP.req && !hout.ch[0].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[0].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_CAUSE_SNAP.rd_ack=hout.ch[0].FIRST_CAUSE_SNAP.req && !hout.ch[0].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[0].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[0].FIRST_COUNT_LO_SNAP.req && !hout.ch[0].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[0].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[0].FIRST_COUNT_HI_SNAP.req && !hout.ch[0].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[0].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_SOURCE_SNAP.rd_ack=hout.ch[0].FIRST_SOURCE_SNAP.req && !hout.ch[0].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[0].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[0].FIRST_CFG_VERSION_SNAP.req && !hout.ch[0].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[0].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_MISSING_SNAP.rd_ack=hout.ch[0].FIRST_MISSING_SNAP.req && !hout.ch[0].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[0].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[0].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[0].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[0].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FIRST_STATE_SNAP.rd_ack=hout.ch[0].FIRST_STATE_SNAP.req && !hout.ch[0].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[0].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[0].CTRL_ACTIVE_SNAP.req && !hout.ch[0].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[0].PRESCALE_ACTIVE_SNAP.req && !hout.ch[0].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[0].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[0].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[0].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[0].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[0].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[0].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[0].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[0].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[0].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[0].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[0].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[0].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[0].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[0].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[0].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[0].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[0].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[0].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[0].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[0].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[0].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[0].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[0].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[0].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[0].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[0].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[0].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[0].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_SELECT.rd_ack=hout.ch[0].CLIENT_SELECT.req && !hout.ch[0].CLIENT_SELECT.req_is_wr;
assign hin.ch[0].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[0].CLIENT_SELECT.wr_ack=hout.ch[0].CLIENT_SELECT.req && hout.ch[0].CLIENT_SELECT.req_is_wr;
assign hin.ch[0].CLIENT_OWNER_STAGE.rd_ack=hout.ch[0].CLIENT_OWNER_STAGE.req && !hout.ch[0].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_OWNER_STAGE.wr_ack=hout.ch[0].CLIENT_OWNER_STAGE.req && hout.ch[0].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[0].CLIENT_ALIVE_STAGE.req && !hout.ch[0].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[0].CLIENT_ALIVE_STAGE.req && hout.ch[0].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_FLOW_STAGE.rd_ack=hout.ch[0].CLIENT_FLOW_STAGE.req && !hout.ch[0].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[0].CLIENT_FLOW_STAGE.wr_ack=hout.ch[0].CLIENT_FLOW_STAGE.req && hout.ch[0].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[0].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[0].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[0].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[0].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[0].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[0].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[0].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[0].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[0].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[0].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[0].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[0].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[0].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[0].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[0].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[0].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[0].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[0].CLIENT_FLAGS_SNAP.req && !hout.ch[0].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[0].CLIENT_TOKEN_SNAP.req && !hout.ch[0].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[0].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[0].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[0].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[0].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[0].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[0].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[0].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[0].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[0].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[0].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[0].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[0].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[0].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[0].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[0].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[0].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[0].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[0].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[0].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[0].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[0].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[0].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CTRL_STAGE.rd_ack=hout.ch[1].CTRL_STAGE.req && !hout.ch[1].CTRL_STAGE.req_is_wr;
assign hin.ch[1].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[1].CTRL_STAGE.wr_ack=hout.ch[1].CTRL_STAGE.req && hout.ch[1].CTRL_STAGE.req_is_wr;
assign hin.ch[1].PRESCALE_STAGE.rd_ack=hout.ch[1].PRESCALE_STAGE.req && !hout.ch[1].PRESCALE_STAGE.req_is_wr;
assign hin.ch[1].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].PRESCALE_STAGE.wr_ack=hout.ch[1].PRESCALE_STAGE.req && hout.ch[1].PRESCALE_STAGE.req_is_wr;
assign hin.ch[1].WIN_MIN_LO_STAGE.rd_ack=hout.ch[1].WIN_MIN_LO_STAGE.req && !hout.ch[1].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[1].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].WIN_MIN_LO_STAGE.wr_ack=hout.ch[1].WIN_MIN_LO_STAGE.req && hout.ch[1].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[1].WIN_MIN_HI_STAGE.rd_ack=hout.ch[1].WIN_MIN_HI_STAGE.req && !hout.ch[1].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[1].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].WIN_MIN_HI_STAGE.wr_ack=hout.ch[1].WIN_MIN_HI_STAGE.req && hout.ch[1].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[1].TIMEOUT_LO_STAGE.rd_ack=hout.ch[1].TIMEOUT_LO_STAGE.req && !hout.ch[1].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[1].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].TIMEOUT_LO_STAGE.wr_ack=hout.ch[1].TIMEOUT_LO_STAGE.req && hout.ch[1].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[1].TIMEOUT_HI_STAGE.rd_ack=hout.ch[1].TIMEOUT_HI_STAGE.req && !hout.ch[1].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[1].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].TIMEOUT_HI_STAGE.wr_ack=hout.ch[1].TIMEOUT_HI_STAGE.req && hout.ch[1].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[1].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[1].PRETIMEOUT_LO_STAGE.req && !hout.ch[1].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[1].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[1].PRETIMEOUT_LO_STAGE.req && hout.ch[1].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[1].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[1].PRETIMEOUT_HI_STAGE.req && !hout.ch[1].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[1].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[1].PRETIMEOUT_HI_STAGE.req && hout.ch[1].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[1].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[1].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[1].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[1].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[1].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[1].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[1].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[1].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[1].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[1].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[1].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[1].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[1].SEQ_LIMIT_STAGE.rd_ack=hout.ch[1].SEQ_LIMIT_STAGE.req && !hout.ch[1].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[1].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].SEQ_LIMIT_STAGE.wr_ack=hout.ch[1].SEQ_LIMIT_STAGE.req && hout.ch[1].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[1].REQUIRE_MASK_STAGE.rd_ack=hout.ch[1].REQUIRE_MASK_STAGE.req && !hout.ch[1].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[1].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].REQUIRE_MASK_STAGE.wr_ack=hout.ch[1].REQUIRE_MASK_STAGE.req && hout.ch[1].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[1].FAULT_POLICY_STAGE.rd_ack=hout.ch[1].FAULT_POLICY_STAGE.req && !hout.ch[1].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[1].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[1].FAULT_POLICY_STAGE.wr_ack=hout.ch[1].FAULT_POLICY_STAGE.req && hout.ch[1].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[1].LOCAL_DELAY_STAGE.rd_ack=hout.ch[1].LOCAL_DELAY_STAGE.req && !hout.ch[1].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[1].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].LOCAL_DELAY_STAGE.wr_ack=hout.ch[1].LOCAL_DELAY_STAGE.req && hout.ch[1].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[1].FINAL_DELAY_STAGE.rd_ack=hout.ch[1].FINAL_DELAY_STAGE.req && !hout.ch[1].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[1].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FINAL_DELAY_STAGE.wr_ack=hout.ch[1].FINAL_DELAY_STAGE.req && hout.ch[1].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[1].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[1].RECOVERY_LIMIT_STAGE.req && !hout.ch[1].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[1].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[1].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[1].RECOVERY_LIMIT_STAGE.req && hout.ch[1].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[1].UNLOCK.wr_ack=hout.ch[1].UNLOCK.req && hout.ch[1].UNLOCK.req_is_wr;
assign hin.ch[1].COMMAND.wr_ack=hout.ch[1].COMMAND.req && hout.ch[1].COMMAND.req_is_wr;
assign hin.ch[1].LOCK_SET.wr_ack=hout.ch[1].LOCK_SET.req && hout.ch[1].LOCK_SET.req_is_wr;
assign hin.ch[1].SERVICE_SELECT.rd_ack=hout.ch[1].SERVICE_SELECT.req && !hout.ch[1].SERVICE_SELECT.req_is_wr;
assign hin.ch[1].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[1].SERVICE_SELECT.wr_ack=hout.ch[1].SERVICE_SELECT.req && hout.ch[1].SERVICE_SELECT.req_is_wr;
assign hin.ch[1].SERVICE.wr_ack=hout.ch[1].SERVICE.req && hout.ch[1].SERVICE.req_is_wr;
assign hin.ch[1].IRQ_ENABLE.wr_ack=hout.ch[1].IRQ_ENABLE.req && hout.ch[1].IRQ_ENABLE.req_is_wr;
assign hin.ch[1].IRQ_CLEAR.wr_ack=hout.ch[1].IRQ_CLEAR.req && hout.ch[1].IRQ_CLEAR.req_is_wr;
assign hin.ch[1].IRQ_TEST.wr_ack=hout.ch[1].IRQ_TEST.req && hout.ch[1].IRQ_TEST.req_is_wr;
assign hin.ch[1].DIAG_CLEAR.wr_ack=hout.ch[1].DIAG_CLEAR.req && hout.ch[1].DIAG_CLEAR.req_is_wr;
assign hin.ch[1].FAULT_INJECT.wr_ack=hout.ch[1].FAULT_INJECT.req && hout.ch[1].FAULT_INJECT.req_is_wr;
assign hin.ch[1].SNAP_META.rd_ack=hout.ch[1].SNAP_META.req && !hout.ch[1].SNAP_META.req_is_wr;
assign hin.ch[1].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[1].SNAP_SEQ.rd_ack=hout.ch[1].SNAP_SEQ.req && !hout.ch[1].SNAP_SEQ.req_is_wr;
assign hin.ch[1].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].STATUS_SNAP.rd_ack=hout.ch[1].STATUS_SNAP.req && !hout.ch[1].STATUS_SNAP.req_is_wr;
assign hin.ch[1].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CFG_VERSION_SNAP.rd_ack=hout.ch[1].CFG_VERSION_SNAP.req && !hout.ch[1].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[1].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].COUNT_LO_SNAP.rd_ack=hout.ch[1].COUNT_LO_SNAP.req && !hout.ch[1].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[1].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].COUNT_HI_SNAP.rd_ack=hout.ch[1].COUNT_HI_SNAP.req && !hout.ch[1].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[1].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].EVENT_RAW_SNAP.rd_ack=hout.ch[1].EVENT_RAW_SNAP.req && !hout.ch[1].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[1].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].IRQ_ENABLE_SNAP.rd_ack=hout.ch[1].IRQ_ENABLE_SNAP.req && !hout.ch[1].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[1].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].SEEN_MASK_SNAP.rd_ack=hout.ch[1].SEEN_MASK_SNAP.req && !hout.ch[1].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[1].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].MISSING_MASK_SNAP.rd_ack=hout.ch[1].MISSING_MASK_SNAP.req && !hout.ch[1].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[1].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[1].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[1].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[1].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FAULT_COUNT_SNAP.rd_ack=hout.ch[1].FAULT_COUNT_SNAP.req && !hout.ch[1].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[1].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[1].RECOVERY_COUNT_SNAP.req && !hout.ch[1].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[1].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].ESC_AGE_SNAP.rd_ack=hout.ch[1].ESC_AGE_SNAP.req && !hout.ch[1].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[1].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_FLAGS_SNAP.rd_ack=hout.ch[1].FIRST_FLAGS_SNAP.req && !hout.ch[1].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[1].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_CAUSE_SNAP.rd_ack=hout.ch[1].FIRST_CAUSE_SNAP.req && !hout.ch[1].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[1].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[1].FIRST_COUNT_LO_SNAP.req && !hout.ch[1].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[1].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[1].FIRST_COUNT_HI_SNAP.req && !hout.ch[1].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[1].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_SOURCE_SNAP.rd_ack=hout.ch[1].FIRST_SOURCE_SNAP.req && !hout.ch[1].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[1].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[1].FIRST_CFG_VERSION_SNAP.req && !hout.ch[1].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[1].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_MISSING_SNAP.rd_ack=hout.ch[1].FIRST_MISSING_SNAP.req && !hout.ch[1].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[1].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[1].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[1].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[1].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FIRST_STATE_SNAP.rd_ack=hout.ch[1].FIRST_STATE_SNAP.req && !hout.ch[1].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[1].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[1].CTRL_ACTIVE_SNAP.req && !hout.ch[1].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[1].PRESCALE_ACTIVE_SNAP.req && !hout.ch[1].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[1].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[1].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[1].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[1].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[1].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[1].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[1].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[1].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[1].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[1].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[1].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[1].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[1].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[1].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[1].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[1].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[1].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[1].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[1].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[1].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[1].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[1].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[1].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[1].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[1].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[1].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[1].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[1].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_SELECT.rd_ack=hout.ch[1].CLIENT_SELECT.req && !hout.ch[1].CLIENT_SELECT.req_is_wr;
assign hin.ch[1].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[1].CLIENT_SELECT.wr_ack=hout.ch[1].CLIENT_SELECT.req && hout.ch[1].CLIENT_SELECT.req_is_wr;
assign hin.ch[1].CLIENT_OWNER_STAGE.rd_ack=hout.ch[1].CLIENT_OWNER_STAGE.req && !hout.ch[1].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_OWNER_STAGE.wr_ack=hout.ch[1].CLIENT_OWNER_STAGE.req && hout.ch[1].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[1].CLIENT_ALIVE_STAGE.req && !hout.ch[1].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[1].CLIENT_ALIVE_STAGE.req && hout.ch[1].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_FLOW_STAGE.rd_ack=hout.ch[1].CLIENT_FLOW_STAGE.req && !hout.ch[1].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[1].CLIENT_FLOW_STAGE.wr_ack=hout.ch[1].CLIENT_FLOW_STAGE.req && hout.ch[1].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[1].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[1].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[1].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[1].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[1].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[1].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[1].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[1].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[1].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[1].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[1].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[1].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[1].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[1].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[1].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[1].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[1].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[1].CLIENT_FLAGS_SNAP.req && !hout.ch[1].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[1].CLIENT_TOKEN_SNAP.req && !hout.ch[1].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[1].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[1].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[1].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[1].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[1].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[1].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[1].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[1].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[1].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[1].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[1].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[1].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[1].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[1].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[1].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[1].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[1].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[1].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[1].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[1].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[1].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[1].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CTRL_STAGE.rd_ack=hout.ch[2].CTRL_STAGE.req && !hout.ch[2].CTRL_STAGE.req_is_wr;
assign hin.ch[2].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[2].CTRL_STAGE.wr_ack=hout.ch[2].CTRL_STAGE.req && hout.ch[2].CTRL_STAGE.req_is_wr;
assign hin.ch[2].PRESCALE_STAGE.rd_ack=hout.ch[2].PRESCALE_STAGE.req && !hout.ch[2].PRESCALE_STAGE.req_is_wr;
assign hin.ch[2].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].PRESCALE_STAGE.wr_ack=hout.ch[2].PRESCALE_STAGE.req && hout.ch[2].PRESCALE_STAGE.req_is_wr;
assign hin.ch[2].WIN_MIN_LO_STAGE.rd_ack=hout.ch[2].WIN_MIN_LO_STAGE.req && !hout.ch[2].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[2].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].WIN_MIN_LO_STAGE.wr_ack=hout.ch[2].WIN_MIN_LO_STAGE.req && hout.ch[2].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[2].WIN_MIN_HI_STAGE.rd_ack=hout.ch[2].WIN_MIN_HI_STAGE.req && !hout.ch[2].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[2].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].WIN_MIN_HI_STAGE.wr_ack=hout.ch[2].WIN_MIN_HI_STAGE.req && hout.ch[2].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[2].TIMEOUT_LO_STAGE.rd_ack=hout.ch[2].TIMEOUT_LO_STAGE.req && !hout.ch[2].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[2].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].TIMEOUT_LO_STAGE.wr_ack=hout.ch[2].TIMEOUT_LO_STAGE.req && hout.ch[2].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[2].TIMEOUT_HI_STAGE.rd_ack=hout.ch[2].TIMEOUT_HI_STAGE.req && !hout.ch[2].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[2].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].TIMEOUT_HI_STAGE.wr_ack=hout.ch[2].TIMEOUT_HI_STAGE.req && hout.ch[2].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[2].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[2].PRETIMEOUT_LO_STAGE.req && !hout.ch[2].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[2].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[2].PRETIMEOUT_LO_STAGE.req && hout.ch[2].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[2].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[2].PRETIMEOUT_HI_STAGE.req && !hout.ch[2].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[2].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[2].PRETIMEOUT_HI_STAGE.req && hout.ch[2].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[2].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[2].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[2].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[2].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[2].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[2].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[2].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[2].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[2].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[2].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[2].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[2].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[2].SEQ_LIMIT_STAGE.rd_ack=hout.ch[2].SEQ_LIMIT_STAGE.req && !hout.ch[2].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[2].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].SEQ_LIMIT_STAGE.wr_ack=hout.ch[2].SEQ_LIMIT_STAGE.req && hout.ch[2].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[2].REQUIRE_MASK_STAGE.rd_ack=hout.ch[2].REQUIRE_MASK_STAGE.req && !hout.ch[2].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[2].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].REQUIRE_MASK_STAGE.wr_ack=hout.ch[2].REQUIRE_MASK_STAGE.req && hout.ch[2].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[2].FAULT_POLICY_STAGE.rd_ack=hout.ch[2].FAULT_POLICY_STAGE.req && !hout.ch[2].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[2].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[2].FAULT_POLICY_STAGE.wr_ack=hout.ch[2].FAULT_POLICY_STAGE.req && hout.ch[2].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[2].LOCAL_DELAY_STAGE.rd_ack=hout.ch[2].LOCAL_DELAY_STAGE.req && !hout.ch[2].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[2].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].LOCAL_DELAY_STAGE.wr_ack=hout.ch[2].LOCAL_DELAY_STAGE.req && hout.ch[2].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[2].FINAL_DELAY_STAGE.rd_ack=hout.ch[2].FINAL_DELAY_STAGE.req && !hout.ch[2].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[2].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FINAL_DELAY_STAGE.wr_ack=hout.ch[2].FINAL_DELAY_STAGE.req && hout.ch[2].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[2].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[2].RECOVERY_LIMIT_STAGE.req && !hout.ch[2].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[2].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[2].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[2].RECOVERY_LIMIT_STAGE.req && hout.ch[2].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[2].UNLOCK.wr_ack=hout.ch[2].UNLOCK.req && hout.ch[2].UNLOCK.req_is_wr;
assign hin.ch[2].COMMAND.wr_ack=hout.ch[2].COMMAND.req && hout.ch[2].COMMAND.req_is_wr;
assign hin.ch[2].LOCK_SET.wr_ack=hout.ch[2].LOCK_SET.req && hout.ch[2].LOCK_SET.req_is_wr;
assign hin.ch[2].SERVICE_SELECT.rd_ack=hout.ch[2].SERVICE_SELECT.req && !hout.ch[2].SERVICE_SELECT.req_is_wr;
assign hin.ch[2].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[2].SERVICE_SELECT.wr_ack=hout.ch[2].SERVICE_SELECT.req && hout.ch[2].SERVICE_SELECT.req_is_wr;
assign hin.ch[2].SERVICE.wr_ack=hout.ch[2].SERVICE.req && hout.ch[2].SERVICE.req_is_wr;
assign hin.ch[2].IRQ_ENABLE.wr_ack=hout.ch[2].IRQ_ENABLE.req && hout.ch[2].IRQ_ENABLE.req_is_wr;
assign hin.ch[2].IRQ_CLEAR.wr_ack=hout.ch[2].IRQ_CLEAR.req && hout.ch[2].IRQ_CLEAR.req_is_wr;
assign hin.ch[2].IRQ_TEST.wr_ack=hout.ch[2].IRQ_TEST.req && hout.ch[2].IRQ_TEST.req_is_wr;
assign hin.ch[2].DIAG_CLEAR.wr_ack=hout.ch[2].DIAG_CLEAR.req && hout.ch[2].DIAG_CLEAR.req_is_wr;
assign hin.ch[2].FAULT_INJECT.wr_ack=hout.ch[2].FAULT_INJECT.req && hout.ch[2].FAULT_INJECT.req_is_wr;
assign hin.ch[2].SNAP_META.rd_ack=hout.ch[2].SNAP_META.req && !hout.ch[2].SNAP_META.req_is_wr;
assign hin.ch[2].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[2].SNAP_SEQ.rd_ack=hout.ch[2].SNAP_SEQ.req && !hout.ch[2].SNAP_SEQ.req_is_wr;
assign hin.ch[2].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].STATUS_SNAP.rd_ack=hout.ch[2].STATUS_SNAP.req && !hout.ch[2].STATUS_SNAP.req_is_wr;
assign hin.ch[2].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CFG_VERSION_SNAP.rd_ack=hout.ch[2].CFG_VERSION_SNAP.req && !hout.ch[2].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[2].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].COUNT_LO_SNAP.rd_ack=hout.ch[2].COUNT_LO_SNAP.req && !hout.ch[2].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[2].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].COUNT_HI_SNAP.rd_ack=hout.ch[2].COUNT_HI_SNAP.req && !hout.ch[2].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[2].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].EVENT_RAW_SNAP.rd_ack=hout.ch[2].EVENT_RAW_SNAP.req && !hout.ch[2].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[2].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].IRQ_ENABLE_SNAP.rd_ack=hout.ch[2].IRQ_ENABLE_SNAP.req && !hout.ch[2].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[2].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].SEEN_MASK_SNAP.rd_ack=hout.ch[2].SEEN_MASK_SNAP.req && !hout.ch[2].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[2].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].MISSING_MASK_SNAP.rd_ack=hout.ch[2].MISSING_MASK_SNAP.req && !hout.ch[2].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[2].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[2].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[2].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[2].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FAULT_COUNT_SNAP.rd_ack=hout.ch[2].FAULT_COUNT_SNAP.req && !hout.ch[2].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[2].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[2].RECOVERY_COUNT_SNAP.req && !hout.ch[2].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[2].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].ESC_AGE_SNAP.rd_ack=hout.ch[2].ESC_AGE_SNAP.req && !hout.ch[2].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[2].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_FLAGS_SNAP.rd_ack=hout.ch[2].FIRST_FLAGS_SNAP.req && !hout.ch[2].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[2].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_CAUSE_SNAP.rd_ack=hout.ch[2].FIRST_CAUSE_SNAP.req && !hout.ch[2].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[2].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[2].FIRST_COUNT_LO_SNAP.req && !hout.ch[2].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[2].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[2].FIRST_COUNT_HI_SNAP.req && !hout.ch[2].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[2].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_SOURCE_SNAP.rd_ack=hout.ch[2].FIRST_SOURCE_SNAP.req && !hout.ch[2].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[2].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[2].FIRST_CFG_VERSION_SNAP.req && !hout.ch[2].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[2].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_MISSING_SNAP.rd_ack=hout.ch[2].FIRST_MISSING_SNAP.req && !hout.ch[2].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[2].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[2].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[2].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[2].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FIRST_STATE_SNAP.rd_ack=hout.ch[2].FIRST_STATE_SNAP.req && !hout.ch[2].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[2].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[2].CTRL_ACTIVE_SNAP.req && !hout.ch[2].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[2].PRESCALE_ACTIVE_SNAP.req && !hout.ch[2].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[2].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[2].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[2].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[2].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[2].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[2].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[2].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[2].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[2].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[2].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[2].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[2].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[2].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[2].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[2].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[2].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[2].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[2].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[2].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[2].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[2].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[2].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[2].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[2].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[2].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[2].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[2].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[2].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_SELECT.rd_ack=hout.ch[2].CLIENT_SELECT.req && !hout.ch[2].CLIENT_SELECT.req_is_wr;
assign hin.ch[2].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[2].CLIENT_SELECT.wr_ack=hout.ch[2].CLIENT_SELECT.req && hout.ch[2].CLIENT_SELECT.req_is_wr;
assign hin.ch[2].CLIENT_OWNER_STAGE.rd_ack=hout.ch[2].CLIENT_OWNER_STAGE.req && !hout.ch[2].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_OWNER_STAGE.wr_ack=hout.ch[2].CLIENT_OWNER_STAGE.req && hout.ch[2].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[2].CLIENT_ALIVE_STAGE.req && !hout.ch[2].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[2].CLIENT_ALIVE_STAGE.req && hout.ch[2].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_FLOW_STAGE.rd_ack=hout.ch[2].CLIENT_FLOW_STAGE.req && !hout.ch[2].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[2].CLIENT_FLOW_STAGE.wr_ack=hout.ch[2].CLIENT_FLOW_STAGE.req && hout.ch[2].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[2].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[2].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[2].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[2].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[2].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[2].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[2].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[2].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[2].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[2].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[2].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[2].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[2].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[2].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[2].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[2].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[2].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[2].CLIENT_FLAGS_SNAP.req && !hout.ch[2].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[2].CLIENT_TOKEN_SNAP.req && !hout.ch[2].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[2].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[2].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[2].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[2].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[2].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[2].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[2].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[2].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[2].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[2].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[2].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[2].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[2].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[2].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[2].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[2].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[2].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[2].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[2].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[2].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[2].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[2].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CTRL_STAGE.rd_ack=hout.ch[3].CTRL_STAGE.req && !hout.ch[3].CTRL_STAGE.req_is_wr;
assign hin.ch[3].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[3].CTRL_STAGE.wr_ack=hout.ch[3].CTRL_STAGE.req && hout.ch[3].CTRL_STAGE.req_is_wr;
assign hin.ch[3].PRESCALE_STAGE.rd_ack=hout.ch[3].PRESCALE_STAGE.req && !hout.ch[3].PRESCALE_STAGE.req_is_wr;
assign hin.ch[3].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].PRESCALE_STAGE.wr_ack=hout.ch[3].PRESCALE_STAGE.req && hout.ch[3].PRESCALE_STAGE.req_is_wr;
assign hin.ch[3].WIN_MIN_LO_STAGE.rd_ack=hout.ch[3].WIN_MIN_LO_STAGE.req && !hout.ch[3].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[3].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].WIN_MIN_LO_STAGE.wr_ack=hout.ch[3].WIN_MIN_LO_STAGE.req && hout.ch[3].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[3].WIN_MIN_HI_STAGE.rd_ack=hout.ch[3].WIN_MIN_HI_STAGE.req && !hout.ch[3].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[3].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].WIN_MIN_HI_STAGE.wr_ack=hout.ch[3].WIN_MIN_HI_STAGE.req && hout.ch[3].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[3].TIMEOUT_LO_STAGE.rd_ack=hout.ch[3].TIMEOUT_LO_STAGE.req && !hout.ch[3].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[3].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].TIMEOUT_LO_STAGE.wr_ack=hout.ch[3].TIMEOUT_LO_STAGE.req && hout.ch[3].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[3].TIMEOUT_HI_STAGE.rd_ack=hout.ch[3].TIMEOUT_HI_STAGE.req && !hout.ch[3].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[3].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].TIMEOUT_HI_STAGE.wr_ack=hout.ch[3].TIMEOUT_HI_STAGE.req && hout.ch[3].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[3].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[3].PRETIMEOUT_LO_STAGE.req && !hout.ch[3].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[3].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[3].PRETIMEOUT_LO_STAGE.req && hout.ch[3].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[3].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[3].PRETIMEOUT_HI_STAGE.req && !hout.ch[3].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[3].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[3].PRETIMEOUT_HI_STAGE.req && hout.ch[3].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[3].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[3].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[3].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[3].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[3].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[3].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[3].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[3].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[3].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[3].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[3].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[3].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[3].SEQ_LIMIT_STAGE.rd_ack=hout.ch[3].SEQ_LIMIT_STAGE.req && !hout.ch[3].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[3].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].SEQ_LIMIT_STAGE.wr_ack=hout.ch[3].SEQ_LIMIT_STAGE.req && hout.ch[3].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[3].REQUIRE_MASK_STAGE.rd_ack=hout.ch[3].REQUIRE_MASK_STAGE.req && !hout.ch[3].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[3].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].REQUIRE_MASK_STAGE.wr_ack=hout.ch[3].REQUIRE_MASK_STAGE.req && hout.ch[3].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[3].FAULT_POLICY_STAGE.rd_ack=hout.ch[3].FAULT_POLICY_STAGE.req && !hout.ch[3].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[3].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[3].FAULT_POLICY_STAGE.wr_ack=hout.ch[3].FAULT_POLICY_STAGE.req && hout.ch[3].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[3].LOCAL_DELAY_STAGE.rd_ack=hout.ch[3].LOCAL_DELAY_STAGE.req && !hout.ch[3].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[3].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].LOCAL_DELAY_STAGE.wr_ack=hout.ch[3].LOCAL_DELAY_STAGE.req && hout.ch[3].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[3].FINAL_DELAY_STAGE.rd_ack=hout.ch[3].FINAL_DELAY_STAGE.req && !hout.ch[3].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[3].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FINAL_DELAY_STAGE.wr_ack=hout.ch[3].FINAL_DELAY_STAGE.req && hout.ch[3].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[3].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[3].RECOVERY_LIMIT_STAGE.req && !hout.ch[3].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[3].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[3].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[3].RECOVERY_LIMIT_STAGE.req && hout.ch[3].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[3].UNLOCK.wr_ack=hout.ch[3].UNLOCK.req && hout.ch[3].UNLOCK.req_is_wr;
assign hin.ch[3].COMMAND.wr_ack=hout.ch[3].COMMAND.req && hout.ch[3].COMMAND.req_is_wr;
assign hin.ch[3].LOCK_SET.wr_ack=hout.ch[3].LOCK_SET.req && hout.ch[3].LOCK_SET.req_is_wr;
assign hin.ch[3].SERVICE_SELECT.rd_ack=hout.ch[3].SERVICE_SELECT.req && !hout.ch[3].SERVICE_SELECT.req_is_wr;
assign hin.ch[3].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[3].SERVICE_SELECT.wr_ack=hout.ch[3].SERVICE_SELECT.req && hout.ch[3].SERVICE_SELECT.req_is_wr;
assign hin.ch[3].SERVICE.wr_ack=hout.ch[3].SERVICE.req && hout.ch[3].SERVICE.req_is_wr;
assign hin.ch[3].IRQ_ENABLE.wr_ack=hout.ch[3].IRQ_ENABLE.req && hout.ch[3].IRQ_ENABLE.req_is_wr;
assign hin.ch[3].IRQ_CLEAR.wr_ack=hout.ch[3].IRQ_CLEAR.req && hout.ch[3].IRQ_CLEAR.req_is_wr;
assign hin.ch[3].IRQ_TEST.wr_ack=hout.ch[3].IRQ_TEST.req && hout.ch[3].IRQ_TEST.req_is_wr;
assign hin.ch[3].DIAG_CLEAR.wr_ack=hout.ch[3].DIAG_CLEAR.req && hout.ch[3].DIAG_CLEAR.req_is_wr;
assign hin.ch[3].FAULT_INJECT.wr_ack=hout.ch[3].FAULT_INJECT.req && hout.ch[3].FAULT_INJECT.req_is_wr;
assign hin.ch[3].SNAP_META.rd_ack=hout.ch[3].SNAP_META.req && !hout.ch[3].SNAP_META.req_is_wr;
assign hin.ch[3].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[3].SNAP_SEQ.rd_ack=hout.ch[3].SNAP_SEQ.req && !hout.ch[3].SNAP_SEQ.req_is_wr;
assign hin.ch[3].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].STATUS_SNAP.rd_ack=hout.ch[3].STATUS_SNAP.req && !hout.ch[3].STATUS_SNAP.req_is_wr;
assign hin.ch[3].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CFG_VERSION_SNAP.rd_ack=hout.ch[3].CFG_VERSION_SNAP.req && !hout.ch[3].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[3].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].COUNT_LO_SNAP.rd_ack=hout.ch[3].COUNT_LO_SNAP.req && !hout.ch[3].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[3].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].COUNT_HI_SNAP.rd_ack=hout.ch[3].COUNT_HI_SNAP.req && !hout.ch[3].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[3].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].EVENT_RAW_SNAP.rd_ack=hout.ch[3].EVENT_RAW_SNAP.req && !hout.ch[3].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[3].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].IRQ_ENABLE_SNAP.rd_ack=hout.ch[3].IRQ_ENABLE_SNAP.req && !hout.ch[3].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[3].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].SEEN_MASK_SNAP.rd_ack=hout.ch[3].SEEN_MASK_SNAP.req && !hout.ch[3].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[3].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].MISSING_MASK_SNAP.rd_ack=hout.ch[3].MISSING_MASK_SNAP.req && !hout.ch[3].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[3].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[3].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[3].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[3].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FAULT_COUNT_SNAP.rd_ack=hout.ch[3].FAULT_COUNT_SNAP.req && !hout.ch[3].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[3].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[3].RECOVERY_COUNT_SNAP.req && !hout.ch[3].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[3].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].ESC_AGE_SNAP.rd_ack=hout.ch[3].ESC_AGE_SNAP.req && !hout.ch[3].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[3].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_FLAGS_SNAP.rd_ack=hout.ch[3].FIRST_FLAGS_SNAP.req && !hout.ch[3].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[3].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_CAUSE_SNAP.rd_ack=hout.ch[3].FIRST_CAUSE_SNAP.req && !hout.ch[3].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[3].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[3].FIRST_COUNT_LO_SNAP.req && !hout.ch[3].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[3].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[3].FIRST_COUNT_HI_SNAP.req && !hout.ch[3].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[3].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_SOURCE_SNAP.rd_ack=hout.ch[3].FIRST_SOURCE_SNAP.req && !hout.ch[3].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[3].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[3].FIRST_CFG_VERSION_SNAP.req && !hout.ch[3].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[3].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_MISSING_SNAP.rd_ack=hout.ch[3].FIRST_MISSING_SNAP.req && !hout.ch[3].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[3].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[3].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[3].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[3].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FIRST_STATE_SNAP.rd_ack=hout.ch[3].FIRST_STATE_SNAP.req && !hout.ch[3].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[3].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[3].CTRL_ACTIVE_SNAP.req && !hout.ch[3].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[3].PRESCALE_ACTIVE_SNAP.req && !hout.ch[3].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[3].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[3].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[3].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[3].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[3].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[3].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[3].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[3].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[3].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[3].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[3].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[3].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[3].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[3].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[3].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[3].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[3].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[3].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[3].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[3].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[3].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[3].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[3].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[3].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[3].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[3].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[3].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[3].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_SELECT.rd_ack=hout.ch[3].CLIENT_SELECT.req && !hout.ch[3].CLIENT_SELECT.req_is_wr;
assign hin.ch[3].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[3].CLIENT_SELECT.wr_ack=hout.ch[3].CLIENT_SELECT.req && hout.ch[3].CLIENT_SELECT.req_is_wr;
assign hin.ch[3].CLIENT_OWNER_STAGE.rd_ack=hout.ch[3].CLIENT_OWNER_STAGE.req && !hout.ch[3].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_OWNER_STAGE.wr_ack=hout.ch[3].CLIENT_OWNER_STAGE.req && hout.ch[3].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[3].CLIENT_ALIVE_STAGE.req && !hout.ch[3].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[3].CLIENT_ALIVE_STAGE.req && hout.ch[3].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_FLOW_STAGE.rd_ack=hout.ch[3].CLIENT_FLOW_STAGE.req && !hout.ch[3].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[3].CLIENT_FLOW_STAGE.wr_ack=hout.ch[3].CLIENT_FLOW_STAGE.req && hout.ch[3].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[3].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[3].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[3].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[3].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[3].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[3].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[3].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[3].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[3].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[3].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[3].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[3].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[3].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[3].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[3].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[3].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[3].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[3].CLIENT_FLAGS_SNAP.req && !hout.ch[3].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[3].CLIENT_TOKEN_SNAP.req && !hout.ch[3].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[3].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[3].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[3].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[3].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[3].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[3].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[3].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[3].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[3].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[3].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[3].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[3].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[3].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[3].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[3].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[3].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[3].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[3].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[3].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[3].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[3].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[3].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CTRL_STAGE.rd_ack=hout.ch[4].CTRL_STAGE.req && !hout.ch[4].CTRL_STAGE.req_is_wr;
assign hin.ch[4].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[4].CTRL_STAGE.wr_ack=hout.ch[4].CTRL_STAGE.req && hout.ch[4].CTRL_STAGE.req_is_wr;
assign hin.ch[4].PRESCALE_STAGE.rd_ack=hout.ch[4].PRESCALE_STAGE.req && !hout.ch[4].PRESCALE_STAGE.req_is_wr;
assign hin.ch[4].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].PRESCALE_STAGE.wr_ack=hout.ch[4].PRESCALE_STAGE.req && hout.ch[4].PRESCALE_STAGE.req_is_wr;
assign hin.ch[4].WIN_MIN_LO_STAGE.rd_ack=hout.ch[4].WIN_MIN_LO_STAGE.req && !hout.ch[4].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[4].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].WIN_MIN_LO_STAGE.wr_ack=hout.ch[4].WIN_MIN_LO_STAGE.req && hout.ch[4].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[4].WIN_MIN_HI_STAGE.rd_ack=hout.ch[4].WIN_MIN_HI_STAGE.req && !hout.ch[4].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[4].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].WIN_MIN_HI_STAGE.wr_ack=hout.ch[4].WIN_MIN_HI_STAGE.req && hout.ch[4].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[4].TIMEOUT_LO_STAGE.rd_ack=hout.ch[4].TIMEOUT_LO_STAGE.req && !hout.ch[4].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[4].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].TIMEOUT_LO_STAGE.wr_ack=hout.ch[4].TIMEOUT_LO_STAGE.req && hout.ch[4].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[4].TIMEOUT_HI_STAGE.rd_ack=hout.ch[4].TIMEOUT_HI_STAGE.req && !hout.ch[4].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[4].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].TIMEOUT_HI_STAGE.wr_ack=hout.ch[4].TIMEOUT_HI_STAGE.req && hout.ch[4].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[4].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[4].PRETIMEOUT_LO_STAGE.req && !hout.ch[4].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[4].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[4].PRETIMEOUT_LO_STAGE.req && hout.ch[4].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[4].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[4].PRETIMEOUT_HI_STAGE.req && !hout.ch[4].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[4].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[4].PRETIMEOUT_HI_STAGE.req && hout.ch[4].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[4].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[4].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[4].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[4].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[4].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[4].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[4].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[4].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[4].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[4].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[4].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[4].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[4].SEQ_LIMIT_STAGE.rd_ack=hout.ch[4].SEQ_LIMIT_STAGE.req && !hout.ch[4].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[4].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].SEQ_LIMIT_STAGE.wr_ack=hout.ch[4].SEQ_LIMIT_STAGE.req && hout.ch[4].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[4].REQUIRE_MASK_STAGE.rd_ack=hout.ch[4].REQUIRE_MASK_STAGE.req && !hout.ch[4].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[4].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].REQUIRE_MASK_STAGE.wr_ack=hout.ch[4].REQUIRE_MASK_STAGE.req && hout.ch[4].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[4].FAULT_POLICY_STAGE.rd_ack=hout.ch[4].FAULT_POLICY_STAGE.req && !hout.ch[4].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[4].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[4].FAULT_POLICY_STAGE.wr_ack=hout.ch[4].FAULT_POLICY_STAGE.req && hout.ch[4].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[4].LOCAL_DELAY_STAGE.rd_ack=hout.ch[4].LOCAL_DELAY_STAGE.req && !hout.ch[4].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[4].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].LOCAL_DELAY_STAGE.wr_ack=hout.ch[4].LOCAL_DELAY_STAGE.req && hout.ch[4].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[4].FINAL_DELAY_STAGE.rd_ack=hout.ch[4].FINAL_DELAY_STAGE.req && !hout.ch[4].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[4].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FINAL_DELAY_STAGE.wr_ack=hout.ch[4].FINAL_DELAY_STAGE.req && hout.ch[4].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[4].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[4].RECOVERY_LIMIT_STAGE.req && !hout.ch[4].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[4].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[4].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[4].RECOVERY_LIMIT_STAGE.req && hout.ch[4].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[4].UNLOCK.wr_ack=hout.ch[4].UNLOCK.req && hout.ch[4].UNLOCK.req_is_wr;
assign hin.ch[4].COMMAND.wr_ack=hout.ch[4].COMMAND.req && hout.ch[4].COMMAND.req_is_wr;
assign hin.ch[4].LOCK_SET.wr_ack=hout.ch[4].LOCK_SET.req && hout.ch[4].LOCK_SET.req_is_wr;
assign hin.ch[4].SERVICE_SELECT.rd_ack=hout.ch[4].SERVICE_SELECT.req && !hout.ch[4].SERVICE_SELECT.req_is_wr;
assign hin.ch[4].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[4].SERVICE_SELECT.wr_ack=hout.ch[4].SERVICE_SELECT.req && hout.ch[4].SERVICE_SELECT.req_is_wr;
assign hin.ch[4].SERVICE.wr_ack=hout.ch[4].SERVICE.req && hout.ch[4].SERVICE.req_is_wr;
assign hin.ch[4].IRQ_ENABLE.wr_ack=hout.ch[4].IRQ_ENABLE.req && hout.ch[4].IRQ_ENABLE.req_is_wr;
assign hin.ch[4].IRQ_CLEAR.wr_ack=hout.ch[4].IRQ_CLEAR.req && hout.ch[4].IRQ_CLEAR.req_is_wr;
assign hin.ch[4].IRQ_TEST.wr_ack=hout.ch[4].IRQ_TEST.req && hout.ch[4].IRQ_TEST.req_is_wr;
assign hin.ch[4].DIAG_CLEAR.wr_ack=hout.ch[4].DIAG_CLEAR.req && hout.ch[4].DIAG_CLEAR.req_is_wr;
assign hin.ch[4].FAULT_INJECT.wr_ack=hout.ch[4].FAULT_INJECT.req && hout.ch[4].FAULT_INJECT.req_is_wr;
assign hin.ch[4].SNAP_META.rd_ack=hout.ch[4].SNAP_META.req && !hout.ch[4].SNAP_META.req_is_wr;
assign hin.ch[4].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[4].SNAP_SEQ.rd_ack=hout.ch[4].SNAP_SEQ.req && !hout.ch[4].SNAP_SEQ.req_is_wr;
assign hin.ch[4].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].STATUS_SNAP.rd_ack=hout.ch[4].STATUS_SNAP.req && !hout.ch[4].STATUS_SNAP.req_is_wr;
assign hin.ch[4].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CFG_VERSION_SNAP.rd_ack=hout.ch[4].CFG_VERSION_SNAP.req && !hout.ch[4].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[4].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].COUNT_LO_SNAP.rd_ack=hout.ch[4].COUNT_LO_SNAP.req && !hout.ch[4].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[4].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].COUNT_HI_SNAP.rd_ack=hout.ch[4].COUNT_HI_SNAP.req && !hout.ch[4].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[4].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].EVENT_RAW_SNAP.rd_ack=hout.ch[4].EVENT_RAW_SNAP.req && !hout.ch[4].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[4].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].IRQ_ENABLE_SNAP.rd_ack=hout.ch[4].IRQ_ENABLE_SNAP.req && !hout.ch[4].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[4].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].SEEN_MASK_SNAP.rd_ack=hout.ch[4].SEEN_MASK_SNAP.req && !hout.ch[4].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[4].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].MISSING_MASK_SNAP.rd_ack=hout.ch[4].MISSING_MASK_SNAP.req && !hout.ch[4].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[4].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[4].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[4].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[4].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FAULT_COUNT_SNAP.rd_ack=hout.ch[4].FAULT_COUNT_SNAP.req && !hout.ch[4].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[4].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[4].RECOVERY_COUNT_SNAP.req && !hout.ch[4].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[4].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].ESC_AGE_SNAP.rd_ack=hout.ch[4].ESC_AGE_SNAP.req && !hout.ch[4].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[4].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_FLAGS_SNAP.rd_ack=hout.ch[4].FIRST_FLAGS_SNAP.req && !hout.ch[4].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[4].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_CAUSE_SNAP.rd_ack=hout.ch[4].FIRST_CAUSE_SNAP.req && !hout.ch[4].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[4].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[4].FIRST_COUNT_LO_SNAP.req && !hout.ch[4].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[4].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[4].FIRST_COUNT_HI_SNAP.req && !hout.ch[4].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[4].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_SOURCE_SNAP.rd_ack=hout.ch[4].FIRST_SOURCE_SNAP.req && !hout.ch[4].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[4].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[4].FIRST_CFG_VERSION_SNAP.req && !hout.ch[4].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[4].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_MISSING_SNAP.rd_ack=hout.ch[4].FIRST_MISSING_SNAP.req && !hout.ch[4].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[4].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[4].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[4].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[4].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FIRST_STATE_SNAP.rd_ack=hout.ch[4].FIRST_STATE_SNAP.req && !hout.ch[4].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[4].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[4].CTRL_ACTIVE_SNAP.req && !hout.ch[4].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[4].PRESCALE_ACTIVE_SNAP.req && !hout.ch[4].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[4].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[4].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[4].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[4].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[4].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[4].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[4].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[4].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[4].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[4].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[4].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[4].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[4].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[4].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[4].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[4].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[4].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[4].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[4].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[4].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[4].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[4].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[4].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[4].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[4].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[4].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[4].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[4].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_SELECT.rd_ack=hout.ch[4].CLIENT_SELECT.req && !hout.ch[4].CLIENT_SELECT.req_is_wr;
assign hin.ch[4].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[4].CLIENT_SELECT.wr_ack=hout.ch[4].CLIENT_SELECT.req && hout.ch[4].CLIENT_SELECT.req_is_wr;
assign hin.ch[4].CLIENT_OWNER_STAGE.rd_ack=hout.ch[4].CLIENT_OWNER_STAGE.req && !hout.ch[4].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_OWNER_STAGE.wr_ack=hout.ch[4].CLIENT_OWNER_STAGE.req && hout.ch[4].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[4].CLIENT_ALIVE_STAGE.req && !hout.ch[4].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[4].CLIENT_ALIVE_STAGE.req && hout.ch[4].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_FLOW_STAGE.rd_ack=hout.ch[4].CLIENT_FLOW_STAGE.req && !hout.ch[4].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[4].CLIENT_FLOW_STAGE.wr_ack=hout.ch[4].CLIENT_FLOW_STAGE.req && hout.ch[4].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[4].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[4].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[4].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[4].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[4].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[4].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[4].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[4].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[4].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[4].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[4].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[4].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[4].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[4].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[4].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[4].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[4].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[4].CLIENT_FLAGS_SNAP.req && !hout.ch[4].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[4].CLIENT_TOKEN_SNAP.req && !hout.ch[4].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[4].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[4].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[4].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[4].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[4].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[4].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[4].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[4].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[4].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[4].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[4].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[4].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[4].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[4].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[4].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[4].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[4].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[4].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[4].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[4].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[4].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[4].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CTRL_STAGE.rd_ack=hout.ch[5].CTRL_STAGE.req && !hout.ch[5].CTRL_STAGE.req_is_wr;
assign hin.ch[5].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[5].CTRL_STAGE.wr_ack=hout.ch[5].CTRL_STAGE.req && hout.ch[5].CTRL_STAGE.req_is_wr;
assign hin.ch[5].PRESCALE_STAGE.rd_ack=hout.ch[5].PRESCALE_STAGE.req && !hout.ch[5].PRESCALE_STAGE.req_is_wr;
assign hin.ch[5].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].PRESCALE_STAGE.wr_ack=hout.ch[5].PRESCALE_STAGE.req && hout.ch[5].PRESCALE_STAGE.req_is_wr;
assign hin.ch[5].WIN_MIN_LO_STAGE.rd_ack=hout.ch[5].WIN_MIN_LO_STAGE.req && !hout.ch[5].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[5].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].WIN_MIN_LO_STAGE.wr_ack=hout.ch[5].WIN_MIN_LO_STAGE.req && hout.ch[5].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[5].WIN_MIN_HI_STAGE.rd_ack=hout.ch[5].WIN_MIN_HI_STAGE.req && !hout.ch[5].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[5].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].WIN_MIN_HI_STAGE.wr_ack=hout.ch[5].WIN_MIN_HI_STAGE.req && hout.ch[5].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[5].TIMEOUT_LO_STAGE.rd_ack=hout.ch[5].TIMEOUT_LO_STAGE.req && !hout.ch[5].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[5].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].TIMEOUT_LO_STAGE.wr_ack=hout.ch[5].TIMEOUT_LO_STAGE.req && hout.ch[5].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[5].TIMEOUT_HI_STAGE.rd_ack=hout.ch[5].TIMEOUT_HI_STAGE.req && !hout.ch[5].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[5].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].TIMEOUT_HI_STAGE.wr_ack=hout.ch[5].TIMEOUT_HI_STAGE.req && hout.ch[5].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[5].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[5].PRETIMEOUT_LO_STAGE.req && !hout.ch[5].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[5].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[5].PRETIMEOUT_LO_STAGE.req && hout.ch[5].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[5].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[5].PRETIMEOUT_HI_STAGE.req && !hout.ch[5].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[5].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[5].PRETIMEOUT_HI_STAGE.req && hout.ch[5].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[5].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[5].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[5].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[5].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[5].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[5].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[5].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[5].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[5].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[5].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[5].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[5].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[5].SEQ_LIMIT_STAGE.rd_ack=hout.ch[5].SEQ_LIMIT_STAGE.req && !hout.ch[5].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[5].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].SEQ_LIMIT_STAGE.wr_ack=hout.ch[5].SEQ_LIMIT_STAGE.req && hout.ch[5].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[5].REQUIRE_MASK_STAGE.rd_ack=hout.ch[5].REQUIRE_MASK_STAGE.req && !hout.ch[5].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[5].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].REQUIRE_MASK_STAGE.wr_ack=hout.ch[5].REQUIRE_MASK_STAGE.req && hout.ch[5].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[5].FAULT_POLICY_STAGE.rd_ack=hout.ch[5].FAULT_POLICY_STAGE.req && !hout.ch[5].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[5].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[5].FAULT_POLICY_STAGE.wr_ack=hout.ch[5].FAULT_POLICY_STAGE.req && hout.ch[5].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[5].LOCAL_DELAY_STAGE.rd_ack=hout.ch[5].LOCAL_DELAY_STAGE.req && !hout.ch[5].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[5].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].LOCAL_DELAY_STAGE.wr_ack=hout.ch[5].LOCAL_DELAY_STAGE.req && hout.ch[5].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[5].FINAL_DELAY_STAGE.rd_ack=hout.ch[5].FINAL_DELAY_STAGE.req && !hout.ch[5].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[5].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FINAL_DELAY_STAGE.wr_ack=hout.ch[5].FINAL_DELAY_STAGE.req && hout.ch[5].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[5].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[5].RECOVERY_LIMIT_STAGE.req && !hout.ch[5].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[5].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[5].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[5].RECOVERY_LIMIT_STAGE.req && hout.ch[5].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[5].UNLOCK.wr_ack=hout.ch[5].UNLOCK.req && hout.ch[5].UNLOCK.req_is_wr;
assign hin.ch[5].COMMAND.wr_ack=hout.ch[5].COMMAND.req && hout.ch[5].COMMAND.req_is_wr;
assign hin.ch[5].LOCK_SET.wr_ack=hout.ch[5].LOCK_SET.req && hout.ch[5].LOCK_SET.req_is_wr;
assign hin.ch[5].SERVICE_SELECT.rd_ack=hout.ch[5].SERVICE_SELECT.req && !hout.ch[5].SERVICE_SELECT.req_is_wr;
assign hin.ch[5].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[5].SERVICE_SELECT.wr_ack=hout.ch[5].SERVICE_SELECT.req && hout.ch[5].SERVICE_SELECT.req_is_wr;
assign hin.ch[5].SERVICE.wr_ack=hout.ch[5].SERVICE.req && hout.ch[5].SERVICE.req_is_wr;
assign hin.ch[5].IRQ_ENABLE.wr_ack=hout.ch[5].IRQ_ENABLE.req && hout.ch[5].IRQ_ENABLE.req_is_wr;
assign hin.ch[5].IRQ_CLEAR.wr_ack=hout.ch[5].IRQ_CLEAR.req && hout.ch[5].IRQ_CLEAR.req_is_wr;
assign hin.ch[5].IRQ_TEST.wr_ack=hout.ch[5].IRQ_TEST.req && hout.ch[5].IRQ_TEST.req_is_wr;
assign hin.ch[5].DIAG_CLEAR.wr_ack=hout.ch[5].DIAG_CLEAR.req && hout.ch[5].DIAG_CLEAR.req_is_wr;
assign hin.ch[5].FAULT_INJECT.wr_ack=hout.ch[5].FAULT_INJECT.req && hout.ch[5].FAULT_INJECT.req_is_wr;
assign hin.ch[5].SNAP_META.rd_ack=hout.ch[5].SNAP_META.req && !hout.ch[5].SNAP_META.req_is_wr;
assign hin.ch[5].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[5].SNAP_SEQ.rd_ack=hout.ch[5].SNAP_SEQ.req && !hout.ch[5].SNAP_SEQ.req_is_wr;
assign hin.ch[5].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].STATUS_SNAP.rd_ack=hout.ch[5].STATUS_SNAP.req && !hout.ch[5].STATUS_SNAP.req_is_wr;
assign hin.ch[5].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CFG_VERSION_SNAP.rd_ack=hout.ch[5].CFG_VERSION_SNAP.req && !hout.ch[5].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[5].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].COUNT_LO_SNAP.rd_ack=hout.ch[5].COUNT_LO_SNAP.req && !hout.ch[5].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[5].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].COUNT_HI_SNAP.rd_ack=hout.ch[5].COUNT_HI_SNAP.req && !hout.ch[5].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[5].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].EVENT_RAW_SNAP.rd_ack=hout.ch[5].EVENT_RAW_SNAP.req && !hout.ch[5].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[5].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].IRQ_ENABLE_SNAP.rd_ack=hout.ch[5].IRQ_ENABLE_SNAP.req && !hout.ch[5].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[5].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].SEEN_MASK_SNAP.rd_ack=hout.ch[5].SEEN_MASK_SNAP.req && !hout.ch[5].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[5].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].MISSING_MASK_SNAP.rd_ack=hout.ch[5].MISSING_MASK_SNAP.req && !hout.ch[5].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[5].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[5].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[5].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[5].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FAULT_COUNT_SNAP.rd_ack=hout.ch[5].FAULT_COUNT_SNAP.req && !hout.ch[5].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[5].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[5].RECOVERY_COUNT_SNAP.req && !hout.ch[5].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[5].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].ESC_AGE_SNAP.rd_ack=hout.ch[5].ESC_AGE_SNAP.req && !hout.ch[5].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[5].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_FLAGS_SNAP.rd_ack=hout.ch[5].FIRST_FLAGS_SNAP.req && !hout.ch[5].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[5].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_CAUSE_SNAP.rd_ack=hout.ch[5].FIRST_CAUSE_SNAP.req && !hout.ch[5].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[5].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[5].FIRST_COUNT_LO_SNAP.req && !hout.ch[5].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[5].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[5].FIRST_COUNT_HI_SNAP.req && !hout.ch[5].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[5].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_SOURCE_SNAP.rd_ack=hout.ch[5].FIRST_SOURCE_SNAP.req && !hout.ch[5].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[5].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[5].FIRST_CFG_VERSION_SNAP.req && !hout.ch[5].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[5].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_MISSING_SNAP.rd_ack=hout.ch[5].FIRST_MISSING_SNAP.req && !hout.ch[5].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[5].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[5].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[5].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[5].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FIRST_STATE_SNAP.rd_ack=hout.ch[5].FIRST_STATE_SNAP.req && !hout.ch[5].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[5].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[5].CTRL_ACTIVE_SNAP.req && !hout.ch[5].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[5].PRESCALE_ACTIVE_SNAP.req && !hout.ch[5].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[5].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[5].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[5].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[5].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[5].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[5].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[5].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[5].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[5].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[5].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[5].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[5].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[5].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[5].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[5].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[5].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[5].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[5].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[5].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[5].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[5].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[5].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[5].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[5].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[5].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[5].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[5].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[5].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_SELECT.rd_ack=hout.ch[5].CLIENT_SELECT.req && !hout.ch[5].CLIENT_SELECT.req_is_wr;
assign hin.ch[5].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[5].CLIENT_SELECT.wr_ack=hout.ch[5].CLIENT_SELECT.req && hout.ch[5].CLIENT_SELECT.req_is_wr;
assign hin.ch[5].CLIENT_OWNER_STAGE.rd_ack=hout.ch[5].CLIENT_OWNER_STAGE.req && !hout.ch[5].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_OWNER_STAGE.wr_ack=hout.ch[5].CLIENT_OWNER_STAGE.req && hout.ch[5].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[5].CLIENT_ALIVE_STAGE.req && !hout.ch[5].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[5].CLIENT_ALIVE_STAGE.req && hout.ch[5].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_FLOW_STAGE.rd_ack=hout.ch[5].CLIENT_FLOW_STAGE.req && !hout.ch[5].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[5].CLIENT_FLOW_STAGE.wr_ack=hout.ch[5].CLIENT_FLOW_STAGE.req && hout.ch[5].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[5].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[5].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[5].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[5].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[5].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[5].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[5].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[5].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[5].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[5].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[5].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[5].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[5].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[5].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[5].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[5].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[5].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[5].CLIENT_FLAGS_SNAP.req && !hout.ch[5].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[5].CLIENT_TOKEN_SNAP.req && !hout.ch[5].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[5].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[5].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[5].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[5].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[5].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[5].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[5].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[5].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[5].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[5].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[5].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[5].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[5].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[5].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[5].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[5].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[5].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[5].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[5].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[5].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[5].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[5].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CTRL_STAGE.rd_ack=hout.ch[6].CTRL_STAGE.req && !hout.ch[6].CTRL_STAGE.req_is_wr;
assign hin.ch[6].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[6].CTRL_STAGE.wr_ack=hout.ch[6].CTRL_STAGE.req && hout.ch[6].CTRL_STAGE.req_is_wr;
assign hin.ch[6].PRESCALE_STAGE.rd_ack=hout.ch[6].PRESCALE_STAGE.req && !hout.ch[6].PRESCALE_STAGE.req_is_wr;
assign hin.ch[6].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].PRESCALE_STAGE.wr_ack=hout.ch[6].PRESCALE_STAGE.req && hout.ch[6].PRESCALE_STAGE.req_is_wr;
assign hin.ch[6].WIN_MIN_LO_STAGE.rd_ack=hout.ch[6].WIN_MIN_LO_STAGE.req && !hout.ch[6].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[6].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].WIN_MIN_LO_STAGE.wr_ack=hout.ch[6].WIN_MIN_LO_STAGE.req && hout.ch[6].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[6].WIN_MIN_HI_STAGE.rd_ack=hout.ch[6].WIN_MIN_HI_STAGE.req && !hout.ch[6].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[6].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].WIN_MIN_HI_STAGE.wr_ack=hout.ch[6].WIN_MIN_HI_STAGE.req && hout.ch[6].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[6].TIMEOUT_LO_STAGE.rd_ack=hout.ch[6].TIMEOUT_LO_STAGE.req && !hout.ch[6].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[6].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].TIMEOUT_LO_STAGE.wr_ack=hout.ch[6].TIMEOUT_LO_STAGE.req && hout.ch[6].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[6].TIMEOUT_HI_STAGE.rd_ack=hout.ch[6].TIMEOUT_HI_STAGE.req && !hout.ch[6].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[6].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].TIMEOUT_HI_STAGE.wr_ack=hout.ch[6].TIMEOUT_HI_STAGE.req && hout.ch[6].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[6].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[6].PRETIMEOUT_LO_STAGE.req && !hout.ch[6].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[6].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[6].PRETIMEOUT_LO_STAGE.req && hout.ch[6].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[6].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[6].PRETIMEOUT_HI_STAGE.req && !hout.ch[6].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[6].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[6].PRETIMEOUT_HI_STAGE.req && hout.ch[6].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[6].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[6].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[6].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[6].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[6].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[6].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[6].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[6].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[6].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[6].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[6].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[6].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[6].SEQ_LIMIT_STAGE.rd_ack=hout.ch[6].SEQ_LIMIT_STAGE.req && !hout.ch[6].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[6].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].SEQ_LIMIT_STAGE.wr_ack=hout.ch[6].SEQ_LIMIT_STAGE.req && hout.ch[6].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[6].REQUIRE_MASK_STAGE.rd_ack=hout.ch[6].REQUIRE_MASK_STAGE.req && !hout.ch[6].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[6].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].REQUIRE_MASK_STAGE.wr_ack=hout.ch[6].REQUIRE_MASK_STAGE.req && hout.ch[6].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[6].FAULT_POLICY_STAGE.rd_ack=hout.ch[6].FAULT_POLICY_STAGE.req && !hout.ch[6].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[6].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[6].FAULT_POLICY_STAGE.wr_ack=hout.ch[6].FAULT_POLICY_STAGE.req && hout.ch[6].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[6].LOCAL_DELAY_STAGE.rd_ack=hout.ch[6].LOCAL_DELAY_STAGE.req && !hout.ch[6].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[6].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].LOCAL_DELAY_STAGE.wr_ack=hout.ch[6].LOCAL_DELAY_STAGE.req && hout.ch[6].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[6].FINAL_DELAY_STAGE.rd_ack=hout.ch[6].FINAL_DELAY_STAGE.req && !hout.ch[6].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[6].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FINAL_DELAY_STAGE.wr_ack=hout.ch[6].FINAL_DELAY_STAGE.req && hout.ch[6].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[6].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[6].RECOVERY_LIMIT_STAGE.req && !hout.ch[6].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[6].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[6].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[6].RECOVERY_LIMIT_STAGE.req && hout.ch[6].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[6].UNLOCK.wr_ack=hout.ch[6].UNLOCK.req && hout.ch[6].UNLOCK.req_is_wr;
assign hin.ch[6].COMMAND.wr_ack=hout.ch[6].COMMAND.req && hout.ch[6].COMMAND.req_is_wr;
assign hin.ch[6].LOCK_SET.wr_ack=hout.ch[6].LOCK_SET.req && hout.ch[6].LOCK_SET.req_is_wr;
assign hin.ch[6].SERVICE_SELECT.rd_ack=hout.ch[6].SERVICE_SELECT.req && !hout.ch[6].SERVICE_SELECT.req_is_wr;
assign hin.ch[6].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[6].SERVICE_SELECT.wr_ack=hout.ch[6].SERVICE_SELECT.req && hout.ch[6].SERVICE_SELECT.req_is_wr;
assign hin.ch[6].SERVICE.wr_ack=hout.ch[6].SERVICE.req && hout.ch[6].SERVICE.req_is_wr;
assign hin.ch[6].IRQ_ENABLE.wr_ack=hout.ch[6].IRQ_ENABLE.req && hout.ch[6].IRQ_ENABLE.req_is_wr;
assign hin.ch[6].IRQ_CLEAR.wr_ack=hout.ch[6].IRQ_CLEAR.req && hout.ch[6].IRQ_CLEAR.req_is_wr;
assign hin.ch[6].IRQ_TEST.wr_ack=hout.ch[6].IRQ_TEST.req && hout.ch[6].IRQ_TEST.req_is_wr;
assign hin.ch[6].DIAG_CLEAR.wr_ack=hout.ch[6].DIAG_CLEAR.req && hout.ch[6].DIAG_CLEAR.req_is_wr;
assign hin.ch[6].FAULT_INJECT.wr_ack=hout.ch[6].FAULT_INJECT.req && hout.ch[6].FAULT_INJECT.req_is_wr;
assign hin.ch[6].SNAP_META.rd_ack=hout.ch[6].SNAP_META.req && !hout.ch[6].SNAP_META.req_is_wr;
assign hin.ch[6].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[6].SNAP_SEQ.rd_ack=hout.ch[6].SNAP_SEQ.req && !hout.ch[6].SNAP_SEQ.req_is_wr;
assign hin.ch[6].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].STATUS_SNAP.rd_ack=hout.ch[6].STATUS_SNAP.req && !hout.ch[6].STATUS_SNAP.req_is_wr;
assign hin.ch[6].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CFG_VERSION_SNAP.rd_ack=hout.ch[6].CFG_VERSION_SNAP.req && !hout.ch[6].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[6].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].COUNT_LO_SNAP.rd_ack=hout.ch[6].COUNT_LO_SNAP.req && !hout.ch[6].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[6].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].COUNT_HI_SNAP.rd_ack=hout.ch[6].COUNT_HI_SNAP.req && !hout.ch[6].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[6].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].EVENT_RAW_SNAP.rd_ack=hout.ch[6].EVENT_RAW_SNAP.req && !hout.ch[6].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[6].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].IRQ_ENABLE_SNAP.rd_ack=hout.ch[6].IRQ_ENABLE_SNAP.req && !hout.ch[6].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[6].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].SEEN_MASK_SNAP.rd_ack=hout.ch[6].SEEN_MASK_SNAP.req && !hout.ch[6].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[6].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].MISSING_MASK_SNAP.rd_ack=hout.ch[6].MISSING_MASK_SNAP.req && !hout.ch[6].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[6].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[6].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[6].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[6].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FAULT_COUNT_SNAP.rd_ack=hout.ch[6].FAULT_COUNT_SNAP.req && !hout.ch[6].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[6].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[6].RECOVERY_COUNT_SNAP.req && !hout.ch[6].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[6].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].ESC_AGE_SNAP.rd_ack=hout.ch[6].ESC_AGE_SNAP.req && !hout.ch[6].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[6].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_FLAGS_SNAP.rd_ack=hout.ch[6].FIRST_FLAGS_SNAP.req && !hout.ch[6].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[6].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_CAUSE_SNAP.rd_ack=hout.ch[6].FIRST_CAUSE_SNAP.req && !hout.ch[6].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[6].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[6].FIRST_COUNT_LO_SNAP.req && !hout.ch[6].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[6].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[6].FIRST_COUNT_HI_SNAP.req && !hout.ch[6].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[6].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_SOURCE_SNAP.rd_ack=hout.ch[6].FIRST_SOURCE_SNAP.req && !hout.ch[6].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[6].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[6].FIRST_CFG_VERSION_SNAP.req && !hout.ch[6].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[6].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_MISSING_SNAP.rd_ack=hout.ch[6].FIRST_MISSING_SNAP.req && !hout.ch[6].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[6].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[6].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[6].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[6].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FIRST_STATE_SNAP.rd_ack=hout.ch[6].FIRST_STATE_SNAP.req && !hout.ch[6].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[6].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[6].CTRL_ACTIVE_SNAP.req && !hout.ch[6].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[6].PRESCALE_ACTIVE_SNAP.req && !hout.ch[6].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[6].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[6].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[6].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[6].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[6].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[6].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[6].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[6].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[6].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[6].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[6].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[6].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[6].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[6].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[6].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[6].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[6].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[6].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[6].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[6].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[6].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[6].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[6].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[6].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[6].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[6].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[6].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[6].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_SELECT.rd_ack=hout.ch[6].CLIENT_SELECT.req && !hout.ch[6].CLIENT_SELECT.req_is_wr;
assign hin.ch[6].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[6].CLIENT_SELECT.wr_ack=hout.ch[6].CLIENT_SELECT.req && hout.ch[6].CLIENT_SELECT.req_is_wr;
assign hin.ch[6].CLIENT_OWNER_STAGE.rd_ack=hout.ch[6].CLIENT_OWNER_STAGE.req && !hout.ch[6].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_OWNER_STAGE.wr_ack=hout.ch[6].CLIENT_OWNER_STAGE.req && hout.ch[6].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[6].CLIENT_ALIVE_STAGE.req && !hout.ch[6].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[6].CLIENT_ALIVE_STAGE.req && hout.ch[6].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_FLOW_STAGE.rd_ack=hout.ch[6].CLIENT_FLOW_STAGE.req && !hout.ch[6].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[6].CLIENT_FLOW_STAGE.wr_ack=hout.ch[6].CLIENT_FLOW_STAGE.req && hout.ch[6].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[6].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[6].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[6].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[6].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[6].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[6].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[6].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[6].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[6].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[6].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[6].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[6].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[6].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[6].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[6].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[6].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[6].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[6].CLIENT_FLAGS_SNAP.req && !hout.ch[6].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[6].CLIENT_TOKEN_SNAP.req && !hout.ch[6].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[6].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[6].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[6].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[6].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[6].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[6].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[6].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[6].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[6].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[6].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[6].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[6].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[6].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[6].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[6].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[6].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[6].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[6].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[6].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[6].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[6].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[6].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CTRL_STAGE.rd_ack=hout.ch[7].CTRL_STAGE.req && !hout.ch[7].CTRL_STAGE.req_is_wr;
assign hin.ch[7].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[7].CTRL_STAGE.wr_ack=hout.ch[7].CTRL_STAGE.req && hout.ch[7].CTRL_STAGE.req_is_wr;
assign hin.ch[7].PRESCALE_STAGE.rd_ack=hout.ch[7].PRESCALE_STAGE.req && !hout.ch[7].PRESCALE_STAGE.req_is_wr;
assign hin.ch[7].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].PRESCALE_STAGE.wr_ack=hout.ch[7].PRESCALE_STAGE.req && hout.ch[7].PRESCALE_STAGE.req_is_wr;
assign hin.ch[7].WIN_MIN_LO_STAGE.rd_ack=hout.ch[7].WIN_MIN_LO_STAGE.req && !hout.ch[7].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[7].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].WIN_MIN_LO_STAGE.wr_ack=hout.ch[7].WIN_MIN_LO_STAGE.req && hout.ch[7].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[7].WIN_MIN_HI_STAGE.rd_ack=hout.ch[7].WIN_MIN_HI_STAGE.req && !hout.ch[7].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[7].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].WIN_MIN_HI_STAGE.wr_ack=hout.ch[7].WIN_MIN_HI_STAGE.req && hout.ch[7].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[7].TIMEOUT_LO_STAGE.rd_ack=hout.ch[7].TIMEOUT_LO_STAGE.req && !hout.ch[7].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[7].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].TIMEOUT_LO_STAGE.wr_ack=hout.ch[7].TIMEOUT_LO_STAGE.req && hout.ch[7].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[7].TIMEOUT_HI_STAGE.rd_ack=hout.ch[7].TIMEOUT_HI_STAGE.req && !hout.ch[7].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[7].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].TIMEOUT_HI_STAGE.wr_ack=hout.ch[7].TIMEOUT_HI_STAGE.req && hout.ch[7].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[7].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[7].PRETIMEOUT_LO_STAGE.req && !hout.ch[7].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[7].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[7].PRETIMEOUT_LO_STAGE.req && hout.ch[7].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[7].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[7].PRETIMEOUT_HI_STAGE.req && !hout.ch[7].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[7].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[7].PRETIMEOUT_HI_STAGE.req && hout.ch[7].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[7].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[7].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[7].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[7].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[7].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[7].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[7].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[7].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[7].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[7].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[7].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[7].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[7].SEQ_LIMIT_STAGE.rd_ack=hout.ch[7].SEQ_LIMIT_STAGE.req && !hout.ch[7].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[7].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].SEQ_LIMIT_STAGE.wr_ack=hout.ch[7].SEQ_LIMIT_STAGE.req && hout.ch[7].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[7].REQUIRE_MASK_STAGE.rd_ack=hout.ch[7].REQUIRE_MASK_STAGE.req && !hout.ch[7].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[7].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].REQUIRE_MASK_STAGE.wr_ack=hout.ch[7].REQUIRE_MASK_STAGE.req && hout.ch[7].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[7].FAULT_POLICY_STAGE.rd_ack=hout.ch[7].FAULT_POLICY_STAGE.req && !hout.ch[7].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[7].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[7].FAULT_POLICY_STAGE.wr_ack=hout.ch[7].FAULT_POLICY_STAGE.req && hout.ch[7].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[7].LOCAL_DELAY_STAGE.rd_ack=hout.ch[7].LOCAL_DELAY_STAGE.req && !hout.ch[7].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[7].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].LOCAL_DELAY_STAGE.wr_ack=hout.ch[7].LOCAL_DELAY_STAGE.req && hout.ch[7].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[7].FINAL_DELAY_STAGE.rd_ack=hout.ch[7].FINAL_DELAY_STAGE.req && !hout.ch[7].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[7].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FINAL_DELAY_STAGE.wr_ack=hout.ch[7].FINAL_DELAY_STAGE.req && hout.ch[7].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[7].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[7].RECOVERY_LIMIT_STAGE.req && !hout.ch[7].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[7].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[7].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[7].RECOVERY_LIMIT_STAGE.req && hout.ch[7].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[7].UNLOCK.wr_ack=hout.ch[7].UNLOCK.req && hout.ch[7].UNLOCK.req_is_wr;
assign hin.ch[7].COMMAND.wr_ack=hout.ch[7].COMMAND.req && hout.ch[7].COMMAND.req_is_wr;
assign hin.ch[7].LOCK_SET.wr_ack=hout.ch[7].LOCK_SET.req && hout.ch[7].LOCK_SET.req_is_wr;
assign hin.ch[7].SERVICE_SELECT.rd_ack=hout.ch[7].SERVICE_SELECT.req && !hout.ch[7].SERVICE_SELECT.req_is_wr;
assign hin.ch[7].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[7].SERVICE_SELECT.wr_ack=hout.ch[7].SERVICE_SELECT.req && hout.ch[7].SERVICE_SELECT.req_is_wr;
assign hin.ch[7].SERVICE.wr_ack=hout.ch[7].SERVICE.req && hout.ch[7].SERVICE.req_is_wr;
assign hin.ch[7].IRQ_ENABLE.wr_ack=hout.ch[7].IRQ_ENABLE.req && hout.ch[7].IRQ_ENABLE.req_is_wr;
assign hin.ch[7].IRQ_CLEAR.wr_ack=hout.ch[7].IRQ_CLEAR.req && hout.ch[7].IRQ_CLEAR.req_is_wr;
assign hin.ch[7].IRQ_TEST.wr_ack=hout.ch[7].IRQ_TEST.req && hout.ch[7].IRQ_TEST.req_is_wr;
assign hin.ch[7].DIAG_CLEAR.wr_ack=hout.ch[7].DIAG_CLEAR.req && hout.ch[7].DIAG_CLEAR.req_is_wr;
assign hin.ch[7].FAULT_INJECT.wr_ack=hout.ch[7].FAULT_INJECT.req && hout.ch[7].FAULT_INJECT.req_is_wr;
assign hin.ch[7].SNAP_META.rd_ack=hout.ch[7].SNAP_META.req && !hout.ch[7].SNAP_META.req_is_wr;
assign hin.ch[7].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[7].SNAP_SEQ.rd_ack=hout.ch[7].SNAP_SEQ.req && !hout.ch[7].SNAP_SEQ.req_is_wr;
assign hin.ch[7].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].STATUS_SNAP.rd_ack=hout.ch[7].STATUS_SNAP.req && !hout.ch[7].STATUS_SNAP.req_is_wr;
assign hin.ch[7].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CFG_VERSION_SNAP.rd_ack=hout.ch[7].CFG_VERSION_SNAP.req && !hout.ch[7].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[7].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].COUNT_LO_SNAP.rd_ack=hout.ch[7].COUNT_LO_SNAP.req && !hout.ch[7].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[7].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].COUNT_HI_SNAP.rd_ack=hout.ch[7].COUNT_HI_SNAP.req && !hout.ch[7].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[7].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].EVENT_RAW_SNAP.rd_ack=hout.ch[7].EVENT_RAW_SNAP.req && !hout.ch[7].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[7].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].IRQ_ENABLE_SNAP.rd_ack=hout.ch[7].IRQ_ENABLE_SNAP.req && !hout.ch[7].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[7].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].SEEN_MASK_SNAP.rd_ack=hout.ch[7].SEEN_MASK_SNAP.req && !hout.ch[7].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[7].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].MISSING_MASK_SNAP.rd_ack=hout.ch[7].MISSING_MASK_SNAP.req && !hout.ch[7].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[7].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[7].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[7].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[7].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FAULT_COUNT_SNAP.rd_ack=hout.ch[7].FAULT_COUNT_SNAP.req && !hout.ch[7].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[7].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[7].RECOVERY_COUNT_SNAP.req && !hout.ch[7].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[7].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].ESC_AGE_SNAP.rd_ack=hout.ch[7].ESC_AGE_SNAP.req && !hout.ch[7].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[7].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_FLAGS_SNAP.rd_ack=hout.ch[7].FIRST_FLAGS_SNAP.req && !hout.ch[7].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[7].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_CAUSE_SNAP.rd_ack=hout.ch[7].FIRST_CAUSE_SNAP.req && !hout.ch[7].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[7].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[7].FIRST_COUNT_LO_SNAP.req && !hout.ch[7].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[7].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[7].FIRST_COUNT_HI_SNAP.req && !hout.ch[7].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[7].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_SOURCE_SNAP.rd_ack=hout.ch[7].FIRST_SOURCE_SNAP.req && !hout.ch[7].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[7].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[7].FIRST_CFG_VERSION_SNAP.req && !hout.ch[7].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[7].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_MISSING_SNAP.rd_ack=hout.ch[7].FIRST_MISSING_SNAP.req && !hout.ch[7].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[7].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[7].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[7].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[7].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FIRST_STATE_SNAP.rd_ack=hout.ch[7].FIRST_STATE_SNAP.req && !hout.ch[7].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[7].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[7].CTRL_ACTIVE_SNAP.req && !hout.ch[7].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[7].PRESCALE_ACTIVE_SNAP.req && !hout.ch[7].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[7].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[7].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[7].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[7].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[7].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[7].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[7].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[7].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[7].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[7].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[7].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[7].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[7].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[7].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[7].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[7].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[7].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[7].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[7].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[7].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[7].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[7].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[7].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[7].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[7].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[7].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[7].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[7].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_SELECT.rd_ack=hout.ch[7].CLIENT_SELECT.req && !hout.ch[7].CLIENT_SELECT.req_is_wr;
assign hin.ch[7].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[7].CLIENT_SELECT.wr_ack=hout.ch[7].CLIENT_SELECT.req && hout.ch[7].CLIENT_SELECT.req_is_wr;
assign hin.ch[7].CLIENT_OWNER_STAGE.rd_ack=hout.ch[7].CLIENT_OWNER_STAGE.req && !hout.ch[7].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_OWNER_STAGE.wr_ack=hout.ch[7].CLIENT_OWNER_STAGE.req && hout.ch[7].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[7].CLIENT_ALIVE_STAGE.req && !hout.ch[7].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[7].CLIENT_ALIVE_STAGE.req && hout.ch[7].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_FLOW_STAGE.rd_ack=hout.ch[7].CLIENT_FLOW_STAGE.req && !hout.ch[7].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[7].CLIENT_FLOW_STAGE.wr_ack=hout.ch[7].CLIENT_FLOW_STAGE.req && hout.ch[7].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[7].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[7].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[7].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[7].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[7].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[7].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[7].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[7].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[7].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[7].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[7].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[7].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[7].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[7].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[7].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[7].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[7].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[7].CLIENT_FLAGS_SNAP.req && !hout.ch[7].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[7].CLIENT_TOKEN_SNAP.req && !hout.ch[7].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[7].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[7].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[7].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[7].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[7].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[7].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[7].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[7].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[7].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[7].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[7].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[7].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[7].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[7].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[7].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[7].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[7].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[7].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[7].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[7].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[7].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[7].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CTRL_STAGE.rd_ack=hout.ch[8].CTRL_STAGE.req && !hout.ch[8].CTRL_STAGE.req_is_wr;
assign hin.ch[8].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[8].CTRL_STAGE.wr_ack=hout.ch[8].CTRL_STAGE.req && hout.ch[8].CTRL_STAGE.req_is_wr;
assign hin.ch[8].PRESCALE_STAGE.rd_ack=hout.ch[8].PRESCALE_STAGE.req && !hout.ch[8].PRESCALE_STAGE.req_is_wr;
assign hin.ch[8].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].PRESCALE_STAGE.wr_ack=hout.ch[8].PRESCALE_STAGE.req && hout.ch[8].PRESCALE_STAGE.req_is_wr;
assign hin.ch[8].WIN_MIN_LO_STAGE.rd_ack=hout.ch[8].WIN_MIN_LO_STAGE.req && !hout.ch[8].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[8].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].WIN_MIN_LO_STAGE.wr_ack=hout.ch[8].WIN_MIN_LO_STAGE.req && hout.ch[8].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[8].WIN_MIN_HI_STAGE.rd_ack=hout.ch[8].WIN_MIN_HI_STAGE.req && !hout.ch[8].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[8].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].WIN_MIN_HI_STAGE.wr_ack=hout.ch[8].WIN_MIN_HI_STAGE.req && hout.ch[8].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[8].TIMEOUT_LO_STAGE.rd_ack=hout.ch[8].TIMEOUT_LO_STAGE.req && !hout.ch[8].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[8].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].TIMEOUT_LO_STAGE.wr_ack=hout.ch[8].TIMEOUT_LO_STAGE.req && hout.ch[8].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[8].TIMEOUT_HI_STAGE.rd_ack=hout.ch[8].TIMEOUT_HI_STAGE.req && !hout.ch[8].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[8].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].TIMEOUT_HI_STAGE.wr_ack=hout.ch[8].TIMEOUT_HI_STAGE.req && hout.ch[8].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[8].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[8].PRETIMEOUT_LO_STAGE.req && !hout.ch[8].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[8].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[8].PRETIMEOUT_LO_STAGE.req && hout.ch[8].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[8].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[8].PRETIMEOUT_HI_STAGE.req && !hout.ch[8].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[8].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[8].PRETIMEOUT_HI_STAGE.req && hout.ch[8].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[8].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[8].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[8].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[8].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[8].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[8].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[8].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[8].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[8].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[8].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[8].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[8].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[8].SEQ_LIMIT_STAGE.rd_ack=hout.ch[8].SEQ_LIMIT_STAGE.req && !hout.ch[8].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[8].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].SEQ_LIMIT_STAGE.wr_ack=hout.ch[8].SEQ_LIMIT_STAGE.req && hout.ch[8].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[8].REQUIRE_MASK_STAGE.rd_ack=hout.ch[8].REQUIRE_MASK_STAGE.req && !hout.ch[8].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[8].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].REQUIRE_MASK_STAGE.wr_ack=hout.ch[8].REQUIRE_MASK_STAGE.req && hout.ch[8].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[8].FAULT_POLICY_STAGE.rd_ack=hout.ch[8].FAULT_POLICY_STAGE.req && !hout.ch[8].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[8].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[8].FAULT_POLICY_STAGE.wr_ack=hout.ch[8].FAULT_POLICY_STAGE.req && hout.ch[8].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[8].LOCAL_DELAY_STAGE.rd_ack=hout.ch[8].LOCAL_DELAY_STAGE.req && !hout.ch[8].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[8].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].LOCAL_DELAY_STAGE.wr_ack=hout.ch[8].LOCAL_DELAY_STAGE.req && hout.ch[8].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[8].FINAL_DELAY_STAGE.rd_ack=hout.ch[8].FINAL_DELAY_STAGE.req && !hout.ch[8].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[8].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FINAL_DELAY_STAGE.wr_ack=hout.ch[8].FINAL_DELAY_STAGE.req && hout.ch[8].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[8].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[8].RECOVERY_LIMIT_STAGE.req && !hout.ch[8].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[8].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[8].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[8].RECOVERY_LIMIT_STAGE.req && hout.ch[8].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[8].UNLOCK.wr_ack=hout.ch[8].UNLOCK.req && hout.ch[8].UNLOCK.req_is_wr;
assign hin.ch[8].COMMAND.wr_ack=hout.ch[8].COMMAND.req && hout.ch[8].COMMAND.req_is_wr;
assign hin.ch[8].LOCK_SET.wr_ack=hout.ch[8].LOCK_SET.req && hout.ch[8].LOCK_SET.req_is_wr;
assign hin.ch[8].SERVICE_SELECT.rd_ack=hout.ch[8].SERVICE_SELECT.req && !hout.ch[8].SERVICE_SELECT.req_is_wr;
assign hin.ch[8].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[8].SERVICE_SELECT.wr_ack=hout.ch[8].SERVICE_SELECT.req && hout.ch[8].SERVICE_SELECT.req_is_wr;
assign hin.ch[8].SERVICE.wr_ack=hout.ch[8].SERVICE.req && hout.ch[8].SERVICE.req_is_wr;
assign hin.ch[8].IRQ_ENABLE.wr_ack=hout.ch[8].IRQ_ENABLE.req && hout.ch[8].IRQ_ENABLE.req_is_wr;
assign hin.ch[8].IRQ_CLEAR.wr_ack=hout.ch[8].IRQ_CLEAR.req && hout.ch[8].IRQ_CLEAR.req_is_wr;
assign hin.ch[8].IRQ_TEST.wr_ack=hout.ch[8].IRQ_TEST.req && hout.ch[8].IRQ_TEST.req_is_wr;
assign hin.ch[8].DIAG_CLEAR.wr_ack=hout.ch[8].DIAG_CLEAR.req && hout.ch[8].DIAG_CLEAR.req_is_wr;
assign hin.ch[8].FAULT_INJECT.wr_ack=hout.ch[8].FAULT_INJECT.req && hout.ch[8].FAULT_INJECT.req_is_wr;
assign hin.ch[8].SNAP_META.rd_ack=hout.ch[8].SNAP_META.req && !hout.ch[8].SNAP_META.req_is_wr;
assign hin.ch[8].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[8].SNAP_SEQ.rd_ack=hout.ch[8].SNAP_SEQ.req && !hout.ch[8].SNAP_SEQ.req_is_wr;
assign hin.ch[8].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].STATUS_SNAP.rd_ack=hout.ch[8].STATUS_SNAP.req && !hout.ch[8].STATUS_SNAP.req_is_wr;
assign hin.ch[8].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CFG_VERSION_SNAP.rd_ack=hout.ch[8].CFG_VERSION_SNAP.req && !hout.ch[8].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[8].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].COUNT_LO_SNAP.rd_ack=hout.ch[8].COUNT_LO_SNAP.req && !hout.ch[8].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[8].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].COUNT_HI_SNAP.rd_ack=hout.ch[8].COUNT_HI_SNAP.req && !hout.ch[8].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[8].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].EVENT_RAW_SNAP.rd_ack=hout.ch[8].EVENT_RAW_SNAP.req && !hout.ch[8].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[8].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].IRQ_ENABLE_SNAP.rd_ack=hout.ch[8].IRQ_ENABLE_SNAP.req && !hout.ch[8].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[8].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].SEEN_MASK_SNAP.rd_ack=hout.ch[8].SEEN_MASK_SNAP.req && !hout.ch[8].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[8].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].MISSING_MASK_SNAP.rd_ack=hout.ch[8].MISSING_MASK_SNAP.req && !hout.ch[8].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[8].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[8].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[8].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[8].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FAULT_COUNT_SNAP.rd_ack=hout.ch[8].FAULT_COUNT_SNAP.req && !hout.ch[8].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[8].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[8].RECOVERY_COUNT_SNAP.req && !hout.ch[8].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[8].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].ESC_AGE_SNAP.rd_ack=hout.ch[8].ESC_AGE_SNAP.req && !hout.ch[8].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[8].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_FLAGS_SNAP.rd_ack=hout.ch[8].FIRST_FLAGS_SNAP.req && !hout.ch[8].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[8].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_CAUSE_SNAP.rd_ack=hout.ch[8].FIRST_CAUSE_SNAP.req && !hout.ch[8].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[8].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[8].FIRST_COUNT_LO_SNAP.req && !hout.ch[8].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[8].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[8].FIRST_COUNT_HI_SNAP.req && !hout.ch[8].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[8].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_SOURCE_SNAP.rd_ack=hout.ch[8].FIRST_SOURCE_SNAP.req && !hout.ch[8].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[8].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[8].FIRST_CFG_VERSION_SNAP.req && !hout.ch[8].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[8].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_MISSING_SNAP.rd_ack=hout.ch[8].FIRST_MISSING_SNAP.req && !hout.ch[8].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[8].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[8].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[8].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[8].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FIRST_STATE_SNAP.rd_ack=hout.ch[8].FIRST_STATE_SNAP.req && !hout.ch[8].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[8].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[8].CTRL_ACTIVE_SNAP.req && !hout.ch[8].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[8].PRESCALE_ACTIVE_SNAP.req && !hout.ch[8].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[8].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[8].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[8].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[8].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[8].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[8].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[8].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[8].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[8].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[8].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[8].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[8].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[8].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[8].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[8].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[8].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[8].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[8].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[8].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[8].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[8].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[8].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[8].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[8].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[8].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[8].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[8].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[8].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_SELECT.rd_ack=hout.ch[8].CLIENT_SELECT.req && !hout.ch[8].CLIENT_SELECT.req_is_wr;
assign hin.ch[8].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[8].CLIENT_SELECT.wr_ack=hout.ch[8].CLIENT_SELECT.req && hout.ch[8].CLIENT_SELECT.req_is_wr;
assign hin.ch[8].CLIENT_OWNER_STAGE.rd_ack=hout.ch[8].CLIENT_OWNER_STAGE.req && !hout.ch[8].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_OWNER_STAGE.wr_ack=hout.ch[8].CLIENT_OWNER_STAGE.req && hout.ch[8].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[8].CLIENT_ALIVE_STAGE.req && !hout.ch[8].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[8].CLIENT_ALIVE_STAGE.req && hout.ch[8].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_FLOW_STAGE.rd_ack=hout.ch[8].CLIENT_FLOW_STAGE.req && !hout.ch[8].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[8].CLIENT_FLOW_STAGE.wr_ack=hout.ch[8].CLIENT_FLOW_STAGE.req && hout.ch[8].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[8].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[8].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[8].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[8].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[8].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[8].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[8].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[8].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[8].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[8].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[8].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[8].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[8].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[8].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[8].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[8].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[8].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[8].CLIENT_FLAGS_SNAP.req && !hout.ch[8].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[8].CLIENT_TOKEN_SNAP.req && !hout.ch[8].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[8].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[8].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[8].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[8].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[8].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[8].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[8].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[8].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[8].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[8].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[8].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[8].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[8].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[8].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[8].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[8].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[8].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[8].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[8].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[8].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[8].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[8].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CTRL_STAGE.rd_ack=hout.ch[9].CTRL_STAGE.req && !hout.ch[9].CTRL_STAGE.req_is_wr;
assign hin.ch[9].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[9].CTRL_STAGE.wr_ack=hout.ch[9].CTRL_STAGE.req && hout.ch[9].CTRL_STAGE.req_is_wr;
assign hin.ch[9].PRESCALE_STAGE.rd_ack=hout.ch[9].PRESCALE_STAGE.req && !hout.ch[9].PRESCALE_STAGE.req_is_wr;
assign hin.ch[9].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].PRESCALE_STAGE.wr_ack=hout.ch[9].PRESCALE_STAGE.req && hout.ch[9].PRESCALE_STAGE.req_is_wr;
assign hin.ch[9].WIN_MIN_LO_STAGE.rd_ack=hout.ch[9].WIN_MIN_LO_STAGE.req && !hout.ch[9].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[9].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].WIN_MIN_LO_STAGE.wr_ack=hout.ch[9].WIN_MIN_LO_STAGE.req && hout.ch[9].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[9].WIN_MIN_HI_STAGE.rd_ack=hout.ch[9].WIN_MIN_HI_STAGE.req && !hout.ch[9].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[9].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].WIN_MIN_HI_STAGE.wr_ack=hout.ch[9].WIN_MIN_HI_STAGE.req && hout.ch[9].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[9].TIMEOUT_LO_STAGE.rd_ack=hout.ch[9].TIMEOUT_LO_STAGE.req && !hout.ch[9].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[9].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].TIMEOUT_LO_STAGE.wr_ack=hout.ch[9].TIMEOUT_LO_STAGE.req && hout.ch[9].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[9].TIMEOUT_HI_STAGE.rd_ack=hout.ch[9].TIMEOUT_HI_STAGE.req && !hout.ch[9].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[9].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].TIMEOUT_HI_STAGE.wr_ack=hout.ch[9].TIMEOUT_HI_STAGE.req && hout.ch[9].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[9].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[9].PRETIMEOUT_LO_STAGE.req && !hout.ch[9].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[9].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[9].PRETIMEOUT_LO_STAGE.req && hout.ch[9].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[9].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[9].PRETIMEOUT_HI_STAGE.req && !hout.ch[9].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[9].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[9].PRETIMEOUT_HI_STAGE.req && hout.ch[9].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[9].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[9].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[9].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[9].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[9].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[9].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[9].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[9].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[9].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[9].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[9].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[9].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[9].SEQ_LIMIT_STAGE.rd_ack=hout.ch[9].SEQ_LIMIT_STAGE.req && !hout.ch[9].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[9].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].SEQ_LIMIT_STAGE.wr_ack=hout.ch[9].SEQ_LIMIT_STAGE.req && hout.ch[9].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[9].REQUIRE_MASK_STAGE.rd_ack=hout.ch[9].REQUIRE_MASK_STAGE.req && !hout.ch[9].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[9].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].REQUIRE_MASK_STAGE.wr_ack=hout.ch[9].REQUIRE_MASK_STAGE.req && hout.ch[9].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[9].FAULT_POLICY_STAGE.rd_ack=hout.ch[9].FAULT_POLICY_STAGE.req && !hout.ch[9].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[9].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[9].FAULT_POLICY_STAGE.wr_ack=hout.ch[9].FAULT_POLICY_STAGE.req && hout.ch[9].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[9].LOCAL_DELAY_STAGE.rd_ack=hout.ch[9].LOCAL_DELAY_STAGE.req && !hout.ch[9].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[9].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].LOCAL_DELAY_STAGE.wr_ack=hout.ch[9].LOCAL_DELAY_STAGE.req && hout.ch[9].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[9].FINAL_DELAY_STAGE.rd_ack=hout.ch[9].FINAL_DELAY_STAGE.req && !hout.ch[9].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[9].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FINAL_DELAY_STAGE.wr_ack=hout.ch[9].FINAL_DELAY_STAGE.req && hout.ch[9].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[9].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[9].RECOVERY_LIMIT_STAGE.req && !hout.ch[9].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[9].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[9].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[9].RECOVERY_LIMIT_STAGE.req && hout.ch[9].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[9].UNLOCK.wr_ack=hout.ch[9].UNLOCK.req && hout.ch[9].UNLOCK.req_is_wr;
assign hin.ch[9].COMMAND.wr_ack=hout.ch[9].COMMAND.req && hout.ch[9].COMMAND.req_is_wr;
assign hin.ch[9].LOCK_SET.wr_ack=hout.ch[9].LOCK_SET.req && hout.ch[9].LOCK_SET.req_is_wr;
assign hin.ch[9].SERVICE_SELECT.rd_ack=hout.ch[9].SERVICE_SELECT.req && !hout.ch[9].SERVICE_SELECT.req_is_wr;
assign hin.ch[9].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[9].SERVICE_SELECT.wr_ack=hout.ch[9].SERVICE_SELECT.req && hout.ch[9].SERVICE_SELECT.req_is_wr;
assign hin.ch[9].SERVICE.wr_ack=hout.ch[9].SERVICE.req && hout.ch[9].SERVICE.req_is_wr;
assign hin.ch[9].IRQ_ENABLE.wr_ack=hout.ch[9].IRQ_ENABLE.req && hout.ch[9].IRQ_ENABLE.req_is_wr;
assign hin.ch[9].IRQ_CLEAR.wr_ack=hout.ch[9].IRQ_CLEAR.req && hout.ch[9].IRQ_CLEAR.req_is_wr;
assign hin.ch[9].IRQ_TEST.wr_ack=hout.ch[9].IRQ_TEST.req && hout.ch[9].IRQ_TEST.req_is_wr;
assign hin.ch[9].DIAG_CLEAR.wr_ack=hout.ch[9].DIAG_CLEAR.req && hout.ch[9].DIAG_CLEAR.req_is_wr;
assign hin.ch[9].FAULT_INJECT.wr_ack=hout.ch[9].FAULT_INJECT.req && hout.ch[9].FAULT_INJECT.req_is_wr;
assign hin.ch[9].SNAP_META.rd_ack=hout.ch[9].SNAP_META.req && !hout.ch[9].SNAP_META.req_is_wr;
assign hin.ch[9].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[9].SNAP_SEQ.rd_ack=hout.ch[9].SNAP_SEQ.req && !hout.ch[9].SNAP_SEQ.req_is_wr;
assign hin.ch[9].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].STATUS_SNAP.rd_ack=hout.ch[9].STATUS_SNAP.req && !hout.ch[9].STATUS_SNAP.req_is_wr;
assign hin.ch[9].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CFG_VERSION_SNAP.rd_ack=hout.ch[9].CFG_VERSION_SNAP.req && !hout.ch[9].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[9].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].COUNT_LO_SNAP.rd_ack=hout.ch[9].COUNT_LO_SNAP.req && !hout.ch[9].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[9].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].COUNT_HI_SNAP.rd_ack=hout.ch[9].COUNT_HI_SNAP.req && !hout.ch[9].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[9].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].EVENT_RAW_SNAP.rd_ack=hout.ch[9].EVENT_RAW_SNAP.req && !hout.ch[9].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[9].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].IRQ_ENABLE_SNAP.rd_ack=hout.ch[9].IRQ_ENABLE_SNAP.req && !hout.ch[9].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[9].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].SEEN_MASK_SNAP.rd_ack=hout.ch[9].SEEN_MASK_SNAP.req && !hout.ch[9].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[9].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].MISSING_MASK_SNAP.rd_ack=hout.ch[9].MISSING_MASK_SNAP.req && !hout.ch[9].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[9].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[9].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[9].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[9].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FAULT_COUNT_SNAP.rd_ack=hout.ch[9].FAULT_COUNT_SNAP.req && !hout.ch[9].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[9].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[9].RECOVERY_COUNT_SNAP.req && !hout.ch[9].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[9].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].ESC_AGE_SNAP.rd_ack=hout.ch[9].ESC_AGE_SNAP.req && !hout.ch[9].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[9].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_FLAGS_SNAP.rd_ack=hout.ch[9].FIRST_FLAGS_SNAP.req && !hout.ch[9].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[9].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_CAUSE_SNAP.rd_ack=hout.ch[9].FIRST_CAUSE_SNAP.req && !hout.ch[9].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[9].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[9].FIRST_COUNT_LO_SNAP.req && !hout.ch[9].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[9].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[9].FIRST_COUNT_HI_SNAP.req && !hout.ch[9].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[9].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_SOURCE_SNAP.rd_ack=hout.ch[9].FIRST_SOURCE_SNAP.req && !hout.ch[9].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[9].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[9].FIRST_CFG_VERSION_SNAP.req && !hout.ch[9].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[9].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_MISSING_SNAP.rd_ack=hout.ch[9].FIRST_MISSING_SNAP.req && !hout.ch[9].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[9].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[9].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[9].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[9].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FIRST_STATE_SNAP.rd_ack=hout.ch[9].FIRST_STATE_SNAP.req && !hout.ch[9].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[9].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[9].CTRL_ACTIVE_SNAP.req && !hout.ch[9].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[9].PRESCALE_ACTIVE_SNAP.req && !hout.ch[9].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[9].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[9].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[9].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[9].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[9].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[9].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[9].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[9].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[9].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[9].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[9].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[9].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[9].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[9].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[9].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[9].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[9].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[9].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[9].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[9].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[9].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[9].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[9].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[9].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[9].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[9].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[9].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[9].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_SELECT.rd_ack=hout.ch[9].CLIENT_SELECT.req && !hout.ch[9].CLIENT_SELECT.req_is_wr;
assign hin.ch[9].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[9].CLIENT_SELECT.wr_ack=hout.ch[9].CLIENT_SELECT.req && hout.ch[9].CLIENT_SELECT.req_is_wr;
assign hin.ch[9].CLIENT_OWNER_STAGE.rd_ack=hout.ch[9].CLIENT_OWNER_STAGE.req && !hout.ch[9].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_OWNER_STAGE.wr_ack=hout.ch[9].CLIENT_OWNER_STAGE.req && hout.ch[9].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[9].CLIENT_ALIVE_STAGE.req && !hout.ch[9].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[9].CLIENT_ALIVE_STAGE.req && hout.ch[9].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_FLOW_STAGE.rd_ack=hout.ch[9].CLIENT_FLOW_STAGE.req && !hout.ch[9].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[9].CLIENT_FLOW_STAGE.wr_ack=hout.ch[9].CLIENT_FLOW_STAGE.req && hout.ch[9].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[9].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[9].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[9].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[9].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[9].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[9].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[9].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[9].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[9].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[9].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[9].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[9].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[9].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[9].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[9].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[9].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[9].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[9].CLIENT_FLAGS_SNAP.req && !hout.ch[9].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[9].CLIENT_TOKEN_SNAP.req && !hout.ch[9].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[9].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[9].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[9].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[9].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[9].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[9].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[9].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[9].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[9].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[9].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[9].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[9].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[9].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[9].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[9].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[9].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[9].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[9].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[9].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[9].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[9].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[9].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CTRL_STAGE.rd_ack=hout.ch[10].CTRL_STAGE.req && !hout.ch[10].CTRL_STAGE.req_is_wr;
assign hin.ch[10].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[10].CTRL_STAGE.wr_ack=hout.ch[10].CTRL_STAGE.req && hout.ch[10].CTRL_STAGE.req_is_wr;
assign hin.ch[10].PRESCALE_STAGE.rd_ack=hout.ch[10].PRESCALE_STAGE.req && !hout.ch[10].PRESCALE_STAGE.req_is_wr;
assign hin.ch[10].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].PRESCALE_STAGE.wr_ack=hout.ch[10].PRESCALE_STAGE.req && hout.ch[10].PRESCALE_STAGE.req_is_wr;
assign hin.ch[10].WIN_MIN_LO_STAGE.rd_ack=hout.ch[10].WIN_MIN_LO_STAGE.req && !hout.ch[10].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[10].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].WIN_MIN_LO_STAGE.wr_ack=hout.ch[10].WIN_MIN_LO_STAGE.req && hout.ch[10].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[10].WIN_MIN_HI_STAGE.rd_ack=hout.ch[10].WIN_MIN_HI_STAGE.req && !hout.ch[10].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[10].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].WIN_MIN_HI_STAGE.wr_ack=hout.ch[10].WIN_MIN_HI_STAGE.req && hout.ch[10].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[10].TIMEOUT_LO_STAGE.rd_ack=hout.ch[10].TIMEOUT_LO_STAGE.req && !hout.ch[10].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[10].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].TIMEOUT_LO_STAGE.wr_ack=hout.ch[10].TIMEOUT_LO_STAGE.req && hout.ch[10].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[10].TIMEOUT_HI_STAGE.rd_ack=hout.ch[10].TIMEOUT_HI_STAGE.req && !hout.ch[10].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[10].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].TIMEOUT_HI_STAGE.wr_ack=hout.ch[10].TIMEOUT_HI_STAGE.req && hout.ch[10].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[10].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[10].PRETIMEOUT_LO_STAGE.req && !hout.ch[10].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[10].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[10].PRETIMEOUT_LO_STAGE.req && hout.ch[10].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[10].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[10].PRETIMEOUT_HI_STAGE.req && !hout.ch[10].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[10].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[10].PRETIMEOUT_HI_STAGE.req && hout.ch[10].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[10].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[10].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[10].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[10].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[10].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[10].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[10].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[10].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[10].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[10].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[10].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[10].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[10].SEQ_LIMIT_STAGE.rd_ack=hout.ch[10].SEQ_LIMIT_STAGE.req && !hout.ch[10].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[10].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].SEQ_LIMIT_STAGE.wr_ack=hout.ch[10].SEQ_LIMIT_STAGE.req && hout.ch[10].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[10].REQUIRE_MASK_STAGE.rd_ack=hout.ch[10].REQUIRE_MASK_STAGE.req && !hout.ch[10].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[10].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].REQUIRE_MASK_STAGE.wr_ack=hout.ch[10].REQUIRE_MASK_STAGE.req && hout.ch[10].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[10].FAULT_POLICY_STAGE.rd_ack=hout.ch[10].FAULT_POLICY_STAGE.req && !hout.ch[10].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[10].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[10].FAULT_POLICY_STAGE.wr_ack=hout.ch[10].FAULT_POLICY_STAGE.req && hout.ch[10].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[10].LOCAL_DELAY_STAGE.rd_ack=hout.ch[10].LOCAL_DELAY_STAGE.req && !hout.ch[10].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[10].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].LOCAL_DELAY_STAGE.wr_ack=hout.ch[10].LOCAL_DELAY_STAGE.req && hout.ch[10].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[10].FINAL_DELAY_STAGE.rd_ack=hout.ch[10].FINAL_DELAY_STAGE.req && !hout.ch[10].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[10].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FINAL_DELAY_STAGE.wr_ack=hout.ch[10].FINAL_DELAY_STAGE.req && hout.ch[10].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[10].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[10].RECOVERY_LIMIT_STAGE.req && !hout.ch[10].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[10].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[10].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[10].RECOVERY_LIMIT_STAGE.req && hout.ch[10].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[10].UNLOCK.wr_ack=hout.ch[10].UNLOCK.req && hout.ch[10].UNLOCK.req_is_wr;
assign hin.ch[10].COMMAND.wr_ack=hout.ch[10].COMMAND.req && hout.ch[10].COMMAND.req_is_wr;
assign hin.ch[10].LOCK_SET.wr_ack=hout.ch[10].LOCK_SET.req && hout.ch[10].LOCK_SET.req_is_wr;
assign hin.ch[10].SERVICE_SELECT.rd_ack=hout.ch[10].SERVICE_SELECT.req && !hout.ch[10].SERVICE_SELECT.req_is_wr;
assign hin.ch[10].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[10].SERVICE_SELECT.wr_ack=hout.ch[10].SERVICE_SELECT.req && hout.ch[10].SERVICE_SELECT.req_is_wr;
assign hin.ch[10].SERVICE.wr_ack=hout.ch[10].SERVICE.req && hout.ch[10].SERVICE.req_is_wr;
assign hin.ch[10].IRQ_ENABLE.wr_ack=hout.ch[10].IRQ_ENABLE.req && hout.ch[10].IRQ_ENABLE.req_is_wr;
assign hin.ch[10].IRQ_CLEAR.wr_ack=hout.ch[10].IRQ_CLEAR.req && hout.ch[10].IRQ_CLEAR.req_is_wr;
assign hin.ch[10].IRQ_TEST.wr_ack=hout.ch[10].IRQ_TEST.req && hout.ch[10].IRQ_TEST.req_is_wr;
assign hin.ch[10].DIAG_CLEAR.wr_ack=hout.ch[10].DIAG_CLEAR.req && hout.ch[10].DIAG_CLEAR.req_is_wr;
assign hin.ch[10].FAULT_INJECT.wr_ack=hout.ch[10].FAULT_INJECT.req && hout.ch[10].FAULT_INJECT.req_is_wr;
assign hin.ch[10].SNAP_META.rd_ack=hout.ch[10].SNAP_META.req && !hout.ch[10].SNAP_META.req_is_wr;
assign hin.ch[10].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[10].SNAP_SEQ.rd_ack=hout.ch[10].SNAP_SEQ.req && !hout.ch[10].SNAP_SEQ.req_is_wr;
assign hin.ch[10].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].STATUS_SNAP.rd_ack=hout.ch[10].STATUS_SNAP.req && !hout.ch[10].STATUS_SNAP.req_is_wr;
assign hin.ch[10].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CFG_VERSION_SNAP.rd_ack=hout.ch[10].CFG_VERSION_SNAP.req && !hout.ch[10].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[10].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].COUNT_LO_SNAP.rd_ack=hout.ch[10].COUNT_LO_SNAP.req && !hout.ch[10].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[10].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].COUNT_HI_SNAP.rd_ack=hout.ch[10].COUNT_HI_SNAP.req && !hout.ch[10].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[10].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].EVENT_RAW_SNAP.rd_ack=hout.ch[10].EVENT_RAW_SNAP.req && !hout.ch[10].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[10].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].IRQ_ENABLE_SNAP.rd_ack=hout.ch[10].IRQ_ENABLE_SNAP.req && !hout.ch[10].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[10].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].SEEN_MASK_SNAP.rd_ack=hout.ch[10].SEEN_MASK_SNAP.req && !hout.ch[10].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[10].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].MISSING_MASK_SNAP.rd_ack=hout.ch[10].MISSING_MASK_SNAP.req && !hout.ch[10].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[10].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[10].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[10].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[10].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FAULT_COUNT_SNAP.rd_ack=hout.ch[10].FAULT_COUNT_SNAP.req && !hout.ch[10].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[10].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[10].RECOVERY_COUNT_SNAP.req && !hout.ch[10].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[10].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].ESC_AGE_SNAP.rd_ack=hout.ch[10].ESC_AGE_SNAP.req && !hout.ch[10].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[10].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_FLAGS_SNAP.rd_ack=hout.ch[10].FIRST_FLAGS_SNAP.req && !hout.ch[10].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[10].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_CAUSE_SNAP.rd_ack=hout.ch[10].FIRST_CAUSE_SNAP.req && !hout.ch[10].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[10].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[10].FIRST_COUNT_LO_SNAP.req && !hout.ch[10].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[10].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[10].FIRST_COUNT_HI_SNAP.req && !hout.ch[10].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[10].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_SOURCE_SNAP.rd_ack=hout.ch[10].FIRST_SOURCE_SNAP.req && !hout.ch[10].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[10].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[10].FIRST_CFG_VERSION_SNAP.req && !hout.ch[10].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[10].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_MISSING_SNAP.rd_ack=hout.ch[10].FIRST_MISSING_SNAP.req && !hout.ch[10].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[10].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[10].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[10].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[10].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FIRST_STATE_SNAP.rd_ack=hout.ch[10].FIRST_STATE_SNAP.req && !hout.ch[10].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[10].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[10].CTRL_ACTIVE_SNAP.req && !hout.ch[10].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[10].PRESCALE_ACTIVE_SNAP.req && !hout.ch[10].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[10].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[10].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[10].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[10].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[10].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[10].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[10].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[10].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[10].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[10].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[10].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[10].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[10].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[10].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[10].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[10].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[10].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[10].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[10].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[10].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[10].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[10].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[10].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[10].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[10].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[10].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[10].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[10].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_SELECT.rd_ack=hout.ch[10].CLIENT_SELECT.req && !hout.ch[10].CLIENT_SELECT.req_is_wr;
assign hin.ch[10].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[10].CLIENT_SELECT.wr_ack=hout.ch[10].CLIENT_SELECT.req && hout.ch[10].CLIENT_SELECT.req_is_wr;
assign hin.ch[10].CLIENT_OWNER_STAGE.rd_ack=hout.ch[10].CLIENT_OWNER_STAGE.req && !hout.ch[10].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_OWNER_STAGE.wr_ack=hout.ch[10].CLIENT_OWNER_STAGE.req && hout.ch[10].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[10].CLIENT_ALIVE_STAGE.req && !hout.ch[10].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[10].CLIENT_ALIVE_STAGE.req && hout.ch[10].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_FLOW_STAGE.rd_ack=hout.ch[10].CLIENT_FLOW_STAGE.req && !hout.ch[10].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[10].CLIENT_FLOW_STAGE.wr_ack=hout.ch[10].CLIENT_FLOW_STAGE.req && hout.ch[10].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[10].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[10].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[10].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[10].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[10].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[10].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[10].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[10].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[10].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[10].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[10].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[10].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[10].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[10].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[10].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[10].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[10].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[10].CLIENT_FLAGS_SNAP.req && !hout.ch[10].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[10].CLIENT_TOKEN_SNAP.req && !hout.ch[10].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[10].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[10].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[10].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[10].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[10].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[10].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[10].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[10].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[10].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[10].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[10].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[10].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[10].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[10].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[10].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[10].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[10].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[10].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[10].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[10].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[10].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[10].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CTRL_STAGE.rd_ack=hout.ch[11].CTRL_STAGE.req && !hout.ch[11].CTRL_STAGE.req_is_wr;
assign hin.ch[11].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[11].CTRL_STAGE.wr_ack=hout.ch[11].CTRL_STAGE.req && hout.ch[11].CTRL_STAGE.req_is_wr;
assign hin.ch[11].PRESCALE_STAGE.rd_ack=hout.ch[11].PRESCALE_STAGE.req && !hout.ch[11].PRESCALE_STAGE.req_is_wr;
assign hin.ch[11].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].PRESCALE_STAGE.wr_ack=hout.ch[11].PRESCALE_STAGE.req && hout.ch[11].PRESCALE_STAGE.req_is_wr;
assign hin.ch[11].WIN_MIN_LO_STAGE.rd_ack=hout.ch[11].WIN_MIN_LO_STAGE.req && !hout.ch[11].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[11].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].WIN_MIN_LO_STAGE.wr_ack=hout.ch[11].WIN_MIN_LO_STAGE.req && hout.ch[11].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[11].WIN_MIN_HI_STAGE.rd_ack=hout.ch[11].WIN_MIN_HI_STAGE.req && !hout.ch[11].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[11].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].WIN_MIN_HI_STAGE.wr_ack=hout.ch[11].WIN_MIN_HI_STAGE.req && hout.ch[11].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[11].TIMEOUT_LO_STAGE.rd_ack=hout.ch[11].TIMEOUT_LO_STAGE.req && !hout.ch[11].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[11].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].TIMEOUT_LO_STAGE.wr_ack=hout.ch[11].TIMEOUT_LO_STAGE.req && hout.ch[11].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[11].TIMEOUT_HI_STAGE.rd_ack=hout.ch[11].TIMEOUT_HI_STAGE.req && !hout.ch[11].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[11].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].TIMEOUT_HI_STAGE.wr_ack=hout.ch[11].TIMEOUT_HI_STAGE.req && hout.ch[11].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[11].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[11].PRETIMEOUT_LO_STAGE.req && !hout.ch[11].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[11].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[11].PRETIMEOUT_LO_STAGE.req && hout.ch[11].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[11].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[11].PRETIMEOUT_HI_STAGE.req && !hout.ch[11].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[11].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[11].PRETIMEOUT_HI_STAGE.req && hout.ch[11].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[11].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[11].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[11].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[11].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[11].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[11].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[11].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[11].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[11].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[11].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[11].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[11].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[11].SEQ_LIMIT_STAGE.rd_ack=hout.ch[11].SEQ_LIMIT_STAGE.req && !hout.ch[11].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[11].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].SEQ_LIMIT_STAGE.wr_ack=hout.ch[11].SEQ_LIMIT_STAGE.req && hout.ch[11].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[11].REQUIRE_MASK_STAGE.rd_ack=hout.ch[11].REQUIRE_MASK_STAGE.req && !hout.ch[11].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[11].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].REQUIRE_MASK_STAGE.wr_ack=hout.ch[11].REQUIRE_MASK_STAGE.req && hout.ch[11].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[11].FAULT_POLICY_STAGE.rd_ack=hout.ch[11].FAULT_POLICY_STAGE.req && !hout.ch[11].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[11].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[11].FAULT_POLICY_STAGE.wr_ack=hout.ch[11].FAULT_POLICY_STAGE.req && hout.ch[11].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[11].LOCAL_DELAY_STAGE.rd_ack=hout.ch[11].LOCAL_DELAY_STAGE.req && !hout.ch[11].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[11].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].LOCAL_DELAY_STAGE.wr_ack=hout.ch[11].LOCAL_DELAY_STAGE.req && hout.ch[11].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[11].FINAL_DELAY_STAGE.rd_ack=hout.ch[11].FINAL_DELAY_STAGE.req && !hout.ch[11].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[11].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FINAL_DELAY_STAGE.wr_ack=hout.ch[11].FINAL_DELAY_STAGE.req && hout.ch[11].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[11].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[11].RECOVERY_LIMIT_STAGE.req && !hout.ch[11].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[11].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[11].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[11].RECOVERY_LIMIT_STAGE.req && hout.ch[11].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[11].UNLOCK.wr_ack=hout.ch[11].UNLOCK.req && hout.ch[11].UNLOCK.req_is_wr;
assign hin.ch[11].COMMAND.wr_ack=hout.ch[11].COMMAND.req && hout.ch[11].COMMAND.req_is_wr;
assign hin.ch[11].LOCK_SET.wr_ack=hout.ch[11].LOCK_SET.req && hout.ch[11].LOCK_SET.req_is_wr;
assign hin.ch[11].SERVICE_SELECT.rd_ack=hout.ch[11].SERVICE_SELECT.req && !hout.ch[11].SERVICE_SELECT.req_is_wr;
assign hin.ch[11].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[11].SERVICE_SELECT.wr_ack=hout.ch[11].SERVICE_SELECT.req && hout.ch[11].SERVICE_SELECT.req_is_wr;
assign hin.ch[11].SERVICE.wr_ack=hout.ch[11].SERVICE.req && hout.ch[11].SERVICE.req_is_wr;
assign hin.ch[11].IRQ_ENABLE.wr_ack=hout.ch[11].IRQ_ENABLE.req && hout.ch[11].IRQ_ENABLE.req_is_wr;
assign hin.ch[11].IRQ_CLEAR.wr_ack=hout.ch[11].IRQ_CLEAR.req && hout.ch[11].IRQ_CLEAR.req_is_wr;
assign hin.ch[11].IRQ_TEST.wr_ack=hout.ch[11].IRQ_TEST.req && hout.ch[11].IRQ_TEST.req_is_wr;
assign hin.ch[11].DIAG_CLEAR.wr_ack=hout.ch[11].DIAG_CLEAR.req && hout.ch[11].DIAG_CLEAR.req_is_wr;
assign hin.ch[11].FAULT_INJECT.wr_ack=hout.ch[11].FAULT_INJECT.req && hout.ch[11].FAULT_INJECT.req_is_wr;
assign hin.ch[11].SNAP_META.rd_ack=hout.ch[11].SNAP_META.req && !hout.ch[11].SNAP_META.req_is_wr;
assign hin.ch[11].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[11].SNAP_SEQ.rd_ack=hout.ch[11].SNAP_SEQ.req && !hout.ch[11].SNAP_SEQ.req_is_wr;
assign hin.ch[11].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].STATUS_SNAP.rd_ack=hout.ch[11].STATUS_SNAP.req && !hout.ch[11].STATUS_SNAP.req_is_wr;
assign hin.ch[11].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CFG_VERSION_SNAP.rd_ack=hout.ch[11].CFG_VERSION_SNAP.req && !hout.ch[11].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[11].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].COUNT_LO_SNAP.rd_ack=hout.ch[11].COUNT_LO_SNAP.req && !hout.ch[11].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[11].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].COUNT_HI_SNAP.rd_ack=hout.ch[11].COUNT_HI_SNAP.req && !hout.ch[11].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[11].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].EVENT_RAW_SNAP.rd_ack=hout.ch[11].EVENT_RAW_SNAP.req && !hout.ch[11].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[11].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].IRQ_ENABLE_SNAP.rd_ack=hout.ch[11].IRQ_ENABLE_SNAP.req && !hout.ch[11].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[11].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].SEEN_MASK_SNAP.rd_ack=hout.ch[11].SEEN_MASK_SNAP.req && !hout.ch[11].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[11].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].MISSING_MASK_SNAP.rd_ack=hout.ch[11].MISSING_MASK_SNAP.req && !hout.ch[11].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[11].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[11].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[11].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[11].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FAULT_COUNT_SNAP.rd_ack=hout.ch[11].FAULT_COUNT_SNAP.req && !hout.ch[11].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[11].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[11].RECOVERY_COUNT_SNAP.req && !hout.ch[11].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[11].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].ESC_AGE_SNAP.rd_ack=hout.ch[11].ESC_AGE_SNAP.req && !hout.ch[11].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[11].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_FLAGS_SNAP.rd_ack=hout.ch[11].FIRST_FLAGS_SNAP.req && !hout.ch[11].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[11].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_CAUSE_SNAP.rd_ack=hout.ch[11].FIRST_CAUSE_SNAP.req && !hout.ch[11].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[11].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[11].FIRST_COUNT_LO_SNAP.req && !hout.ch[11].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[11].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[11].FIRST_COUNT_HI_SNAP.req && !hout.ch[11].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[11].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_SOURCE_SNAP.rd_ack=hout.ch[11].FIRST_SOURCE_SNAP.req && !hout.ch[11].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[11].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[11].FIRST_CFG_VERSION_SNAP.req && !hout.ch[11].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[11].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_MISSING_SNAP.rd_ack=hout.ch[11].FIRST_MISSING_SNAP.req && !hout.ch[11].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[11].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[11].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[11].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[11].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FIRST_STATE_SNAP.rd_ack=hout.ch[11].FIRST_STATE_SNAP.req && !hout.ch[11].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[11].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[11].CTRL_ACTIVE_SNAP.req && !hout.ch[11].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[11].PRESCALE_ACTIVE_SNAP.req && !hout.ch[11].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[11].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[11].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[11].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[11].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[11].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[11].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[11].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[11].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[11].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[11].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[11].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[11].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[11].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[11].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[11].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[11].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[11].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[11].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[11].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[11].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[11].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[11].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[11].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[11].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[11].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[11].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[11].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[11].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_SELECT.rd_ack=hout.ch[11].CLIENT_SELECT.req && !hout.ch[11].CLIENT_SELECT.req_is_wr;
assign hin.ch[11].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[11].CLIENT_SELECT.wr_ack=hout.ch[11].CLIENT_SELECT.req && hout.ch[11].CLIENT_SELECT.req_is_wr;
assign hin.ch[11].CLIENT_OWNER_STAGE.rd_ack=hout.ch[11].CLIENT_OWNER_STAGE.req && !hout.ch[11].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_OWNER_STAGE.wr_ack=hout.ch[11].CLIENT_OWNER_STAGE.req && hout.ch[11].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[11].CLIENT_ALIVE_STAGE.req && !hout.ch[11].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[11].CLIENT_ALIVE_STAGE.req && hout.ch[11].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_FLOW_STAGE.rd_ack=hout.ch[11].CLIENT_FLOW_STAGE.req && !hout.ch[11].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[11].CLIENT_FLOW_STAGE.wr_ack=hout.ch[11].CLIENT_FLOW_STAGE.req && hout.ch[11].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[11].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[11].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[11].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[11].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[11].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[11].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[11].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[11].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[11].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[11].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[11].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[11].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[11].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[11].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[11].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[11].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[11].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[11].CLIENT_FLAGS_SNAP.req && !hout.ch[11].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[11].CLIENT_TOKEN_SNAP.req && !hout.ch[11].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[11].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[11].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[11].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[11].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[11].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[11].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[11].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[11].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[11].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[11].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[11].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[11].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[11].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[11].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[11].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[11].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[11].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[11].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[11].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[11].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[11].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[11].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CTRL_STAGE.rd_ack=hout.ch[12].CTRL_STAGE.req && !hout.ch[12].CTRL_STAGE.req_is_wr;
assign hin.ch[12].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[12].CTRL_STAGE.wr_ack=hout.ch[12].CTRL_STAGE.req && hout.ch[12].CTRL_STAGE.req_is_wr;
assign hin.ch[12].PRESCALE_STAGE.rd_ack=hout.ch[12].PRESCALE_STAGE.req && !hout.ch[12].PRESCALE_STAGE.req_is_wr;
assign hin.ch[12].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].PRESCALE_STAGE.wr_ack=hout.ch[12].PRESCALE_STAGE.req && hout.ch[12].PRESCALE_STAGE.req_is_wr;
assign hin.ch[12].WIN_MIN_LO_STAGE.rd_ack=hout.ch[12].WIN_MIN_LO_STAGE.req && !hout.ch[12].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[12].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].WIN_MIN_LO_STAGE.wr_ack=hout.ch[12].WIN_MIN_LO_STAGE.req && hout.ch[12].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[12].WIN_MIN_HI_STAGE.rd_ack=hout.ch[12].WIN_MIN_HI_STAGE.req && !hout.ch[12].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[12].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].WIN_MIN_HI_STAGE.wr_ack=hout.ch[12].WIN_MIN_HI_STAGE.req && hout.ch[12].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[12].TIMEOUT_LO_STAGE.rd_ack=hout.ch[12].TIMEOUT_LO_STAGE.req && !hout.ch[12].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[12].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].TIMEOUT_LO_STAGE.wr_ack=hout.ch[12].TIMEOUT_LO_STAGE.req && hout.ch[12].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[12].TIMEOUT_HI_STAGE.rd_ack=hout.ch[12].TIMEOUT_HI_STAGE.req && !hout.ch[12].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[12].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].TIMEOUT_HI_STAGE.wr_ack=hout.ch[12].TIMEOUT_HI_STAGE.req && hout.ch[12].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[12].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[12].PRETIMEOUT_LO_STAGE.req && !hout.ch[12].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[12].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[12].PRETIMEOUT_LO_STAGE.req && hout.ch[12].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[12].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[12].PRETIMEOUT_HI_STAGE.req && !hout.ch[12].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[12].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[12].PRETIMEOUT_HI_STAGE.req && hout.ch[12].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[12].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[12].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[12].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[12].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[12].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[12].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[12].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[12].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[12].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[12].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[12].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[12].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[12].SEQ_LIMIT_STAGE.rd_ack=hout.ch[12].SEQ_LIMIT_STAGE.req && !hout.ch[12].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[12].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].SEQ_LIMIT_STAGE.wr_ack=hout.ch[12].SEQ_LIMIT_STAGE.req && hout.ch[12].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[12].REQUIRE_MASK_STAGE.rd_ack=hout.ch[12].REQUIRE_MASK_STAGE.req && !hout.ch[12].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[12].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].REQUIRE_MASK_STAGE.wr_ack=hout.ch[12].REQUIRE_MASK_STAGE.req && hout.ch[12].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[12].FAULT_POLICY_STAGE.rd_ack=hout.ch[12].FAULT_POLICY_STAGE.req && !hout.ch[12].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[12].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[12].FAULT_POLICY_STAGE.wr_ack=hout.ch[12].FAULT_POLICY_STAGE.req && hout.ch[12].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[12].LOCAL_DELAY_STAGE.rd_ack=hout.ch[12].LOCAL_DELAY_STAGE.req && !hout.ch[12].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[12].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].LOCAL_DELAY_STAGE.wr_ack=hout.ch[12].LOCAL_DELAY_STAGE.req && hout.ch[12].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[12].FINAL_DELAY_STAGE.rd_ack=hout.ch[12].FINAL_DELAY_STAGE.req && !hout.ch[12].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[12].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FINAL_DELAY_STAGE.wr_ack=hout.ch[12].FINAL_DELAY_STAGE.req && hout.ch[12].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[12].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[12].RECOVERY_LIMIT_STAGE.req && !hout.ch[12].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[12].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[12].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[12].RECOVERY_LIMIT_STAGE.req && hout.ch[12].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[12].UNLOCK.wr_ack=hout.ch[12].UNLOCK.req && hout.ch[12].UNLOCK.req_is_wr;
assign hin.ch[12].COMMAND.wr_ack=hout.ch[12].COMMAND.req && hout.ch[12].COMMAND.req_is_wr;
assign hin.ch[12].LOCK_SET.wr_ack=hout.ch[12].LOCK_SET.req && hout.ch[12].LOCK_SET.req_is_wr;
assign hin.ch[12].SERVICE_SELECT.rd_ack=hout.ch[12].SERVICE_SELECT.req && !hout.ch[12].SERVICE_SELECT.req_is_wr;
assign hin.ch[12].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[12].SERVICE_SELECT.wr_ack=hout.ch[12].SERVICE_SELECT.req && hout.ch[12].SERVICE_SELECT.req_is_wr;
assign hin.ch[12].SERVICE.wr_ack=hout.ch[12].SERVICE.req && hout.ch[12].SERVICE.req_is_wr;
assign hin.ch[12].IRQ_ENABLE.wr_ack=hout.ch[12].IRQ_ENABLE.req && hout.ch[12].IRQ_ENABLE.req_is_wr;
assign hin.ch[12].IRQ_CLEAR.wr_ack=hout.ch[12].IRQ_CLEAR.req && hout.ch[12].IRQ_CLEAR.req_is_wr;
assign hin.ch[12].IRQ_TEST.wr_ack=hout.ch[12].IRQ_TEST.req && hout.ch[12].IRQ_TEST.req_is_wr;
assign hin.ch[12].DIAG_CLEAR.wr_ack=hout.ch[12].DIAG_CLEAR.req && hout.ch[12].DIAG_CLEAR.req_is_wr;
assign hin.ch[12].FAULT_INJECT.wr_ack=hout.ch[12].FAULT_INJECT.req && hout.ch[12].FAULT_INJECT.req_is_wr;
assign hin.ch[12].SNAP_META.rd_ack=hout.ch[12].SNAP_META.req && !hout.ch[12].SNAP_META.req_is_wr;
assign hin.ch[12].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[12].SNAP_SEQ.rd_ack=hout.ch[12].SNAP_SEQ.req && !hout.ch[12].SNAP_SEQ.req_is_wr;
assign hin.ch[12].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].STATUS_SNAP.rd_ack=hout.ch[12].STATUS_SNAP.req && !hout.ch[12].STATUS_SNAP.req_is_wr;
assign hin.ch[12].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CFG_VERSION_SNAP.rd_ack=hout.ch[12].CFG_VERSION_SNAP.req && !hout.ch[12].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[12].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].COUNT_LO_SNAP.rd_ack=hout.ch[12].COUNT_LO_SNAP.req && !hout.ch[12].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[12].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].COUNT_HI_SNAP.rd_ack=hout.ch[12].COUNT_HI_SNAP.req && !hout.ch[12].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[12].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].EVENT_RAW_SNAP.rd_ack=hout.ch[12].EVENT_RAW_SNAP.req && !hout.ch[12].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[12].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].IRQ_ENABLE_SNAP.rd_ack=hout.ch[12].IRQ_ENABLE_SNAP.req && !hout.ch[12].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[12].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].SEEN_MASK_SNAP.rd_ack=hout.ch[12].SEEN_MASK_SNAP.req && !hout.ch[12].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[12].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].MISSING_MASK_SNAP.rd_ack=hout.ch[12].MISSING_MASK_SNAP.req && !hout.ch[12].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[12].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[12].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[12].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[12].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FAULT_COUNT_SNAP.rd_ack=hout.ch[12].FAULT_COUNT_SNAP.req && !hout.ch[12].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[12].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[12].RECOVERY_COUNT_SNAP.req && !hout.ch[12].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[12].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].ESC_AGE_SNAP.rd_ack=hout.ch[12].ESC_AGE_SNAP.req && !hout.ch[12].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[12].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_FLAGS_SNAP.rd_ack=hout.ch[12].FIRST_FLAGS_SNAP.req && !hout.ch[12].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[12].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_CAUSE_SNAP.rd_ack=hout.ch[12].FIRST_CAUSE_SNAP.req && !hout.ch[12].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[12].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[12].FIRST_COUNT_LO_SNAP.req && !hout.ch[12].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[12].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[12].FIRST_COUNT_HI_SNAP.req && !hout.ch[12].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[12].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_SOURCE_SNAP.rd_ack=hout.ch[12].FIRST_SOURCE_SNAP.req && !hout.ch[12].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[12].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[12].FIRST_CFG_VERSION_SNAP.req && !hout.ch[12].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[12].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_MISSING_SNAP.rd_ack=hout.ch[12].FIRST_MISSING_SNAP.req && !hout.ch[12].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[12].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[12].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[12].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[12].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FIRST_STATE_SNAP.rd_ack=hout.ch[12].FIRST_STATE_SNAP.req && !hout.ch[12].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[12].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[12].CTRL_ACTIVE_SNAP.req && !hout.ch[12].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[12].PRESCALE_ACTIVE_SNAP.req && !hout.ch[12].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[12].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[12].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[12].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[12].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[12].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[12].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[12].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[12].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[12].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[12].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[12].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[12].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[12].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[12].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[12].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[12].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[12].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[12].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[12].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[12].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[12].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[12].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[12].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[12].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[12].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[12].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[12].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[12].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_SELECT.rd_ack=hout.ch[12].CLIENT_SELECT.req && !hout.ch[12].CLIENT_SELECT.req_is_wr;
assign hin.ch[12].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[12].CLIENT_SELECT.wr_ack=hout.ch[12].CLIENT_SELECT.req && hout.ch[12].CLIENT_SELECT.req_is_wr;
assign hin.ch[12].CLIENT_OWNER_STAGE.rd_ack=hout.ch[12].CLIENT_OWNER_STAGE.req && !hout.ch[12].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_OWNER_STAGE.wr_ack=hout.ch[12].CLIENT_OWNER_STAGE.req && hout.ch[12].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[12].CLIENT_ALIVE_STAGE.req && !hout.ch[12].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[12].CLIENT_ALIVE_STAGE.req && hout.ch[12].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_FLOW_STAGE.rd_ack=hout.ch[12].CLIENT_FLOW_STAGE.req && !hout.ch[12].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[12].CLIENT_FLOW_STAGE.wr_ack=hout.ch[12].CLIENT_FLOW_STAGE.req && hout.ch[12].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[12].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[12].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[12].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[12].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[12].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[12].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[12].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[12].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[12].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[12].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[12].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[12].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[12].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[12].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[12].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[12].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[12].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[12].CLIENT_FLAGS_SNAP.req && !hout.ch[12].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[12].CLIENT_TOKEN_SNAP.req && !hout.ch[12].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[12].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[12].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[12].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[12].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[12].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[12].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[12].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[12].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[12].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[12].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[12].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[12].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[12].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[12].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[12].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[12].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[12].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[12].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[12].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[12].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[12].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[12].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CTRL_STAGE.rd_ack=hout.ch[13].CTRL_STAGE.req && !hout.ch[13].CTRL_STAGE.req_is_wr;
assign hin.ch[13].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[13].CTRL_STAGE.wr_ack=hout.ch[13].CTRL_STAGE.req && hout.ch[13].CTRL_STAGE.req_is_wr;
assign hin.ch[13].PRESCALE_STAGE.rd_ack=hout.ch[13].PRESCALE_STAGE.req && !hout.ch[13].PRESCALE_STAGE.req_is_wr;
assign hin.ch[13].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].PRESCALE_STAGE.wr_ack=hout.ch[13].PRESCALE_STAGE.req && hout.ch[13].PRESCALE_STAGE.req_is_wr;
assign hin.ch[13].WIN_MIN_LO_STAGE.rd_ack=hout.ch[13].WIN_MIN_LO_STAGE.req && !hout.ch[13].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[13].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].WIN_MIN_LO_STAGE.wr_ack=hout.ch[13].WIN_MIN_LO_STAGE.req && hout.ch[13].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[13].WIN_MIN_HI_STAGE.rd_ack=hout.ch[13].WIN_MIN_HI_STAGE.req && !hout.ch[13].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[13].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].WIN_MIN_HI_STAGE.wr_ack=hout.ch[13].WIN_MIN_HI_STAGE.req && hout.ch[13].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[13].TIMEOUT_LO_STAGE.rd_ack=hout.ch[13].TIMEOUT_LO_STAGE.req && !hout.ch[13].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[13].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].TIMEOUT_LO_STAGE.wr_ack=hout.ch[13].TIMEOUT_LO_STAGE.req && hout.ch[13].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[13].TIMEOUT_HI_STAGE.rd_ack=hout.ch[13].TIMEOUT_HI_STAGE.req && !hout.ch[13].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[13].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].TIMEOUT_HI_STAGE.wr_ack=hout.ch[13].TIMEOUT_HI_STAGE.req && hout.ch[13].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[13].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[13].PRETIMEOUT_LO_STAGE.req && !hout.ch[13].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[13].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[13].PRETIMEOUT_LO_STAGE.req && hout.ch[13].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[13].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[13].PRETIMEOUT_HI_STAGE.req && !hout.ch[13].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[13].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[13].PRETIMEOUT_HI_STAGE.req && hout.ch[13].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[13].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[13].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[13].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[13].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[13].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[13].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[13].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[13].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[13].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[13].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[13].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[13].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[13].SEQ_LIMIT_STAGE.rd_ack=hout.ch[13].SEQ_LIMIT_STAGE.req && !hout.ch[13].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[13].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].SEQ_LIMIT_STAGE.wr_ack=hout.ch[13].SEQ_LIMIT_STAGE.req && hout.ch[13].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[13].REQUIRE_MASK_STAGE.rd_ack=hout.ch[13].REQUIRE_MASK_STAGE.req && !hout.ch[13].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[13].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].REQUIRE_MASK_STAGE.wr_ack=hout.ch[13].REQUIRE_MASK_STAGE.req && hout.ch[13].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[13].FAULT_POLICY_STAGE.rd_ack=hout.ch[13].FAULT_POLICY_STAGE.req && !hout.ch[13].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[13].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[13].FAULT_POLICY_STAGE.wr_ack=hout.ch[13].FAULT_POLICY_STAGE.req && hout.ch[13].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[13].LOCAL_DELAY_STAGE.rd_ack=hout.ch[13].LOCAL_DELAY_STAGE.req && !hout.ch[13].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[13].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].LOCAL_DELAY_STAGE.wr_ack=hout.ch[13].LOCAL_DELAY_STAGE.req && hout.ch[13].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[13].FINAL_DELAY_STAGE.rd_ack=hout.ch[13].FINAL_DELAY_STAGE.req && !hout.ch[13].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[13].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FINAL_DELAY_STAGE.wr_ack=hout.ch[13].FINAL_DELAY_STAGE.req && hout.ch[13].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[13].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[13].RECOVERY_LIMIT_STAGE.req && !hout.ch[13].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[13].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[13].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[13].RECOVERY_LIMIT_STAGE.req && hout.ch[13].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[13].UNLOCK.wr_ack=hout.ch[13].UNLOCK.req && hout.ch[13].UNLOCK.req_is_wr;
assign hin.ch[13].COMMAND.wr_ack=hout.ch[13].COMMAND.req && hout.ch[13].COMMAND.req_is_wr;
assign hin.ch[13].LOCK_SET.wr_ack=hout.ch[13].LOCK_SET.req && hout.ch[13].LOCK_SET.req_is_wr;
assign hin.ch[13].SERVICE_SELECT.rd_ack=hout.ch[13].SERVICE_SELECT.req && !hout.ch[13].SERVICE_SELECT.req_is_wr;
assign hin.ch[13].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[13].SERVICE_SELECT.wr_ack=hout.ch[13].SERVICE_SELECT.req && hout.ch[13].SERVICE_SELECT.req_is_wr;
assign hin.ch[13].SERVICE.wr_ack=hout.ch[13].SERVICE.req && hout.ch[13].SERVICE.req_is_wr;
assign hin.ch[13].IRQ_ENABLE.wr_ack=hout.ch[13].IRQ_ENABLE.req && hout.ch[13].IRQ_ENABLE.req_is_wr;
assign hin.ch[13].IRQ_CLEAR.wr_ack=hout.ch[13].IRQ_CLEAR.req && hout.ch[13].IRQ_CLEAR.req_is_wr;
assign hin.ch[13].IRQ_TEST.wr_ack=hout.ch[13].IRQ_TEST.req && hout.ch[13].IRQ_TEST.req_is_wr;
assign hin.ch[13].DIAG_CLEAR.wr_ack=hout.ch[13].DIAG_CLEAR.req && hout.ch[13].DIAG_CLEAR.req_is_wr;
assign hin.ch[13].FAULT_INJECT.wr_ack=hout.ch[13].FAULT_INJECT.req && hout.ch[13].FAULT_INJECT.req_is_wr;
assign hin.ch[13].SNAP_META.rd_ack=hout.ch[13].SNAP_META.req && !hout.ch[13].SNAP_META.req_is_wr;
assign hin.ch[13].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[13].SNAP_SEQ.rd_ack=hout.ch[13].SNAP_SEQ.req && !hout.ch[13].SNAP_SEQ.req_is_wr;
assign hin.ch[13].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].STATUS_SNAP.rd_ack=hout.ch[13].STATUS_SNAP.req && !hout.ch[13].STATUS_SNAP.req_is_wr;
assign hin.ch[13].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CFG_VERSION_SNAP.rd_ack=hout.ch[13].CFG_VERSION_SNAP.req && !hout.ch[13].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[13].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].COUNT_LO_SNAP.rd_ack=hout.ch[13].COUNT_LO_SNAP.req && !hout.ch[13].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[13].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].COUNT_HI_SNAP.rd_ack=hout.ch[13].COUNT_HI_SNAP.req && !hout.ch[13].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[13].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].EVENT_RAW_SNAP.rd_ack=hout.ch[13].EVENT_RAW_SNAP.req && !hout.ch[13].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[13].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].IRQ_ENABLE_SNAP.rd_ack=hout.ch[13].IRQ_ENABLE_SNAP.req && !hout.ch[13].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[13].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].SEEN_MASK_SNAP.rd_ack=hout.ch[13].SEEN_MASK_SNAP.req && !hout.ch[13].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[13].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].MISSING_MASK_SNAP.rd_ack=hout.ch[13].MISSING_MASK_SNAP.req && !hout.ch[13].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[13].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[13].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[13].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[13].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FAULT_COUNT_SNAP.rd_ack=hout.ch[13].FAULT_COUNT_SNAP.req && !hout.ch[13].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[13].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[13].RECOVERY_COUNT_SNAP.req && !hout.ch[13].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[13].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].ESC_AGE_SNAP.rd_ack=hout.ch[13].ESC_AGE_SNAP.req && !hout.ch[13].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[13].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_FLAGS_SNAP.rd_ack=hout.ch[13].FIRST_FLAGS_SNAP.req && !hout.ch[13].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[13].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_CAUSE_SNAP.rd_ack=hout.ch[13].FIRST_CAUSE_SNAP.req && !hout.ch[13].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[13].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[13].FIRST_COUNT_LO_SNAP.req && !hout.ch[13].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[13].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[13].FIRST_COUNT_HI_SNAP.req && !hout.ch[13].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[13].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_SOURCE_SNAP.rd_ack=hout.ch[13].FIRST_SOURCE_SNAP.req && !hout.ch[13].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[13].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[13].FIRST_CFG_VERSION_SNAP.req && !hout.ch[13].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[13].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_MISSING_SNAP.rd_ack=hout.ch[13].FIRST_MISSING_SNAP.req && !hout.ch[13].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[13].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[13].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[13].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[13].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FIRST_STATE_SNAP.rd_ack=hout.ch[13].FIRST_STATE_SNAP.req && !hout.ch[13].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[13].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[13].CTRL_ACTIVE_SNAP.req && !hout.ch[13].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[13].PRESCALE_ACTIVE_SNAP.req && !hout.ch[13].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[13].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[13].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[13].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[13].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[13].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[13].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[13].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[13].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[13].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[13].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[13].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[13].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[13].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[13].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[13].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[13].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[13].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[13].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[13].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[13].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[13].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[13].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[13].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[13].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[13].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[13].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[13].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[13].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_SELECT.rd_ack=hout.ch[13].CLIENT_SELECT.req && !hout.ch[13].CLIENT_SELECT.req_is_wr;
assign hin.ch[13].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[13].CLIENT_SELECT.wr_ack=hout.ch[13].CLIENT_SELECT.req && hout.ch[13].CLIENT_SELECT.req_is_wr;
assign hin.ch[13].CLIENT_OWNER_STAGE.rd_ack=hout.ch[13].CLIENT_OWNER_STAGE.req && !hout.ch[13].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_OWNER_STAGE.wr_ack=hout.ch[13].CLIENT_OWNER_STAGE.req && hout.ch[13].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[13].CLIENT_ALIVE_STAGE.req && !hout.ch[13].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[13].CLIENT_ALIVE_STAGE.req && hout.ch[13].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_FLOW_STAGE.rd_ack=hout.ch[13].CLIENT_FLOW_STAGE.req && !hout.ch[13].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[13].CLIENT_FLOW_STAGE.wr_ack=hout.ch[13].CLIENT_FLOW_STAGE.req && hout.ch[13].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[13].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[13].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[13].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[13].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[13].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[13].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[13].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[13].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[13].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[13].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[13].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[13].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[13].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[13].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[13].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[13].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[13].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[13].CLIENT_FLAGS_SNAP.req && !hout.ch[13].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[13].CLIENT_TOKEN_SNAP.req && !hout.ch[13].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[13].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[13].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[13].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[13].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[13].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[13].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[13].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[13].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[13].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[13].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[13].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[13].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[13].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[13].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[13].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[13].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[13].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[13].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[13].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[13].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[13].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[13].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CTRL_STAGE.rd_ack=hout.ch[14].CTRL_STAGE.req && !hout.ch[14].CTRL_STAGE.req_is_wr;
assign hin.ch[14].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[14].CTRL_STAGE.wr_ack=hout.ch[14].CTRL_STAGE.req && hout.ch[14].CTRL_STAGE.req_is_wr;
assign hin.ch[14].PRESCALE_STAGE.rd_ack=hout.ch[14].PRESCALE_STAGE.req && !hout.ch[14].PRESCALE_STAGE.req_is_wr;
assign hin.ch[14].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].PRESCALE_STAGE.wr_ack=hout.ch[14].PRESCALE_STAGE.req && hout.ch[14].PRESCALE_STAGE.req_is_wr;
assign hin.ch[14].WIN_MIN_LO_STAGE.rd_ack=hout.ch[14].WIN_MIN_LO_STAGE.req && !hout.ch[14].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[14].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].WIN_MIN_LO_STAGE.wr_ack=hout.ch[14].WIN_MIN_LO_STAGE.req && hout.ch[14].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[14].WIN_MIN_HI_STAGE.rd_ack=hout.ch[14].WIN_MIN_HI_STAGE.req && !hout.ch[14].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[14].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].WIN_MIN_HI_STAGE.wr_ack=hout.ch[14].WIN_MIN_HI_STAGE.req && hout.ch[14].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[14].TIMEOUT_LO_STAGE.rd_ack=hout.ch[14].TIMEOUT_LO_STAGE.req && !hout.ch[14].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[14].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].TIMEOUT_LO_STAGE.wr_ack=hout.ch[14].TIMEOUT_LO_STAGE.req && hout.ch[14].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[14].TIMEOUT_HI_STAGE.rd_ack=hout.ch[14].TIMEOUT_HI_STAGE.req && !hout.ch[14].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[14].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].TIMEOUT_HI_STAGE.wr_ack=hout.ch[14].TIMEOUT_HI_STAGE.req && hout.ch[14].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[14].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[14].PRETIMEOUT_LO_STAGE.req && !hout.ch[14].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[14].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[14].PRETIMEOUT_LO_STAGE.req && hout.ch[14].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[14].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[14].PRETIMEOUT_HI_STAGE.req && !hout.ch[14].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[14].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[14].PRETIMEOUT_HI_STAGE.req && hout.ch[14].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[14].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[14].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[14].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[14].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[14].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[14].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[14].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[14].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[14].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[14].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[14].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[14].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[14].SEQ_LIMIT_STAGE.rd_ack=hout.ch[14].SEQ_LIMIT_STAGE.req && !hout.ch[14].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[14].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].SEQ_LIMIT_STAGE.wr_ack=hout.ch[14].SEQ_LIMIT_STAGE.req && hout.ch[14].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[14].REQUIRE_MASK_STAGE.rd_ack=hout.ch[14].REQUIRE_MASK_STAGE.req && !hout.ch[14].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[14].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].REQUIRE_MASK_STAGE.wr_ack=hout.ch[14].REQUIRE_MASK_STAGE.req && hout.ch[14].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[14].FAULT_POLICY_STAGE.rd_ack=hout.ch[14].FAULT_POLICY_STAGE.req && !hout.ch[14].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[14].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[14].FAULT_POLICY_STAGE.wr_ack=hout.ch[14].FAULT_POLICY_STAGE.req && hout.ch[14].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[14].LOCAL_DELAY_STAGE.rd_ack=hout.ch[14].LOCAL_DELAY_STAGE.req && !hout.ch[14].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[14].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].LOCAL_DELAY_STAGE.wr_ack=hout.ch[14].LOCAL_DELAY_STAGE.req && hout.ch[14].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[14].FINAL_DELAY_STAGE.rd_ack=hout.ch[14].FINAL_DELAY_STAGE.req && !hout.ch[14].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[14].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FINAL_DELAY_STAGE.wr_ack=hout.ch[14].FINAL_DELAY_STAGE.req && hout.ch[14].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[14].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[14].RECOVERY_LIMIT_STAGE.req && !hout.ch[14].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[14].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[14].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[14].RECOVERY_LIMIT_STAGE.req && hout.ch[14].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[14].UNLOCK.wr_ack=hout.ch[14].UNLOCK.req && hout.ch[14].UNLOCK.req_is_wr;
assign hin.ch[14].COMMAND.wr_ack=hout.ch[14].COMMAND.req && hout.ch[14].COMMAND.req_is_wr;
assign hin.ch[14].LOCK_SET.wr_ack=hout.ch[14].LOCK_SET.req && hout.ch[14].LOCK_SET.req_is_wr;
assign hin.ch[14].SERVICE_SELECT.rd_ack=hout.ch[14].SERVICE_SELECT.req && !hout.ch[14].SERVICE_SELECT.req_is_wr;
assign hin.ch[14].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[14].SERVICE_SELECT.wr_ack=hout.ch[14].SERVICE_SELECT.req && hout.ch[14].SERVICE_SELECT.req_is_wr;
assign hin.ch[14].SERVICE.wr_ack=hout.ch[14].SERVICE.req && hout.ch[14].SERVICE.req_is_wr;
assign hin.ch[14].IRQ_ENABLE.wr_ack=hout.ch[14].IRQ_ENABLE.req && hout.ch[14].IRQ_ENABLE.req_is_wr;
assign hin.ch[14].IRQ_CLEAR.wr_ack=hout.ch[14].IRQ_CLEAR.req && hout.ch[14].IRQ_CLEAR.req_is_wr;
assign hin.ch[14].IRQ_TEST.wr_ack=hout.ch[14].IRQ_TEST.req && hout.ch[14].IRQ_TEST.req_is_wr;
assign hin.ch[14].DIAG_CLEAR.wr_ack=hout.ch[14].DIAG_CLEAR.req && hout.ch[14].DIAG_CLEAR.req_is_wr;
assign hin.ch[14].FAULT_INJECT.wr_ack=hout.ch[14].FAULT_INJECT.req && hout.ch[14].FAULT_INJECT.req_is_wr;
assign hin.ch[14].SNAP_META.rd_ack=hout.ch[14].SNAP_META.req && !hout.ch[14].SNAP_META.req_is_wr;
assign hin.ch[14].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[14].SNAP_SEQ.rd_ack=hout.ch[14].SNAP_SEQ.req && !hout.ch[14].SNAP_SEQ.req_is_wr;
assign hin.ch[14].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].STATUS_SNAP.rd_ack=hout.ch[14].STATUS_SNAP.req && !hout.ch[14].STATUS_SNAP.req_is_wr;
assign hin.ch[14].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CFG_VERSION_SNAP.rd_ack=hout.ch[14].CFG_VERSION_SNAP.req && !hout.ch[14].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[14].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].COUNT_LO_SNAP.rd_ack=hout.ch[14].COUNT_LO_SNAP.req && !hout.ch[14].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[14].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].COUNT_HI_SNAP.rd_ack=hout.ch[14].COUNT_HI_SNAP.req && !hout.ch[14].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[14].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].EVENT_RAW_SNAP.rd_ack=hout.ch[14].EVENT_RAW_SNAP.req && !hout.ch[14].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[14].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].IRQ_ENABLE_SNAP.rd_ack=hout.ch[14].IRQ_ENABLE_SNAP.req && !hout.ch[14].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[14].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].SEEN_MASK_SNAP.rd_ack=hout.ch[14].SEEN_MASK_SNAP.req && !hout.ch[14].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[14].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].MISSING_MASK_SNAP.rd_ack=hout.ch[14].MISSING_MASK_SNAP.req && !hout.ch[14].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[14].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[14].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[14].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[14].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FAULT_COUNT_SNAP.rd_ack=hout.ch[14].FAULT_COUNT_SNAP.req && !hout.ch[14].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[14].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[14].RECOVERY_COUNT_SNAP.req && !hout.ch[14].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[14].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].ESC_AGE_SNAP.rd_ack=hout.ch[14].ESC_AGE_SNAP.req && !hout.ch[14].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[14].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_FLAGS_SNAP.rd_ack=hout.ch[14].FIRST_FLAGS_SNAP.req && !hout.ch[14].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[14].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_CAUSE_SNAP.rd_ack=hout.ch[14].FIRST_CAUSE_SNAP.req && !hout.ch[14].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[14].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[14].FIRST_COUNT_LO_SNAP.req && !hout.ch[14].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[14].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[14].FIRST_COUNT_HI_SNAP.req && !hout.ch[14].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[14].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_SOURCE_SNAP.rd_ack=hout.ch[14].FIRST_SOURCE_SNAP.req && !hout.ch[14].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[14].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[14].FIRST_CFG_VERSION_SNAP.req && !hout.ch[14].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[14].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_MISSING_SNAP.rd_ack=hout.ch[14].FIRST_MISSING_SNAP.req && !hout.ch[14].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[14].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[14].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[14].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[14].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FIRST_STATE_SNAP.rd_ack=hout.ch[14].FIRST_STATE_SNAP.req && !hout.ch[14].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[14].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[14].CTRL_ACTIVE_SNAP.req && !hout.ch[14].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[14].PRESCALE_ACTIVE_SNAP.req && !hout.ch[14].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[14].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[14].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[14].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[14].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[14].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[14].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[14].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[14].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[14].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[14].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[14].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[14].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[14].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[14].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[14].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[14].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[14].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[14].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[14].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[14].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[14].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[14].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[14].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[14].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[14].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[14].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[14].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[14].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_SELECT.rd_ack=hout.ch[14].CLIENT_SELECT.req && !hout.ch[14].CLIENT_SELECT.req_is_wr;
assign hin.ch[14].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[14].CLIENT_SELECT.wr_ack=hout.ch[14].CLIENT_SELECT.req && hout.ch[14].CLIENT_SELECT.req_is_wr;
assign hin.ch[14].CLIENT_OWNER_STAGE.rd_ack=hout.ch[14].CLIENT_OWNER_STAGE.req && !hout.ch[14].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_OWNER_STAGE.wr_ack=hout.ch[14].CLIENT_OWNER_STAGE.req && hout.ch[14].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[14].CLIENT_ALIVE_STAGE.req && !hout.ch[14].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[14].CLIENT_ALIVE_STAGE.req && hout.ch[14].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_FLOW_STAGE.rd_ack=hout.ch[14].CLIENT_FLOW_STAGE.req && !hout.ch[14].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[14].CLIENT_FLOW_STAGE.wr_ack=hout.ch[14].CLIENT_FLOW_STAGE.req && hout.ch[14].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[14].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[14].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[14].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[14].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[14].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[14].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[14].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[14].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[14].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[14].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[14].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[14].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[14].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[14].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[14].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[14].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[14].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[14].CLIENT_FLAGS_SNAP.req && !hout.ch[14].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[14].CLIENT_TOKEN_SNAP.req && !hout.ch[14].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[14].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[14].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[14].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[14].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[14].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[14].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[14].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[14].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[14].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[14].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[14].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[14].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[14].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[14].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[14].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[14].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[14].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[14].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[14].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[14].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[14].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[14].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CTRL_STAGE.rd_ack=hout.ch[15].CTRL_STAGE.req && !hout.ch[15].CTRL_STAGE.req_is_wr;
assign hin.ch[15].CTRL_STAGE.rd_data=rdata & 32'h00001fff;
assign hin.ch[15].CTRL_STAGE.wr_ack=hout.ch[15].CTRL_STAGE.req && hout.ch[15].CTRL_STAGE.req_is_wr;
assign hin.ch[15].PRESCALE_STAGE.rd_ack=hout.ch[15].PRESCALE_STAGE.req && !hout.ch[15].PRESCALE_STAGE.req_is_wr;
assign hin.ch[15].PRESCALE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].PRESCALE_STAGE.wr_ack=hout.ch[15].PRESCALE_STAGE.req && hout.ch[15].PRESCALE_STAGE.req_is_wr;
assign hin.ch[15].WIN_MIN_LO_STAGE.rd_ack=hout.ch[15].WIN_MIN_LO_STAGE.req && !hout.ch[15].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[15].WIN_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].WIN_MIN_LO_STAGE.wr_ack=hout.ch[15].WIN_MIN_LO_STAGE.req && hout.ch[15].WIN_MIN_LO_STAGE.req_is_wr;
assign hin.ch[15].WIN_MIN_HI_STAGE.rd_ack=hout.ch[15].WIN_MIN_HI_STAGE.req && !hout.ch[15].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[15].WIN_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].WIN_MIN_HI_STAGE.wr_ack=hout.ch[15].WIN_MIN_HI_STAGE.req && hout.ch[15].WIN_MIN_HI_STAGE.req_is_wr;
assign hin.ch[15].TIMEOUT_LO_STAGE.rd_ack=hout.ch[15].TIMEOUT_LO_STAGE.req && !hout.ch[15].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[15].TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].TIMEOUT_LO_STAGE.wr_ack=hout.ch[15].TIMEOUT_LO_STAGE.req && hout.ch[15].TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[15].TIMEOUT_HI_STAGE.rd_ack=hout.ch[15].TIMEOUT_HI_STAGE.req && !hout.ch[15].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[15].TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].TIMEOUT_HI_STAGE.wr_ack=hout.ch[15].TIMEOUT_HI_STAGE.req && hout.ch[15].TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[15].PRETIMEOUT_LO_STAGE.rd_ack=hout.ch[15].PRETIMEOUT_LO_STAGE.req && !hout.ch[15].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[15].PRETIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].PRETIMEOUT_LO_STAGE.wr_ack=hout.ch[15].PRETIMEOUT_LO_STAGE.req && hout.ch[15].PRETIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[15].PRETIMEOUT_HI_STAGE.rd_ack=hout.ch[15].PRETIMEOUT_HI_STAGE.req && !hout.ch[15].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[15].PRETIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].PRETIMEOUT_HI_STAGE.wr_ack=hout.ch[15].PRETIMEOUT_HI_STAGE.req && hout.ch[15].PRETIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[15].BOOT_TIMEOUT_LO_STAGE.rd_ack=hout.ch[15].BOOT_TIMEOUT_LO_STAGE.req && !hout.ch[15].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[15].BOOT_TIMEOUT_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].BOOT_TIMEOUT_LO_STAGE.wr_ack=hout.ch[15].BOOT_TIMEOUT_LO_STAGE.req && hout.ch[15].BOOT_TIMEOUT_LO_STAGE.req_is_wr;
assign hin.ch[15].BOOT_TIMEOUT_HI_STAGE.rd_ack=hout.ch[15].BOOT_TIMEOUT_HI_STAGE.req && !hout.ch[15].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[15].BOOT_TIMEOUT_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].BOOT_TIMEOUT_HI_STAGE.wr_ack=hout.ch[15].BOOT_TIMEOUT_HI_STAGE.req && hout.ch[15].BOOT_TIMEOUT_HI_STAGE.req_is_wr;
assign hin.ch[15].SEQ_LIMIT_STAGE.rd_ack=hout.ch[15].SEQ_LIMIT_STAGE.req && !hout.ch[15].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[15].SEQ_LIMIT_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].SEQ_LIMIT_STAGE.wr_ack=hout.ch[15].SEQ_LIMIT_STAGE.req && hout.ch[15].SEQ_LIMIT_STAGE.req_is_wr;
assign hin.ch[15].REQUIRE_MASK_STAGE.rd_ack=hout.ch[15].REQUIRE_MASK_STAGE.req && !hout.ch[15].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[15].REQUIRE_MASK_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].REQUIRE_MASK_STAGE.wr_ack=hout.ch[15].REQUIRE_MASK_STAGE.req && hout.ch[15].REQUIRE_MASK_STAGE.req_is_wr;
assign hin.ch[15].FAULT_POLICY_STAGE.rd_ack=hout.ch[15].FAULT_POLICY_STAGE.req && !hout.ch[15].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[15].FAULT_POLICY_STAGE.rd_data=rdata & 32'h000007fe;
assign hin.ch[15].FAULT_POLICY_STAGE.wr_ack=hout.ch[15].FAULT_POLICY_STAGE.req && hout.ch[15].FAULT_POLICY_STAGE.req_is_wr;
assign hin.ch[15].LOCAL_DELAY_STAGE.rd_ack=hout.ch[15].LOCAL_DELAY_STAGE.req && !hout.ch[15].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[15].LOCAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].LOCAL_DELAY_STAGE.wr_ack=hout.ch[15].LOCAL_DELAY_STAGE.req && hout.ch[15].LOCAL_DELAY_STAGE.req_is_wr;
assign hin.ch[15].FINAL_DELAY_STAGE.rd_ack=hout.ch[15].FINAL_DELAY_STAGE.req && !hout.ch[15].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[15].FINAL_DELAY_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FINAL_DELAY_STAGE.wr_ack=hout.ch[15].FINAL_DELAY_STAGE.req && hout.ch[15].FINAL_DELAY_STAGE.req_is_wr;
assign hin.ch[15].RECOVERY_LIMIT_STAGE.rd_ack=hout.ch[15].RECOVERY_LIMIT_STAGE.req && !hout.ch[15].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[15].RECOVERY_LIMIT_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[15].RECOVERY_LIMIT_STAGE.wr_ack=hout.ch[15].RECOVERY_LIMIT_STAGE.req && hout.ch[15].RECOVERY_LIMIT_STAGE.req_is_wr;
assign hin.ch[15].UNLOCK.wr_ack=hout.ch[15].UNLOCK.req && hout.ch[15].UNLOCK.req_is_wr;
assign hin.ch[15].COMMAND.wr_ack=hout.ch[15].COMMAND.req && hout.ch[15].COMMAND.req_is_wr;
assign hin.ch[15].LOCK_SET.wr_ack=hout.ch[15].LOCK_SET.req && hout.ch[15].LOCK_SET.req_is_wr;
assign hin.ch[15].SERVICE_SELECT.rd_ack=hout.ch[15].SERVICE_SELECT.req && !hout.ch[15].SERVICE_SELECT.req_is_wr;
assign hin.ch[15].SERVICE_SELECT.rd_data=rdata & 32'h0000071f;
assign hin.ch[15].SERVICE_SELECT.wr_ack=hout.ch[15].SERVICE_SELECT.req && hout.ch[15].SERVICE_SELECT.req_is_wr;
assign hin.ch[15].SERVICE.wr_ack=hout.ch[15].SERVICE.req && hout.ch[15].SERVICE.req_is_wr;
assign hin.ch[15].IRQ_ENABLE.wr_ack=hout.ch[15].IRQ_ENABLE.req && hout.ch[15].IRQ_ENABLE.req_is_wr;
assign hin.ch[15].IRQ_CLEAR.wr_ack=hout.ch[15].IRQ_CLEAR.req && hout.ch[15].IRQ_CLEAR.req_is_wr;
assign hin.ch[15].IRQ_TEST.wr_ack=hout.ch[15].IRQ_TEST.req && hout.ch[15].IRQ_TEST.req_is_wr;
assign hin.ch[15].DIAG_CLEAR.wr_ack=hout.ch[15].DIAG_CLEAR.req && hout.ch[15].DIAG_CLEAR.req_is_wr;
assign hin.ch[15].FAULT_INJECT.wr_ack=hout.ch[15].FAULT_INJECT.req && hout.ch[15].FAULT_INJECT.req_is_wr;
assign hin.ch[15].SNAP_META.rd_ack=hout.ch[15].SNAP_META.req && !hout.ch[15].SNAP_META.req_is_wr;
assign hin.ch[15].SNAP_META.rd_data=rdata & 32'h00000001;
assign hin.ch[15].SNAP_SEQ.rd_ack=hout.ch[15].SNAP_SEQ.req && !hout.ch[15].SNAP_SEQ.req_is_wr;
assign hin.ch[15].SNAP_SEQ.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].STATUS_SNAP.rd_ack=hout.ch[15].STATUS_SNAP.req && !hout.ch[15].STATUS_SNAP.req_is_wr;
assign hin.ch[15].STATUS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CFG_VERSION_SNAP.rd_ack=hout.ch[15].CFG_VERSION_SNAP.req && !hout.ch[15].CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[15].CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].COUNT_LO_SNAP.rd_ack=hout.ch[15].COUNT_LO_SNAP.req && !hout.ch[15].COUNT_LO_SNAP.req_is_wr;
assign hin.ch[15].COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].COUNT_HI_SNAP.rd_ack=hout.ch[15].COUNT_HI_SNAP.req && !hout.ch[15].COUNT_HI_SNAP.req_is_wr;
assign hin.ch[15].COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].EVENT_RAW_SNAP.rd_ack=hout.ch[15].EVENT_RAW_SNAP.req && !hout.ch[15].EVENT_RAW_SNAP.req_is_wr;
assign hin.ch[15].EVENT_RAW_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].IRQ_ENABLE_SNAP.rd_ack=hout.ch[15].IRQ_ENABLE_SNAP.req && !hout.ch[15].IRQ_ENABLE_SNAP.req_is_wr;
assign hin.ch[15].IRQ_ENABLE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].SEEN_MASK_SNAP.rd_ack=hout.ch[15].SEEN_MASK_SNAP.req && !hout.ch[15].SEEN_MASK_SNAP.req_is_wr;
assign hin.ch[15].SEEN_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].MISSING_MASK_SNAP.rd_ack=hout.ch[15].MISSING_MASK_SNAP.req && !hout.ch[15].MISSING_MASK_SNAP.req_is_wr;
assign hin.ch[15].MISSING_MASK_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].LAST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[15].LAST_SERVICE_SEQ_SNAP.req && !hout.ch[15].LAST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[15].LAST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FAULT_COUNT_SNAP.rd_ack=hout.ch[15].FAULT_COUNT_SNAP.req && !hout.ch[15].FAULT_COUNT_SNAP.req_is_wr;
assign hin.ch[15].FAULT_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].RECOVERY_COUNT_SNAP.rd_ack=hout.ch[15].RECOVERY_COUNT_SNAP.req && !hout.ch[15].RECOVERY_COUNT_SNAP.req_is_wr;
assign hin.ch[15].RECOVERY_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].ESC_AGE_SNAP.rd_ack=hout.ch[15].ESC_AGE_SNAP.req && !hout.ch[15].ESC_AGE_SNAP.req_is_wr;
assign hin.ch[15].ESC_AGE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_FLAGS_SNAP.rd_ack=hout.ch[15].FIRST_FLAGS_SNAP.req && !hout.ch[15].FIRST_FLAGS_SNAP.req_is_wr;
assign hin.ch[15].FIRST_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_CAUSE_SNAP.rd_ack=hout.ch[15].FIRST_CAUSE_SNAP.req && !hout.ch[15].FIRST_CAUSE_SNAP.req_is_wr;
assign hin.ch[15].FIRST_CAUSE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_COUNT_LO_SNAP.rd_ack=hout.ch[15].FIRST_COUNT_LO_SNAP.req && !hout.ch[15].FIRST_COUNT_LO_SNAP.req_is_wr;
assign hin.ch[15].FIRST_COUNT_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_COUNT_HI_SNAP.rd_ack=hout.ch[15].FIRST_COUNT_HI_SNAP.req && !hout.ch[15].FIRST_COUNT_HI_SNAP.req_is_wr;
assign hin.ch[15].FIRST_COUNT_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_SOURCE_SNAP.rd_ack=hout.ch[15].FIRST_SOURCE_SNAP.req && !hout.ch[15].FIRST_SOURCE_SNAP.req_is_wr;
assign hin.ch[15].FIRST_SOURCE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_CFG_VERSION_SNAP.rd_ack=hout.ch[15].FIRST_CFG_VERSION_SNAP.req && !hout.ch[15].FIRST_CFG_VERSION_SNAP.req_is_wr;
assign hin.ch[15].FIRST_CFG_VERSION_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_MISSING_SNAP.rd_ack=hout.ch[15].FIRST_MISSING_SNAP.req && !hout.ch[15].FIRST_MISSING_SNAP.req_is_wr;
assign hin.ch[15].FIRST_MISSING_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_SERVICE_SEQ_SNAP.rd_ack=hout.ch[15].FIRST_SERVICE_SEQ_SNAP.req && !hout.ch[15].FIRST_SERVICE_SEQ_SNAP.req_is_wr;
assign hin.ch[15].FIRST_SERVICE_SEQ_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FIRST_STATE_SNAP.rd_ack=hout.ch[15].FIRST_STATE_SNAP.req && !hout.ch[15].FIRST_STATE_SNAP.req_is_wr;
assign hin.ch[15].FIRST_STATE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CTRL_ACTIVE_SNAP.rd_ack=hout.ch[15].CTRL_ACTIVE_SNAP.req && !hout.ch[15].CTRL_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CTRL_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].PRESCALE_ACTIVE_SNAP.rd_ack=hout.ch[15].PRESCALE_ACTIVE_SNAP.req && !hout.ch[15].PRESCALE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].PRESCALE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].WIN_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[15].WIN_MIN_LO_ACTIVE_SNAP.req && !hout.ch[15].WIN_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].WIN_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].WIN_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[15].WIN_MIN_HI_ACTIVE_SNAP.req && !hout.ch[15].WIN_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].WIN_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[15].TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[15].TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[15].TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[15].TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].PRETIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[15].PRETIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[15].PRETIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].PRETIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].PRETIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[15].PRETIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[15].PRETIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].PRETIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_ack=hout.ch[15].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req && !hout.ch[15].BOOT_TIMEOUT_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].BOOT_TIMEOUT_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_ack=hout.ch[15].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req && !hout.ch[15].BOOT_TIMEOUT_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].BOOT_TIMEOUT_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].SEQ_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[15].SEQ_LIMIT_ACTIVE_SNAP.req && !hout.ch[15].SEQ_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].SEQ_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].REQUIRE_MASK_ACTIVE_SNAP.rd_ack=hout.ch[15].REQUIRE_MASK_ACTIVE_SNAP.req && !hout.ch[15].REQUIRE_MASK_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].REQUIRE_MASK_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FAULT_POLICY_ACTIVE_SNAP.rd_ack=hout.ch[15].FAULT_POLICY_ACTIVE_SNAP.req && !hout.ch[15].FAULT_POLICY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].FAULT_POLICY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].LOCAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[15].LOCAL_DELAY_ACTIVE_SNAP.req && !hout.ch[15].LOCAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].LOCAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].FINAL_DELAY_ACTIVE_SNAP.rd_ack=hout.ch[15].FINAL_DELAY_ACTIVE_SNAP.req && !hout.ch[15].FINAL_DELAY_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].FINAL_DELAY_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].RECOVERY_LIMIT_ACTIVE_SNAP.rd_ack=hout.ch[15].RECOVERY_LIMIT_ACTIVE_SNAP.req && !hout.ch[15].RECOVERY_LIMIT_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].RECOVERY_LIMIT_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_SELECT.rd_ack=hout.ch[15].CLIENT_SELECT.req && !hout.ch[15].CLIENT_SELECT.req_is_wr;
assign hin.ch[15].CLIENT_SELECT.rd_data=rdata & 32'h0000001f;
assign hin.ch[15].CLIENT_SELECT.wr_ack=hout.ch[15].CLIENT_SELECT.req && hout.ch[15].CLIENT_SELECT.req_is_wr;
assign hin.ch[15].CLIENT_OWNER_STAGE.rd_ack=hout.ch[15].CLIENT_OWNER_STAGE.req && !hout.ch[15].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_OWNER_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_OWNER_STAGE.wr_ack=hout.ch[15].CLIENT_OWNER_STAGE.req && hout.ch[15].CLIENT_OWNER_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_ALIVE_STAGE.rd_ack=hout.ch[15].CLIENT_ALIVE_STAGE.req && !hout.ch[15].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_ALIVE_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_ALIVE_STAGE.wr_ack=hout.ch[15].CLIENT_ALIVE_STAGE.req && hout.ch[15].CLIENT_ALIVE_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_FLOW_STAGE.rd_ack=hout.ch[15].CLIENT_FLOW_STAGE.req && !hout.ch[15].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_FLOW_STAGE.rd_data=rdata & 32'h000000ff;
assign hin.ch[15].CLIENT_FLOW_STAGE.wr_ack=hout.ch[15].CLIENT_FLOW_STAGE.req && hout.ch[15].CLIENT_FLOW_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MIN_LO_STAGE.rd_ack=hout.ch[15].CLIENT_DEADLINE_MIN_LO_STAGE.req && !hout.ch[15].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MIN_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MIN_LO_STAGE.wr_ack=hout.ch[15].CLIENT_DEADLINE_MIN_LO_STAGE.req && hout.ch[15].CLIENT_DEADLINE_MIN_LO_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MIN_HI_STAGE.rd_ack=hout.ch[15].CLIENT_DEADLINE_MIN_HI_STAGE.req && !hout.ch[15].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MIN_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MIN_HI_STAGE.wr_ack=hout.ch[15].CLIENT_DEADLINE_MIN_HI_STAGE.req && hout.ch[15].CLIENT_DEADLINE_MIN_HI_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MAX_LO_STAGE.rd_ack=hout.ch[15].CLIENT_DEADLINE_MAX_LO_STAGE.req && !hout.ch[15].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MAX_LO_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MAX_LO_STAGE.wr_ack=hout.ch[15].CLIENT_DEADLINE_MAX_LO_STAGE.req && hout.ch[15].CLIENT_DEADLINE_MAX_LO_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MAX_HI_STAGE.rd_ack=hout.ch[15].CLIENT_DEADLINE_MAX_HI_STAGE.req && !hout.ch[15].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MAX_HI_STAGE.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MAX_HI_STAGE.wr_ack=hout.ch[15].CLIENT_DEADLINE_MAX_HI_STAGE.req && hout.ch[15].CLIENT_DEADLINE_MAX_HI_STAGE.req_is_wr;
assign hin.ch[15].CLIENT_FLAGS_SNAP.rd_ack=hout.ch[15].CLIENT_FLAGS_SNAP.req && !hout.ch[15].CLIENT_FLAGS_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_FLAGS_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_TOKEN_SNAP.rd_ack=hout.ch[15].CLIENT_TOKEN_SNAP.req && !hout.ch[15].CLIENT_TOKEN_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_TOKEN_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_ALIVE_COUNT_SNAP.rd_ack=hout.ch[15].CLIENT_ALIVE_COUNT_SNAP.req && !hout.ch[15].CLIENT_ALIVE_COUNT_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_ALIVE_COUNT_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_ELAPSED_LO_SNAP.rd_ack=hout.ch[15].CLIENT_ELAPSED_LO_SNAP.req && !hout.ch[15].CLIENT_ELAPSED_LO_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_ELAPSED_LO_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_ELAPSED_HI_SNAP.rd_ack=hout.ch[15].CLIENT_ELAPSED_HI_SNAP.req && !hout.ch[15].CLIENT_ELAPSED_HI_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_ELAPSED_HI_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_OWNER_ACTIVE_SNAP.rd_ack=hout.ch[15].CLIENT_OWNER_ACTIVE_SNAP.req && !hout.ch[15].CLIENT_OWNER_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_OWNER_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_ALIVE_ACTIVE_SNAP.rd_ack=hout.ch[15].CLIENT_ALIVE_ACTIVE_SNAP.req && !hout.ch[15].CLIENT_ALIVE_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_ALIVE_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_FLOW_ACTIVE_SNAP.rd_ack=hout.ch[15].CLIENT_FLOW_ACTIVE_SNAP.req && !hout.ch[15].CLIENT_FLOW_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_FLOW_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_ack=hout.ch[15].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req && !hout.ch[15].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MIN_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_ack=hout.ch[15].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req && !hout.ch[15].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MIN_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_ack=hout.ch[15].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req && !hout.ch[15].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
assign hin.ch[15].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_ack=hout.ch[15].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req && !hout.ch[15].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.req_is_wr;
assign hin.ch[15].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.rd_data=rdata & 32'hffffffff;
always_comb begin
write_mask=0; writable=0; valid_addr=0;
case(addr)
15'h0000: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0004: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0008: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h000c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0010: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0014: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0018: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h001c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0020: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0024: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h0028: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1000: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h1004: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1008: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h100c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1010: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1014: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1018: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h101c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1020: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1024: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1028: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h102c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1030: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h1034: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1038: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h103c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1040: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1044: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1048: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h104c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h1050: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1054: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h1058: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h105c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h1060: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h1064: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h1068: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h106c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1070: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1074: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1078: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h107c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1080: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1084: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1088: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h108c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1090: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1094: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1098: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h109c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h10c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1100: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1104: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1108: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h110c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1110: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1114: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1118: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h111c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1120: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1124: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1128: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h112c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1130: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1134: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1138: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h113c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1140: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h1144: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1148: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h114c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1150: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1154: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1158: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h115c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1180: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1184: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1188: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h118c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1190: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h11a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h11a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h11a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h11ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h11b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h11b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h11b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1400: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h1404: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1408: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h140c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1410: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1414: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1418: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h141c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1420: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1424: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1428: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h142c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1430: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h1434: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1438: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h143c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1440: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1444: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1448: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h144c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h1450: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1454: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h1458: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h145c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h1460: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h1464: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h1468: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h146c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1470: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1474: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1478: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h147c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1480: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1484: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1488: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h148c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1490: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1494: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1498: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h149c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h14c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1500: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1504: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1508: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h150c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1510: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1514: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1518: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h151c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1520: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1524: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1528: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h152c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1530: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1534: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1538: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h153c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1540: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h1544: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1548: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h154c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1550: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1554: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1558: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h155c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1580: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1584: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1588: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h158c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1590: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h15a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h15a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h15a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h15ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h15b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h15b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h15b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1800: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h1804: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1808: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h180c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1810: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1814: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1818: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h181c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1820: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1824: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1828: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h182c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1830: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h1834: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1838: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h183c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1840: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1844: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1848: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h184c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h1850: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1854: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h1858: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h185c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h1860: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h1864: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h1868: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h186c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1870: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1874: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1878: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h187c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1880: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1884: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1888: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h188c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1890: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1894: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1898: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h189c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h18c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1900: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1904: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1908: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h190c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1910: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1914: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1918: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h191c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1920: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1924: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1928: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h192c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1930: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1934: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1938: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h193c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1940: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h1944: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1948: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h194c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1950: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1954: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1958: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h195c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1980: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1984: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1988: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h198c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1990: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h19a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h19a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h19a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h19ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h19b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h19b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h19b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c00: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h1c04: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c08: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c0c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c10: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c14: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c18: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c1c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c20: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c24: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c28: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c2c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c30: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h1c34: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c38: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c3c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1c40: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c44: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1c48: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h1c4c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h1c50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1c54: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h1c58: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h1c5c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h1c60: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h1c64: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h1c68: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h1c6c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c70: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c74: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c78: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c7c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c94: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c98: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1c9c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1ca0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1ca4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1ca8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1cac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1cb0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1cb4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1cb8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1cbc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1cc0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d00: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d04: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d08: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d0c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d10: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d14: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d18: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d1c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d20: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d24: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d28: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d2c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d30: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d34: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d38: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d3c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d40: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h1d44: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1d48: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1d4c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h1d50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1d54: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1d58: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1d5c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h1d80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1d90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1da0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1da4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1da8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1dac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1db0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1db4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h1db8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2000: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h2004: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2008: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h200c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2010: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2014: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2018: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h201c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2020: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2024: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2028: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h202c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2030: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h2034: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2038: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h203c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2040: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2044: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2048: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h204c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h2050: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2054: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h2058: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h205c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h2060: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h2064: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h2068: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h206c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2070: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2074: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2078: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h207c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2080: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2084: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2088: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h208c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2090: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2094: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2098: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h209c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h20c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2100: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2104: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2108: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h210c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2110: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2114: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2118: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h211c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2120: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2124: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2128: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h212c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2130: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2134: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2138: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h213c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2140: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h2144: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2148: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h214c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2150: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2154: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2158: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h215c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2180: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2184: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2188: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h218c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2190: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h21a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h21a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h21a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h21ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h21b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h21b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h21b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2400: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h2404: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2408: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h240c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2410: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2414: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2418: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h241c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2420: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2424: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2428: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h242c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2430: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h2434: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2438: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h243c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2440: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2444: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2448: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h244c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h2450: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2454: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h2458: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h245c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h2460: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h2464: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h2468: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h246c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2470: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2474: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2478: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h247c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2480: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2484: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2488: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h248c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2490: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2494: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2498: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h249c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h24c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2500: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2504: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2508: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h250c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2510: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2514: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2518: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h251c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2520: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2524: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2528: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h252c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2530: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2534: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2538: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h253c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2540: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h2544: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2548: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h254c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2550: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2554: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2558: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h255c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2580: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2584: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2588: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h258c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2590: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h25a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h25a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h25a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h25ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h25b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h25b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h25b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2800: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h2804: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2808: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h280c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2810: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2814: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2818: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h281c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2820: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2824: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2828: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h282c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2830: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h2834: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2838: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h283c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2840: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2844: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2848: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h284c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h2850: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2854: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h2858: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h285c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h2860: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h2864: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h2868: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h286c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2870: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2874: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2878: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h287c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2880: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2884: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2888: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h288c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2890: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2894: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2898: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h289c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h28c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2900: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2904: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2908: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h290c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2910: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2914: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2918: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h291c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2920: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2924: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2928: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h292c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2930: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2934: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2938: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h293c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2940: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h2944: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2948: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h294c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2950: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2954: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2958: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h295c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2980: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2984: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2988: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h298c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2990: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h29a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h29a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h29a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h29ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h29b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h29b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h29b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c00: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h2c04: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c08: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c0c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c10: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c14: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c18: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c1c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c20: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c24: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c28: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c2c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c30: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h2c34: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c38: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c3c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2c40: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c44: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2c48: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h2c4c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h2c50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2c54: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h2c58: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h2c5c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h2c60: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h2c64: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h2c68: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h2c6c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c70: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c74: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c78: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c7c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c94: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c98: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2c9c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2ca0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2ca4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2ca8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2cac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2cb0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2cb4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2cb8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2cbc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2cc0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d00: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d04: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d08: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d0c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d10: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d14: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d18: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d1c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d20: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d24: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d28: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d2c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d30: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d34: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d38: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d3c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d40: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h2d44: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2d48: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2d4c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h2d50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2d54: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2d58: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2d5c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h2d80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2d90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2da0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2da4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2da8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2dac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2db0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2db4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h2db8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3000: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h3004: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3008: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h300c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3010: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3014: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3018: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h301c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3020: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3024: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3028: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h302c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3030: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h3034: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3038: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h303c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3040: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3044: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3048: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h304c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h3050: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3054: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h3058: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h305c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h3060: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h3064: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h3068: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h306c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3070: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3074: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3078: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h307c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3080: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3084: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3088: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h308c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3090: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3094: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3098: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h309c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h30c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3100: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3104: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3108: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h310c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3110: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3114: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3118: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h311c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3120: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3124: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3128: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h312c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3130: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3134: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3138: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h313c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3140: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h3144: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3148: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h314c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3150: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3154: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3158: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h315c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3180: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3184: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3188: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h318c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3190: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h31a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h31a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h31a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h31ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h31b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h31b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h31b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3400: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h3404: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3408: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h340c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3410: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3414: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3418: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h341c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3420: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3424: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3428: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h342c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3430: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h3434: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3438: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h343c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3440: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3444: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3448: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h344c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h3450: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3454: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h3458: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h345c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h3460: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h3464: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h3468: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h346c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3470: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3474: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3478: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h347c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3480: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3484: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3488: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h348c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3490: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3494: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3498: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h349c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h34c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3500: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3504: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3508: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h350c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3510: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3514: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3518: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h351c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3520: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3524: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3528: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h352c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3530: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3534: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3538: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h353c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3540: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h3544: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3548: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h354c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3550: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3554: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3558: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h355c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3580: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3584: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3588: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h358c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3590: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h35a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h35a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h35a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h35ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h35b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h35b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h35b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3800: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h3804: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3808: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h380c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3810: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3814: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3818: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h381c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3820: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3824: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3828: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h382c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3830: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h3834: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3838: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h383c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3840: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3844: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3848: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h384c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h3850: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3854: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h3858: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h385c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h3860: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h3864: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h3868: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h386c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3870: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3874: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3878: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h387c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3880: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3884: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3888: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h388c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3890: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3894: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3898: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h389c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h38c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3900: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3904: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3908: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h390c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3910: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3914: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3918: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h391c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3920: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3924: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3928: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h392c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3930: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3934: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3938: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h393c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3940: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h3944: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3948: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h394c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3950: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3954: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3958: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h395c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3980: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3984: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3988: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h398c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3990: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h39a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h39a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h39a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h39ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h39b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h39b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h39b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c00: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h3c04: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c08: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c0c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c10: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c14: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c18: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c1c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c20: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c24: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c28: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c2c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c30: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h3c34: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c38: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c3c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3c40: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c44: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3c48: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h3c4c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h3c50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3c54: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h3c58: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h3c5c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h3c60: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h3c64: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h3c68: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h3c6c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c70: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c74: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c78: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c7c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c94: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c98: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3c9c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3ca0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3ca4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3ca8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3cac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3cb0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3cb4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3cb8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3cbc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3cc0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d00: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d04: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d08: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d0c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d10: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d14: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d18: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d1c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d20: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d24: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d28: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d2c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d30: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d34: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d38: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d3c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d40: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h3d44: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3d48: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3d4c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h3d50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3d54: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3d58: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3d5c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h3d80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3d90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3da0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3da4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3da8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3dac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3db0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3db4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h3db8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4000: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h4004: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4008: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h400c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4010: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4014: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4018: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h401c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4020: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4024: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4028: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h402c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4030: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h4034: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4038: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h403c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4040: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4044: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4048: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h404c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h4050: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4054: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h4058: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h405c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h4060: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h4064: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h4068: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h406c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4070: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4074: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4078: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h407c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4080: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4084: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4088: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h408c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4090: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4094: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4098: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h409c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h40c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4100: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4104: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4108: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h410c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4110: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4114: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4118: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h411c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4120: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4124: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4128: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h412c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4130: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4134: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4138: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h413c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4140: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h4144: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4148: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h414c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4150: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4154: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4158: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h415c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4180: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4184: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4188: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h418c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4190: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h41a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h41a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h41a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h41ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h41b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h41b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h41b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4400: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h4404: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4408: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h440c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4410: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4414: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4418: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h441c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4420: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4424: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4428: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h442c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4430: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h4434: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4438: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h443c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4440: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4444: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4448: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h444c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h4450: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4454: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h4458: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h445c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h4460: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h4464: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h4468: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h446c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4470: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4474: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4478: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h447c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4480: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4484: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4488: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h448c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4490: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4494: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4498: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h449c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h44c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4500: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4504: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4508: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h450c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4510: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4514: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4518: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h451c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4520: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4524: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4528: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h452c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4530: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4534: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4538: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h453c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4540: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h4544: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4548: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h454c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4550: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4554: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4558: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h455c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4580: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4584: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4588: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h458c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4590: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h45a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h45a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h45a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h45ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h45b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h45b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h45b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4800: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h4804: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4808: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h480c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4810: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4814: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4818: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h481c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4820: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4824: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4828: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h482c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4830: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h4834: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4838: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h483c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4840: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4844: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4848: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h484c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h4850: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4854: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h4858: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h485c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h4860: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h4864: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h4868: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h486c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4870: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4874: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4878: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h487c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4880: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4884: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4888: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h488c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4890: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4894: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4898: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h489c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48bc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h48c0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4900: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4904: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4908: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h490c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4910: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4914: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4918: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h491c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4920: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4924: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4928: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h492c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4930: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4934: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4938: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h493c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4940: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h4944: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4948: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h494c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4950: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4954: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4958: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h495c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4980: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4984: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4988: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h498c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4990: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h49a0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h49a4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h49a8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h49ac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h49b0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h49b4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h49b8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c00: begin valid_addr=1; writable=1'b1; write_mask=32'h00001fff; end
15'h4c04: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c08: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c0c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c10: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c14: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c18: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c1c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c20: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c24: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c28: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c2c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c30: begin valid_addr=1; writable=1'b1; write_mask=32'h000007fe; end
15'h4c34: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c38: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c3c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4c40: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c44: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4c48: begin valid_addr=1; writable=1'b1; write_mask=32'h0000000f; end
15'h4c4c: begin valid_addr=1; writable=1'b1; write_mask=32'h0000071f; end
15'h4c50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4c54: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h4c58: begin valid_addr=1; writable=1'b1; write_mask=32'h0007ffff; end
15'h4c5c: begin valid_addr=1; writable=1'b1; write_mask=32'h00000001; end
15'h4c60: begin valid_addr=1; writable=1'b1; write_mask=32'h00000003; end
15'h4c64: begin valid_addr=1; writable=1'b1; write_mask=32'h000003ff; end
15'h4c68: begin valid_addr=1; writable=1'b0; write_mask=32'h00000001; end
15'h4c6c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c70: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c74: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c78: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c7c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c94: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c98: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4c9c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4ca0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4ca4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4ca8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4cac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4cb0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4cb4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4cb8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4cbc: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4cc0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d00: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d04: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d08: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d0c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d10: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d14: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d18: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d1c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d20: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d24: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d28: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d2c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d30: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d34: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d38: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d3c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d40: begin valid_addr=1; writable=1'b1; write_mask=32'h0000001f; end
15'h4d44: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4d48: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4d4c: begin valid_addr=1; writable=1'b1; write_mask=32'h000000ff; end
15'h4d50: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4d54: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4d58: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4d5c: begin valid_addr=1; writable=1'b1; write_mask=32'hffffffff; end
15'h4d80: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d84: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d88: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d8c: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4d90: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4da0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4da4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4da8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4dac: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4db0: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4db4: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
15'h4db8: begin valid_addr=1; writable=1'b0; write_mask=32'hffffffff; end
default: begin end
endcase
end
endmodule
