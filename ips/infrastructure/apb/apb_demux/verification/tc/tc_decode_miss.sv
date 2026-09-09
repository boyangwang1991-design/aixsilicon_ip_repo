// tc_decode_miss.sv - Decode Miss 立即错误响应（smoke）
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_decode_miss extends tc_base;

  `uvm_component_utils(tc_decode_miss)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    apb_item it;
    bit [31:0] miss_addr = 32'h5000_0000;  // 未命中任何端口
    bit slverr;
    bit [31:0] rdata;
    phase.raise_objection(this);
    // 直接发起读未命中地址，验证返回 PSLVERR=1（decode miss 语义）
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    it = apb_item::type_id::create("miss_r");
    bseq.start_item(it);
    it.direction = APB_READ;
    it.addr      = miss_addr;
    it.strb      = '0;
    bseq.finish_item(it);
    rdata = it.rdata;
    slverr = it.slverr;
    if (!slverr)
      `uvm_error(get_type_name(), $sformatf("decode miss expected PSLVERR=1, got %0b", slverr))
    if (rdata !== 0)
      `uvm_error(get_type_name(), $sformatf("decode miss expected PRDATA=0, got 0x%0h", rdata))
    // 写未命中地址同样返回错误
    it = apb_item::type_id::create("miss_w");
    bseq.start_item(it);
    it.direction = APB_WRITE;
    it.addr      = miss_addr;
    it.wdata     = 32'hDEAD_BEEF;
    it.strb      = '1;
    bseq.finish_item(it);
    if (!it.slverr)
      `uvm_error(get_type_name(), "decode miss write expected PSLVERR=1")
    phase.drop_objection(this);
  endtask

endclass : tc_decode_miss
