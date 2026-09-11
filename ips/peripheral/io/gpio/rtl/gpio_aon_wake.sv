// LLD.MOD.GPIO.AON: active configuration and pending have AON cold reset only.
module gpio_aon_wake #(
  parameter int N_GPIO=32,
  parameter logic [N_GPIO-1:0] INPUT_CAP_MASK='1,
  localparam int N_BANK=(N_GPIO+31)/32
) (
  input logic clk_i, rst_ni,
  input logic [N_GPIO-1:0] pad_i, available_i,
  input logic command_i,
  input logic [223:0] request_i,
  output logic response_valid_o, error_o,
  output logic [351:0] response_o,
  output logic wake_req_o
);
  (* ASYNC_REG="TRUE" *) logic [N_GPIO-1:0] sync_q[2];
  logic [N_GPIO-1:0] enable_q, lock_q, pending_q, value_q, valid_q, previous_q, baseline_q;
  logic [N_GPIO-1:0][2:0] mode_q;
  logic [N_BANK-1:0][15:0] divider_q, div_counter_q;
  logic [N_BANK-1:0][7:0] count_cfg_q;
  logic [N_GPIO-1:0][1:0] fill_q;
  logic [N_GPIO-1:0] candidate_q;
  logic [N_GPIO-1:0][8:0] count_q;
  logic [N_GPIO-1:0] event_now, clear_mask, lock_mask, pending_next;
  logic [3:0] cmd;
  logic [1:0] bank;
  logic [31:0] new_enable, new_mode0, new_mode1, new_mode2, mask;
  logic [15:0] new_divider;
  logic [7:0] new_count;
  logic command_error, commit;
  logic [N_BANK-1:0] bank_locked;
  assign cmd=request_i[3:0]; assign bank=request_i[5:4];
  assign new_enable=request_i[37:6]; assign new_mode0=request_i[69:38];
  assign new_mode1=request_i[101:70]; assign new_mode2=request_i[133:102];
  assign new_divider=request_i[149:134]; assign new_count=request_i[157:150];
  assign mask=request_i[189:158];
  assign wake_req_o=|pending_q;
  always_comb begin
    bank_locked='0;
    for (int i=0; i<N_GPIO; i++) bank_locked[i/32] |= lock_q[i];
    command_error=bank>=N_BANK || !(cmd==4'b0001 || cmd==4'b0010 || cmd==4'b0100 || cmd==4'b1000);
    if (cmd==4'b0001) begin
      for (int i=0; i<N_GPIO; i++) begin
        if (i/32==bank) begin
          if (new_enable[i%32] && (!INPUT_CAP_MASK[i] || {new_mode2[i%32],new_mode1[i%32],new_mode0[i%32]}>3'd5)) command_error=1'b1;
          if (lock_q[i] && (new_enable[i%32]!=enable_q[i] || {new_mode2[i%32],new_mode1[i%32],new_mode0[i%32]}!=mode_q[i])) command_error=1'b1;
        end
      end
      for (int b=0; b<N_BANK; b++) begin
        if (bank==b && bank_locked[b] && (divider_q[b]!=new_divider || count_cfg_q[b]!=new_count)) command_error=1'b1;
      end
    end
  end
  assign commit=command_i && !command_error && cmd==4'b0001;
  always_comb begin
    clear_mask='0; lock_mask='0;
    for (int i=0; i<N_GPIO; i++) begin
      if (command_i && !command_error && i/32==bank) begin
        clear_mask[i]=(cmd==4'b0100) && mask[i%32];
        lock_mask[i]=(cmd==4'b1000) && mask[i%32];
      end
    end
  end
  assign pending_next=(pending_q & ~clear_mask) | event_now;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin sync_q[0]<='0; sync_q[1]<='0; end
    else begin sync_q[0]<=pad_i; sync_q[1]<=sync_q[0]; end
  end
  for (genvar b=0; b<N_BANK; b++) begin : g_bank
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin divider_q[b]<='0; count_cfg_q[b]<='0; div_counter_q[b]<='0; end
      else if (commit && bank==b) begin divider_q[b]<=new_divider; count_cfg_q[b]<=new_count; div_counter_q[b]<='0; end
      else if (div_counter_q[b]==divider_q[b]) div_counter_q[b]<='0;
      else div_counter_q[b]<=div_counter_q[b]+16'd1;
    end
  end
  for (genvar i=0; i<N_GPIO; i++) begin : g_pin
    logic [8:0] next_count;
    logic edge_qualified, rising, falling;
    assign next_count=(count_q[i]==0 || sync_q[1][i]!=candidate_q[i]) ? 9'd1 :
                      (count_q[i]<9'd256 ? count_q[i]+9'd1 : 9'd256);
    assign edge_qualified=valid_q[i] && baseline_q[i] && available_i[i] && enable_q[i] && !(commit && bank==i/32);
    assign rising=edge_qualified && !previous_q[i] && value_q[i];
    assign falling=edge_qualified && previous_q[i] && !value_q[i];
    assign event_now[i]=(rising && (mode_q[i]==3'd1 || mode_q[i]==3'd3)) ||
                        (falling && (mode_q[i]==3'd2 || mode_q[i]==3'd3)) ||
                        (valid_q[i] && available_i[i] && enable_q[i] && !(commit && bank==i/32) &&
                         ((mode_q[i]==3'd4 && value_q[i]) || (mode_q[i]==3'd5 && !value_q[i])));
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        enable_q[i]<=1'b0; mode_q[i]<='0; lock_q[i]<=1'b0; pending_q[i]<=1'b0;
        fill_q[i]<='0; count_q[i]<='0; candidate_q[i]<=1'b0;
        value_q[i]<=1'b0; valid_q[i]<=1'b0; previous_q[i]<=1'b0; baseline_q[i]<=1'b0;
      end else begin
        pending_q[i]<=pending_next[i]; lock_q[i]<=lock_q[i] | lock_mask[i];
        previous_q[i]<=value_q[i]; baseline_q[i]<=valid_q[i] && enable_q[i] && available_i[i];
        if (commit && bank==i/32) begin
          enable_q[i]<=new_enable[i%32]; mode_q[i]<={new_mode2[i%32],new_mode1[i%32],new_mode0[i%32]};
        end
        if (!INPUT_CAP_MASK[i] || !available_i[i] || (commit && bank==i/32)) begin
          fill_q[i]<='0; count_q[i]<='0; candidate_q[i]<=1'b0;
          value_q[i]<=1'b0; valid_q[i]<=1'b0; previous_q[i]<=1'b0; baseline_q[i]<=1'b0;
        end else if (fill_q[i]<2'd2) fill_q[i]<=fill_q[i]+2'd1;
        else if (div_counter_q[i/32]==divider_q[i/32]) begin
          count_q[i]<=next_count; candidate_q[i]<=sync_q[1][i];
          if (next_count>={1'b0,count_cfg_q[i/32]}+9'd1) begin value_q[i]<=sync_q[1][i]; valid_q[i]<=1'b1; end
        end
      end
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin response_valid_o<=1'b0; error_o<=1'b0; response_o<='0; end
    else begin
      response_valid_o<=command_i;
      if (command_i) begin
        error_o<=command_error; response_o<='0;
        for (int i=0; i<N_GPIO; i++) begin
          if (i/32==bank) begin
            response_o[i%32]<=cmd==4'b0100 && !command_error ? pending_next[i] : pending_q[i];
            response_o[32+i%32]<=commit ? 1'b0 : valid_q[i] && available_i[i];
            response_o[64+i%32]<=lock_q[i] | lock_mask[i];
            response_o[96+i%32]<=commit ? new_enable[i%32] : enable_q[i];
            response_o[128+i%32]<=commit ? new_mode0[i%32] : mode_q[i][0];
            response_o[160+i%32]<=commit ? new_mode1[i%32] : mode_q[i][1];
            response_o[192+i%32]<=commit ? new_mode2[i%32] : mode_q[i][2];
          end
        end
        for (int b=0; b<N_BANK; b++) begin
          if (bank==b) begin
            response_o[239:224]<=commit ? new_divider : divider_q[b];
            response_o[263:256]<=commit ? new_count : count_cfg_q[b];
          end
        end
      end
    end
  end
endmodule
