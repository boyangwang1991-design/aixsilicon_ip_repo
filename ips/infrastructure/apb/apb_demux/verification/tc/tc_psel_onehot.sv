// tc_psel_onehot.sv - PSEL one-hot 约束（随机地址序列）
// 通过 scoreboard 的 onehot 断言（VIP checker）+ 事务匹配验证
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_psel_onehot extends tc_base;

  `uvm_component_utils(tc_psel_onehot)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_sequence wseq;
    int n = 32;
    phase.raise_objection(this);
    // 随机地址写序列（覆盖命中各端口与未命中）
    wseq = apb_write_sequence::type_id::create("wseq");
    wseq.num_writes = n;
    wseq.base_addr  = 32'h4000_0000;
    wseq.start(env.master_agent.sequencer);
    // VIP checker 的 onehot 断言在 monitor 侧持续检查 M_PSEL
    `uvm_info(get_type_name(), "psel onehot checked via VIP checker assertion", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_psel_onehot
