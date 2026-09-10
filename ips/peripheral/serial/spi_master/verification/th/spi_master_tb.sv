`timescale 1ns/1ps
module spi_master_tb;
    import uvm_pkg::*;
    import spi_master_tests::*;
    logic pclk=0;
    always #5 pclk=~pclk;
    spi_tb_if vif(pclk);
    spi_master_top #(.NUM_CS(`SPI_NUM_CS),.TX_FIFO_DEPTH(`SPI_TX_DEPTH),.RX_FIFO_DEPTH(`SPI_RX_DEPTH),.CMD_FIFO_DEPTH(`SPI_CMD_DEPTH)) dut(
        .pclk(pclk),.preset_n(vif.preset_n),.psel(vif.psel),.penable(vif.penable),.pwrite(vif.pwrite),
        .paddr(vif.paddr),.pwdata(vif.pwdata),.pstrb(vif.pstrb),.pprot(vif.pprot),.prdata(vif.prdata),
        .pready(vif.pready),.pslverr(vif.pslverr),.spi_sclk_o(vif.sclk),.spi_mosi_o(vif.mosi),
        .spi_miso_i(vif.miso),.spi_cs_n_o(vif.cs_n),.irq_o(vif.irq));
    // Sample at PCLK boundaries; MISO is intentionally exempt from async-stability checks.
    ap_cs_onehot: assert property (@(posedge pclk) disable iff(!vif.preset_n)
        $onehot0(~vif.cs_n)) else $error("Assertion failed: multiple CS");
    ap_zero_wait: assert property (@(posedge pclk) disable iff(!vif.preset_n)
        vif.psel && vif.penable |-> vif.pready) else $error("Assertion failed: APB wait");
    ap_known_outputs: assert property (@(posedge pclk) disable iff(!vif.preset_n)
        !$isunknown({vif.cs_n,vif.sclk,vif.mosi,vif.irq,vif.pready}))
        else $error("Assertion failed: unknown outputs");
    ap_tx_bound: assert property (@(posedge pclk) disable iff(!vif.preset_n)
        dut.u_queues.tx_count_o <= `SPI_TX_DEPTH) else $error("Assertion failed: TX count");
    ap_rx_bound: assert property (@(posedge pclk) disable iff(!vif.preset_n)
        dut.u_queues.rx_count_o <= `SPI_RX_DEPTH) else $error("Assertion failed: RX count");
    ap_cmd_bound: assert property (@(posedge pclk) disable iff(!vif.preset_n)
        dut.u_queues.cmd_count_o <= `SPI_CMD_DEPTH) else $error("Assertion failed: CMD count");
    initial begin
        uvm_config_db#(virtual spi_tb_if)::set(null,"*","vif",vif);
        run_test();
    end
    initial begin #100000000; $fatal(1,"global simulation watchdog");end
endmodule
