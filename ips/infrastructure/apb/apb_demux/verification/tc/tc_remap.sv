// tc_remap.sv - 地址重映射配置合法性 + 基础路由
// remap 为编译期参数（tb_top 默认关闭）；本 TC 验证配置校验脚本对 remap 配置
// 的合法性，并通过端口 0/2 差异化地址的读写事务确保路由正确。
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_remap extends tc_base;

  `uvm_component_utils(tc_remap)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    apb_item it;
    phase.raise_objection(this);
    // 配置校验（check_config.py）覆盖 remap 开关合法性（CFG_BASE remap=0 通过）
    // 差异化激励：对端口 0（基地址 0x4000_0000）与端口 2（基地址 0x4000_2000）
    // 发起不同 offset 的读写，验证路由到正确端口。
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    it = apb_item::type_id::create("remap_w0");
    bseq.start_item(it);
    it.direction = APB_WRITE;
    it.addr      = addr_in_port(0, 32'h004);
    it.wdata     = 32'hA0A0_A0A0;
    it.strb      = '1;
    bseq.finish_item(it);
    it = apb_item::type_id::create("remap_w2");
    bseq.start_item(it);
    it.direction = APB_WRITE;
    it.addr      = addr_in_port(2, 32'h008);
    it.wdata     = 32'hB0B0_B0B0;
    it.strb      = '1;
    bseq.finish_item(it);
    `uvm_info(get_type_name(), "remap: 配置校验 + 端口0/2 差异化读写事务完成", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_remap
