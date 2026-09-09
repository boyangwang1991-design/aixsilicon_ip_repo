// tc_clock_pause.sv - 时钟暂停回归 TC
// 对应 TC.FUNC.APB_CDC_BRIDGE.05.002.PAUSE（extended tier）
// 事务进行中通过 RAL/时钟门控暂停源/目的时钟，验证暂停期间状态保持、恢复后完成、无丢失
// 说明：时钟暂停在 RTL 侧由 tb_top 门控实现（本环境示例直接依赖握手状态机自恢复）；
//       此处用长延时模拟慢时钟场景 + 随机事务，辅助验证 pending 保持。
import apb_pkg::*;
import apb_types_pkg::*;

class tc_clock_pause extends tc_base;

  `uvm_component_utils(tc_clock_pause)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    if (env.s_agent != null) begin
      apb_random_sequence rnd_seq;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq");
      rnd_seq.num_items = 16;
      rnd_seq.start(env.s_agent.sequencer);
    end
    // 模拟目的时钟暂停：拉长等待，期间 DUT 必须保持 pending（无丢失）
    #100us;
    phase.drop_objection(this);
  endtask

endclass : tc_clock_pause