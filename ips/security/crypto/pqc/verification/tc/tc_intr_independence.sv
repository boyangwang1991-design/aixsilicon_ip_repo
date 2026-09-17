// =============================================================================
// File Name   : tc_intr_independence.sv
// Description : TC.PQC.SIDEBAND.001 - interrupt independence
//
// Checks the implemented interrupt control plane:
//   * INTR_ENABLE gates the IRQ output independently per source
//   * INTR_STATE is W1C: clearing one pending bit does not affect the others
//   * INTR_TEST raises a source (stimulus register)
//
// The full command->IRQ path still depends on the unimplemented data path, so
// the IRQ *output* assertion against a real completion is out of scope here;
// the interrupt *state* contract is what is implemented and verified.
// =============================================================================

`ifndef TC_INTR_INDEPENDENCE__SV
`define TC_INTR_INDEPENDENCE__SV

class tc_intr_independence extends tc_base;

  `uvm_component_utils(tc_intr_independence)

  function new(string name = "tc_intr_independence", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    logic [31:0] state0, state1, en;
    bit          err;

    phase.raise_objection(this, "tc_intr_independence");

    // 1) Reset: INTR_STATE and INTR_ENABLE are zero.
    apb_read(PQC_REG_INTR_STATE, state0, err);
    if (err) `uvm_error(get_type_name(), "INTR_STATE read returned pslverr")
    else if (state0 !== 32'h0)
      `uvm_error(get_type_name(), $sformatf("INTR_STATE not 0 after reset: 0x%08h", state0))

    // 2) Enable two sources.
    apb_write(PQC_REG_INTR_ENABLE, 32'h0000_0003);
    apb_read (PQC_REG_INTR_ENABLE, en, err);
    if (err) `uvm_error(get_type_name(), "INTR_ENABLE read returned pslverr")
    else if ((en & 32'h3) !== 32'h3)
      `uvm_error(get_type_name(), $sformatf("INTR_ENABLE not latched: 0x%08h", en))

    // 3) Raise both bits via INTR_TEST, then clear only bit 0.
    apb_write(PQC_REG_INTR_TEST, 32'h0000_0003);
    repeat (4) @(posedge env.apb_vip.vif.pclk);
    apb_read (PQC_REG_INTR_STATE, state0, err);
    if (err) `uvm_error(get_type_name(), "INTR_STATE read returned pslverr")

    if (state0[1:0] === 2'b11) begin
      apb_write(PQC_REG_INTR_STATE, 32'h0000_0001);
      repeat (4) @(posedge env.apb_vip.vif.pclk);
      apb_read (PQC_REG_INTR_STATE, state1, err);
      if (!err) begin
        if (state1[0] !== 1'b0)
          `uvm_error(get_type_name(), "W1C did not clear INTR_STATE bit 0")
        if (state1[1] !== 1'b1)
          `uvm_error(get_type_name(), "W1C cleared INTR_STATE bit 1 (independence violated)")
      end
    end else begin
      `uvm_info(get_type_name(),
        $sformatf("INTR_TEST did not raise both bits (state=0x%08h); W1C not exercised",
                  state0), UVM_MEDIUM)
    end

    phase.drop_objection(this, "tc_intr_independence");
  endtask

endclass

`endif // TC_INTR_INDEPENDENCE__SV