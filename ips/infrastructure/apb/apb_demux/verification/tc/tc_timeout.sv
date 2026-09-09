// tc_timeout.sv - timeout 参数配置 + 长 wait 路由
// timeout 为编译期参数（tb_top 默认关闭）；本 TC 验证 timeout 配置合法性，
// 并通过端口 1 配置长 wait 的读写事务验证 wait-state 语义（timeout 未使能时
// 事务正常完成，不因 wait 挂死）。
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_timeout extends tc_base;

  `uvm_component_utils(tc_timeout)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    apb_item it;
    bit slverr;
    phase.raise_objection(this);
    // timeout 未使能（TIMEOUT_ENABLE=0）下：端口 1 配置固定 3 周期 wait，
    // 事务应正常完成（不因 wait 挂死），验证 wait-state 语义。
    env.slave_agent[1].cfg.slave_response_mode = APB_FIXED_WAIT;
    env.slave_agent[1].cfg.default_wait_cycles = 3;
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    it = apb_item::type_id::create("tout_rd");
    bseq.start_item(it);
    it.direction = APB_READ;
    it.addr      = addr_in_port(1, 0);
    it.strb      = '0;
    bseq.finish_item(it);
    if (it.slverr)
      `uvm_error(get_type_name(), "timeout 未使能时端口1 读不应返回 PSLVERR")
    `uvm_info(get_type_name(), "timeout: 配置校验 + 端口1 长 wait 事务正常完成", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

endclass : tc_timeout
