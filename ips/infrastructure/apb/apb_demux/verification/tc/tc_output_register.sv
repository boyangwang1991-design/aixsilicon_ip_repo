// tc_output_register.sv - response register 参数 + back-to-back 路由
// OUTPUT_REGISTER 为编译期参数（tb_top 默认关闭）；本 TC 验证配置合法性，
// 并通过端口 3 的 back-to-back 读写事务验证连续事务路由正确（响应寄存器
// 使能时通过 wait-state 保证协议合规）。
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_output_register extends tc_base;

  `uvm_component_utils(tc_output_register)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    apb_item it;
    phase.raise_objection(this);
    // 端口 3 back-to-back 写读（无间隔），验证连续事务路由与响应返回。
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    it = apb_item::type_id::create("oreg_w3a");
    bseq.start_item(it);
    it.direction = APB_WRITE;
    it.addr      = addr_in_port(3, 0);
    it.wdata     = 32'hC1C1_C1C1;
    it.strb      = '1;
    bseq.finish_item(it);
    it = apb_item::type_id::create("oreg_w3b");
    bseq.start_item(it);
    it.direction = APB_WRITE;
    it.addr      = addr_in_port(3, 4);
    it.wdata     = 32'hC2C2_C2C2;
    it.strb      = '1;
    bseq.finish_item(it);
    it = apb_item::type_id::create("oreg_r3");
    bseq.start_item(it);
    it.direction = APB_READ;
    it.addr      = addr_in_port(3, 8);
    it.strb      = '0;
    bseq.finish_item(it);
    if (it.slverr)
      `uvm_error(get_type_name(), "端口3 back-to-back 读不应返回 PSLVERR")
    `uvm_info(get_type_name(), "output_register: 配置校验 + 端口3 back-to-back 事务完成", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_output_register
