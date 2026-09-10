// Reuses the asset FIFO without copying or modifying its implementation.
module spi_master_queues #(
    parameter int TX_FIFO_DEPTH=32, RX_FIFO_DEPTH=32, CMD_FIFO_DEPTH=4
) (
    input logic pclk, rst_n,
    input logic clear_tx_i, clear_rx_i, clear_cmd_i,
    input logic tx_push_i, tx_pop_i, rx_push_i, rx_pop_i, cmd_push_i, cmd_pop_i,
    input logic [31:0] tx_data_i, rx_data_i,
    input logic [63:0] cmd_data_i,
    output logic [31:0] tx_data_o, rx_data_o,
    output logic [63:0] cmd_data_o,
    output logic tx_full_o, tx_empty_o, rx_full_o, rx_empty_o, cmd_full_o, cmd_empty_o,
    output logic [8:0] tx_count_o, rx_count_o,
    output logic [4:0] cmd_count_o
);
    logic [2:0] clear_q;
    logic [$clog2(TX_FIFO_DEPTH+1)-1:0] tx_count;
    logic [$clog2(RX_FIFO_DEPTH+1)-1:0] rx_count;
    logic [$clog2(CMD_FIFO_DEPTH+1)-1:0] cmd_count;
    // Register clear requests so reset assertion cannot glitch with APB address/data.
    always_ff @(posedge pclk or negedge rst_n)
        if (!rst_n) clear_q<='0;
        else clear_q<={clear_cmd_i,clear_rx_i,clear_tx_i};
    assign tx_count_o=9'(tx_count);
    assign rx_count_o=9'(rx_count);
    assign cmd_count_o=5'(cmd_count);
    sync_fifo #(.DATA_W(32),.DEPTH(TX_FIFO_DEPTH),.OUTPUT_REG(0),.IMPL(0)) u_tx (
        .clk(pclk),.rst_n(rst_n & ~clear_q[0]),.push_i(tx_push_i & ~clear_q[0]),
        .data_i(tx_data_i),.pop_i(tx_pop_i & ~clear_q[0]),.rd_valid_o(),
        .rd_data_o(tx_data_o),.full_o(tx_full_o),.empty_o(tx_empty_o),.count_o(tx_count));
    sync_fifo #(.DATA_W(32),.DEPTH(RX_FIFO_DEPTH),.OUTPUT_REG(0),.IMPL(0)) u_rx (
        .clk(pclk),.rst_n(rst_n & ~clear_q[1]),.push_i(rx_push_i & ~clear_q[1]),
        .data_i(rx_data_i),.pop_i(rx_pop_i & ~clear_q[1]),.rd_valid_o(),
        .rd_data_o(rx_data_o),.full_o(rx_full_o),.empty_o(rx_empty_o),.count_o(rx_count));
    sync_fifo #(.DATA_W(64),.DEPTH(CMD_FIFO_DEPTH),.OUTPUT_REG(0),.IMPL(0)) u_cmd (
        .clk(pclk),.rst_n(rst_n & ~clear_q[2]),.push_i(cmd_push_i & ~clear_q[2]),
        .data_i(cmd_data_i),.pop_i(cmd_pop_i & ~clear_q[2]),.rd_valid_o(),
        .rd_data_o(cmd_data_o),.full_o(cmd_full_o),.empty_o(cmd_empty_o),.count_o(cmd_count));
endmodule
