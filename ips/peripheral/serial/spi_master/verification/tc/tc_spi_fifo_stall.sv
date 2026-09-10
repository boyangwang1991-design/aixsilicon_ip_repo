import uvm_pkg::*;
import spi_master_tests::*;
class tc_spi_fifo_stall extends spi_master_base_test;
  `uvm_component_utils(tc_spi_fifo_stall)
  extern function new(string name,uvm_component parent);
  extern virtual task execute_scenario();
endclass
function tc_spi_fifo_stall::new(string name,uvm_component parent);
    super.new(name,parent);group_name="fifo_stall";
  endfunction

task tc_spi_fifo_stall::execute_scenario();
    env.vif.test_fifo_stall();
endtask
