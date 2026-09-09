// tc_pslverr.sv - 下游 PSLVERR 传播回归 TC
// 对应 TC.FUNC.APB_CDC_BRIDGE.02.002.ERR（regression tier）+ LRS.CONS 错误覆盖
// 目的侧 slave 配置地址区间错误响应（0x1000-0x10FF slverr=1），验证上游收到对应 PSLVERR
import apb_pkg::*;
import apb_types_pkg::*;

class tc_pslverr extends tc_base;

  `uvm_component_utils(tc_pslverr)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1us;
    // 通过 m_agent 的 cfg 句柄（driver 共享同一对象）配置地址区间错误响应
    if (env.m_agent != null && env.m_agent.cfg != null) begin
      apb_addr_region_s err_region;
      apb_addr_region_s ok_region;
      err_region.base = 'h1000;
      err_region.limit = 'h10FF;
      err_region.wait_cycles = 0;
      err_region.slverr = 1'b1;
      ok_region.base = 'h0000;
      ok_region.limit = 'h0FFF;
      ok_region.wait_cycles = 0;
      ok_region.slverr = 1'b0;
      env.m_agent.cfg.slave_regions = new[2];
      env.m_agent.cfg.slave_regions[0] = ok_region;
      env.m_agent.cfg.slave_regions[1] = err_region;
      env.m_agent.cfg.slave_error_mode = APB_ERR_ADDRESS_RANGE;
    end
    if (env.s_agent != null) begin
      // 用 addr_min/max 限定在错误区间，触发 SLVERR
      apb_random_sequence rnd_seq;
      rnd_seq = apb_random_sequence::type_id::create("rnd_seq");
      rnd_seq.num_items = 8;
      rnd_seq.addr_min = 'h1000;
      rnd_seq.addr_max = 'h10FF;
      rnd_seq.start(env.s_agent.sequencer);
    end
    #60us;
    phase.drop_objection(this);
  endtask

endclass : tc_pslverr