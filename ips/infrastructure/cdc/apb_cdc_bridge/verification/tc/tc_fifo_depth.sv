// tc_fifo_depth.sv - ASYNC_FIFO 深度配置回归 TC
// 对应 TC.FUNC.APB_CDC_BRIDGE.04.001.FIFO（regression tier）
// DUT 以 CDC_IMPL=1（ASYNC_FIFO, depth 1/2）编译；随机读写验证无丢失/重复、单事务语义保持
// 说明：拓扑化 DUT 参数由 Makefile 用 +CDC_IMPL=1 覆盖（见 regression 目标），
//       本 TC 仅负责驱动随机事务流。
import apb_pkg::*;
import apb_types_pkg::*;

class tc_fifo_depth extends tc_base;

  `uvm_component_utils(tc_fifo_depth)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    if (env.s_agent != null) begin
      apb_random_sequence rnd_seq;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq");
      rnd_seq.num_items = 24;
      rnd_seq.start(env.s_agent.sequencer);
    end
    #60us;
    phase.drop_objection(this);
  endtask

endclass : tc_fifo_depth