`include "uvm_macros.svh"
package spi_master_tests;
    import uvm_pkg::*;
    class spi_master_env extends uvm_env;
        `uvm_component_utils(spi_master_env)
        virtual spi_tb_if vif;
        extern function new(string name,uvm_component parent);
        extern function void build_phase(uvm_phase phase);
    endclass
    class spi_master_base_test extends uvm_test;
        `uvm_component_utils(spi_master_base_test)
        spi_master_env env;
        string group_name="apb";
        extern function new(string name,uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern virtual task execute_scenario();
        extern task run_phase(uvm_phase phase);
    endclass
    function spi_master_env::new(string name,uvm_component parent);super.new(name,parent);endfunction

    function void spi_master_env::build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual spi_tb_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
        endfunction

    function spi_master_base_test::new(string name,uvm_component parent);super.new(name,parent);endfunction

    function void spi_master_base_test::build_phase(uvm_phase phase);
            super.build_phase(phase);env=spi_master_env::type_id::create("env",this);
        endfunction

    task spi_master_base_test::execute_scenario();
        `uvm_fatal("SCENARIO","test must implement execute_scenario")
    endtask

    task spi_master_base_test::run_phase(uvm_phase phase);
            phase.raise_objection(this);
            env.vif.group_name=group_name;
            execute_scenario();
            if(env.vif.errors!=0) `uvm_error("SPI_CHECK",$sformatf("%0d checks failed",env.vif.errors))
            else `uvm_info("SPI_PASS",$sformatf("%s PASS checks=%0d",group_name,env.vif.checks),UVM_LOW)
            phase.drop_objection(this);
        endtask
endpackage
