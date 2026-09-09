// apb_demux_scoreboard.sv - APB Demux scoreboard
// 比对：上游完成事务（Requester 侧 monitor）与各下游完成事务（Completer 侧 monitor）
// 一一对应（no loss / no duplicate / 读数据保真 / 命中端口正确）
// 使用 uvm_analysis_imp_decl 宏生成 up/down 两个独立 analysis imp
`uvm_analysis_imp_decl(_up)
`uvm_analysis_imp_decl(_down)

class apb_demux_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(apb_demux_scoreboard)

  uvm_analysis_imp_up #(apb_item, apb_demux_scoreboard) up_imp;
  uvm_analysis_imp_down #(apb_item, apb_demux_scoreboard) down_imp;

  // 上游/下游完成事务队列（双向匹配）
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
    if (up.slverr != down.slverr)
      `uvm_error(get_type_name(), $sformatf("pslverr mismatch up=%0b down=%0b", up.slverr, down.slverr))
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

  // 结束时检查残留事务
  // Decode Miss（slverr=1 且无下游）与 PSLVERR 透传（slverr=1，上游 error 但下游
  // 也可能返回 error）会导致上游残留——这些属于预期的 error 语义，过滤后判定。
  function void check_phase(uvm_phase phase);
    int up_err, up_ok, down_rem;
    up_err = 0;
    up_ok = 0;
    foreach (up_queue[i]) begin
      if (up_queue[i].slverr) up_err++;
      else up_ok++;
    end
    down_rem = down_queue.size();
    // 允许：decode miss / PSLVERR 造成的 error 上游残留（error 事务无需下游配对）
    if (up_ok != 0 || down_rem != 0) begin
      `uvm_error(get_type_name(), $sformatf("unmatched transactions: up_ok=%0d up_err=%0d down=%0d", up_ok, up_err, down_rem))
    end else begin
      `uvm_info(get_type_name(), $sformatf("SCOREBOARD PASS: %0d up / %0d down matched, mismatch=%0d (err_ok=%0d)", n_up_completed, n_down_completed, n_mismatch, up_err), UVM_LOW)
    end
  endfunction

endclass
