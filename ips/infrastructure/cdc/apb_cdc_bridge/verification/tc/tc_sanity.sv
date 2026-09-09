// tc_sanity.sv - APB CDC Bridge smoke testcase（sanity read/write）
// 对应 TC.FUNC.APB_CDC_BRIDGE.01.001.SAN（smoke tier）
// 通过源侧 master agent 发起单次写 + 单次读，scoreboard 比对上下游事务
import apb_pkg::*;
import apb_types_pkg::*;

class tc_sanity extends tc_base;

  `uvm_component_utils(tc_sanity)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    // 等待复位释放与 env 就绪
    #1us;

    // 通过源侧 master sequencer 发起少量写 + 读（VIP 标准 sequence）
    if (env.s_agent != null) begin
      apb_write_sequence wr_seq;
      apb_read_sequence  rd_seq;
      wr_seq = apb_write_sequence::type_id::create("wr_seq");
      wr_seq.num_writes = 4;
      wr_seq.base_addr  = 'h2A;
      wr_seq.start(env.s_agent.sequencer);
      rd_seq = apb_read_sequence::type_id::create("rd_seq");
      rd_seq.num_reads = 4;
      rd_seq.base_addr = 'h10;
      rd_seq.start(env.s_agent.sequencer);
    end else begin
      `uvm_error(get_type_name(), "source master agent not created")
    end

    // 等待 scoreboard 完成比对
    #10us;
    phase.drop_objection(this);
  endtask

endclass : tc_sanity
