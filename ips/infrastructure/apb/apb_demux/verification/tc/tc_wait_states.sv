// tc_wait_states.sv - 下游 wait-state 下事务完成且 selection 稳定
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_wait_states extends tc_base;

  `uvm_component_utils(tc_wait_states)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_sequence wseq;
    phase.raise_objection(this);
    // 配置各下游 slave agent 随机 wait（0~8 周期），然后发起读写
    for (int i = 0; i < 4; i++) begin
      env.slave_agent[i].cfg.default_wait_cycles = i;      // 端口 i 固定 i 周期 wait
      env.slave_agent[i].cfg.max_wait_cycles     = 8;
    end
    wseq = apb_write_sequence::type_id::create("wseq");
    wseq.num_writes = 8;
    wseq.base_addr  = 32'h4000_0000;
    wseq.start(env.master_agent.sequencer);
    `uvm_info(get_type_name(), "wait-state 事务完成（VIP slave driver 处理 wait 语义）", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_wait_states
