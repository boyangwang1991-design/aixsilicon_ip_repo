import uvm_pkg::*;
import spi_master_tests::*;
class tc_spi_commands extends spi_master_base_test;
  `uvm_component_utils(tc_spi_commands)
  extern function new(string name,uvm_component parent);
  extern virtual task execute_scenario();
endclass
function tc_spi_commands::new(string name,uvm_component parent);
    super.new(name,parent);group_name="commands";
  endfunction

task tc_spi_commands::execute_scenario();
    env.vif.test_commands();
endtask
