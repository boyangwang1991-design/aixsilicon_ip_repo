// apb_cdc_sync_chain.sv - 可配置级数 2FF 同步器链
// 仅同步单 bit 控制（toggle），payload 通过 bundled-data 保护。
// 满足 LRS.FUNC.APB_CDC_BRIDGE.03.002 / LRS.CONS.APB_CDC_BRIDGE.02.001
module apb_cdc_sync_chain #(
  parameter int unsigned SYNC_STAGES = 2 // >= 2
) (
  input  logic din,
  input  logic clk,
  input  logic rst_n, // 目标域复位（async assert / sync deassert 由复位处理层保证）
  output logic dout
);

  // 同步器链寄存器（SYNC_STAGES 个 FF）
  logic [SYNC_STAGES-1:0] sync_ff;

  generate
    if (SYNC_STAGES == 2) begin : g_2stage
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          sync_ff <= '0;
        end else begin
          sync_ff[0] <= din;
          sync_ff[1] <= sync_ff[0];
        end
      end
    end else begin : g_multi
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          sync_ff <= '0;
        end else begin
          sync_ff[0] <= din;
          for (int i = 1; i < SYNC_STAGES; i++) begin
            sync_ff[i] <= sync_ff[i-1];
          end
        end
      end
    end
  endgenerate

  assign dout = sync_ff[SYNC_STAGES-1];

endmodule : apb_cdc_sync_chain
