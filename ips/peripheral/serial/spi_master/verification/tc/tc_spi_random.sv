import uvm_pkg::*;
import spi_master_tests::*;
class tc_spi_random extends spi_master_base_test;
  `uvm_component_utils(tc_spi_random)
  extern function new(string name,uvm_component parent);
  extern virtual task execute_scenario();
endclass
function tc_spi_random::new(string name,uvm_component parent);
    super.new(name,parent);group_name="random";
  endfunction

task tc_spi_random::execute_scenario();
    env.vif.test_random();
endtask
