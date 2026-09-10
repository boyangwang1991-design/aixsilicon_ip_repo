`timescale 1ns/1ps
module spi_queues_ut;
  logic pclk=0,rst_n=0;
  always #5 pclk=~pclk;
  logic clear_tx_i=0,clear_rx_i=0,clear_cmd_i=0;
  logic tx_push_i=0,tx_pop_i=0,rx_push_i=0,rx_pop_i=0,cmd_push_i=0,cmd_pop_i=0;
  logic [31:0] tx_data_i=0,rx_data_i=0,tx_data_o,rx_data_o;
  logic [63:0] cmd_data_i=0,cmd_data_o;
  logic tx_full_o,tx_empty_o,rx_full_o,rx_empty_o,cmd_full_o,cmd_empty_o;
  logic [8:0] tx_count_o,rx_count_o;
  logic [4:0] cmd_count_o;
  logic [31:0] txq[$],rxq[$],discard32;
  logic [63:0] cmdq[$],discard64;
  int errors=0;
  spi_master_queues #(.TX_FIFO_DEPTH(4),.RX_FIFO_DEPTH(8),.CMD_FIFO_DEPTH(2)) dut(.*);
  task automatic check(bit ok,string message);if(!ok)begin errors++;$error("UT %s",message);end endtask
  initial begin
    repeat(3)@(negedge pclk);rst_n=1;
    for(int i=0;i<2000;i++)begin
      @(negedge pclk);
      tx_pop_i=txq.size()!=0 && $urandom_range(0,1);tx_push_i=txq.size()<4 && $urandom_range(0,1);
      rx_pop_i=rxq.size()!=0 && $urandom_range(0,1);rx_push_i=rxq.size()<8 && $urandom_range(0,1);
      cmd_pop_i=cmdq.size()!=0 && $urandom_range(0,1);cmd_push_i=cmdq.size()<2 && $urandom_range(0,1);
      tx_data_i=$urandom;rx_data_i=$urandom;cmd_data_i={$urandom,$urandom};
      if(tx_pop_i)begin check(tx_data_o===txq[0],"TX ordering");discard32=txq.pop_front();end
      if(rx_pop_i)begin check(rx_data_o===rxq[0],"RX ordering");discard32=rxq.pop_front();end
      if(cmd_pop_i)begin check(cmd_data_o===cmdq[0],"CMD ordering");discard64=cmdq.pop_front();end
      if(tx_push_i)txq.push_back(tx_data_i);
      if(rx_push_i)rxq.push_back(rx_data_i);
      if(cmd_push_i)cmdq.push_back(cmd_data_i);
      @(posedge pclk);#0.01;
      check(tx_count_o==txq.size() && rx_count_o==rxq.size() && cmd_count_o==cmdq.size(),"counts and wraparound");
    end
    @(negedge pclk);tx_pop_i=0;tx_push_i=0;rx_pop_i=0;rx_push_i=0;cmd_pop_i=0;cmd_push_i=0;
    clear_tx_i=1;clear_cmd_i=1;
    @(negedge pclk);check(tx_empty_o && cmd_empty_o && rx_count_o==rxq.size(),"selective clear retains RX");
    clear_tx_i=0;clear_cmd_i=0;clear_rx_i=1;
    @(negedge pclk);check(rx_empty_o,"RX clear");
    if(errors)$fatal(1,"QUEUES_UT fail %0d",errors);
    $display("QUEUES_UT PASS");$display("UT_SPI_QUEUES: PASS (errors=0)");$finish;
  end
endmodule
