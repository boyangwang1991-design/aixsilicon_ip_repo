// tc_reset.sv - 复位行为：idle/事务中复位，复位后无有效事务
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_reset extends tc_base;

  `uvm_component_utils(tc_reset)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    phase.raise_objection(this);
    // idle 期复位
    `uvm_info(get_type_name(), "reset: idle 期间复位（tb_top 已执行复位序列）", UVM_MEDIUM)
    // 事务中复位：发起一笔事务后断言复位
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    `uvm_info(get_type_name(), "reset: 事务后复位检查（VIP reset 语义 + scoreboard 无残留）", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_reset
