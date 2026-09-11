// Implements LLD.MOD.APB_SECURE_DEMUX.EVENTS. No bus backpressure.
module apb_secure_demux_events #(
    parameter int unsigned EVENT_FIFO_DEPTH = 8,
    localparam int unsigned PTR_W = (EVENT_FIFO_DEPTH > 1) ? $clog2(EVENT_FIFO_DEPTH) : 1
) (
    input logic pclk,
    input logic preset_n,
    // Index 0 integrity, 1 bus failure, 2 wait, 3 synthetic. Word 4..6 overwritten here.
    input logic [3:0] candidate_valid_i,
    input logic [255:0] candidate_data_i [4],
    input logic [3:0] fault_clear_i,
    input logic [3:0] counter_clear_i,
    input logic fifo_pop_i,
    input logic first_word0_read_i,
    input logic last_word0_read_i,
    input logic access_deny_i,
    input logic cfg_deny_i,
    input logic downstream_error_i,
    output logic first_valid_o,
    output logic last_valid_o,
    output logic [255:0] first_read_o,
    output logic [255:0] last_read_o,
    output logic [255:0] fifo_head_o,
    output logic [31:0] fifo_status_o,
    output logic [31:0] access_deny_count_o,
    output logic [31:0] cfg_deny_count_o,
    output logic [31:0] event_lost_count_o,
    output logic [31:0] downstream_error_count_o,
    output logic [2:0] lost_increment_o
);
    logic [63:0] timestamp_q;
    logic [31:0] sequence_q;
    logic [255:0] first_q,last_q,first_snapshot_q,last_snapshot_q;
    logic [255:0] selected_data;
    logic selected_valid;
    logic [2:0] candidate_count, arbitration_lost;
    logic fifo_drop;
    function automatic logic [31:0] sat_add(input logic [31:0] value, input logic [2:0] increment);
        logic [32:0] sum;
        sum={1'b0,value}+{30'b0,increment};
        return sum[32] ? 32'hffffffff : sum[31:0];
    endfunction
    always_comb begin
        selected_data='0;
        selected_valid=1'b0;
        candidate_count='0;
        for(int unsigned c=0;c<4;c++) begin
            candidate_count=candidate_count+3'(candidate_valid_i[c]);
            if(candidate_valid_i[c] && !selected_valid) begin
                selected_data=candidate_data_i[c];selected_valid=1'b1;
            end
        end
        selected_data[191:128]=timestamp_q;
        selected_data[223:192]=sequence_q;
        arbitration_lost=candidate_count-3'(selected_valid);
    end
    assign lost_increment_o=arbitration_lost+3'(fifo_drop);
    // Word zero always reads the current record. Other words use independent snapshots.
    assign first_read_o=first_valid_o ? {first_snapshot_q[255:32],first_q[31:0]} : 256'b0;
    assign last_read_o=last_valid_o ? {last_snapshot_q[255:32],last_q[31:0]} : 256'b0;
    always_ff @(posedge pclk or negedge preset_n) begin
        if(!preset_n) begin
            timestamp_q<=64'b0;sequence_q<=32'b0;
            first_q<='0;last_q<='0;first_snapshot_q<='0;last_snapshot_q<='0;
            first_valid_o<=1'b0;last_valid_o<=1'b0;
            access_deny_count_o<=32'b0;cfg_deny_count_o<=32'b0;
            event_lost_count_o<=32'b0;downstream_error_count_o<=32'b0;
        end else begin
            timestamp_q<=timestamp_q+64'd1;
            if(fault_clear_i[0]) begin first_valid_o<=1'b0;first_snapshot_q<='0;end
            else if(first_word0_read_i) first_snapshot_q<=first_valid_o ? first_q : 256'b0;
            if(fault_clear_i[1]) begin last_valid_o<=1'b0;last_snapshot_q<='0;end
            else if(last_word0_read_i) last_snapshot_q<=last_valid_o ? last_q : 256'b0;
            if(selected_valid) begin
                sequence_q<=sequence_q+32'd1;
                if(!first_valid_o || fault_clear_i[0]) begin first_q<=selected_data;first_valid_o<=1'b1;end
                last_q<=selected_data;last_valid_o<=1'b1;
            end
            access_deny_count_o<=sat_add(counter_clear_i[0] ? 32'b0 : access_deny_count_o,3'(access_deny_i));
            cfg_deny_count_o<=sat_add(counter_clear_i[1] ? 32'b0 : cfg_deny_count_o,3'(cfg_deny_i));
            event_lost_count_o<=sat_add(counter_clear_i[2] ? 32'b0 : event_lost_count_o,lost_increment_o);
            downstream_error_count_o<=sat_add(counter_clear_i[3] ? 32'b0 : downstream_error_count_o,3'(downstream_error_i));
        end
    end
    if(EVENT_FIFO_DEPTH==0) begin : g_no_fifo
        assign fifo_drop=1'b0;
        assign fifo_head_o=256'b0;
        assign fifo_status_o=32'h00000100;
    end else begin : g_fifo
        logic [255:0] memory_q [EVENT_FIFO_DEPTH];
        logic [PTR_W-1:0] read_q,write_q,read_d,write_d;
        logic [5:0] count_q,count_d;
        logic overflow_q,overflow_d,push;
        function automatic logic [PTR_W-1:0] advance(input logic [PTR_W-1:0] pointer);
            return (pointer==PTR_W'(EVENT_FIFO_DEPTH-1)) ? '0 : pointer+PTR_W'(1);
        endfunction
        always_comb begin
            read_d=read_q;write_d=write_q;count_d=count_q;overflow_d=overflow_q;
            push=1'b0;fifo_drop=1'b0;
            if(fault_clear_i[2]) begin read_d='0;write_d='0;count_d='0;end
            if(fault_clear_i[3]) overflow_d=1'b0;
            if(fifo_pop_i && count_d!=0) begin read_d=advance(read_d);count_d=count_d-6'd1;end
            if(selected_valid) begin
                if(count_d<6'(EVENT_FIFO_DEPTH)) begin
                    push=1'b1;count_d=count_d+6'd1;write_d=advance(write_d);
                end else begin fifo_drop=1'b1;overflow_d=1'b1;end
            end
        end
        always_ff @(posedge pclk or negedge preset_n) begin
            if(!preset_n) begin
                read_q<='0;write_q<='0;count_q<='0;overflow_q<=1'b0;
                for(int unsigned slot=0;slot<EVENT_FIFO_DEPTH;slot++) memory_q[slot]<='0;
            end else begin
                read_q<=read_d;write_q<=write_d;count_q<=count_d;overflow_q<=overflow_d;
                if(push) memory_q[fault_clear_i[2] ? PTR_W'(0) : write_q]<=selected_data;
            end
        end
        assign fifo_head_o=(count_q==0) ? 256'b0 : memory_q[read_q];
        assign fifo_status_o={21'b0,overflow_q,(count_q==6'(EVENT_FIFO_DEPTH)),(count_q==0),2'b0,count_q};
    end
endmodule
