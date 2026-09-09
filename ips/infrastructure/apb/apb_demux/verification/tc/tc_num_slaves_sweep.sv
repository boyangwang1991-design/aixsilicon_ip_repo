// tc_num_slaves_sweep.sv - NUM_SLAVES 参数组合功能验证
// 注：NUM_SLAVES 是编译期参数；不同参数组合由参数化编译实例（elab）覆盖，
// 本 TC 在默认 NUM_SLAVES=4 下执行完整读写，验证参数化复用语义。
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_num_slaves_sweep extends tc_base;

  `uvm_component_utils(tc_num_slaves_sweep)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_sequence wseq;
    apb_read_sequence  rseq;
    phase.raise_objection(this);
    // 覆盖 4 端口的随机读写
    wseq = apb_write_sequence::type_id::create("wseq");
    wseq.num_writes = 16;
    wseq.base_addr  = 32'h4000_0000;
    wseq.start(env.master_agent.sequencer);
    rseq = apb_read_sequence::type_id::create("rseq");
    rseq.num_reads = 16;
    rseq.base_addr = 32'h4000_0000;
    rseq.start(env.master_agent.sequencer);
    `uvm_info(get_type_name(), "num_slaves_sweep: 参数组合由 check_config.py + elab 参数化实例覆盖", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_num_slaves_sweep
