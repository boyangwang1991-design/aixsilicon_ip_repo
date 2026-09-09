// tc_clock_relation.sv - 时钟关系矩阵回归 TC
// 对应 TC.FUNC.APB_CDC_BRIDGE.05.001.CLK（regression tier）
// 时钟比值由 tb_top 的 +S_PERIOD_PS/+M_PERIOD_PS plusarg 控制（Makefile 回归用多组
// plusarg 覆盖 1:1/1:2/1:4/1:8/2:1/4:1/8:1/near/irrational）；本 TC 驱动随机读写，
// 所有关系下事务必须正确（无丢失/重复）。
import apb_pkg::*;
import apb_types_pkg::*;

class tc_clock_relation extends tc_base;

  `uvm_component_utils(tc_clock_relation)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    if (env.s_agent != null) begin
      apb_random_sequence rnd_seq;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq");
      rnd_seq.num_items = 20;
      rnd_seq.start(env.s_agent.sequencer);
    end
    #60us;
    phase.drop_objection(this);
  endtask

endclass : tc_clock_relation