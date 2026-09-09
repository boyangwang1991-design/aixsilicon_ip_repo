// tc_pslverr.sv - 下游 PSLVERR 透传上游
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_demux_env_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_pslverr extends tc_base;

  `uvm_component_utils(tc_pslverr)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_base_sequence bseq;
    apb_item it;
    bit slverr;
    phase.raise_objection(this);
    // 配置端口 1 100% 返回 PSLVERR
    // 注意：ZERO_WAIT 路径下 VIP slave driver 不调用 decide_error（pslverr 恒 0），
    // 因此使用 FIXED_WAIT（PREADY 由 driver 决策）来触发 error responder。
    env.slave_agent[1].cfg.slave_response_mode = APB_FIXED_WAIT;
    env.slave_agent[1].cfg.default_wait_cycles = 1;
    env.slave_agent[1].cfg.slave_error_mode    = APB_ERR_RANDOM;
    env.slave_agent[1].cfg.slave_err_prob      = 1.0;
    bseq = apb_base_sequence::type_id::create("bseq");
    bseq.start(env.master_agent.sequencer);
    // 读端口 1 地址（配置 error 区域命中）
    it = apb_item::type_id::create("err_rd");
    bseq.start_item(it);
    it.direction = APB_READ;
    it.addr      = addr_in_port(1, 0);
    it.strb      = '0;
    bseq.finish_item(it);
    slverr = it.slverr;
    if (!slverr)
      `uvm_error(get_type_name(), "端口1 配置 PSLVERR 后上游应观察到 PSLVERR=1")
    phase.drop_objection(this);
  endtask

endclass : tc_pslverr
