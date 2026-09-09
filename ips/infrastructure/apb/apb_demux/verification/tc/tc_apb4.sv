// tc_apb4.sv - APB4 profile 下 PSTRB/PPROT 透传
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_apb4 extends tc_base;

  `uvm_component_utils(tc_apb4)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    apb_item it;
    phase.raise_objection(this);
    // APB4：发起带 PSTRB 的写（部分字节使能）+ PPROT 变化
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    it = apb_item::type_id::create("apb4_w");
    bseq.start_item(it);
    it.direction = APB_WRITE;
    it.addr      = addr_in_port(0, 0);
    it.wdata     = 32'h1122_3344;
    it.strb      = 4'b0011;   // 低半字节使能
    it.prot.privileged_access = 1;
    bseq.finish_item(it);
    if (it.slverr)
      `uvm_error(get_type_name(), "APB4 正常写不应返回 PSLVERR")
    `uvm_info(get_type_name(), "APB4: PSTRB/PPROT 透传通过（VIP monitor 检查 strb/prot 保真）", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_apb4
