// =============================================================================
// tc_timeout.sv - APB 超时与 FSM 恢复验证
//   场景：APB completer 被禁用（+X2P_APB_TIMEOUT=1，env 内 agent DISABLED），
//   PREADY 恒低 → x2p APB 引擎挂起 → 内部超时（TIMEOUT_CYCLES=256）→ AXI 返回
//   SLVERR。连续多笔读写每笔都能在超时窗内返回 SLVERR ⇒ FSM 未锁死。
// =============================================================================

`ifndef TC_TIMEOUT__SV
`define TC_TIMEOUT__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_pkg::*;
import axi4_types_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_timeout extends tc_base;

  `uvm_component_utils(tc_timeout)

  function new(string name = "tc_timeout", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_response resp;
    bit [63:0]    rdata;
    int           errors = 0;
    bit           timeout_cfg;

    phase.raise_objection(this);

    timeout_cfg = $test$plusargs("X2P_APB_TIMEOUT");
    if (!timeout_cfg)
      `uvm_info(get_type_name(), "需要 +X2P_APB_TIMEOUT=1 才进入超时断言（本次仅 warmup）", UVM_LOW)
    else
      `uvm_info(get_type_name(), "X2P_APB_TIMEOUT=1: APB 无响应 → DUT 超时 SLVERR", UVM_LOW)

    wait (axi_vif.areset_n && apb_vif.presetn);
    repeat (10) @(posedge axi_vif.aclk);

    // ---- 写：APB 永不响应 → B SLVERR ----
    axi_write(32'h0000_3000, 64'h0, 4'h6, resp);
    if (timeout_cfg) begin
      if (resp == AXI4_SLAVE_ERROR)
        `uvm_info(get_type_name(), "W0: SLVERR after APB timeout (as expected)", UVM_LOW)
      else begin
        `uvm_error(get_type_name(), $sformatf("W0: expect SLVERR on APB timeout, got %s", resp.name()));
        errors++;
      end
    end else begin
      check_resp("W0", resp, errors);   // 正常模式应 OKAY
    end

    // ---- 读：同理 → R SLVERR ----
    axi_read(32'h0000_3000, 4'h7, rdata, resp);
    if (timeout_cfg) begin
      if (resp == AXI4_SLAVE_ERROR)
        `uvm_info(get_type_name(), "R0: SLVERR after APB timeout (as expected)", UVM_LOW)
      else begin
        `uvm_error(get_type_name(), $sformatf("R0: expect SLVERR on APB timeout, got %s", resp.name()));
        errors++;
      end
    end else begin
      check_resp("R0", resp, errors);
    end

    // ---- FSM 恢复：超时后 DUT 仍持续处理后续请求（每笔均在超时窗内返回）----
    for (int i = 1; i <= 4; i++) begin
      axi_write(32'h0000_3000 + (i*8), 64'h0, 4'h8, resp);
      if (timeout_cfg) begin
        if (resp != AXI4_SLAVE_ERROR) begin
          `uvm_error(get_type_name(), $sformatf("recW%0d: expect SLVERR (recovery), got %s", i, resp.name()));
          errors++;
        end
      end else begin
        check_resp($sformatf("recW%0d", i), resp, errors);
      end
    end

    if (errors == 0)
      `uvm_info(get_type_name(), "PASS", UVM_LOW)
    else
      `uvm_error(get_type_name(), "FAIL")

    phase.drop_objection(this);
  endtask

endclass

`endif
