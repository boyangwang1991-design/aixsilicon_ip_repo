module spi_master_top #(
    parameter int NUM_CS=4, TX_FIFO_DEPTH=32, RX_FIFO_DEPTH=32, CMD_FIFO_DEPTH=4
) (
    input logic pclk, preset_n, psel, penable, pwrite,
    input logic [11:0] paddr,
    input logic [31:0] pwdata,
    input logic [3:0] pstrb,
    input logic [2:0] pprot,
    output logic [31:0] prdata,
    output logic pready, pslverr,
    output logic spi_sclk_o, spi_mosi_o,
    input logic spi_miso_i,
    output logic [NUM_CS-1:0] spi_cs_n_o,
    output logic irq_o
);
    import spi_master_csr_pkg::*;
    import spi_master_addr_pkg::*;
    spi_master__in_t hwi;
    spi_master__out_t hwo;
    logic access, write_access, good, csr_req, soft_reset_q, rst_n;
    logic [31:0] byte_mask, csr_rdata, wm_merged, cmd_cfg;
    logic [9:0] apb_error, engine_error, error_set, error_state;
    logic [5:0] action, irq_raw;
    logic [2:0] events;
    logic busy, active, aborting, faulted, wait_tx, wait_rx, wait_cmd, enabled;
    logic tx_push,tx_pop,rx_push,rx_pop,cmd_push,cmd_pop,flush;
    logic tx_full,tx_empty,rx_full,rx_empty,cmd_full,cmd_empty;
    logic [8:0] tx_count,rx_count;
    logic [4:0] cmd_count;
    logic [31:0] tx_head,rx_head,rx_word,done_count;
    logic [63:0] cmd_head,cmd_word;
    logic [15:0] active_tag,progress,last_tag;
    logic [2:0] active_cs,active_op;
    logic [7:0][3:0] cs_cfg;
    logic [7:0][15:0] divider,cs_setup,cs_hold,cs_idle,frame_gap;
    logic [7:0][31:0] dummy;
    logic cmd_valid,cs_address;

    generate
        if (NUM_CS<1 || NUM_CS>8) begin:g_bad_cs
            $error("spi_master NUM_CS must be 1..8");
        end
        if (TX_FIFO_DEPTH<4 || TX_FIFO_DEPTH>256 || (TX_FIFO_DEPTH & (TX_FIFO_DEPTH-1))!=0) begin:g_bad_tx
            $error("spi_master illegal TX_FIFO_DEPTH");
        end
        if (RX_FIFO_DEPTH<4 || RX_FIFO_DEPTH>256 || (RX_FIFO_DEPTH & (RX_FIFO_DEPTH-1))!=0) begin:g_bad_rx
            $error("spi_master illegal RX_FIFO_DEPTH");
        end
        if (CMD_FIFO_DEPTH<2 || CMD_FIFO_DEPTH>16 || (CMD_FIFO_DEPTH & (CMD_FIFO_DEPTH-1))!=0) begin:g_bad_cmd
            $error("spi_master illegal CMD_FIFO_DEPTH");
        end
    endgenerate

    assign rst_n=preset_n & ~soft_reset_q;
    assign pready=preset_n;
    assign access=psel && penable && pready;
    assign write_access=access && pwrite && (|pstrb);
    assign byte_mask={{8{pstrb[3]}},{8{pstrb[2]}},{8{pstrb[1]}},{8{pstrb[0]}}};
    assign enabled=hwo.ctrl.enable.value;
    assign wm_merged=({14'd0,hwo.watermark.rx.value,hwo.watermark.tx.value} & ~byte_mask) | (pwdata & byte_mask);
    assign cs_address=(paddr>=A_CS0_CFG);
    assign cmd_cfg={14'd0,hwo.cmd_cfg.allow_stall.value,hwo.cmd_cfg.keep_cs.value,
        2'd0,hwo.cmd_cfg.frame_bits.value,1'd0,hwo.cmd_cfg.op.value,1'd0,hwo.cmd_cfg.csid.value};
    assign cmd_word={hwo.cmd_tag.value.value,hwo.cmd_len.value.value,cmd_cfg};
    always_comb begin
        cmd_valid=(hwo.cmd_cfg.csid.value < 4'(NUM_CS));
        case(hwo.cmd_cfg.op.value)
            3'd0,3'd1,3'd2: cmd_valid &= hwo.cmd_len.value.value!=0 &&
                hwo.cmd_cfg.frame_bits.value>=1 && hwo.cmd_cfg.frame_bits.value<=32;
            3'd3: cmd_valid &= hwo.cmd_len.value.value!=0 && hwo.cmd_cfg.frame_bits.value==0;
            3'd4: cmd_valid &= hwo.cmd_len.value.value==0 && hwo.cmd_cfg.frame_bits.value==0 &&
                !hwo.cmd_cfg.keep_cs.value && !hwo.cmd_cfg.allow_stall.value;
            default: cmd_valid=1'b0;
        endcase
    end

    always_comb begin
        apb_error='0;
        if (access) begin
            if (!access_ok(paddr,pwrite) ||
                (cs_address && (paddr[7:5]>=4'(NUM_CS))) ||
                (write_access && (paddr==A_TXDATA || paddr==A_CMD_PUSH || paddr==A_ACTION) && pstrb!=4'hf))
                apb_error[0]=1'b1;
            else if (write_access) begin
                case(paddr)
                    A_TXDATA: apb_error[1]=tx_full;
                    A_CMD_PUSH: if (pwdata[0]) begin
                        if (cmd_full) apb_error[3]=1'b1;
                        else apb_error[4]=!enabled || faulted || aborting || !cmd_valid;
                    end
                    A_ACTION: begin
                        if ((pwdata[5:0] & (pwdata[5:0]-6'd1))!=0) apb_error[0]=1'b1;
                        else if ((|pwdata[5:1]) && (enabled || busy)) apb_error[0]=1'b1;
                    end
                    A_CTRL: if (pstrb[0] && pwdata[0]!=enabled)
                        apb_error[5]=pwdata[0] ? faulted : busy;
                    A_WATERMARK: apb_error[5]=wm_merged[8:0]>9'(TX_FIFO_DEPTH) ||
                        wm_merged[17:9]==0 || wm_merged[17:9]>9'(RX_FIFO_DEPTH);
                    A_WAIT_TIMEOUT: apb_error[5]=enabled;
                    default: if (cs_address) apb_error[5]=enabled;
                endcase
            end else if (!pwrite && paddr==A_RXDATA) apb_error[2]=rx_empty;
        end
    end
    assign good=access && !(|apb_error);
    assign pslverr=access && (|apb_error);
    assign csr_req=good && (!pwrite || (|pstrb));
    assign prdata=(good && !pwrite) ? csr_rdata : 32'd0;
    assign action=(good && write_access && paddr==A_ACTION) ? pwdata[5:0] : 6'd0;
    always_ff @(posedge pclk or negedge preset_n)
        if (!preset_n) soft_reset_q<=1'b0;
        else soft_reset_q<=action[5];
    assign tx_push=good && write_access && paddr==A_TXDATA;
    assign rx_pop=good && !pwrite && paddr==A_RXDATA;
    assign cmd_push=good && write_access && paddr==A_CMD_PUSH && pwdata[0];
    assign error_set=apb_error | engine_error;
    assign error_state={hwo.error_status.cs_mismatch.value,hwo.error_status.wait_timeout.value,
        hwo.error_status.rx_resource.value,hwo.error_status.tx_resource.value,hwo.error_status.config_write.value,
        hwo.error_status.cmd_invalid.value,hwo.error_status.cmd_full_push.value,hwo.error_status.rx_empty_read.value,
        hwo.error_status.tx_full_write.value,hwo.error_status.apb_access.value};
    assign irq_raw={(rx_count>=hwo.watermark.rx.value),(enabled && tx_count<=hwo.watermark.tx.value),
        (|error_state),hwo.irq_state.abort_done.value,hwo.irq_state.xfer_done.value,hwo.irq_state.seg_done.value};
    assign irq_o=|(irq_raw & hwo.irq_enable.value.value);
    assign hwi.capability.value.next={2'b11,6'd32,4'($clog2(CMD_FIFO_DEPTH)),4'($clog2(RX_FIFO_DEPTH)),4'($clog2(TX_FIFO_DEPTH)),4'(NUM_CS)};
    assign hwi.status.value.next={active,enabled,cmd_empty,cmd_full,rx_empty,rx_full,tx_empty,tx_full,
        faulted,aborting,wait_cmd,wait_rx,wait_tx,(spi_cs_n_o!={NUM_CS{1'b1}}),busy};
    assign hwi.fifo_level.value.next={cmd_count,rx_count,tx_count};
    assign hwi.irq_state.seg_done.hwset=events[0];
    assign hwi.irq_state.xfer_done.hwset=events[1];
    assign hwi.irq_state.abort_done.hwset=events[2];
    assign hwi.irq_raw.value.next=irq_raw;
    assign hwi.error_status.apb_access.hwset=error_set[0];
    assign hwi.error_status.tx_full_write.hwset=error_set[1];
    assign hwi.error_status.rx_empty_read.hwset=error_set[2];
    assign hwi.error_status.cmd_full_push.hwset=error_set[3];
    assign hwi.error_status.cmd_invalid.hwset=error_set[4];
    assign hwi.error_status.config_write.hwset=error_set[5];
    assign hwi.error_status.tx_resource.hwset=error_set[6];
    assign hwi.error_status.rx_resource.hwset=error_set[7];
    assign hwi.error_status.wait_timeout.hwset=error_set[8];
    assign hwi.error_status.cs_mismatch.hwset=error_set[9];
    assign hwi.rxdata.value.next=rx_head;
    assign hwi.active_tag.value.next=active_tag;
    assign hwi.progress.value.next=progress;
    assign hwi.last_done_tag.value.next=last_tag;
    assign hwi.done_count.value.next=done_count;
    assign hwi.active_info.csid.next=active_cs;
    assign hwi.active_info.op.next=active_op;
    assign hwi.active_info.valid.next=active;
    for(genvar i=0;i<8;i++) begin:g_config
        assign cs_cfg[i]={hwo.cs[i].cfg.loopback.value,hwo.cs[i].cfg.lsb_first.value,hwo.cs[i].cfg.cpha.value,hwo.cs[i].cfg.cpol.value};
        assign divider[i]=hwo.cs[i].clkdiv.value.value;
        assign cs_setup[i]=hwo.cs[i].timing0.setup.value;
        assign cs_hold[i]=hwo.cs[i].timing0.hold_time.value;
        assign cs_idle[i]=hwo.cs[i].timing1.idle.value;
        assign frame_gap[i]=hwo.cs[i].timing1.frame_gap.value;
        assign dummy[i]=hwo.cs[i].dummy.value.value;
    end
    spi_master_csr u_csr(.clk(pclk),.arst_n(rst_n),.s_cpuif_req(csr_req),.s_cpuif_req_is_wr(pwrite),
        .s_cpuif_addr(paddr),.s_cpuif_wr_data(pwdata),.s_cpuif_wr_biten(byte_mask),
        .s_cpuif_req_stall_wr(),.s_cpuif_req_stall_rd(),.s_cpuif_rd_ack(),.s_cpuif_rd_err(),
        .s_cpuif_rd_data(csr_rdata),.s_cpuif_wr_ack(),.s_cpuif_wr_err(),.hwif_in(hwi),.hwif_out(hwo));
    spi_master_queues #(.TX_FIFO_DEPTH(TX_FIFO_DEPTH),.RX_FIFO_DEPTH(RX_FIFO_DEPTH),.CMD_FIFO_DEPTH(CMD_FIFO_DEPTH)) u_queues(
        .pclk(pclk),.rst_n(rst_n),.clear_tx_i(action[1] || flush),.clear_rx_i(action[2]),.clear_cmd_i(action[3] || flush),
        .tx_push_i(tx_push),.tx_pop_i(tx_pop),.rx_push_i(rx_push),.rx_pop_i(rx_pop),.cmd_push_i(cmd_push),.cmd_pop_i(cmd_pop),
        .tx_data_i(pwdata),.rx_data_i(rx_word),.cmd_data_i(cmd_word),.tx_data_o(tx_head),.rx_data_o(rx_head),.cmd_data_o(cmd_head),
        .tx_full_o(tx_full),.tx_empty_o(tx_empty),.rx_full_o(rx_full),.rx_empty_o(rx_empty),.cmd_full_o(cmd_full),.cmd_empty_o(cmd_empty),
        .tx_count_o(tx_count),.rx_count_o(rx_count),.cmd_count_o(cmd_count));
    spi_master_engine #(.NUM_CS(NUM_CS),.RX_FIFO_DEPTH(RX_FIFO_DEPTH)) u_engine(
        .pclk(pclk),.rst_n(rst_n),.enable_i(enabled),.abort_i(action[0]),.clear_fault_i(action[4]),
        .timeout_i(hwo.wait_timeout.value.value),.cs_cfg_i(cs_cfg),.divider_i(divider),.setup_i(cs_setup),.hold_i(cs_hold),
        .idle_i(cs_idle),.gap_i(frame_gap),.dummy_i(dummy),.cmd_empty_i(cmd_empty),.cmd_data_i(cmd_head),.cmd_pop_o(cmd_pop),
        .tx_empty_i(tx_empty),.tx_data_i(tx_head),.tx_pop_o(tx_pop),.rx_count_i(rx_count),.rx_push_o(rx_push),.rx_data_o(rx_word),
        .flush_o(flush),.busy_o(busy),.active_o(active),.aborting_o(aborting),.faulted_o(faulted),
        .wait_tx_o(wait_tx),.wait_rx_o(wait_rx),.wait_cmd_o(wait_cmd),.tag_o(active_tag),.progress_o(progress),
        .last_tag_o(last_tag),.done_count_o(done_count),.csid_o(active_cs),.op_o(active_op),.event_o(events),.error_o(engine_error),
        .miso_i(spi_miso_i),.sclk_o(spi_sclk_o),.mosi_o(spi_mosi_o),.cs_n_o(spi_cs_n_o));
    // PPROT is intentionally accepted without filtering (APB-008).
endmodule
