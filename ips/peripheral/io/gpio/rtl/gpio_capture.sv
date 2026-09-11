// LLD.MOD.GPIO.CAPTURE: one atomic pre-edge snapshot; strap is physical and one-shot.
module gpio_capture #(
  parameter int N_GPIO=32,
  parameter bit SNAPSHOT_EN=1, STRAP_EN=1,
  parameter logic [N_GPIO-1:0] INPUT_CAP_MASK='1
) (
  input logic clk_i, rst_ni,
  input logic [N_GPIO-1:0] data_i, valid_i, sync_i, sync_valid_i,
  input logic snapshot_sw_i, snapshot_hw_i, strap_sample_i, clear_early_i,
  output logic [N_GPIO-1:0] snapshot_data_o, snapshot_valid_o, strap_data_o,
  output logic [31:0] sequence_o,
  output logic strap_valid_o, strap_early_o
);
  logic strap_ready;
  assign strap_ready = (sync_valid_i & INPUT_CAP_MASK) == INPUT_CAP_MASK;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      snapshot_data_o<='0; snapshot_valid_o<='0; sequence_o<='0;
      strap_data_o<='0; strap_valid_o<=1'b0; strap_early_o<=1'b0;
    end else begin
      if (SNAPSHOT_EN && (snapshot_sw_i || snapshot_hw_i)) begin
        snapshot_data_o<=data_i; snapshot_valid_o<=valid_i; sequence_o<=sequence_o+32'd1;
      end
      if (clear_early_i) strap_early_o<=1'b0;
      if (STRAP_EN && strap_sample_i && !strap_valid_o) begin
        if (strap_ready) begin strap_data_o<=sync_i & INPUT_CAP_MASK; strap_valid_o<=1'b1; end
        else strap_early_o<=1'b1;
      end
    end
  end
endmodule
