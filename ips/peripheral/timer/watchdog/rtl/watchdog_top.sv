module watchdog_top #(
  parameter int NUM_CHANNELS=1, COUNTER_WIDTH=32, PRESCALE_WIDTH=16,
    NUM_CLIENTS=1, SOURCE_WIDTH=4, SYNC_STAGES=2,
  parameter bit SUPPORT_TOKEN_QA=0, SUPPORT_SUPERVISION=0, SUPPORT_HW_EVENT=0,
    SAFETY_EN=0, ALLOW_RUNTIME_UPDATE=0, DIAG_INJECT_EN=0,
  parameter logic [NUM_CHANNELS-1:0] AUTO_START_MASK='0, NO_STOP_MASK='1, HARD_CFG_LOCK_MASK='0,
  parameter watchdog_pkg::config_t DEFAULT_CFG[NUM_CHANNELS]='{default:watchdog_pkg::default_config()}
)(
  input logic pclk,preset_n,wdt_clk,por_n,
  input logic PSEL,PENABLE,PWRITE,
  input logic [14:0] PADDR,
  input logic [31:0] PWDATA,
  input logic [3:0] PSTRB,
  input logic [2:0] PPROT,
  output logic [31:0] PRDATA,
  output logic PREADY,PSLVERR,
  input logic [SOURCE_WIDTH-1:0] access_source_i,
  input logic cfg_auth_i,service_auth_i,diag_auth_i,
  input logic sleep_req_i,debug_req_i,debug_auth_i,warm_reset_evt_i,test_auth_i,
  input logic [NUM_CHANNELS-1:0] recovery_done_i,
  output logic [NUM_CHANNELS-1:0] pause_ack_o,recovery_ack_o,irq_o,nmi_req_o,local_reset_req_o,
  output logic system_reset_req_o,safety_alert_o,safe_state_req_o,wake_req_o,
  input logic hw_evt_valid,
  output logic hw_evt_ready,
  input logic [3:0] hw_evt_channel,
  input logic [4:0] hw_evt_client,
  input logic [2:0] hw_evt_type,
  input logic [31:0] hw_evt_data,
  input logic [SOURCE_WIDTH-1:0] hw_evt_source
);
  import watchdog_pkg::*;
  (* async_reg="true" *) logic [SYNC_STAGES-1:0] por_p,por_w,pre_p;
  wire prst_n=por_p[SYNC_STAGES-1], wrst_n=por_w[SYNC_STAGES-1];
  wire apb_rst_n=prst_n && pre_p[SYNC_STAGES-1];
  always_ff @(posedge pclk or negedge por_n)
    if(!por_n) por_p<='0; else por_p<={por_p[SYNC_STAGES-2:0],1'b1};
  always_ff @(posedge wdt_clk or negedge por_n)
    if(!por_n) por_w<='0; else por_w<={por_w[SYNC_STAGES-2:0],1'b1};
  wire interface_reset_n=por_n && preset_n;
  always_ff @(posedge pclk or negedge interface_reset_n)
    if(!interface_reset_n) pre_p<='0; else pre_p<={pre_p[SYNC_STAGES-2:0],1'b1};
  if(NUM_CHANNELS<1 || NUM_CHANNELS>16 || SYNC_STAGES<2 || SYNC_STAGES>4) begin : g_bad_parameters
    $error("Invalid watchdog top parameters");
  end
  config_t staging[NUM_CHANNELS], mailbox_config;
  command_t mailbox_cmd, selected_cmd;
  logic [4:0] client_select[NUM_CHANNELS];
  logic [10:0] service_select[NUM_CHANNELS];
  logic req_toggle,ack_toggle,busy,exec_done;
  (* keep="true", dont_touch="true" *) logic req_bar,ack_bar,mailbox_parity;
  (* async_reg="true" *) logic [SYNC_STAGES-1:0] control_error_sync;
  logic mailbox_integrity;
  (* async_reg="true" *) logic [SYNC_STAGES-1:0] req_sync,ack_sync;
  logic [31:0] issued_seq,done_seq,done_info;
  logic [7:0] done_result,reply_result;
  snapshot_t reply_snapshot, snapshots[NUM_CHANNELS];
  logic [NUM_CHANNELS-1:0] snap_valid;
  logic [31:0] snap_seq[NUM_CHANNELS];
  logic [NUM_CHANNELS-1:0] err_req,err_ack;
  (* async_reg="true" *) logic [NUM_CHANNELS-1:0] err_req_sync[SYNC_STAGES],err_ack_sync[SYNC_STAGES];
  (* async_reg="true" *) logic [NUM_CHANNELS-1:0] irq_sync[SYNC_STAGES],fault_sync[SYNC_STAGES],local_sync[SYNC_STAGES];
  (* async_reg="true" *) logic [SYNC_STAGES-1:0] system_sync,safe_sync;
  logic [NUM_CHANNELS-1:0] irq_w,fault_w,final_w,safe_w,alert_w,wake_w,cmd_v;
  snapshot_t channel_snap[NUM_CHANNELS];
  logic [7:0] channel_result[NUM_CHANNELS];
  logic [1:0] arb_req,arb_grant;
  logic mailbox_available,execute_mailbox;
  logic [SYNC_STAGES-1:0] cancel_sync;
  logic cancel_mailbox;
  logic [31:0] local_read,rdl_read,write_mask;
  logic native_ready,native_error,writable,valid_addr;
  logic format_error,auth_error,busy_error,channel_valid,is_stage,is_command,apb_fire;
  logic [7:0] operation;
  integer channel,index,client_index;
  logic [9:0] offset;
  logic native_req;

  assign native_req=PSEL && PENABLE && apb_rst_n;
  watchdog_reg_adapter u_regs(.clk(pclk),.rst_n(apb_rst_n),.sel(PSEL && apb_rst_n),
    .enable(PENABLE),.write(PWRITE),.prot(PPROT),.strb(PSTRB),
    .addr(PADDR),.wdata(PWDATA),.rdata(local_read),.ready(native_ready),.error(native_error),
    .read_data(rdl_read),.write_mask(write_mask),.writable(writable),.valid_addr(valid_addr));
  always_comb begin
    channel=(int'(PADDR)-'h1000)/'h400;
    channel_valid=PADDR>='h1000 && channel>=0 && channel<NUM_CHANNELS;
    offset=PADDR[9:0]; index=int'(offset)/4; client_index=0;
    if(channel_valid) client_index=int'(client_select[channel]);
    is_stage=channel_valid && (offset<='h3c || offset=='h4c || offset=='h140 ||
      (offset>='h144 && offset<='h15c));
    is_command=channel_valid && offset>='h40 && offset<='h64 && offset!='h4c;
    operation=(offset=='h44) ? PWDATA[7:0] : offset[7:0];
    format_error=PADDR[1:0]!=0 || !valid_addr || (PADDR>='h1000 && !channel_valid);
    auth_error=0; busy_error=0;
    if(PWRITE) begin
      if(channel_valid && offset>='h144 && offset<='h15c && client_index>=NUM_CLIENTS) format_error=1;
      format_error|=PSTRB!=4'hf || !writable || (PWDATA & ~write_mask)!=0;
      if(channel_valid) begin
        if(is_stage) auth_error=!cfg_auth_i;
        else if(is_command) begin
          if(offset=='h50) auth_error=!service_auth_i;
          else if(offset=='h58 || offset=='h5c || offset=='h60) auth_error=!diag_auth_i;
          else if(offset=='h64) auth_error=!diag_auth_i || !cfg_auth_i;
          else if(!(offset=='h44 && PWDATA==SNAPSHOT)) auth_error=!cfg_auth_i;
          busy_error=busy;
        end
      end
    end
    PREADY=apb_rst_n && native_ready;
    PSLVERR=native_req && (format_error || auth_error || busy_error || native_error);
    PRDATA=PSLVERR ? 0 : rdl_read;
    apb_fire=native_req && PREADY;
    local_read=0;
    if(PADDR<'h1000) begin
      case(PADDR)
        'h000: local_read=32'h57445431;
        'h004: local_read=32'h00010000;
        'h008: local_read=32'(NUM_CHANNELS-1) | (32'(NUM_CLIENTS-1)<<5) |
          (32'(COUNTER_WIDTH)<<11) | (32'(PRESCALE_WIDTH)<<18);
        'h00c: local_read=32'(SUPPORT_TOKEN_QA) | (32'(SUPPORT_SUPERVISION)<<1) |
          (32'(SUPPORT_HW_EVENT)<<2) | (32'(SAFETY_EN)<<3) | (32'(ALLOW_RUNTIME_UPDATE)<<4) |
          (32'(DIAG_INJECT_EN)<<5) | (32'(SYNC_STAGES-2)<<8);
        'h010: local_read=32'(busy) | (32'(exec_done)<<1) | (32'(done_result)<<8);
        'h014: local_read=issued_seq;
        'h018: local_read=done_seq;
        'h01c: local_read=done_info;
        'h020: local_read=32'(irq_o);
        'h024: local_read=32'(fault_sync[SYNC_STAGES-1]);
        'h028: local_read=32'(local_sync[SYNC_STAGES-1]) |
          (32'(system_sync[SYNC_STAGES-1])<<16) | (32'(safe_sync[SYNC_STAGES-1])<<17);
        default: local_read=0;
      endcase
    end else if(channel_valid) begin
      if(offset<='h3c) local_read=staging[channel].word[index];
      else if(offset=='h4c) local_read=32'(service_select[channel]);
      else if(offset=='h140) local_read=32'(client_select[channel]);
      else if(offset>='h144 && offset<='h15c && client_index<NUM_CLIENTS)
        local_read=staging[channel].client[client_index][(int'(offset)-'h144)/4];
      else if(offset=='h68) local_read=32'(snap_valid[channel]);
      else if(offset=='h6c) local_read=snap_seq[channel];
      else if(snap_valid[channel]) begin
        if(offset>='h180 && offset<='h1b8 && client_index<NUM_CLIENTS)
          local_read=snapshots[channel].client[client_index][(int'(offset)-'h180)/4];
        else if(offset>='h70 && offset<'h140) local_read=snapshots[channel].word[index];
      end
    end
  end
  always_ff @(posedge pclk or negedge apb_rst_n) begin
    if(!apb_rst_n) begin
      for(int i=0;i<NUM_CHANNELS;i++) begin
        staging[i]<=DEFAULT_CFG[i]; client_select[i]<=0; service_select[i]<=0;
      end
    end else if(apb_fire && PWRITE && !PSLVERR && is_stage) begin
      if(offset<='h3c) staging[channel].word[index]<=PWDATA;
      else if(offset=='h4c) service_select[channel]<=PWDATA[10:0];
      else if(offset=='h140) client_select[channel]<=PWDATA[4:0];
      else if(client_index<NUM_CLIENTS)
        staging[channel].client[client_index][(int'(offset)-'h144)/4]<=PWDATA;
    end
  end
  // POR-retained APB mailbox storage, including sequence and completion records.
  always_ff @(posedge pclk or negedge prst_n) begin
    if(!prst_n) begin
      req_toggle<=0; req_bar<=1; mailbox_parity<=0; mailbox_cmd<='0; mailbox_config<='0;
      busy<=0; exec_done<=0; issued_seq<=0; done_seq<=0; done_info<=0; done_result<=0;
      snap_valid<='0; err_req<='0;
      for(int i=0;i<NUM_CHANNELS;i++) begin snapshots[i]<='0; snap_seq[i]<=0; end
    end else begin
      for(int i=0;i<NUM_CHANNELS;i++) if(err_ack_sync[SYNC_STAGES-1][i]) err_req[i]<=0;
      if(apb_fire && PSLVERR && channel_valid && !busy_error) err_req[channel]<=1;
      if(busy && ack_sync[SYNC_STAGES-1]==req_toggle) begin
        busy<=0; exec_done<=1; done_seq<=mailbox_cmd.seq; done_result<=reply_result;
        done_info<=32'(mailbox_cmd.channel) | (32'(mailbox_cmd.client)<<4) | (32'(mailbox_cmd.opcode)<<9);
        if(mailbox_cmd.opcode==SNAPSHOT && reply_result==OK) begin
          snapshots[mailbox_cmd.channel]<=reply_snapshot;
          snap_valid[mailbox_cmd.channel]<=1; snap_seq[mailbox_cmd.channel]<=mailbox_cmd.seq;
        end
      end
      if(apb_fire && PWRITE && !PSLVERR && is_command) begin
        req_toggle<=~req_toggle; req_bar<=req_toggle; busy<=1; exec_done<=0; issued_seq<=issued_seq+1'b1;
        mailbox_cmd.channel<=4'(channel); mailbox_cmd.client<=service_select[channel][4:0];
        mailbox_cmd.event_type<=service_select[channel][10:8]; mailbox_cmd.opcode<=operation;
        mailbox_cmd.data<=PWDATA; mailbox_cmd.seq<=issued_seq+1'b1;
        mailbox_cmd.source<=16'(access_source_i);
        mailbox_cmd.cfg_auth<=cfg_auth_i; mailbox_cmd.service_auth<=service_auth_i;
        mailbox_cmd.diag_auth<=diag_auth_i; mailbox_cmd.hardware<=0;
        mailbox_config<=staging[channel];
        mailbox_parity<=^{4'(channel),service_select[channel][4:0],service_select[channel][10:8],
          operation,PWDATA,issued_seq+32'b1,16'(access_source_i),cfg_auth_i,service_auth_i,diag_auth_i,1'b0,staging[channel]};
      end
    end
  end
  always_ff @(posedge pclk or negedge prst_n) begin
    if(!prst_n) begin
      ack_sync<='0;
      for(int k=0;k<SYNC_STAGES;k++) err_ack_sync[k]<='0;
    end else begin
      ack_sync<={ack_sync[SYNC_STAGES-2:0],ack_toggle};
      err_ack_sync[0]<=err_ack;
      for(int k=1;k<SYNC_STAGES;k++) err_ack_sync[k]<=err_ack_sync[k-1];
    end
  end
  always_ff @(posedge pclk or negedge apb_rst_n) begin
    if(!apb_rst_n) begin
      system_sync<='0; safe_sync<='0;
      for(int k=0;k<SYNC_STAGES;k++) begin irq_sync[k]<='0; fault_sync[k]<='0; local_sync[k]<='0; end
    end else begin
      system_sync<={system_sync[SYNC_STAGES-2:0],system_reset_req_o};
      safe_sync<={safe_sync[SYNC_STAGES-2:0],safe_state_req_o};
      irq_sync[0]<=irq_w; fault_sync[0]<=fault_w; local_sync[0]<=local_reset_req_o;
      for(int k=1;k<SYNC_STAGES;k++) begin
        irq_sync[k]<=irq_sync[k-1]; fault_sync[k]<=fault_sync[k-1]; local_sync[k]<=local_sync[k-1];
      end
    end
  end
  always_ff @(posedge wdt_clk or negedge wrst_n) begin
    if(!wrst_n) begin
      req_sync<='0; cancel_sync<='0; err_ack<='0; control_error_sync<='0; ack_bar<=1;
      for(int k=0;k<SYNC_STAGES;k++) err_req_sync[k]<='0;
      ack_toggle<=0; reply_result<=0; reply_snapshot<='0;
    end else begin
      req_sync<={req_sync[SYNC_STAGES-2:0],req_toggle};
      cancel_sync<=warm_reset_evt_i ? '1 : {cancel_sync[SYNC_STAGES-2:0],1'b0};
      control_error_sync<={control_error_sync[SYNC_STAGES-2:0],(req_toggle!=~req_bar)};
      err_req_sync[0]<=err_req;
      for(int k=1;k<SYNC_STAGES;k++) err_req_sync[k]<=err_req_sync[k-1];
      err_ack<=err_req_sync[SYNC_STAGES-1];
      if(execute_mailbox) begin
        ack_toggle<=req_sync[SYNC_STAGES-1]; ack_bar<=~req_sync[SYNC_STAGES-1];
        reply_result<=cancel_mailbox ? CANCELED_RESET : mailbox_integrity ? CANCELED_FAULT : channel_result[mailbox_cmd.channel];
        if(mailbox_cmd.opcode==SNAPSHOT) reply_snapshot<=channel_snap[mailbox_cmd.channel];
      end
    end
  end
  assign mailbox_integrity=SAFETY_EN && (control_error_sync[SYNC_STAGES-1] || ack_toggle!=~ack_bar ||
     (mailbox_available && ((^{mailbox_cmd,mailbox_config})!=mailbox_parity)));
  assign mailbox_available=req_sync[SYNC_STAGES-1]!=ack_toggle;
  assign arb_req=cancel_mailbox ? 2'b00 :
    {SUPPORT_HW_EVENT && hw_evt_valid,mailbox_available};
  round_robin_arbiter #(.NUM_REQ(2),.PC_IMPL(0)) u_arb(
    .clk(wdt_clk),.rst_n(wrst_n),.req_i(arb_req),.grant_ack_i(1'b1),.grant_o(arb_grant));
  // Warm reset cancels a visible command regardless of the service arbiter.
  assign cancel_mailbox=warm_reset_evt_i || cancel_sync[SYNC_STAGES-1];
  assign execute_mailbox=(arb_grant[0] || cancel_mailbox) && mailbox_available;
  assign hw_evt_ready=wrst_n && SUPPORT_HW_EVENT && arb_grant[1] && !warm_reset_evt_i && !execute_mailbox;
  always_comb begin
    selected_cmd=mailbox_cmd;
    if(hw_evt_ready) begin
      selected_cmd='0; selected_cmd.channel=hw_evt_channel; selected_cmd.client=hw_evt_client;
      selected_cmd.event_type=hw_evt_type; selected_cmd.opcode=SERVICE; selected_cmd.data=hw_evt_data;
      selected_cmd.source=16'(hw_evt_source); selected_cmd.hardware=1; selected_cmd.service_auth=1;
    end
    cmd_v='0;
    if(execute_mailbox && !cancel_mailbox && !mailbox_integrity) cmd_v[mailbox_cmd.channel]=1;
    else if(hw_evt_ready && hw_evt_valid && int'(hw_evt_channel)<NUM_CHANNELS) cmd_v[hw_evt_channel]=1;
  end
  for(genvar ch=0;ch<NUM_CHANNELS;ch++) begin : g_channel
    watchdog_channel #(.CHANNEL_ID(ch),.COUNTER_WIDTH(COUNTER_WIDTH),.PRESCALE_WIDTH(PRESCALE_WIDTH),
      .NUM_CLIENTS(NUM_CLIENTS),.SOURCE_WIDTH(SOURCE_WIDTH),.SUPPORT_TOKEN_QA(SUPPORT_TOKEN_QA),
      .SUPPORT_SUPERVISION(SUPPORT_SUPERVISION),.SUPPORT_HW_EVENT(SUPPORT_HW_EVENT),.SAFETY_EN(SAFETY_EN),
      .ALLOW_RUNTIME_UPDATE(ALLOW_RUNTIME_UPDATE),.AUTO_START(AUTO_START_MASK[ch]),.NO_STOP(NO_STOP_MASK[ch]),
      .HARD_CFG_LOCK(HARD_CFG_LOCK_MASK[ch]),.DIAG_INJECT_EN(DIAG_INJECT_EN),.DEFAULT_CFG(DEFAULT_CFG[ch])) u_channel(
      .clk(wdt_clk),.rst_n(wrst_n),.cmd_valid(cmd_v[ch]),.cmd(selected_cmd),.cmd_config(mailbox_config),
      .access_error(err_req_sync[SYNC_STAGES-1][ch] && !err_ack[ch]),.cdc_error(mailbox_integrity),
      .sleep_req(sleep_req_i),.debug_req(debug_req_i),.debug_auth(debug_auth_i),
      .warm_reset_evt(warm_reset_evt_i),.recovery_done(recovery_done_i[ch]),.test_auth(test_auth_i),
      .result(channel_result[ch]),.snapshot_next(channel_snap[ch]),.irq(irq_w[ch]),.active_fault(fault_w[ch]),
      .pause_ack(pause_ack_o[ch]),.recovery_ack(recovery_ack_o[ch]),.nmi_req(nmi_req_o[ch]),
      .local_reset_req(local_reset_req_o[ch]),.system_reset_req(final_w[ch]),.safe_state_req(safe_w[ch]),
      .safety_alert(alert_w[ch]),.wake_req(wake_w[ch]));
  end
  assign irq_o=irq_sync[SYNC_STAGES-1];
  assign system_reset_req_o=|final_w;
  assign safety_alert_o=|alert_w;
  assign safe_state_req_o=|safe_w;
  assign wake_req_o=|wake_w;
endmodule
