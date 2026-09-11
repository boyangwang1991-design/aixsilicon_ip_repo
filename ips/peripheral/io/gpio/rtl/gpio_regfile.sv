// LLD.MOD.GPIO.REG. Addresses and external register strobes come only from RDL-derived logic.
module gpio_regfile #(
  parameter int N_GPIO=32, SYNC_STAGES=2, N_IRQ_GROUPS=1, EVENT_FIFO_DEPTH=16,
  parameter bit OUT_INV_EN=1, AON_WAKE_EN=1, SNAPSHOT_EN=1, STRAP_EN=1,
  parameter bit DIAG_EN=1, ACCESS_CTRL_EN=1, CFG_PARITY_EN=0,
  parameter bit BOOT_SECURE_ONLY=1, BOOT_PRIV_ONLY=1,
  parameter logic [N_GPIO-1:0] INPUT_CAP_MASK='1, OUTPUT_CAP_MASK='1,
  parameter logic [N_GPIO-1:0] RESET_OUT='0, RESET_OE='0, RESET_IN_EN=INPUT_CAP_MASK,
  localparam int N_BANK=(N_GPIO+31)/32
) (
  input logic clk_i, rst_ni, por_ni,
  input gpio_reg_desc_pkg::gpio_reg_desc_t descriptor_i,
  input logic pwrite_i, access_error_i,
  input logic [13:0] paddr_i,
  input logic [2:0] pprot_i,
  input logic [3:0] pstrb_i,
  input logic [31:0] write_data_i, byte_mask_i,
  input logic [gpio_reg_desc_pkg::GPIO_REG_COUNT-1:0] write_strobe_i, read_strobe_i,
  input gpio_pkg::gpio_status_t status_i,
  output gpio_pkg::gpio_config_t config_o,
  output gpio_pkg::gpio_command_t command_o,
  output logic [31:0] read_words_o [gpio_reg_desc_pkg::GPIO_REG_COUNT],
  output logic optional_disabled_o, semantic_error_o, fault_irq_o, parity_error_o
);
  import gpio_pkg::*;
  import gpio_reg_desc_pkg::*;
  gpio_config_t q, d;
  logic access_fault_q;
  logic [31:0] access_first_q;
  logic [3:0][351:0] aon_cache_q;
  logic [127:0] exists_mask, input_cap, output_cap;
  logic [7:0] faults;
  logic [31:0] old_word, new_word, target, effective_write_mask;
  logic [31:0] bank_exists, bank_input_cap, bank_output_cap, bank_cfg_lock, bank_data_lock;
  logic full_strobe_required, global_protected, bit_operation, output_operation, cfg_operation;
  logic [1:0] selected_bank;
  assign config_o=q;
  always_comb begin
    exists_mask='0; input_cap='0; output_cap='0;
    exists_mask[N_GPIO-1:0]='1; input_cap[N_GPIO-1:0]=INPUT_CAP_MASK; output_cap[N_GPIO-1:0]=OUTPUT_CAP_MASK;
  end
  assign faults={status_i.aon_error_fault,status_i.fifo_watermark,|(status_i.diag_pending & q.diag_enable),
                 status_i.parity_safe,status_i.strap_early,status_i.aon_timeout_fault,status_i.fifo_overflow,access_fault_q};
  assign fault_irq_o=|(faults & q.fault_irq_enable);
  assign selected_bank=descriptor_i.instance_id[1:0];
  always_comb begin
    optional_disabled_o=1'b0;
    case (descriptor_i.op)
      OP_ACCESS_CFG: optional_disabled_o=!ACCESS_CTRL_EN;
      OP_SNAPSHOT_CMD,OP_SNAP_SEQ,OP_BANK_SNAP_DATA,OP_BANK_SNAP_VALID: optional_disabled_o=!SNAPSHOT_EN;
      OP_STRAP_VALID,OP_BANK_STRAP_DATA: optional_disabled_o=!STRAP_EN;
      OP_TS_LO,OP_TS_HI,OP_FIFO_CTRL,OP_FIFO_WATERMARK,OP_FIFO_LEVEL,OP_FIFO_LOST,
      OP_EVENT_HEAD0,OP_EVENT_HEAD1,OP_EVENT_HEAD2,OP_EVENT_HEAD3,OP_EVENT_POP,OP_FIFO_CMD,OP_BANK_EVENT_ENABLE:
        optional_disabled_o=EVENT_FIFO_DEPTH==0;
      OP_PIN_DIAG_CFG,OP_BANK_DIAG_ENABLE,OP_BANK_DIAG_PENDING,OP_BANK_DIAG_TEST: optional_disabled_o=!DIAG_EN;
      OP_PARITY_INJECT: optional_disabled_o=!CFG_PARITY_EN;
      OP_AON_STATUS,OP_AON_TIMEOUT: optional_disabled_o=!AON_WAKE_EN;
      default: if (descriptor_i.group_id==2'd3) optional_disabled_o=!AON_WAKE_EN;
    endcase
    old_word=read_words_o[descriptor_i.index];
    effective_write_mask=byte_mask_i & descriptor_i.write_mask;
    if (descriptor_i.op==OP_PIN_PIN_CFG && !OUT_INV_EN) effective_write_mask[4]=1'b0;
    new_word=(old_word & ~effective_write_mask) | (write_data_i & effective_write_mask);
    bank_exists=exists_mask[32*selected_bank+:32]; bank_input_cap=input_cap[32*selected_bank+:32];
    bank_output_cap=output_cap[32*selected_bank+:32]; bank_cfg_lock=status_i.cfg_lock[32*selected_bank+:32];
    bank_data_lock=status_i.data_lock[32*selected_bank+:32];
    target=effective_write_mask & bank_exists;
    full_strobe_required=1'b0; global_protected=1'b0; bit_operation=1'b0; output_operation=1'b0; cfg_operation=1'b0;
    case (descriptor_i.op)
      OP_BANK_OUT_SET,OP_BANK_OUT_CLR,OP_BANK_OUT_TOGGLE,OP_BANK_OE_SET,OP_BANK_OE_CLR,
      OP_BANK_CFG_LOCK,OP_BANK_DATA_LOCK,OP_BANK_IRQ_PENDING,OP_BANK_RISING_PENDING,OP_BANK_FALLING_PENDING,OP_BANK_DIAG_PENDING:
        bit_operation=1'b1;
      default: bit_operation=1'b0;
    endcase
    if (bit_operation) target=target & write_data_i;
    case (descriptor_i.op)
      OP_BANK_OUT_MASKED_LO,OP_BANK_OE_MASKED_LO: begin target={16'd0,write_data_i[31:16]} & bank_exists; full_strobe_required=1'b1; end
      OP_BANK_OUT_MASKED_HI,OP_BANK_OE_MASKED_HI: begin target={write_data_i[31:16],16'd0} & bank_exists; full_strobe_required=1'b1; end
      OP_FAULT_CLEAR,OP_SNAPSHOT_CMD,OP_EVENT_POP,OP_FIFO_CMD,OP_PARITY_INJECT,OP_BANK_IRQ_TEST,OP_BANK_DIAG_TEST,OP_AON_AON_CMD:
        full_strobe_required=1'b1;
      default: begin end
    endcase
    case (descriptor_i.op)
      OP_BANK_OUT_DATA,OP_BANK_OUT_OE,OP_BANK_OUT_SET,OP_BANK_OUT_CLR,OP_BANK_OUT_TOGGLE,
      OP_BANK_OE_SET,OP_BANK_OE_CLR,OP_BANK_OUT_MASKED_LO,OP_BANK_OUT_MASKED_HI,OP_BANK_OE_MASKED_LO,OP_BANK_OE_MASKED_HI:
        output_operation=1'b1;
      OP_BANK_IN_ENABLE,OP_BANK_IRQ_DETECT_EN,OP_BANK_IRQ_ENABLE,OP_BANK_EVENT_ENABLE,OP_BANK_DIAG_ENABLE:
        cfg_operation=1'b1;
      default: begin end
    endcase
    case (descriptor_i.op)
      OP_ACCESS_CFG,OP_FAULT_IRQ_ENABLE,OP_FIFO_CTRL,OP_FIFO_WATERMARK,OP_AON_TIMEOUT,
      OP_BANK_BANK_DEBOUNCE_DIV,OP_BANK_IN_ENABLE,OP_BANK_IRQ_DETECT_EN,OP_BANK_IRQ_ENABLE,
      OP_BANK_EVENT_ENABLE,OP_BANK_DIAG_ENABLE,OP_PIN_PIN_CFG,OP_PIN_FILTER_CFG,OP_PIN_DEBOUNCE_CFG,OP_PIN_DIAG_CFG:
        global_protected=|effective_write_mask;
      OP_PARITY_INJECT,OP_BANK_IRQ_TEST,OP_BANK_DIAG_TEST: global_protected=|(write_data_i & descriptor_i.write_mask);
      OP_AON_AON_CMD: global_protected=write_data_i[0] || write_data_i[3];
      default: begin end
    endcase
    semantic_error_o=1'b0;
    if (pwrite_i && !optional_disabled_o) begin
      if (full_strobe_required && pstrb_i!=4'hf) semantic_error_o=1'b1;
      if (status_i.global_lock && global_protected) semantic_error_o=1'b1;
      if (output_operation && |(target & bank_data_lock)) semantic_error_o=1'b1;
      if (cfg_operation && |(target & bank_cfg_lock)) semantic_error_o=1'b1;
      if (descriptor_i.op==OP_BANK_BANK_DEBOUNCE_DIV && |effective_write_mask && |bank_cfg_lock) semantic_error_o=1'b1;
      if (descriptor_i.group_id==2'd2 && |effective_write_mask && status_i.cfg_lock[descriptor_i.instance_id]) semantic_error_o=1'b1;
      if (output_operation) begin
        if (descriptor_i.op==OP_BANK_OUT_MASKED_LO || descriptor_i.op==OP_BANK_OE_MASKED_LO) begin
          if (|(target & {16'd0,write_data_i[15:0]} & ~bank_output_cap)) semantic_error_o=1'b1;
        end else if (descriptor_i.op==OP_BANK_OUT_MASKED_HI || descriptor_i.op==OP_BANK_OE_MASKED_HI) begin
          if (|(target & {write_data_i[15:0],16'd0} & ~bank_output_cap)) semantic_error_o=1'b1;
        end else if (|(write_data_i & target & ~bank_output_cap)) semantic_error_o=1'b1;
      end
      if (cfg_operation && |(write_data_i & target & ~bank_input_cap)) semantic_error_o=1'b1;
      if (descriptor_i.op==OP_PIN_PIN_CFG) begin
        if (byte_mask_i[0] && new_word[7:5]>3'd5) semantic_error_o=1'b1;
        if (byte_mask_i[8] && new_word[9:8]>=N_IRQ_GROUPS) semantic_error_o=1'b1;
        if (byte_mask_i[8] && status_i.sleep_ack) semantic_error_o=1'b1;
        if (q.out_oe[descriptor_i.instance_id] && |((new_word^old_word)&32'h18)) semantic_error_o=1'b1;
        if (!input_cap[descriptor_i.instance_id] && |(write_data_i & effective_write_mask & 32'he7)) semantic_error_o=1'b1;
        if (!output_cap[descriptor_i.instance_id] && |(write_data_i & effective_write_mask & 32'h18)) semantic_error_o=1'b1;
      end
      if (descriptor_i.op==OP_PIN_DIAG_CFG && |effective_write_mask[15:0] && new_word[15:0]<SYNC_STAGES+2) semantic_error_o=1'b1;
      if (descriptor_i.op==OP_FIFO_WATERMARK && |effective_write_mask && (new_word[6:0]<1 || new_word[6:0]>EVENT_FIFO_DEPTH)) semantic_error_o=1'b1;
      if (descriptor_i.op==OP_AON_TIMEOUT && |effective_write_mask && new_word[23:0]<24'd16) semantic_error_o=1'b1;
      if (descriptor_i.op==OP_PARITY_INJECT && write_data_i[0] && write_data_i[9:8]>=N_BANK) semantic_error_o=1'b1;
      if (descriptor_i.group_id==2'd3) begin
        if (descriptor_i.op==OP_AON_AON_CMD) begin
          if (write_data_i[3:0]!=0) begin
            if (!status_i.aon_ready || status_i.aon_busy) semantic_error_o=1'b1;
            if ((write_data_i[3:0] & (write_data_i[3:0]-4'd1))!=0) semantic_error_o=1'b1;
            if (ACCESS_CTRL_EN && write_data_i[3] && (pprot_i[1] || !pprot_i[0])) semantic_error_o=1'b1;
          end
        end else if (descriptor_i.writable && |effective_write_mask && status_i.aon_busy) semantic_error_o=1'b1;
      end
    end
  end
  always_comb begin
    d=q; command_o='0;
    command_o.access_value=status_i.access_cfg;
    if (!optional_disabled_o && write_strobe_i[descriptor_i.index]) begin
      case (descriptor_i.op)
        OP_GLOBAL_LOCK: command_o.global_set=write_data_i[0] && byte_mask_i[0];
        OP_ACCESS_CFG: begin command_o.access_write=|effective_write_mask; command_o.access_value=new_word[1:0]; end
        OP_FAULT_IRQ_ENABLE: d.fault_irq_enable=new_word[7:0];
        OP_FAULT_CLEAR: begin
          command_o.clear_overflow=write_data_i[1]; command_o.clear_aon_timeout=write_data_i[2];
          command_o.clear_strap_early=write_data_i[3]; command_o.clear_aon_error=write_data_i[7];
        end
        OP_SNAPSHOT_CMD: command_o.snapshot=write_data_i[0];
        OP_FIFO_CTRL: d.fifo_ctrl=new_word[1:0];
        OP_FIFO_WATERMARK: d.watermark=new_word[6:0];
        OP_EVENT_POP: command_o.fifo_pop=write_data_i[0];
        OP_FIFO_CMD: begin command_o.fifo_flush=write_data_i[0]; command_o.clear_lost=write_data_i[1]; end
        OP_AON_TIMEOUT: d.aon_timeout=new_word[23:0];
        OP_PARITY_INJECT: command_o.parity_inject[write_data_i[9:8]]=write_data_i[0];
        OP_BANK_IN_ENABLE: d.in_enable[32*selected_bank+:32]=new_word & bank_exists;
        OP_BANK_OUT_DATA: d.out_data[32*selected_bank+:32]=new_word & bank_exists;
        OP_BANK_OUT_OE: d.out_oe[32*selected_bank+:32]=new_word & bank_exists;
        OP_BANK_OUT_SET: d.out_data[32*selected_bank+:32]=q.out_data[32*selected_bank+:32] | target;
        OP_BANK_OUT_CLR: d.out_data[32*selected_bank+:32]=q.out_data[32*selected_bank+:32] & ~target;
        OP_BANK_OUT_TOGGLE: d.out_data[32*selected_bank+:32]=q.out_data[32*selected_bank+:32] ^ target;
        OP_BANK_OE_SET: d.out_oe[32*selected_bank+:32]=q.out_oe[32*selected_bank+:32] | target;
        OP_BANK_OE_CLR: d.out_oe[32*selected_bank+:32]=q.out_oe[32*selected_bank+:32] & ~target;
        OP_BANK_OUT_MASKED_LO,OP_BANK_OUT_MASKED_HI:
          d.out_data[32*selected_bank+:32]=(q.out_data[32*selected_bank+:32] & ~target) |
            (target & (descriptor_i.op==OP_BANK_OUT_MASKED_HI ? {write_data_i[15:0],16'd0} : {16'd0,write_data_i[15:0]}));
        OP_BANK_OE_MASKED_LO,OP_BANK_OE_MASKED_HI:
          d.out_oe[32*selected_bank+:32]=(q.out_oe[32*selected_bank+:32] & ~target) |
            (target & (descriptor_i.op==OP_BANK_OE_MASKED_HI ? {write_data_i[15:0],16'd0} : {16'd0,write_data_i[15:0]}));
        OP_BANK_IRQ_DETECT_EN: d.irq_detect[32*selected_bank+:32]=new_word & bank_exists;
        OP_BANK_IRQ_ENABLE: d.irq_enable[32*selected_bank+:32]=new_word & bank_exists;
        OP_BANK_IRQ_PENDING: command_o.irq_clear[32*selected_bank+:32]=target;
        OP_BANK_RISING_PENDING: command_o.rising_clear[32*selected_bank+:32]=target;
        OP_BANK_FALLING_PENDING: command_o.falling_clear[32*selected_bank+:32]=target;
        OP_BANK_IRQ_TEST: command_o.irq_test[32*selected_bank+:32]=write_data_i & bank_exists;
        OP_BANK_CFG_LOCK: command_o.cfg_set[32*selected_bank+:32]=target;
        OP_BANK_DATA_LOCK: command_o.data_set[32*selected_bank+:32]=target;
        OP_BANK_BANK_DEBOUNCE_DIV: begin d.bank_div[selected_bank]=new_word[15:0]; command_o.divider_write[selected_bank]=|effective_write_mask; end
        OP_BANK_EVENT_ENABLE: d.event_enable[32*selected_bank+:32]=new_word & bank_exists;
        OP_BANK_DIAG_ENABLE: d.diag_enable[32*selected_bank+:32]=new_word & bank_exists;
        OP_BANK_DIAG_PENDING: command_o.diag_clear[32*selected_bank+:32]=target;
        OP_BANK_DIAG_TEST: command_o.diag_test[32*selected_bank+:32]=write_data_i & bank_exists;
        OP_PIN_PIN_CFG: begin
          d.pin_cfg[descriptor_i.instance_id]=new_word[11:0];
          command_o.input_restart[descriptor_i.instance_id]=|((new_word^old_word)&32'h7);
          command_o.irq_restart[descriptor_i.instance_id]=byte_mask_i[0];
        end
        OP_PIN_FILTER_CFG: begin d.filter_cfg[descriptor_i.instance_id]=new_word[7:0]; command_o.input_restart[descriptor_i.instance_id]=|effective_write_mask; end
        OP_PIN_DEBOUNCE_CFG: begin d.debounce_cfg[descriptor_i.instance_id]=new_word[7:0]; command_o.input_restart[descriptor_i.instance_id]=|effective_write_mask; end
        OP_PIN_DIAG_CFG: d.diag_cfg[descriptor_i.instance_id]=new_word[23:0];
        OP_AON_WAKE_ENABLE_STAGE: d.aon_stage[selected_bank][0]=new_word & bank_exists;
        OP_AON_WAKE_MODE_STAGE0: d.aon_stage[selected_bank][1]=new_word & bank_exists;
        OP_AON_WAKE_MODE_STAGE1: d.aon_stage[selected_bank][2]=new_word & bank_exists;
        OP_AON_WAKE_MODE_STAGE2: d.aon_stage[selected_bank][3]=new_word & bank_exists;
        OP_AON_WAKE_DIV_STAGE: d.aon_stage[selected_bank][4]=new_word & 32'hffff;
        OP_AON_WAKE_COUNT_STAGE: d.aon_stage[selected_bank][5]=new_word & 32'hff;
        OP_AON_WAKE_MASK_STAGE: d.aon_stage[selected_bank][6]=new_word & bank_exists;
        OP_AON_AON_CMD: begin
          command_o.aon_command=|write_data_i[3:0]; command_o.aon_bank=selected_bank;
          command_o.aon_request[3:0]=write_data_i[3:0]; command_o.aon_request[5:4]=selected_bank;
          command_o.aon_request[37:6]=q.aon_stage[selected_bank][0];
          command_o.aon_request[69:38]=q.aon_stage[selected_bank][1];
          command_o.aon_request[101:70]=q.aon_stage[selected_bank][2];
          command_o.aon_request[133:102]=q.aon_stage[selected_bank][3];
          command_o.aon_request[149:134]=q.aon_stage[selected_bank][4][15:0];
          command_o.aon_request[157:150]=q.aon_stage[selected_bank][5][7:0];
          command_o.aon_request[189:158]=q.aon_stage[selected_bank][6];
        end
        default: begin end
      endcase
    end
    command_o.timestamp_read=read_strobe_i[IDX_TS_LO] && EVENT_FIFO_DEPTH>0;
    command_o.irq_restart |= command_o.input_restart;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      q<='0;
      q.out_data[N_GPIO-1:0]<=RESET_OUT; q.out_oe[N_GPIO-1:0]<=RESET_OE; q.in_enable[N_GPIO-1:0]<=RESET_IN_EN;
      q.watermark<=EVENT_FIFO_DEPTH>0 ? 7'd1 : 7'd0;
      q.aon_timeout<=AON_WAKE_EN ? 24'd65535 : 24'd0;
      for (int i=0; i<N_GPIO; i++) q.diag_cfg[i]<=DIAG_EN ? 24'(SYNC_STAGES+2) : 24'd0;
      access_fault_q<=1'b0; access_first_q<='0; aon_cache_q<='0;
    end else begin
      q<=d;
      if (write_strobe_i[IDX_FAULT_CLEAR] && write_data_i[0]) begin access_fault_q<=1'b0; access_first_q<='0; end
      if (access_error_i) begin
        access_fault_q<=1'b1;
        if (!access_first_q[31] || (write_strobe_i[IDX_FAULT_CLEAR] && write_data_i[0]))
          access_first_q<={1'b1,11'd0,pwrite_i,pprot_i,2'd0,paddr_i};
      end
      if (AON_WAKE_EN && status_i.aon_response_valid && !status_i.aon_error) aon_cache_q[status_i.aon_bank]<=status_i.aon_response;
    end
  end
  always_comb begin
    for (int r=0; r<GPIO_REG_COUNT; r++) read_words_o[r]=32'd0;
    read_words_o[IDX_IP_ID]=32'h4750494f; read_words_o[IDX_VERSION]=32'h00010000;
    read_words_o[IDX_FEATURE]={24'd0,CFG_PARITY_EN,ACCESS_CTRL_EN,DIAG_EN,(EVENT_FIFO_DEPTH>0),STRAP_EN,SNAPSHOT_EN,AON_WAKE_EN,OUT_INV_EN};
    read_words_o[IDX_GEOMETRY]={8'(SYNC_STAGES),8'(N_IRQ_GROUPS),8'(N_BANK),8'(N_GPIO)};
    read_words_o[IDX_GLOBAL_LOCK]={31'd0,status_i.global_lock}; read_words_o[IDX_ACCESS_CFG]={30'd0,status_i.access_cfg};
    read_words_o[IDX_FAULT_STATUS]={24'd0,faults}; read_words_o[IDX_FAULT_IRQ_ENABLE]={24'd0,q.fault_irq_enable};
    read_words_o[IDX_ACCESS_FIRST]=access_first_q; read_words_o[IDX_SNAP_SEQ]=status_i.snapshot_sequence;
    read_words_o[IDX_STRAP_VALID]={31'd0,status_i.strap_valid}; read_words_o[IDX_LP_STATUS]={30'd0,status_i.safe_active,status_i.sleep_ack};
    read_words_o[IDX_TS_LO]=status_i.timestamp_low; read_words_o[IDX_TS_HI]=status_i.timestamp_high;
    read_words_o[IDX_FIFO_CTRL]={30'd0,q.fifo_ctrl}; read_words_o[IDX_FIFO_WATERMARK]={25'd0,q.watermark};
    read_words_o[IDX_FIFO_LEVEL]={25'd0,status_i.fifo_level}; read_words_o[IDX_FIFO_LOST]=status_i.fifo_lost;
    read_words_o[IDX_EVENT_HEAD0]=status_i.fifo_head[31:0]; read_words_o[IDX_EVENT_HEAD1]=status_i.fifo_head[63:32];
    read_words_o[IDX_EVENT_HEAD2]=status_i.fifo_head[95:64]; read_words_o[IDX_EVENT_HEAD3]=status_i.fifo_head[127:96];
    read_words_o[IDX_AON_STATUS]=AON_WAKE_EN ? {22'd0,status_i.aon_bank,3'd0,status_i.aon_error,status_i.aon_timeout,status_i.aon_done,status_i.aon_busy,status_i.aon_ready} : 32'd0;
    read_words_o[IDX_AON_TIMEOUT]={8'd0,q.aon_timeout};
    for (int b=0; b<N_BANK; b++) begin
      read_words_o[idx_BANK_INPUT_CAP(b)]=input_cap[32*b+:32]; read_words_o[idx_BANK_OUTPUT_CAP(b)]=output_cap[32*b+:32];
      read_words_o[idx_BANK_IN_SYNC(b)]=status_i.sync_data[32*b+:32]; read_words_o[idx_BANK_IN_DATA(b)]=status_i.input_data[32*b+:32];
      read_words_o[idx_BANK_IN_VALID(b)]=status_i.input_valid[32*b+:32]; read_words_o[idx_BANK_IN_ENABLE(b)]=q.in_enable[32*b+:32];
      read_words_o[idx_BANK_OUT_DATA(b)]=q.out_data[32*b+:32]; read_words_o[idx_BANK_OUT_OE(b)]=q.out_oe[32*b+:32];
      read_words_o[idx_BANK_IRQ_DETECT_EN(b)]=q.irq_detect[32*b+:32]; read_words_o[idx_BANK_IRQ_ENABLE(b)]=q.irq_enable[32*b+:32];
      read_words_o[idx_BANK_IRQ_PENDING(b)]=status_i.irq_pending[32*b+:32];
      read_words_o[idx_BANK_IRQ_STATUS(b)]=status_i.irq_pending[32*b+:32] & q.irq_enable[32*b+:32];
      read_words_o[idx_BANK_RISING_PENDING(b)]=status_i.rising_pending[32*b+:32]; read_words_o[idx_BANK_FALLING_PENDING(b)]=status_i.falling_pending[32*b+:32];
      read_words_o[idx_BANK_CFG_LOCK(b)]=status_i.cfg_lock[32*b+:32]; read_words_o[idx_BANK_DATA_LOCK(b)]=status_i.data_lock[32*b+:32];
      read_words_o[idx_BANK_BANK_DEBOUNCE_DIV(b)]={16'd0,q.bank_div[b]}; read_words_o[idx_BANK_EVENT_ENABLE(b)]=q.event_enable[32*b+:32];
      read_words_o[idx_BANK_SNAP_DATA(b)]=status_i.snapshot_data[32*b+:32]; read_words_o[idx_BANK_SNAP_VALID(b)]=status_i.snapshot_valid[32*b+:32];
      read_words_o[idx_BANK_STRAP_DATA(b)]=status_i.strap_data[32*b+:32]; read_words_o[idx_BANK_DIAG_ENABLE(b)]=q.diag_enable[32*b+:32];
      read_words_o[idx_BANK_DIAG_PENDING(b)]=status_i.diag_pending[32*b+:32];
      read_words_o[idx_BANK_OUTPUT_OWNED(b)]=status_i.output_owned[32*b+:32]; read_words_o[idx_BANK_INPUT_AVAILABLE(b)]=status_i.input_available[32*b+:32];
      read_words_o[idx_AON_WAKE_ENABLE_STAGE(b)]=q.aon_stage[b][0]; read_words_o[idx_AON_WAKE_MODE_STAGE0(b)]=q.aon_stage[b][1];
      read_words_o[idx_AON_WAKE_MODE_STAGE1(b)]=q.aon_stage[b][2]; read_words_o[idx_AON_WAKE_MODE_STAGE2(b)]=q.aon_stage[b][3];
      read_words_o[idx_AON_WAKE_DIV_STAGE(b)]=q.aon_stage[b][4]; read_words_o[idx_AON_WAKE_COUNT_STAGE(b)]=q.aon_stage[b][5];
      read_words_o[idx_AON_WAKE_MASK_STAGE(b)]=q.aon_stage[b][6];
      read_words_o[idx_AON_WAKE_PENDING_READ(b)]=aon_cache_q[b][31:0]; read_words_o[idx_AON_WAKE_VALID_READ(b)]=aon_cache_q[b][63:32];
      read_words_o[idx_AON_WAKE_LOCK_READ(b)]=aon_cache_q[b][95:64]; read_words_o[idx_AON_WAKE_ENABLE_READ(b)]=aon_cache_q[b][127:96];
      read_words_o[idx_AON_WAKE_MODE_READ0(b)]=aon_cache_q[b][159:128]; read_words_o[idx_AON_WAKE_MODE_READ1(b)]=aon_cache_q[b][191:160];
      read_words_o[idx_AON_WAKE_MODE_READ2(b)]=aon_cache_q[b][223:192]; read_words_o[idx_AON_WAKE_DIV_READ(b)]=aon_cache_q[b][255:224];
      read_words_o[idx_AON_WAKE_COUNT_READ(b)]=aon_cache_q[b][287:256];
    end
    for (int i=0; i<N_GPIO; i++) begin
      read_words_o[idx_PIN_PIN_CFG(i)]={20'd0,q.pin_cfg[i]}; read_words_o[idx_PIN_FILTER_CFG(i)]={24'd0,q.filter_cfg[i]};
      read_words_o[idx_PIN_DEBOUNCE_CFG(i)]={24'd0,q.debounce_cfg[i]}; read_words_o[idx_PIN_DIAG_CFG(i)]={8'd0,q.diag_cfg[i]};
    end
  end
  if (CFG_PARITY_EN) begin : g_parity
    localparam int WORDS=4*N_BANK+N_GPIO;
    logic [WORDS-1:0] saved_q, current_parity, next_parity, injection;
    logic [31:0] current_words[WORDS], next_words[WORDS];
    logic access_saved_q, access_current, access_next;
    for (genvar b=0; b<N_BANK; b++) begin : g_bank
      assign current_words[4*b]=q.out_data[32*b+:32]; assign next_words[4*b]=d.out_data[32*b+:32];
      assign current_words[4*b+1]=q.out_oe[32*b+:32]; assign next_words[4*b+1]=d.out_oe[32*b+:32];
      assign current_words[4*b+2]=q.irq_enable[32*b+:32]; assign next_words[4*b+2]=d.irq_enable[32*b+:32];
      assign current_words[4*b+3]=q.irq_detect[32*b+:32]; assign next_words[4*b+3]=d.irq_detect[32*b+:32];
      assign injection[4*b]=command_o.parity_inject[b]; assign injection[4*b+1+:3]=3'd0;
    end
    for (genvar i=0; i<N_GPIO; i++) begin : g_pin
      assign current_words[4*N_BANK+i]={20'd0,q.pin_cfg[i]}; assign next_words[4*N_BANK+i]={20'd0,d.pin_cfg[i]};
      assign injection[4*N_BANK+i]=1'b0;
    end
    for (genvar w=0; w<WORDS; w++) begin : g_word
      parity_gen_check #(.DATA_WIDTH(32),.PARITY_TYPE(0),.PC_IMPL(0)) u_current(.data_i(current_words[w]),.parity_o(current_parity[w]));
      parity_gen_check #(.DATA_WIDTH(32),.PARITY_TYPE(0),.PC_IMPL(0)) u_next(.data_i(next_words[w]),.parity_o(next_parity[w]));
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          if (w<4*N_BANK && w%4==0) saved_q[w]<=^(128'(RESET_OUT) >> (32*(w/4)) & 128'hffffffff);
          else if (w<4*N_BANK && w%4==1) saved_q[w]<=^(128'(RESET_OE) >> (32*(w/4)) & 128'hffffffff);
          else saved_q[w]<=1'b0;
        end else saved_q[w]<=next_parity[w] ^ injection[w];
      end
    end
    parity_gen_check #(.DATA_WIDTH(32),.PARITY_TYPE(0),.PC_IMPL(0)) u_access_current(.data_i({30'd0,status_i.access_cfg}),.parity_o(access_current));
    parity_gen_check #(.DATA_WIDTH(32),.PARITY_TYPE(0),.PC_IMPL(0)) u_access_next(.data_i({30'd0,command_o.access_value}),.parity_o(access_next));
    always_ff @(posedge clk_i or negedge por_ni) begin
      if (!por_ni) access_saved_q<=ACCESS_CTRL_EN && (BOOT_PRIV_ONLY ^ BOOT_SECURE_ONLY);
      else access_saved_q<=access_next;
    end
    assign parity_error_o=|(saved_q ^ current_parity) || access_saved_q!=access_current;
  end else begin : g_no_parity
    assign parity_error_o=1'b0;
  end
endmodule
