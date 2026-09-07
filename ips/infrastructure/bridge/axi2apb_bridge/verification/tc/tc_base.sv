// =============================================================================
// tc_base.sv - X2P 基础 test（VIP axi4 master + apb slave）
//   携带可检查响应/数据的单笔 AXI 主序列 + 高层 helper（写/读/突发写/突发读）
// =============================================================================

`ifndef TC_BASE__SV
`define TC_BASE__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_pkg::*;
import axi4_types_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

// -----------------------------------------------------------------------------
// 单笔 AXI 主序列：携带 item 引用，在 body 内 start/finish；
// 完成后 driver 会回填 item.response[]（B/R 响应）与 item.data[]（R 数据）。
// 不 randomize item（手工构造字段），避免约束意外改写。
// -----------------------------------------------------------------------------
class x2p_axi_item_seq extends axi4_master_base_seq;

  `uvm_object_utils(x2p_axi_item_seq)

  axi4_master_item req;

  function new(string name = "x2p_axi_item_seq");
    super.new(name);
  endfunction

  virtual task body();
    start_item(req);
    finish_item(req);
  endtask

endclass : x2p_axi_item_seq


/// @class tc_base
/// @brief 基础 test 类：创建 x2p_env，提供 AXI 读写 helper 与响应判读
class tc_base extends uvm_test;

  x2p_env env;

  `uvm_component_utils(tc_base)

  virtual axi4_if axi_vif;
  virtual apb_if  apb_vif;

  function new(string name = "tc_base", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = x2p_env::type_id::create("env", this);
    if (!uvm_config_db#(virtual axi4_if)::get(this, "", "axi_vif", axi_vif))
      `uvm_fatal(get_type_name(), "axi_vif not found in config_db")
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
      `uvm_fatal(get_type_name(), "apb_vif not found in config_db")
  endfunction

  // ---------------------------------------------------------------------------
  // helper：构造 master item（手工字段，不 randomize）
  // ---------------------------------------------------------------------------
  protected function void fill_master_item(axi4_master_item it,
                                           axi4_access_type at,
                                           bit [31:0] addr,
                                           int len,
                                           bit [3:0] id);
    it.access_type  = at;
    it.id           = axi4_id'(id);
    it.address      = axi4_address'(addr);
    it.burst_length = len;
    it.burst_size   = 8;                      // 64-bit beat
    it.burst_type   = AXI4_INCREMENTING_BURST;
    it.lock         = AXI4_NORMAL_LOCK;
    it.protection   = '0;
    it.memory_type  = AXI4_NORMAL_NON_CACHEABLE_BUFFERABLE;
    it.qos          = 0;
    it.region       = 0;
    it.has_response = 1;
  endfunction

  // ---------------------------------------------------------------------------
  // 总线级 B 响应观察（写为 outstanding 异步完成；VIP driver 的 drive_write_data
  // 内含无条件 `disable fork` 会杀掉其后台 B 收集线程，故不从 item.response 取，
  // 直接在 axi4_if 上等 bvalid+bid 握手拿 bresp）
  // ---------------------------------------------------------------------------
  virtual task wait_b_on_bus(bit [3:0] id, int guard, output axi4_response resp);
    resp = AXI4_DECODE_ERROR;
    fork
      begin : b_watch
        forever begin
          @(posedge axi_vif.aclk);
          if (axi_vif.bvalid && (axi_vif.bid == id)) begin
            resp = axi_vif.bresp;
            break;
          end
        end
      end
      begin : b_guard
        repeat (guard) @(posedge axi_vif.aclk);
      end
    join_any
    disable fork;
  endtask

  // ---------------------------------------------------------------------------
  // 单笔 64-bit 写；等 B 响应后返回
  // ---------------------------------------------------------------------------
  virtual task axi_write(input bit [31:0] addr, input bit [63:0] data,
                         input bit [3:0] id, output axi4_response resp);
    x2p_axi_item_seq s;
    axi4_master_item it;
    s  = x2p_axi_item_seq::type_id::create("s");
    it = axi4_master_item::type_id::create("it");
    fill_master_item(it, AXI4_WRITE_ACCESS, addr, 1, id);
    it.data         = new[1];
    it.strobe       = new[1];
    it.data[0]      = axi4_data'(data);
    it.strobe[0]    = '1;
    s.req = it;
    s.start(env.axi_master.sequencer);
    wait_b_on_bus(id, 20000, resp);      // 总线级 B 观察（VIP 后台线程有缺陷）
  endtask

  // ---------------------------------------------------------------------------
  // 单笔 64-bit 读；返回 R 数据与响应
  // ---------------------------------------------------------------------------
  virtual task axi_read(input bit [31:0] addr, input bit [3:0] id,
                        output bit [63:0] data, output axi4_response resp);
    x2p_axi_item_seq s;
    axi4_master_item it;
    s  = x2p_axi_item_seq::type_id::create("s");
    it = axi4_master_item::type_id::create("it");
    fill_master_item(it, AXI4_READ_ACCESS, addr, 1, id);
    s.req = it;
    s.start(env.axi_master.sequencer);
    data = (it.data.size() > 0) ? it.data[0] : '0;
    resp = (it.response.size() > 0) ? it.response[0] : AXI4_DECODE_ERROR;
  endtask

  // ---------------------------------------------------------------------------
  // INCR burst 写（len beats × 8B）；返回 B 响应（多 ID 时取首个）
  // ---------------------------------------------------------------------------
  virtual task axi_burst_write(input bit [31:0] addr, input bit [63:0] data[],
                               input int len, input bit [3:0] id,
                               output axi4_response resp);
    x2p_axi_item_seq s;
    axi4_master_item it;
    s  = x2p_axi_item_seq::type_id::create("s");
    it = axi4_master_item::type_id::create("it");
    fill_master_item(it, AXI4_WRITE_ACCESS, addr, len, id);
    it.data         = new[len];
    it.strobe       = new[len];
    foreach (data[i]) begin
      it.data[i]   = axi4_data'(data[i]);
      it.strobe[i] = '1;
    end
    s.req = it;
    s.start(env.axi_master.sequencer);
    wait_b_on_bus(id, 20000, resp);      // 总线级 B 观察（VIP 后台线程有缺陷）
  endtask

  // ---------------------------------------------------------------------------
  // INCR burst 读（len beats × 8B）；返回逐 beat 数据与首个 R 响应
  // ---------------------------------------------------------------------------
  virtual task axi_burst_read(input bit [31:0] addr, input int len,
                              input bit [3:0] id, output bit [63:0] data[],
                              output axi4_response resp);
    x2p_axi_item_seq s;
    axi4_master_item it;
    s  = x2p_axi_item_seq::type_id::create("s");
    it = axi4_master_item::type_id::create("it");
    fill_master_item(it, AXI4_READ_ACCESS, addr, len, id);
    s.req = it;
    s.start(env.axi_master.sequencer);
    data = new[it.data.size()];
    foreach (it.data[i]) data[i] = it.data[i];
    resp = (it.response.size() > 0) ? it.response[0] : AXI4_DECODE_ERROR;
  endtask

  // ---------------------------------------------------------------------------
  // 响应判读：期望 OKAY；否则 error 计数
  // ---------------------------------------------------------------------------
  virtual function void check_resp(string what, axi4_response resp, ref int errors);
    if (resp !== AXI4_OKAY) begin
      `uvm_error(get_type_name(),
                 $sformatf("%s: unexpected AXI resp=%s (expect OKAY)", what, resp.name()))
      errors++;
    end
  endfunction

endclass : tc_base

`endif
