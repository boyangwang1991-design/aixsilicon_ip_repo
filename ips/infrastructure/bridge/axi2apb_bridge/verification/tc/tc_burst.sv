// =============================================================================
// tc_burst.sv - AXI INCR burst 读写（多 beat × 8B）
//   验证：burst 多拍地址推进、逐 beat 数据写读回一致。
// =============================================================================

`ifndef TC_BURST__SV
`define TC_BURST__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_pkg::*;
import axi4_types_pkg::*;
import apb_pkg::*;
import apb_types_pkg::*;

class tc_burst extends tc_base;

  `uvm_component_utils(tc_burst)

  function new(string name = "tc_burst", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_response resp;
    bit [63:0]    wdata[];
    bit [63:0]    rdata[];
    int           errors = 0;
    int           nbeats = 4;

    phase.raise_objection(this);

    `uvm_info(get_type_name(), "Start tc_burst: INCR burst write/read via VIP", UVM_LOW)

    wait (axi_vif.areset_n && apb_vif.presetn);
    repeat (10) @(posedge axi_vif.aclk);

    // ---- 4-beat INCR write（每 beat 8B，地址推进 8） ----
    wdata = new[nbeats];
    foreach (wdata[i]) wdata[i] = 64'hA000000000000000 + i;
    axi_burst_write(32'h0000_2000, wdata, nbeats, 4'h2, resp);
    check_resp("burstW4", resp, errors);

    // ---- 读回 4-beat，逐 beat 比较 ----
    axi_burst_read(32'h0000_2000, nbeats, 4'h2, rdata, resp);
    check_resp("burstR4", resp, errors);
    if (rdata.size() != nbeats) begin
      `uvm_error(get_type_name(), $sformatf("burstR4: expect %0d beats, got %0d", nbeats, rdata.size()));
      errors++;
    end else begin
      foreach (rdata[i]) begin
        if (rdata[i] !== wdata[i]) begin
          `uvm_error(get_type_name(), $sformatf("burstR4 beat%0d mismatch: got 0x%016h expect 0x%016h",
                                                i, rdata[i], wdata[i]));
          errors++;
        end
      end
    end

    // ---- 2-beat INCR write/read（不同数据段） ----
    begin
      bit [63:0] w2[2];
      w2[0] = 64'h1234_5678_9ABC_DEF0;
      w2[1] = 64'h0FED_CBA9_8765_4321;
      axi_burst_write(32'h0000_2040, w2, 2, 4'h3, resp);
      check_resp("burstW2", resp, errors);
      axi_burst_read(32'h0000_2040, 2, 4'h3, rdata, resp);
      check_resp("burstR2", resp, errors);
      if (rdata.size() != 2) begin
        `uvm_error(get_type_name(), $sformatf("burstR2: expect 2 beats, got %0d", rdata.size()));
        errors++;
      end else begin
        foreach (rdata[i]) begin
          if (rdata[i] !== w2[i]) begin
            `uvm_error(get_type_name(), $sformatf("burstR2 beat%0d mismatch: got 0x%016h expect 0x%016h",
                                                  i, rdata[i], w2[i]));
            errors++;
          end
        end
      end
    end

    // ---- 连续多笔单拍写（覆盖不同 ID，队列深/调度路径） ----
    for (int i = 0; i < 8; i++) begin
      axi_write(32'h0000_3000 + (i*8), 64'h0000_0000_00AA_0000 + i, 4'h0, resp);
      check_resp($sformatf("seqW%0d", i), resp, errors);
    end
    for (int i = 0; i < 8; i++) begin
      bit [63:0] d;
      axi_read(32'h0000_3000 + (i*8), 4'h0, d, resp);
      check_resp($sformatf("seqR%0d", i), resp, errors);
      if (d !== (64'h0000_0000_00AA_0000 + i)) begin
        `uvm_error(get_type_name(), $sformatf("seqR%0d mismatch: got 0x%016h", i, d)); errors++;
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
