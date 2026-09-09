// apb_cdc_bridge_scoreboard.sv - APB CDC Bridge scoreboard
// 比对：上游完成事务（Requester 侧 monitor）与下游完成事务（Completer 侧 monitor）
// 一一对应（no loss / no duplicate / 读数据保真）
// 使用 uvm_analysis_imp_decl 宏生成 up/down 两个独立 analysis imp
`uvm_analysis_imp_decl(_up)
`uvm_analysis_imp_decl(_down)

class apb_cdc_bridge_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(apb_cdc_bridge_scoreboard)

  uvm_analysis_imp_up #(apb_item, apb_cdc_bridge_scoreboard) up_imp;
  uvm_analysis_imp_down #(apb_item, apb_cdc_bridge_scoreboard) down_imp;

  // 上游/下游完成事务队列（跨域延迟导致到达顺序不定，双向匹配）
  apb_item up_queue[$];
  apb_item down_queue[$];

  int n_up_completed;
  int n_down_completed;
  int n_mismatch;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    up_imp   = new("up_imp", this);
    down_imp = new("down_imp", this);
    n_up_completed = 0;
    n_down_completed = 0;
    n_mismatch = 0;
  endfunction

  // 从队列查找并删除匹配项
  function automatic int find_match(apb_item item, ref apb_item queue[$], output apb_item match);
    int idx = -1;
    match = null;
    foreach (queue[i]) begin
      if (queue[i].addr == item.addr && queue[i].direction == item.direction) begin
        match = queue[i];
        idx = i;
        break;
      end
    end
    return idx;
  endfunction

  // 校验匹配事务（读数据保真）
  function automatic void check_match(apb_item up, apb_item down);
    if (down.direction == APB_READ) begin
      if (down.rdata !== up.rdata)
        `uvm_error(get_type_name(), $sformatf("read data mismatch downstream=0x%0h upstream=0x%0h", down.rdata, up.rdata))
    end
  endfunction

  // 上游 monitor（Requester 侧）：与已到的下游配对，否则入队
  function void write_up(apb_item item);
    apb_item match;
    int idx;
    n_up_completed++;
    idx = find_match(item, down_queue, match);
    if (idx >= 0) begin
      check_match(item, match);
      down_queue.delete(idx);
    end else begin
      up_queue.push_back(item);
    end
  endfunction

  // 下游 monitor（Completer 侧）：与已到的上游配对，否则入队
  function void write_down(apb_item item);
    apb_item match;
    int idx;
    n_down_completed++;
    idx = find_match(item, up_queue, match);
    if (idx >= 0) begin
      check_match(match, item);
      up_queue.delete(idx);
    end else begin
      down_queue.push_back(item);
    end
  endfunction

  function void check_phase(uvm_phase phase);
    if (n_mismatch > 0)
      `uvm_error(get_type_name(), $sformatf("%0d mismatches", n_mismatch))
    if (up_queue.size() != 0)
      `uvm_error(get_type_name(), $sformatf("%0d upstream transfers never completed", up_queue.size()))
    if (n_mismatch == 0 && up_queue.size() == 0)
      `uvm_info(get_type_name(), $sformatf("SCOREBOARD PASS: %0d up / %0d down matched", n_up_completed, n_down_completed), UVM_LOW)
  endfunction

endclass : apb_cdc_bridge_scoreboard
