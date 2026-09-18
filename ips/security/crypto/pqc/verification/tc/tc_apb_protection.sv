// =============================================================================
// File Name   : tc_apb_protection.sv
// Description : TC.PQC.APB.001 - unmapped address and idle programming
//
// Checks:
//   * an unmapped address returns pslverr (err-if-bad-addr CSR policy)
//   * a mapped access never returns pslverr
//   * command/descriptor writes are accepted while idle
// =============================================================================

`ifndef TC_APB_PROTECTION__SV
`define TC_APB_PROTECTION__SV

class tc_apb_protection extends tc_base;

  `uvm_component_utils(tc_apb_protection)

  function new(string name = "tc_apb_protection", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    // NOTE: 'before'/'after' are SystemVerilog keywords; use explicit names.
    logic [31:0] rd, cmd_before, cmd_after;
    bit          err;

    phase.raise_objection(this, "tc_apb_protection");

    repeat (20) @(posedge env.apb_vip.vif.pclk);
    bringup();
    repeat (20) @(posedge env.apb_vip.vif.pclk);

    // 1) Unmapped addresses must be rejected (outside every CSR window).
    //
    begin
      logic [9:0] bad_addrs [4] = '{10'h0FC, 10'h0B0, 10'h2F0, 10'h3FC};
      foreach (bad_addrs[j]) begin
        apb_read(bad_addrs[j], rd, err);
        if (!err)
          `uvm_error(get_type_name(),
            $sformatf("unmapped read 0x%03h did not return pslverr", bad_addrs[j]))
        apb_read_sec(bad_addrs[j], rd, err);
        if (!err)
          `uvm_error(get_type_name(), "unmapped privileged read did not return pslverr")
        apb_write(bad_addrs[j], 32'hDEAD_BEEF);
        // a following mapped read must still work (no state corruption)
      end
    end

    // 2) Mapped accesses must not error.
    apb_read(PQC_REG_CTRL, rd, err);
    if (err) `uvm_error(get_type_name(), "mapped CTRL read returned pslverr")
    apb_read(PQC_REG_STATUS, rd, err);
    if (err) `uvm_error(get_type_name(), "mapped STATUS read returned pslverr")

    // 3) Software write-enable (swwe) gating of the COMMAND/descriptor group.
    //
    // Idle programming is covered here. Command-in-flight protection remains
    // a separate obligation; this case does not claim to test the BUSY window.
    apb_write(PQC_REG_COMMAND, 32'h0100_0002);
    apb_read (PQC_REG_COMMAND, cmd_before, err);
    if (err) `uvm_error(get_type_name(), "COMMAND read returned pslverr")
    else if ((cmd_before & 32'h0000_FFFF) !== 32'h0000_0002)
      `uvm_error(get_type_name(),
        $sformatf("COMMAND write not accepted while idle: read=0x%08h", cmd_before))
    else
      `uvm_info(get_type_name(), "COMMAND write accepted and read back", UVM_LOW)

    // Descriptor group writes must also be accepted while idle.
    apb_write(PQC_REG_DESC_ADDR_LO, 32'h0000_2000);
    apb_read (PQC_REG_DESC_ADDR_LO, cmd_after, err);
    if (err) `uvm_error(get_type_name(), "DESC_ADDR_LO read returned pslverr")
    else if (cmd_after !== 32'h0000_2000)
      `uvm_error(get_type_name(),
        $sformatf("DESC_ADDR_LO write not accepted: read=0x%08h", cmd_after))

    phase.drop_objection(this, "tc_apb_protection");
  endtask

endclass

`endif // TC_APB_PROTECTION__SV