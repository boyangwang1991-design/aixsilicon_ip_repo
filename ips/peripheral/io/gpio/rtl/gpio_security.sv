// LLD.MOD.GPIO.SECURITY: these stores must never use main warm reset.
module gpio_security #(
  parameter int N_GPIO=32,
  parameter bit ACCESS_CTRL_EN=1, BOOT_SECURE_ONLY=1, BOOT_PRIV_ONLY=1
) (
  input logic clk_i, por_ni,
  input logic [N_GPIO-1:0] cfg_set_i, data_set_i,
  input logic global_set_i, access_write_i,
  input logic [1:0] access_value_i,
  output logic [N_GPIO-1:0] cfg_lock_o, data_lock_o,
  output logic global_lock_o,
  output logic [1:0] access_cfg_o
);
  always_ff @(posedge clk_i or negedge por_ni) begin
    if (!por_ni) begin
      cfg_lock_o<='0; data_lock_o<='0; global_lock_o<=1'b0;
      access_cfg_o<=ACCESS_CTRL_EN ? {BOOT_PRIV_ONLY,BOOT_SECURE_ONLY} : 2'b00;
    end else begin
      cfg_lock_o<=cfg_lock_o | cfg_set_i;
      data_lock_o<=data_lock_o | data_set_i;
      global_lock_o<=global_lock_o | global_set_i;
      if (ACCESS_CTRL_EN && access_write_i) access_cfg_o<=access_value_i;
    end
  end
endmodule
