// LLD.MOD.GPIO.APB: all business effects use the accepted Access edge.
module gpio_apb_if #(
  parameter int N_GPIO=32,
  parameter bit ACCESS_CTRL_EN=1,
  localparam int N_BANK=(N_GPIO+31)/32
) (
  input logic rst_ni, psel_i, penable_i, pwrite_i,
  input logic [13:0] paddr_i,
  input logic [2:0] pprot_i,
  input logic [3:0] pstrb_i,
  input logic [1:0] access_cfg_i,
  input logic optional_disabled_i, semantic_error_i,
  input logic [31:0] csr_read_data_i,
  output gpio_reg_desc_pkg::gpio_reg_desc_t descriptor_o,
  output logic [31:0] byte_mask_o,
  output logic pready_o, pslverr_o, commit_o, access_error_o,
  output logic [31:0] prdata_o
);
  import gpio_reg_desc_pkg::*;
  logic bad, fixed_security;
  assign descriptor_o=gpio_decode(paddr_i);
  assign fixed_security=pwrite_i &&
    (descriptor_o.op==OP_PARITY_INJECT ||
     (ACCESS_CTRL_EN && (descriptor_o.op==OP_ACCESS_CFG || descriptor_o.op==OP_GLOBAL_LOCK ||
      descriptor_o.op==OP_BANK_CFG_LOCK || descriptor_o.op==OP_BANK_DATA_LOCK)));
  always_comb begin
    for (int b=0; b<4; b++) byte_mask_o[8*b+:8]={8{pstrb_i[b]}};
    bad=!descriptor_o.hit || paddr_i[1:0]!=0 || pprot_i[2];
    if (descriptor_o.group_id==2'd2 && descriptor_o.instance_id>=N_GPIO) bad=1'b1;
    if ((descriptor_o.group_id==2'd1 || descriptor_o.group_id==2'd3) && descriptor_o.instance_id>=N_BANK) bad=1'b1;
    if (ACCESS_CTRL_EN && ((access_cfg_i[0] && pprot_i[1]) || (access_cfg_i[1] && !pprot_i[0]))) bad=1'b1;
    if (!optional_disabled_i) begin
      if (fixed_security && (pprot_i[1] || !pprot_i[0])) bad=1'b1;
      if (pwrite_i && !descriptor_o.writable) bad=1'b1;
      if (semantic_error_i) bad=1'b1;
    end
  end
  assign pready_o=1'b1;
  assign pslverr_o=rst_ni && psel_i && penable_i && bad;
  assign commit_o=rst_ni && psel_i && penable_i && !bad;
  assign access_error_o=rst_ni && psel_i && penable_i && bad;
  assign prdata_o=(bad || optional_disabled_i || !descriptor_o.readable) ? 32'd0 : csr_read_data_i;
endmodule
