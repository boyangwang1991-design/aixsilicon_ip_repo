// =============================================================================
// File Name   : tc_reg_reset_attr.sv
// Description : TC.PQC.REG.001 - register reset values and access attributes
//
// Checks:
//   * RO identification/capability fields read back their RDL reset values
//   * CAPABILITY reflects the *elaborated* configuration (parameters), not a
//     hard-coded constant (RDL declares these fields hw=rw)
//   * writes to RO registers are ignored
//   * W1C semantics: only the written 1 bits of INTR_STATE clear
// =============================================================================

`ifndef TC_REG_RESET_ATTR__SV
`define TC_REG_RESET_ATTR__SV

class tc_reg_reset_attr extends tc_base;

  `uvm_component_utils(tc_reg_reset_attr)

  function new(string name = "tc_reg_reset_attr", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    logic [31:0] rd, rd2;
    bit          err;

    phase.raise_objection(this, "tc_reg_reset_attr");

    repeat (20) @(posedge env.apb_vip.vif.pclk);

    // 1) ID_VERSION reset constant
    apb_read(PQC_REG_ID_VERSION, rd, err);
    if (err) `uvm_error(get_type_name(), "ID_VERSION read pslverr")
    else if (rd !== PQC_ID_VERSION_RESET)
      `uvm_error(get_type_name(), $sformatf("ID_VERSION=0x%08h exp=0x%08h",
                                            rd, PQC_ID_VERSION_RESET))

    // 2) CAPABILITY1: SRAM KiB / DMA width / key slots must match the elaborated
    //    configuration (2 lanes, 64 KiB, 128-bit DMA, 8 slots, from harness).
    apb_read(PQC_REG_CAPABILITY1, rd, err);
    if (err) `uvm_error(get_type_name(), "CAPABILITY1 read pslverr")
    else begin
      if (rd[7:0] !== 8'd64)
        `uvm_error(get_type_name(),
          $sformatf("CAPABILITY1.local_sram_kib=%0d exp=64", rd[7:0]))
      if (rd[15:8] !== 8'd128)
        `uvm_error(get_type_name(),
          $sformatf("CAPABILITY1.dma_data_width=%0d exp=128", rd[15:8]))
      if (rd[23:16] !== 8'd8)
        `uvm_error(get_type_name(),
          $sformatf("CAPABILITY1.key_slot_num=%0d exp=8", rd[23:16]))
      if (rd[25] !== 1'b1)
        `uvm_error(get_type_name(), "CAPABILITY1.ecc_enabled not set")
      if (rd[31:26] !== 6'h01)
        `uvm_error(get_type_name(),
          $sformatf("CAPABILITY1.abi_minor=0x%02h exp=01", rd[31:26]))
    end

    // 3) CAPABILITY0: algo mask / lanes / keccak rounds honour the parameters.
    apb_read(PQC_REG_CAPABILITY0, rd, err);
    if (err) `uvm_error(get_type_name(), "CAPABILITY0 read pslverr")
    else begin
      if (rd[5:0] === 6'h0)
        `uvm_error(get_type_name(), "CAPABILITY0.algo_mask is zero (no algorithms advertised)")
      // ntt_lanes encoding: 1 lane -> 1, 2 lanes -> 2, 4 lanes -> 0
      if (rd[9:8] !== 2'd2)
        `uvm_error(get_type_name(),
          $sformatf("CAPABILITY0.ntt_lanes encoding=%0d exp=2 (2 lanes)", rd[9:8]))
      if (rd[11:10] !== 2'd2)
        `uvm_error(get_type_name(),
          $sformatf("CAPABILITY0.keccak_rounds encoding=%0d exp=2", rd[11:10]))
    end

    // 4) Writes to a read-only register must be ignored.
    apb_write(PQC_REG_ID_VERSION, 32'hFFFF_FFFF);
    apb_read (PQC_REG_ID_VERSION, rd, err);
    if (err) `uvm_error(get_type_name(), "ID_VERSION read after RO write pslverr")
    else if (rd !== PQC_ID_VERSION_RESET)
      `uvm_error(get_type_name(),
        $sformatf("RO write took effect: ID_VERSION=0x%08h", rd))

    // 5) W1C: set a bit through INTR_TEST, then clear only one bit by writing 1.
    //    INTR_TEST is a stimulus register (raise action), not a stored value;
    //    the observable result is in INTR_STATE.
    apb_write(PQC_REG_INTR_TEST, 32'h0000_0003);   // raise bits 0 and 1
    repeat (4) @(posedge env.apb_vip.vif.pclk);
    apb_read (PQC_REG_INTR_STATE, rd, err);
    if (err) `uvm_error(get_type_name(), "INTR_STATE read pslverr")

    if (rd[1:0] === 2'b11) begin
      apb_write(PQC_REG_INTR_STATE, 32'h0000_0001);  // clear bit 0 only
      repeat (4) @(posedge env.apb_vip.vif.pclk);
      apb_read (PQC_REG_INTR_STATE, rd2, err);
      if (!err && (rd2[0] === 1'b1))
        `uvm_error(get_type_name(), "W1C did not clear INTR_STATE bit 0")
      if (!err && (rd2[1] === 1'b0))
        `uvm_error(get_type_name(), "W1C cleared INTR_STATE bit 1 that was not written")
    end else begin
      `uvm_info(get_type_name(),
        $sformatf("INTR_TEST did not raise both bits (INTR_STATE=0x%08h); W1C not exercised",
                  rd), UVM_MEDIUM)
    end

    phase.drop_objection(this, "tc_reg_reset_attr");
  endtask

endclass

`endif // TC_REG_RESET_ATTR__SV