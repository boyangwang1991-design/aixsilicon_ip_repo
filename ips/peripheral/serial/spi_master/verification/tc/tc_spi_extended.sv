import uvm_pkg::*;
import spi_master_tests::*;
class tc_spi_extended extends spi_master_base_test;
  `uvm_component_utils(tc_spi_extended)
  extern function new(string name,uvm_component parent);
  extern virtual task execute_scenario();
endclass
function tc_spi_extended::new(string name,uvm_component parent);
    super.new(name,parent);group_name="extended";
  endfunction

task tc_spi_extended::execute_scenario();
    env.vif.test_extended();
endtask
