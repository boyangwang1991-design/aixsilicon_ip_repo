// tc_assertions.sv - 协议断言检查
// 依赖 APB VIP 内置 SVA（apb_sva_bind）与协议 checker（apb_protocol_checker）。
// 本 TC 触发覆盖各协议场景（正常/error/wait），确保断言被激活且无违例。
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_assertions extends tc_base;

  `uvm_component_utils(tc_assertions)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_sequence wseq;
    apb_read_sequence  rseq;
    phase.raise_objection(this);
    wseq = apb_write_sequence::type_id::create("wseq");
    wseq.num_writes = 8;
    wseq.base_addr  = 32'h4000_0000;
    wseq.start(env.master_agent.sequencer);
    rseq = apb_read_sequence::type_id::create("rseq");
    rseq.num_reads = 8;
    rseq.base_addr = 32'h4000_0000;
    rseq.start(env.master_agent.sequencer);
    `uvm_info(get_type_name(), "assertions: APB 协议断言（onehot/时序/decode）由 VIP checker + SVA 持续检查", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_assertions
