// LLD.MOD.GPIO.IRQ: fresh edges require a valid, enabled previous baseline.
module gpio_irq #(
  parameter int N_GPIO=32, N_IRQ_GROUPS=1
) (
  input logic clk_i, rst_ni,
  input logic [N_GPIO-1:0] data_i, valid_i, detect_i, enable_i, restart_i,
  input logic [N_GPIO-1:0][2:0] mode_i,
  input logic [N_GPIO-1:0][1:0] group_i,
  input logic [N_GPIO-1:0] clear_i, rising_clear_i, falling_clear_i, test_i,
  output logic [N_GPIO-1:0] pending_o, rising_o, falling_o,
  output logic [N_GPIO-1:0] event_o, edge_now_o, rise_now_o, irq_pin_o,
  output logic [N_IRQ_GROUPS-1:0] irq_group_o,
  output logic irq_summary_o
);
  logic [N_GPIO-1:0] previous_q, baseline_q, hw_event;
  for (genvar i=0; i<N_GPIO; i++) begin : g_pin
    logic rising, falling;
    assign rising = valid_i[i] && detect_i[i] && baseline_q[i] && !restart_i[i]
                    && !previous_q[i] && data_i[i];
    assign falling = valid_i[i] && detect_i[i] && baseline_q[i] && !restart_i[i]
                     && previous_q[i] && !data_i[i];
    assign rise_now_o[i] = rising && (mode_i[i]==3'd1 || mode_i[i]==3'd3);
    assign edge_now_o[i] = rise_now_o[i] || (falling && (mode_i[i]==3'd2 || mode_i[i]==3'd3));
    assign hw_event[i] = edge_now_o[i] || (valid_i[i] && detect_i[i] &&
                         ((mode_i[i]==3'd4 && data_i[i]) || (mode_i[i]==3'd5 && !data_i[i])));
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        previous_q[i]<=1'b0; baseline_q[i]<=1'b0;
        pending_o[i]<=1'b0; rising_o[i]<=1'b0; falling_o[i]<=1'b0; event_o[i]<=1'b0;
      end else begin
        previous_q[i] <= data_i[i];
        baseline_q[i] <= valid_i[i] && detect_i[i];
        pending_o[i] <= (pending_o[i] && !clear_i[i]) || hw_event[i] || test_i[i];
        rising_o[i] <= (rising_o[i] && !rising_clear_i[i]) || rise_now_o[i];
        falling_o[i] <= (falling_o[i] && !falling_clear_i[i]) || (edge_now_o[i] && !rise_now_o[i]);
        event_o[i] <= edge_now_o[i];
      end
    end
  end
  assign irq_pin_o = pending_o & enable_i;
  assign irq_summary_o = |irq_pin_o;
  for (genvar g=0; g<N_IRQ_GROUPS; g++) begin : g_group
    logic [N_GPIO-1:0] members;
    for (genvar i=0; i<N_GPIO; i++) begin : g_member
      assign members[i] = irq_pin_o[i] && group_i[i] == 2'(g);
    end
    assign irq_group_o[g] = |members;
  end
endmodule
