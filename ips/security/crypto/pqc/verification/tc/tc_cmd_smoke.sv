// =============================================================================
// File Name   : tc_cmd_smoke.sv
// Description : TC.PQC.CMD.001 - command submission smoke
//
// VPLAN expectation: power-up, enable, self-test pass, submit a legal command
// through the doorbell and receive completion + DONE.
//
// Scope of this testcase (honest boundary): the full algorithm data path
// (input DMA -> KEM/DSA -> output DMA -> completion -> IRQ) is NOT yet closed in
// RTL. This test therefore verifies the *control* contract that exists today:
// enable, self-test gating, command register acceptance, doorbell submission and
// the STATUS/DONE observation path. It must not be read as an end-to-end
// algorithm KAT - those remain open (see reports/report.md ISSUE-004/A03).
// =============================================================================

`ifndef TC_CMD_SMOKE__SV
`define TC_CMD_SMOKE__SV

class tc_cmd_smoke extends tc_base;

  `uvm_component_utils(tc_cmd_smoke)

  function new(string name = "tc_cmd_smoke", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    logic [31:0] rd;
    bit          err;
    int unsigned polls;

    phase.raise_objection(this, "tc_cmd_smoke");

    repeat (20) @(posedge env.apb_vip.vif.pclk);

    // 1) Identification must read back the RDL reset constant.
    apb_read(PQC_REG_ID_VERSION, rd, err);
    if (err) `uvm_error(get_type_name(), "ID_VERSION read returned pslverr")
    else if (rd !== PQC_ID_VERSION_RESET)
      `uvm_error(get_type_name(), $sformatf("ID_VERSION got=0x%08h exp=0x%08h",
                                            rd, PQC_ID_VERSION_RESET))

    // 2) Standard bring-up (enable + self test).
    bringup();

    // 3) Wait for self test to finish (idle re-asserted).
    polls = 0;
    do begin
      repeat (10) @(posedge env.apb_vip.vif.pclk);
      apb_read(PQC_REG_STATUS, rd, err);
      polls++;
    end while (rd[0] !== 1'b1 && polls < 100);

    if (!rd[0]) `uvm_error(get_type_name(), "STATUS.idle never re-asserted after self test")
    if (rd[3])  `uvm_error(get_type_name(), "STATUS.error set after self test")

    // 4) Program a legal command (opcode/pset/abi are swwe-gated, not BUSY now).
    apb_write(PQC_REG_COMMAND, 32'h0100_0001);   // abi=0x01, pset=0, opcode=1

    // 5) Program a descriptor pointer and ring the doorbell.
    apb_write(PQC_REG_DESC_ADDR_LO, 32'h0000_1000);
    apb_write(PQC_REG_DESC_ADDR_HI, 32'h0000_0000);
    apb_write(PQC_REG_DOORBELL,     32'h0000_0001);

    // 6) Observe the frontend accepting the command (BUSY or DONE, never error).
    repeat (40) @(posedge env.apb_vip.vif.pclk);
    apb_read(PQC_REG_STATUS, rd, err);
    if (err) `uvm_error(get_type_name(), "STATUS read returned pslverr after doorbell")
    if (rd[3]) `uvm_error(get_type_name(), "STATUS.error set after command submission")

    `uvm_info(get_type_name(),
      $sformatf("command smoke done: STATUS=0x%08h", rd), UVM_LOW)

    phase.drop_objection(this, "tc_cmd_smoke");
  endtask

endclass

`endif // TC_CMD_SMOKE__SV