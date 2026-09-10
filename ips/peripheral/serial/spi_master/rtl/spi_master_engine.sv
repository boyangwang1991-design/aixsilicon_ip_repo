// Behavior: docs/lld/03_engine.md. All serial events are PCLK enables.
module spi_master_engine #(
    parameter int NUM_CS=4,
    parameter int RX_FIFO_DEPTH=32
) (
    input logic pclk, rst_n,
    input logic enable_i, abort_i, clear_fault_i,
    input logic [31:0] timeout_i,
    input logic [7:0][3:0] cs_cfg_i,
    input logic [7:0][15:0] divider_i, setup_i, hold_i, idle_i, gap_i,
    input logic [7:0][31:0] dummy_i,
    input logic cmd_empty_i,
    input logic [63:0] cmd_data_i,
    output logic cmd_pop_o,
    input logic tx_empty_i,
    input logic [31:0] tx_data_i,
    output logic tx_pop_o,
    input logic [8:0] rx_count_i,
    output logic rx_push_o,
    output logic [31:0] rx_data_o,
    output logic flush_o,
    output logic busy_o, active_o, aborting_o, faulted_o,
    output logic wait_tx_o, wait_rx_o, wait_cmd_o,
    output logic [15:0] tag_o, progress_o, last_tag_o,
    output logic [31:0] done_count_o,
    output logic [2:0] csid_o, op_o,
    output logic [2:0] event_o,
    output logic [9:0] error_o,
    input logic miso_i,
    output logic sclk_o, mosi_o,
    output logic [NUM_CS-1:0] cs_n_o
);
    localparam logic [3:0] IDLE=0, FETCH=1, RESOURCE=2, NEW_IDLE=3,
        SETUP=4, SHIFT=5, GAP=6, HOLD_CS=7, HOLD_TIME=8, IDLE_TIME=9;
    typedef struct packed {
        logic [3:0] state;
        logic [31:0] cfg;
        logic [15:0] len, tag, progress, last_tag;
        logic [31:0] done_count, wait_count, tx, rx;
        logic [16:0] timer;
        logic [6:0] edge_idx;
        logic [2:0] selected;
        logic [NUM_CS-1:0] cs_n;
        logic sclk, mosi, active, stopping, sw_abort, faulted;
    } state_t;
    state_t q,d;
    logic [2:0] csid, op;
    logic [5:0] bits_per_frame;
    logic cpol,cpha,lsb,loopback,need_tx,need_rx,resource_ready;
    logic [31:0] sample_word, frame_word;
    logic [5:0] serial_bit, sample_index;
    logic sample_value, last_edge, stop_now, waiting, progress_now;
    logic [9:0] fatal;

    assign csid=q.cfg[2:0];
    assign op=q.cfg[6:4];
    assign bits_per_frame=(op==3'd3) ? 6'd1 : q.cfg[13:8];
    assign cpol=cs_cfg_i[csid][0];
    assign cpha=cs_cfg_i[csid][1];
    assign lsb=cs_cfg_i[csid][2];
    assign loopback=cs_cfg_i[csid][3];
    assign need_tx=(op==3'd0 || op==3'd2);
    assign need_rx=(op==3'd1 || op==3'd2);
    assign resource_ready=(!need_tx || !tx_empty_i) && (!need_rx || (rx_count_i < 9'(RX_FIFO_DEPTH)));
    assign serial_bit=q.edge_idx[6:1];
    assign sample_index=lsb ? serial_bit : (bits_per_frame-6'd1-serial_bit);
    assign sample_value=loopback ? q.mosi : miso_i;
    assign last_edge=(q.edge_idx == ((7'(bits_per_frame)<<1)-7'd1));
    assign stop_now=q.stopping || abort_i;
    assign frame_word=need_tx ? tx_data_i : dummy_i[csid];
    assign busy_o=(q.state!=IDLE) || !cmd_empty_i || q.stopping;
    assign active_o=q.active;
    assign aborting_o=q.stopping;
    assign faulted_o=q.faulted;
    assign tag_o=q.tag;
    assign progress_o=q.progress;
    assign last_tag_o=q.last_tag;
    assign done_count_o=q.done_count;
    assign csid_o=csid;
    assign op_o=op;
    assign sclk_o=q.sclk;
    assign mosi_o=q.mosi;
    assign cs_n_o=q.cs_n;

    function automatic void prepare_frame();
        d.tx=frame_word;
        d.rx='0;
        d.edge_idx='0;
        tx_pop_o=need_tx;
        if (op==3'd3) d.mosi=dummy_i[csid][0];
        else if (!cpha) d.mosi=lsb ? frame_word[0] : frame_word[bits_per_frame-6'd1];
    endfunction

    function automatic void finish_segment();
        d.active=1'b0;
        d.last_tag=q.tag;
        d.done_count=q.done_count+32'd1;
        event_o[0]=1'b1;
    endfunction

    function automatic void begin_release();
        if (q.cs_n != {NUM_CS{1'b1}}) begin
            d.state=HOLD_TIME;
            d.timer={1'b0,hold_i[q.selected]};
        end else begin
            d.state=IDLE_TIME;
            d.timer='0;
        end
    endfunction

    function automatic void finish_stop();
        d.active=1'b0;
        d.stopping=1'b0;
        d.sw_abort=1'b0;
        d.faulted=1'b1;
        d.state=IDLE;
        flush_o=1'b1;
        event_o[2]=q.sw_abort || abort_i;
    endfunction

    always_comb begin
        d=q;
        cmd_pop_o=1'b0; tx_pop_o=1'b0; rx_push_o=1'b0;
        rx_data_o=q.rx; flush_o=1'b0; event_o='0; error_o='0;
        fatal='0; waiting=1'b0; progress_now=1'b0;
        wait_tx_o=1'b0; wait_rx_o=1'b0; wait_cmd_o=1'b0;
        sample_word=q.rx;
        if (clear_fault_i) d.faulted=1'b0;
        if (abort_i) begin d.stopping=1'b1; d.sw_abort=1'b1; end

        case (q.state)
            IDLE: begin
                d.wait_count='0;
                if (!cmd_empty_i && enable_i && !q.faulted && !stop_now) begin
                    cmd_pop_o=1'b1;
                    d.cfg=cmd_data_i[31:0]; d.len=cmd_data_i[47:32];
                    d.tag=cmd_data_i[63:48]; d.progress='0; d.active=1'b1;
                    d.state=FETCH;
                end
            end
            FETCH: begin
                if (q.cs_n != {NUM_CS{1'b1}} && csid != q.selected) fatal[9]=1'b1;
                else if (op==3'd4) begin
                    if (q.cs_n == {NUM_CS{1'b1}}) begin
                        if (!stop_now) finish_segment();
                        d.state=IDLE;
                    end else begin_release();
                end else d.state=RESOURCE;
            end
            RESOURCE: begin
                wait_tx_o=need_tx && tx_empty_i;
                wait_rx_o=need_rx && (rx_count_i >= 9'(RX_FIFO_DEPTH));
                if (resource_ready && !stop_now) begin
                    progress_now=1'b1;
                    prepare_frame();
                    if (q.cs_n == {NUM_CS{1'b1}}) begin
                        d.selected=csid; d.sclk=cpol;
                        d.timer={1'b0,idle_i[csid]}; d.state=NEW_IDLE;
                    end else begin
                        d.timer={1'b0,divider_i[csid]}; d.state=SHIFT;
                    end
                end else if (!stop_now) begin
                    if (!q.cfg[17]) begin fatal[6]=wait_tx_o; fatal[7]=wait_rx_o; end
                    else waiting=1'b1;
                end
            end
            NEW_IDLE: begin
                if (q.timer!=0) d.timer=q.timer-17'd1;
                else begin
                    d.cs_n={NUM_CS{1'b1}};
                    d.cs_n[q.selected]=1'b0;
                    d.timer={1'b0,setup_i[csid]}; d.state=SETUP;
                end
            end
            SETUP,SHIFT: begin
                if (q.timer!=0) d.timer=q.timer-17'd1;
                else begin
                    d.state=SHIFT;
                    d.sclk=~q.sclk;
                    d.timer={1'b0,divider_i[csid]};
                    d.edge_idx=q.edge_idx+7'd1;
                    if (op!=3'd3) begin
                        if (q.edge_idx[0]==cpha) begin
                            sample_word[sample_index]=sample_value;
                            d.rx=sample_word;
                        end
                        if (cpha && !q.edge_idx[0]) d.mosi=q.tx[sample_index];
                        if (!cpha && q.edge_idx[0] && !last_edge)
                            d.mosi=lsb ? q.tx[serial_bit+6'd1] : q.tx[bits_per_frame-6'd2-serial_bit];
                    end
                    if (last_edge) begin
                        d.progress=q.progress+16'd1;
                        rx_push_o=need_rx;
                        rx_data_o=sample_word;
                        if (stop_now) begin_release();
                        else if (q.progress+16'd1==q.len) begin
                            if (q.cfg[16]) begin
                                finish_segment(); d.state=HOLD_CS;
                            end else begin_release();
                        end else begin
                            // The current completed RX frame consumes its reserved slot.
                            // Do not count an APB pop on this same edge as available capacity.
                            if ((!need_tx || !tx_empty_i) &&
                                (!need_rx || rx_count_i < 9'(RX_FIFO_DEPTH-1))) begin
                                prepare_frame();
                                d.timer={1'b0,divider_i[csid]} + ((op==3'd3)?17'd0:{1'b0,gap_i[csid]});
                            end else if (q.cfg[17]) begin d.state=RESOURCE; end
                            else begin
                                fatal[6]=need_tx && tx_empty_i;
                                fatal[7]=need_rx && rx_count_i >= 9'(RX_FIFO_DEPTH-1);
                            end
                        end
                    end
                end
            end
            HOLD_CS: begin
                if (!cmd_empty_i && !stop_now) begin
                    cmd_pop_o=1'b1; progress_now=1'b1;
                    d.cfg=cmd_data_i[31:0]; d.len=cmd_data_i[47:32];
                    d.tag=cmd_data_i[63:48]; d.progress='0; d.active=1'b1;
                    d.state=FETCH;
                end else if (!stop_now) begin wait_cmd_o=1'b1; waiting=1'b1; end
            end
            HOLD_TIME: begin
                if (q.timer!=0) d.timer=q.timer-17'd1;
                else begin
                    d.cs_n={NUM_CS{1'b1}}; d.mosi=1'b0;
                    d.state=IDLE_TIME; d.timer={1'b0,idle_i[q.selected]};
                    if (!stop_now) begin finish_segment(); event_o[1]=1'b1; end
                end
            end
            IDLE_TIME: begin
                if (q.timer!=0) d.timer=q.timer-17'd1;
                else if (stop_now) finish_stop();
                else d.state=IDLE;
            end
            default: begin
                d.stopping=1'b1;
                begin_release();
            end
        endcase

        if (waiting && !progress_now) begin
            if (timeout_i!=0 && q.wait_count>=timeout_i-32'd1) fatal[8]=1'b1;
            else if (q.wait_count!=32'hffffffff) d.wait_count=q.wait_count+32'd1;
        end else if (progress_now || (q.state!=FETCH && q.state!=HOLD_CS)) d.wait_count='0;

        if (|fatal) begin
            error_o=fatal; d.stopping=1'b1;
            begin_release();
            event_o[1:0]='0; tx_pop_o=1'b0; cmd_pop_o=1'b0;
        end
        // An accepted ABORT wins over launch and normal completion on this edge.
        if (stop_now) begin
            tx_pop_o=1'b0; cmd_pop_o=1'b0; event_o[1:0]='0;
            d.done_count=q.done_count; d.last_tag=q.last_tag;
            if (q.state!=SHIFT && q.state!=HOLD_TIME && q.state!=IDLE_TIME) begin
                // SETUP has not emitted a leading edge yet; do not generate one.
                d.sclk=q.sclk; d.mosi=q.mosi; d.cs_n=q.cs_n;
                rx_push_o=1'b0;
                begin_release();
            end
        end
    end

    always_ff @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin q<='0; q.cs_n<={NUM_CS{1'b1}}; end
        else q<=d;
    end
endmodule
