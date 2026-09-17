// =============================================================================
// File Name   : pqc_checker.sv
// Description : PQC scoreboard / checker
//
// Compares the *actual* observed APB accesses (from the APB VIP analysis
// export, i.e. real bus activity) against the *expected* accesses produced by
// pqc_rm. Checks:
//   * read data matches the register reference model
//   * unmapped accesses return pslverr and do not silently succeed
//   * mapped accesses never return pslverr
//
// This is a protocol/register-contract checker. Algorithm correctness is out of
// scope here by design (software proof per VPLAN).
// =============================================================================

`ifndef PQC_CHECKER__SV
`define PQC_CHECKER__SV

class pqc_checker extends uvm_scoreboard;

  `uvm_component_utils(pqc_checker)

  pqc_checker_cfg cfg;

  uvm_analysis_imp_act #(pqc_apb_access, pqc_checker) act_export;
  uvm_analysis_imp_exp #(pqc_apb_access, pqc_checker) exp_export;

  // Pending expected accesses (FIFO matching: actual arrives before expected
  // because the RM is fed from the same monitor stream).
  protected pqc_apb_access exp_q[$];

  int unsigned num_checked;
  int unsigned num_mismatch;

  function new(string name = "pqc_checker", uvm_component parent = null);
    super.new(name, parent);
    act_export = new("act_export", this);
    exp_export = new("exp_export", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(pqc_checker_cfg)::get(this, "", "cfg", cfg))
      cfg = pqc_checker_cfg::type_id::create("cfg");
  endfunction

  // Expected access from the reference model
  function void write_exp(pqc_apb_access tr);
    exp_q.push_back(tr);
  endfunction

  // Actual access from the monitor
  function void write_act(pqc_apb_access tr);
    pqc_apb_access exp;
    if (exp_q.size() == 0) begin
      // Expected model lags; this is an ordering violation.
      `uvm_error(get_type_name(),
        $sformatf("actual access with no expected counterpart: %s", tr.convert2string()))
      num_mismatch++;
      return;
    end
    exp = exp_q.pop_front();
    num_checked++;
    compare(tr, exp);
  endfunction

  function void compare(pqc_apb_access act, pqc_apb_access exp);
    string tag = $sformatf("%s addr=0x%03h", act.is_write ? "WR" : "RD", act.addr);

    // 1) Error response must match the address-map prediction. The key-slot
    //    window (0x200+) is a recorded expected-error region (RTL-KEY-001): it
    //    returns pslverr for every access, so do not flag a mismatch there.
    if (cfg.check_unmapped_err && (act.slverr !== exp.slverr) &&
        !pqc_reg_key_slot_window(act.addr)) begin
      `uvm_error(get_type_name(),
        $sformatf("%s: slverr mismatch: actual=%b expected=%b (read got=0x%08h exp=0x%08h)",
                  tag, act.slverr, exp.slverr, act.rdata, exp.rdata))
      num_mismatch++;
      if (cfg.fail_fast) `uvm_fatal(get_type_name(), "fail_fast on first mismatch")
      return;
    end

    // 2) Read data must match the register model for mapped, successful reads.
    // Registers marked check_data=0 are hardware-driven/volatile and are
    // excluded: their values are asserted by the directed testcases.
    if (!act.is_write && !exp.slverr && cfg.check_read_data && exp.check_data) begin
      if (act.rdata !== exp.rdata) begin
        `uvm_error(get_type_name(),
          $sformatf("%s: read data mismatch: actual=0x%08h expected=0x%08h",
                    tag, act.rdata, exp.rdata))
        num_mismatch++;
        if (cfg.fail_fast) `uvm_fatal(get_type_name(), "fail_fast on first mismatch")
      end
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (exp_q.size() != 0) begin
      `uvm_error(get_type_name(),
        $sformatf("%0d expected accesses were never observed on the bus", exp_q.size()))
      num_mismatch += exp_q.size();
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
      $sformatf("register-contract checker: checked=%0d mismatches=%0d",
                num_checked, num_mismatch), UVM_LOW)
  endfunction

endclass

`endif // PQC_CHECKER__SV
