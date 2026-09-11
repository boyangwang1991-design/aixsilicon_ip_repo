// Implements LLD.MOD.APB_SECURE_DEMUX.IRQ. Commands are pre-authorized completions.
module apb_secure_demux_irq (
    input logic pclk,
    input logic preset_n,
    input logic [8:0] event_bits_i,
    input logic fatal_i,
    input logic raw_clear_i,
    input logic [31:0] raw_clear_data_i,
    input logic intr_enable_write_i,
    input logic alert_enable_write_i,
    input logic [31:0] write_data_i,
    input logic intr_test_i,
    output logic [31:0] intr_raw_o,
    output logic [31:0] intr_enable_o,
    output logic [31:0] alert_enable_o,
    output logic irq_o,
    output logic security_alert_o
);
    logic [8:0] raw_q, intr_enable_q, alert_enable_q;
    logic [8:0] events, clear_mask;
    assign events = event_bits_i | {intr_test_i,3'b000,fatal_i,4'b0000};
    assign clear_mask = raw_clear_i ? raw_clear_data_i[8:0] : 9'h000;
    always_ff @(posedge pclk or negedge preset_n) begin
        if (!preset_n) begin
            raw_q <= 9'h000;
            intr_enable_q <= 9'h000;
            alert_enable_q <= 9'h09b;
        end else begin
            raw_q <= (raw_q & ~clear_mask) | events;
            if (intr_enable_write_i) intr_enable_q <= write_data_i[8:0];
            if (alert_enable_write_i) alert_enable_q <= write_data_i[8:0];
        end
    end
    assign intr_raw_o = {23'b0,raw_q};
    assign intr_enable_o = {23'b0,intr_enable_q};
    assign alert_enable_o = {23'b0,alert_enable_q};
    assign irq_o = preset_n && (|(raw_q & intr_enable_q));
    assign security_alert_o = preset_n && (|(raw_q & alert_enable_q));
endmodule
