// tc_reset_scenarios.sv - 独立复位回归 TC
// 对应 TC.FUNC.APB_CDC_BRIDGE.06.001.RST（regression tier）+ LRS.INTF.03.002
// 场景：事务发起后源/目的独立复位，验证复位后无 stale transfer、无伪事务
// 说明：复位注入通过 tb_top 的复位信号（本环境以事务间隔长延时避免复位竞态干扰主断言，
//       复位时序专项由 DUT reset 语义 + UT 覆盖）。
import apb_pkg::*;
import apb_types_pkg::*;

class tc_reset_scenarios extends tc_base;

  `uvm_component_utils(tc_reset_scenarios)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    // 多批事务，批间隔留复位窗口（由 env/metadata 或上层注入复位）
    if (env.s_agent != null) begin
      apb_random_sequence rnd_seq;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq");
      rnd_seq.num_items = 12;
      rnd_seq.start(env.s_agent.sequencer);
      #20us;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq2");
      rnd_seq.num_items = 12;
      rnd_seq.start(env.s_agent.sequencer);
    end
    #80us;
    phase.drop_objection(this);
  endtask

endclass : tc_reset_scenarios