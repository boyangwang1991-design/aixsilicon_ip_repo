// LLD.MOD.GPIO.OUTPUT: reset > safe > sleep > normal; final OE guard is unconditional.
module gpio_output #(
  parameter int N_GPIO=32,
  parameter logic [N_GPIO-1:0] OUTPUT_CAP_MASK='1, RESET_OUT='0, RESET_OE='0,
  parameter logic [N_GPIO-1:0] HW_SAFE_OUT='0, HW_SAFE_OE='0
) (
  input logic clk_i, rst_ni,
  input logic [N_GPIO-1:0] data_i, oe_i, invert_i, open_drain_i, owned_i,
  input logic [N_GPIO-1:0][1:0] sleep_mode_i,
  input logic sleep_req_i, safe_req_i, parity_safe_i,
  output logic [N_GPIO-1:0] out_o, oe_o,
  output logic sleep_ack_o, safe_active_o
);
  logic [N_GPIO-1:0] normal_out, normal_oe, hold_out_q, hold_oe_q;
  logic sleep_q;
  assign normal_out = (data_i ^ invert_i) & ~open_drain_i;
  assign normal_oe = oe_i & ~(open_drain_i & (data_i ^ invert_i));
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      sleep_q <= 1'b0; hold_out_q <= '0; hold_oe_q <= '0;
    end else begin
      sleep_q <= sleep_req_i;
      if (sleep_req_i && !sleep_q) begin
        hold_out_q <= normal_out;
        hold_oe_q <= normal_oe & OUTPUT_CAP_MASK & owned_i;
      end
    end
  end
  assign sleep_ack_o = sleep_q;
  assign safe_active_o = rst_ni && (safe_req_i || parity_safe_i);
  always_comb begin
    out_o = normal_out; oe_o = normal_oe;
    for (int i=0; i<N_GPIO; i++) begin
      if (sleep_q) begin
        case (sleep_mode_i[i])
          2'd0: begin out_o[i]=hold_out_q[i]; oe_o[i]=hold_oe_q[i]; end
          2'd1: begin out_o[i]=1'b0; oe_o[i]=1'b1; end
          2'd2: begin out_o[i]=1'b1; oe_o[i]=1'b1; end
          2'd3: begin out_o[i]=1'b0; oe_o[i]=1'b0; end
          default: begin out_o[i]=1'b0; oe_o[i]=1'b0; end
        endcase
      end
    end
    if (safe_active_o) begin out_o=HW_SAFE_OUT; oe_o=HW_SAFE_OE; end
    if (!rst_ni) begin out_o=RESET_OUT; oe_o=RESET_OE; end
    oe_o = oe_o & OUTPUT_CAP_MASK & owned_i;
  end
endmodule
