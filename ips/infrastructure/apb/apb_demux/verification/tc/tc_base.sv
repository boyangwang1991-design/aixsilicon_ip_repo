// tc_base.sv - APB Demux UVM base testcase
// 建立 env、复位释放；子类覆盖 run_phase 注入具体 sequence
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_base extends uvm_test;

  `uvm_component_utils(tc_base)

  apb_demux_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_demux_env::type_id::create("env", this);
  endfunction

  // 供子类调用的地址映射 helper（与 tb_top 默认配置一致）
  // BASE: 0x4000_0000 / 0x4000_1000 / 0x4000_2000 / 0x4000_3000
  // MASK: 0xFFFF_F000（4KB 窗口）
  virtual function bit [31:0] base_addr(int port);
    return 32'h4000_0000 + port * 32'h1000;
  endfunction

  virtual function bit [31:0] addr_in_port(int port, int offset);
    return base_addr(port) + offset;
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #100ns;   // 基础等待（子类事务在 raise_objection 后执行）
    phase.drop_objection(this);
  endtask

endclass : tc_base
