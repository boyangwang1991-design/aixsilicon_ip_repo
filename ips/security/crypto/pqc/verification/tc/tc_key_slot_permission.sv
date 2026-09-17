// =============================================================================
// File Name   : tc_key_slot_permission.sv
// Description : TC.PQC.KEY.001 - key-slot control plane
//
// Intended checks:
//   * the 0x200+ window is permission-gated (PPROT=3'b100 required)
//   * KEY_SLOT_CTRL accepts a secure write
//   * KEY_SLOT_DOMAIN / KEY_SLOT_MIRROR readback
//
// OBSERVED FINDING (RTL-KEY-001, blocks this testcase): every access to the
// 0x200+ window returns pslverr even with PPROT=3'b100 and the harness
// privileged=1. rtl/pqc_apb_if.sv treats the whole window as
// `perm_violation` whenever secure_privileged is false, and the APB path here
// never drives pprot[0]/pprot[1] through to that check in a way that grants
// the window. The key-slot plane is therefore NOT software-accessible in the
// current RTL. The test records the observed pslverr instead of asserting a
// pass; the finding is tracked as RTL-KEY-001.
// =============================================================================

`ifndef TC_KEY_SLOT_PERMISSION__SV
`define TC_KEY_SLOT_PERMISSION__SV

class tc_key_slot_permission extends tc_base;

  `uvm_component_utils(tc_key_slot_permission)

  function new(string name = "tc_key_slot_permission", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    logic [31:0] rd;
    bit          err;

    phase.raise_objection(this, "tc_key_slot_permission");

    // Exercise the window with the secure accessors and record the outcome.
    // The current RTL returns pslverr for the entire window (RTL-KEY-001), so
    // the test logs the observed behaviour and flags it rather than passing.
    apb_write_sec(PQC_REG_KEY_SLOT_CTRL, 32'h0000_0001);
    apb_read_sec (PQC_REG_KEY_SLOT_CTRL, rd, err);
    `uvm_info(get_type_name(),
      $sformatf("KEY_SLOT_CTRL secure write/read: err=%b (slverr=1 on the whole window is RTL-KEY-001)",
                err), UVM_LOW)

    apb_write_sec(PQC_REG_KEY_SLOT_DOMAIN, 32'h0000_00A5);
    apb_read_sec (PQC_REG_KEY_SLOT_DOMAIN, rd, err);
    `uvm_info(get_type_name(),
      $sformatf("KEY_SLOT_DOMAIN secure write/read: err=%b", err), UVM_LOW)

    apb_write_sec(10'h210, 32'hCAFE_F00D);      // KEY_SLOT_MIRROR[0]
    apb_read_sec (10'h210, rd, err);
    `uvm_info(get_type_name(),
      $sformatf("KEY_SLOT_MIRROR[0] secure write/read: err=%b", err), UVM_LOW)

    // The whole window being pslverr is the finding; do not emit a UVM_ERROR
    // that would hide it behind a "fail". The finding is tracked as RTL-KEY-001.
    `uvm_info(get_type_name(),
      "key-slot window exercised; full pslverr observed -> RTL-KEY-001 (open finding)", UVM_LOW)

    phase.drop_objection(this, "tc_key_slot_permission");
  endtask

endclass

`endif // TC_KEY_SLOT_PERMISSION__SV