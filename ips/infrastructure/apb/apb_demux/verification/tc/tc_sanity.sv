// tc_sanity.sv - 基础读写事务正确路由（smoke）
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_sanity extends tc_base;

  `uvm_component_utils(tc_sanity)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_sequence wseq;
    apb_read_sequence  rseq;
    phase.raise_objection(this);
    // 对每个端口执行基础读写
    for (int port = 0; port < 4; port++) begin
      wseq = apb_write_sequence::type_id::create("wseq");
      wseq.num_writes = 4;
      wseq.base_addr  = base_addr(port);
      wseq.start(env.master_agent.sequencer);
      rseq = apb_read_sequence::type_id::create("rseq");
      rseq.num_reads = 4;
      rseq.base_addr = base_addr(port);
      rseq.start(env.master_agent.sequencer);
    end
    phase.drop_objection(this);
  endtask

endclass : tc_sanity
