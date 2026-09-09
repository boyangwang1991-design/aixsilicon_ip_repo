// tc_address_decode.sv - 地址译码正确性：每端口边界地址命中正确端口
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_address_decode extends tc_base;

  `uvm_component_utils(tc_address_decode)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    phase.raise_objection(this);
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    // 每个端口基地址 + 窗口内偏移读
    for (int port = 0; port < 4; port++) begin
      do_port_read(bseq, port, 32'h0);
      do_port_read(bseq, port, 32'hFFC);
    end
    `uvm_info(get_type_name(), "address decode: 每个端口基地址与窗口内地址均发起读", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

  task automatic do_port_read(apb_base_sequence bseq, int port, bit [31:0] offset);
    apb_item it;
    bit slverr;
    it = apb_item::type_id::create($sformatf("dec_rd_p%0d_%0h", port, offset));
    bseq.start_item(it);
    it.direction = APB_READ;
    it.addr      = addr_in_port(port, offset);
    it.strb      = '0;
    bseq.finish_item(it);
    // 命中端口不应返回 decode-miss 错误（除非 offset 落在窗口外）
    if (offset < 32'h1000) begin
      if (it.slverr)
        `uvm_error(get_type_name(), $sformatf("端口 %0d 窗口内地址 0x%0h 意外返回 PSLVERR", port, it.addr))
    end
  endtask

endclass : tc_address_decode
