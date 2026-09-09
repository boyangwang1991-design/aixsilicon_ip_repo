// tc_base.sv - APB CDC Bridge UVM base testcase
// 建立 env、双时钟、复位释放
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_cdc_bridge_env_pkg::*;

class tc_base extends uvm_test;

  `uvm_component_utils(tc_base)

  apb_cdc_bridge_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_cdc_bridge_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    // 基础等待（事务由子类 sequence 驱动；此处释放 objection 供 phase 推进）
    #100ns;
    phase.drop_objection(this);
  endtask

endclass : tc_base
