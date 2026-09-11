// LLD.MOD.GPIO.DIAG: physical mismatch timing and POR-retained parity safe latch.
module gpio_diag #(
  parameter int N_GPIO=32,
  parameter bit DIAG_EN=1, CFG_PARITY_EN=0
) (
  input logic clk_i, rst_ni, por_ni,
  input logic [N_GPIO-1:0] sync_i, sync_valid_i, physical_out_i, physical_oe_i,
  input logic [N_GPIO-1:0] owned_i, available_i, clear_i, test_i,
  input logic [N_GPIO-1:0][15:0] blank_i,
  input logic [N_GPIO-1:0][7:0] mismatch_count_i,
  input logic sleep_i, safe_i, parity_error_i,
  output logic [N_GPIO-1:0] pending_o,
  output logic parity_safe_o
);
  if (CFG_PARITY_EN) begin : g_parity
    always_ff @(posedge clk_i or negedge por_ni) begin
      if (!por_ni) parity_safe_o<=1'b0;
      else if (rst_ni && parity_error_i) parity_safe_o<=1'b1;
    end
  end else begin : g_no_parity
    assign parity_safe_o=1'b0;
  end
  for (genvar i=0; i<N_GPIO; i++) begin : g_pin
    if (DIAG_EN) begin : g_enabled
      logic [5:0] previous_q, condition_now;
      logic [16:0] blank_q;
      logic [8:0] mismatch_q;
      logic eligible, changed, mismatch, event_now;
      assign condition_now={physical_out_i[i],physical_oe_i[i],owned_i[i],available_i[i],sleep_i,safe_i};
      assign changed=condition_now!=previous_q;
      assign eligible=sync_valid_i[i] && physical_oe_i[i] && owned_i[i] && available_i[i];
      assign mismatch=sync_i[i]!=physical_out_i[i];
      assign event_now=eligible && !changed && blank_q>={1'b0,blank_i[i]} && mismatch
                       && mismatch_q>={1'b0,mismatch_count_i[i]};
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          previous_q<='0; blank_q<='0; mismatch_q<='0; pending_o[i]<=1'b0;
        end else begin
          previous_q<=condition_now;
          pending_o[i]<=(pending_o[i] && !clear_i[i]) || test_i[i] || event_now;
          if (changed || !eligible) begin blank_q<='0; mismatch_q<='0; end
          else if (blank_q<{1'b0,blank_i[i]}) begin blank_q<=blank_q+17'd1; mismatch_q<='0; end
          else if (!mismatch) mismatch_q<='0;
          else if (mismatch_q<9'd256) mismatch_q<=mismatch_q+9'd1;
        end
      end
    end else begin : g_disabled
      assign pending_o[i]=1'b0;
    end
  end
endmodule
