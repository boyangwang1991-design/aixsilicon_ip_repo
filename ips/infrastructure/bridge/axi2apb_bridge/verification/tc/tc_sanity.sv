// =============================================================================
// tc_sanity.sv - 基本 64-bit AXI 写/读回比较（smoke）
//   AXI 主激励由 VIP axi4_master_agent 驱动；APB 由 VIP apb_slave_agent
//   （ZERO_WAIT memory responder）响应。写后读回，逐地址比较数据。
// =============================================================================

`ifndef TC_SANITY__SV
`define TC_SANITY__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_pkg::*;
import axi4_types_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_sanity extends tc_base;

  `uvm_component_utils(tc_sanity)

  function new(string name = "tc_sanity", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_response resp;
    bit [63:0]    rdata;
    int           errors = 0;

    phase.raise_objection(this);

    `uvm_info(get_type_name(), "Start tc_sanity: 64-bit write/read loopback via VIP", UVM_LOW)

    wait (axi_vif.areset_n && apb_vif.presetn);
    repeat (10) @(posedge axi_vif.aclk);

    // ---- 写入 4 个 8B 对齐地址（覆盖多种数据模式） ----
    axi_write(32'h0000_1000, 64'h1122_3344_5566_7788, 4'h0, resp); check_resp("W0", resp, errors);
    axi_write(32'h0000_1008, 64'hDEAD_BEEF_CAFE_F00D, 4'h1, resp); check_resp("W1", resp, errors);
    axi_write(32'h0000_1010, 64'h0000_0000_0000_0001, 4'h2, resp); check_resp("W2", resp, errors);
    axi_write(32'h0000_1018, 64'hFFFF_FFFF_FFFF_FFFF, 4'h3, resp); check_resp("W3", resp, errors);

    // ---- 读回比较 ----
    axi_read(32'h0000_1000, 4'h0, rdata, resp);
    check_resp("R0", resp, errors);
    if (rdata !== 64'h1122_3344_5566_7788) begin
      `uvm_error(get_type_name(), $sformatf("R0 mismatch: got 0x%016h", rdata)); errors++;
    end

    axi_read(32'h0000_1008, 4'h1, rdata, resp);
    check_resp("R1", resp, errors);
    if (rdata !== 64'hDEAD_BEEF_CAFE_F00D) begin
      `uvm_error(get_type_name(), $sformatf("R1 mismatch: got 0x%016h", rdata)); errors++;
    end

    axi_read(32'h0000_1010, 4'h2, rdata, resp);
    check_resp("R2", resp, errors);
    if (rdata !== 64'h0000_0000_0000_0001) begin
      `uvm_error(get_type_name(), $sformatf("R2 mismatch: got 0x%016h", rdata)); errors++;
    end

    axi_read(32'h0000_1018, 4'h3, rdata, resp);
    check_resp("R3", resp, errors);
    if (rdata !== 64'hFFFF_FFFF_FFFF_FFFF) begin
      `uvm_error(get_type_name(), $sformatf("R3 mismatch: got 0x%016h", rdata)); errors++;
    end

    // ---- 未写地址读回应为 0 ----
    axi_read(32'h0000_2000, 4'h4, rdata, resp);
    check_resp("Runwritten", resp, errors);
    if (rdata !== 64'h0) begin
      `uvm_error(get_type_name(), $sformatf("Runwritten mismatch: got 0x%016h (expect 0)", rdata)); errors++;
    end

    if (errors == 0)
      `uvm_info(get_type_name(), "PASS", UVM_LOW)
    else
      `uvm_error(get_type_name(), "FAIL")

    phase.drop_objection(this);
  endtask

endclass

`endif
