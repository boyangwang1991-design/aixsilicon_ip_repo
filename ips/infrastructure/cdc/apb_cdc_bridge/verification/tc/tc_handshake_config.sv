// tc_handshake_config.sv - HANDSHAKE 实现多配置回归 TC
// 对应 TC.FUNC.APB_CDC_BRIDGE.03.001.HS（regression tier）
// 随机地址/数据读写序列 × HANDSHAKE+SYNC_STAGES=2；验证无丢失/重复、payload 稳定
import apb_pkg::*;
import apb_types_pkg::*;

class tc_handshake_config extends tc_base;

  `uvm_component_utils(tc_handshake_config)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    if (env.s_agent != null) begin
      apb_random_sequence rnd_seq;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq");
      rnd_seq.num_items = 32;
      rnd_seq.start(env.s_agent.sequencer);
    end
    #80us;
    phase.drop_objection(this);
  endtask

endclass : tc_handshake_config