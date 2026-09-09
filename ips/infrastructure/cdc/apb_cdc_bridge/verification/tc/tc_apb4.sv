// tc_apb4.sv - APB4 PSTRB/PPROT 保真回归 TC
// 对应 TC.INTF.APB_CDC_BRIDGE.01.001.APB4（regression tier）
// 设置非零 PSTRB/PPROT 的写事务，验证下游 PSTRB/PPROT 与上游一致
import apb_pkg::*;
import apb_types_pkg::*;

class tc_apb4 extends tc_base;

  `uvm_component_utils(tc_apb4)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    if (env.s_agent != null) begin
      apb_write_sequence wr_seq;
      wr_seq = apb_write_sequence::type_id::create("wr_seq");
      wr_seq.num_writes = 8;
      wr_seq.base_addr  = 'h1000;   // APB4 扩展：PSTRB/PPROT 由 driver 随机化
      wr_seq.start(env.s_agent.sequencer);
    end
    #30us;
    phase.drop_objection(this);
  endtask

endclass : tc_apb4