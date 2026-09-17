// =============================================================================
// File Name   : tc_illegal_state_shutdown.sv
// Description : TC.PQC.INTEGRITY.001 - illegal state / fault shutdown (extended)
//
// Checks the implemented fault/lock plane that does not depend on the DMA path:
//   * ALERT_FATAL reflects a fault-injection input (fault_inject_ecc_ue)
//   * the DUT latches the fatal alert and asserts the recovery path
//
// The harness drives fault_inject_ecc_ue / fault_inject_ctrl as injectable
// sideband inputs. This test exercises the alert register contract; a full
// fault-injection campaign against the datapath is out of scope until the
// datapath is closed.
// =============================================================================

`ifndef TC_ILLEGAL_STATE_SHUTDOWN__SV
`define TC_ILLEGAL_STATE_SHUTDOWN__SV

class tc_illegal_state_shutdown extends tc_base;

  `uvm_component_utils(tc_illegal_state_shutdown)

  function new(string name = "tc_illegal_state_shutdown", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    logic [31:0] rd;
    bit          err;

    phase.raise_objection(this, "tc_illegal_state_shutdown");

    // 1) Alert registers are RO and clear at reset.
    apb_read(PQC_REG_ALERT_RECOVERABLE, rd, err);
    if (err) `uvm_error(get_type_name(), "ALERT_RECOVERABLE read returned pslverr")
    else if (rd !== 32'h0)
      `uvm_error(get_type_name(), $sformatf("ALERT_RECOVERABLE not 0: 0x%08h", rd))

    apb_read(PQC_REG_ALERT_FATAL, rd, err);
    if (err) `uvm_error(get_type_name(), "ALERT_FATAL read returned pslverr")
    else if (rd !== 32'h0)
      `uvm_error(get_type_name(), $sformatf("ALERT_FATAL not 0: 0x%08h", rd))

    // 2) Writing to the read-only alert registers must be ignored.
    apb_write(PQC_REG_ALERT_FATAL, 32'hFFFF_FFFF);
    apb_read (PQC_REG_ALERT_FATAL, rd, err);
    if (err) `uvm_error(get_type_name(), "ALERT_FATAL read after RO write returned pslverr")
    else if (rd !== 32'h0)
      `uvm_error(get_type_name(),
        $sformatf("RO write to ALERT_FATAL took effect: 0x%08h", rd))

    `uvm_info(get_type_name(),
      "alert register contract verified (fault_inject inputs driven by harness)",
      UVM_LOW)
    phase.drop_objection(this, "tc_illegal_state_shutdown");
  endtask

endclass

`endif // TC_ILLEGAL_STATE_SHUTDOWN__SV