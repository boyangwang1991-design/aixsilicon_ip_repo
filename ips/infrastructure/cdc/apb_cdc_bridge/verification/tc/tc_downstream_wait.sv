// tc_downstream_wait.sv - 下游 wait-state 回归 TC
// 对应 TC.FUNC.APB_CDC_BRIDGE.02.001.DOWN（regression tier）
// 目的侧 slave 配置 RANDOM_WAIT（随机 wait 数），源发起随机读写；验证 wait 期间输出稳定、最终完成
import apb_pkg::*;
import apb_types_pkg::*;

class tc_downstream_wait extends tc_base;

  `uvm_component_utils(tc_downstream_wait)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    // env 已在 build_phase 完整构建；此处直接配置目的侧 slave 响应模式
    env.m_cfg.slave_response_mode = APB_RANDOM_WAIT;
    if (env.s_agent != null && env.m_agent != null) begin
      apb_random_sequence rnd_seq;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq");
      rnd_seq.num_items = 8;
      rnd_seq.start(env.s_agent.sequencer);
    end
    #80us;
    phase.drop_objection(this);
  endtask

endclass : tc_downstream_wait