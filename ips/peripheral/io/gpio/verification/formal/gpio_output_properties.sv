module gpio_output_properties #(parameter int N_GPIO=32, parameter logic[N_GPIO-1:0] OUTPUT_CAP_MASK='1,HW_SAFE_OUT='0,HW_SAFE_OE='0)(
 input logic clk_i,rst_ni,sleep_ack_o,safe_active_o,
 input logic[N_GPIO-1:0] out_o,oe_o,owned_i,open_drain_i,data_i,invert_i,oe_i);
 OE_GUARD: assert property (@(posedge clk_i) (oe_o & ~(owned_i & OUTPUT_CAP_MASK))=='0);
 SAFE_OUTPUT: assert property (@(posedge clk_i) disable iff(!rst_ni) safe_active_o |-> out_o==HW_SAFE_OUT);
 SAFE_OE: assert property (@(posedge clk_i) disable iff(!rst_ni) safe_active_o |-> oe_o==(HW_SAFE_OE & owned_i & OUTPUT_CAP_MASK));
 OPEN_DRAIN: assert property (@(posedge clk_i) disable iff(!rst_ni) !sleep_ack_o && !safe_active_o |-> (out_o & open_drain_i)=='0);
 NORMAL_DATA: assert property (@(posedge clk_i) disable iff(!rst_ni) !sleep_ack_o && !safe_active_o |-> out_o==((data_i^invert_i)&~open_drain_i));
 NORMAL_OE: assert property (@(posedge clk_i) disable iff(!rst_ni) !sleep_ack_o && !safe_active_o |-> oe_o==(oe_i & ~(open_drain_i & (data_i^invert_i)) & owned_i & OUTPUT_CAP_MASK));
 REACH_SLEEP: cover property (@(posedge clk_i) rst_ni && sleep_ack_o && !safe_active_o);
 REACH_SAFE: cover property (@(posedge clk_i) rst_ni && safe_active_o);
endmodule
bind gpio_output gpio_output_properties #(.N_GPIO(N_GPIO),.OUTPUT_CAP_MASK(OUTPUT_CAP_MASK),.HW_SAFE_OUT(HW_SAFE_OUT),.HW_SAFE_OE(HW_SAFE_OE)) proof (.*);
