// LLD.MOD.GPIO.INPUT: registered stages consume pre-edge upstream values.
module gpio_input #(
  parameter int N_GPIO = 32,
  parameter int SYNC_STAGES = 2,
  parameter logic [N_GPIO-1:0] INPUT_CAP_MASK = '1,
  localparam int N_BANK = (N_GPIO+31)/32
) (
  input logic clk_i, rst_ni,
  input logic [N_GPIO-1:0] pad_i, available_i, enable_i,
  input logic [N_GPIO-1:0] filter_enable_i, debounce_enable_i, invert_i, restart_i,
  input logic [N_GPIO-1:0][7:0] filter_count_i, debounce_count_i,
  input logic [N_BANK-1:0][15:0] divider_i,
  input logic [N_BANK-1:0] divider_write_i,
  output logic [N_GPIO-1:0] sync_o, sync_valid_o, data_o, valid_o
);
  (* ASYNC_REG = "TRUE" *) logic [N_GPIO-1:0] sync_q [SYNC_STAGES];
  logic [N_BANK-1:0][15:0] div_q;
  logic [N_BANK-1:0] tick;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (int s=0; s<SYNC_STAGES; s++) sync_q[s] <= '0;
    end else begin
      sync_q[0] <= pad_i;
      for (int s=1; s<SYNC_STAGES; s++) sync_q[s] <= sync_q[s-1];
    end
  end
  for (genvar b=0; b<N_BANK; b++) begin : g_bank
    assign tick[b] = div_q[b] == divider_i[b];
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) div_q[b] <= '0;
      else if (divider_write_i[b] || tick[b]) div_q[b] <= '0;
      else div_q[b] <= div_q[b] + 16'd1;
    end
  end
  for (genvar i=0; i<N_GPIO; i++) begin : g_pin
    logic [2:0] fill_q;
    logic f_candidate_q, f_value_q, f_valid_q;
    logic d_candidate_q, d_value_q, d_valid_q;
    logic [8:0] f_count_q, d_count_q;
    logic active, ready, f_value, f_valid, d_value, d_valid;
    logic [8:0] f_next_count, d_next_count;
    assign active = INPUT_CAP_MASK[i] & enable_i[i] & available_i[i];
    assign ready = active && fill_q == 3'(SYNC_STAGES);
    assign sync_valid_o[i] = ready;
    assign sync_o[i] = ready ? sync_q[SYNC_STAGES-1][i] : 1'b0;
    assign f_value = filter_enable_i[i] ? f_value_q : sync_o[i];
    assign f_valid = filter_enable_i[i] ? f_valid_q : ready;
    assign d_value = debounce_enable_i[i] ? d_value_q : f_value;
    assign d_valid = debounce_enable_i[i] ? d_valid_q : f_valid;
    assign f_next_count = (f_count_q == 0 || sync_o[i] != f_candidate_q)
                         ? 9'd1 : (f_count_q < 9'd256 ? f_count_q+9'd1 : 9'd256);
    assign d_next_count = (d_count_q == 0 || f_value != d_candidate_q)
                         ? 9'd1 : (d_count_q < 9'd256 ? d_count_q+9'd1 : 9'd256);
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        fill_q <= '0;
        f_candidate_q <= 1'b0; f_value_q <= 1'b0; f_valid_q <= 1'b0; f_count_q <= '0;
        d_candidate_q <= 1'b0; d_value_q <= 1'b0; d_valid_q <= 1'b0; d_count_q <= '0;
        data_o[i] <= 1'b0; valid_o[i] <= 1'b0;
      end else if (!active || restart_i[i] || (divider_write_i[i/32] && debounce_enable_i[i])) begin
        fill_q <= '0;
        f_candidate_q <= 1'b0; f_value_q <= 1'b0; f_valid_q <= 1'b0; f_count_q <= '0;
        d_candidate_q <= 1'b0; d_value_q <= 1'b0; d_valid_q <= 1'b0; d_count_q <= '0;
        data_o[i] <= 1'b0; valid_o[i] <= 1'b0;
      end else begin
        if (!ready) fill_q <= fill_q + 3'd1;
        if (ready && filter_enable_i[i]) begin
          f_candidate_q <= sync_o[i]; f_count_q <= f_next_count;
          if (f_next_count >= {1'b0,filter_count_i[i]}+9'd1) begin
            f_value_q <= sync_o[i]; f_valid_q <= 1'b1;
          end
        end
        if (f_valid && tick[i/32] && debounce_enable_i[i]) begin
          d_candidate_q <= f_value; d_count_q <= d_next_count;
          if (d_next_count >= {1'b0,debounce_count_i[i]}+9'd1) begin
            d_value_q <= f_value; d_valid_q <= 1'b1;
          end
        end
        valid_o[i] <= d_valid;
        data_o[i] <= d_valid ? d_value ^ invert_i[i] : 1'b0;
      end
    end
  end
endmodule
