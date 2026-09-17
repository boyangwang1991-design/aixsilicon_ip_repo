// =============================================================================
// File Name   : pqc_checker_cfg.sv
// Description : PQC checker configuration
// =============================================================================

`ifndef PQC_CHECKER_CFG__SV
`define PQC_CHECKER_CFG__SV

class pqc_checker_cfg extends uvm_object;

  /// Compare read data against the register reference model
  bit check_read_data   = 1;
  /// Check that unmapped accesses return pslverr
  bit check_unmapped_err = 1;
  /// Check that a read observed after a write reflects the written value
  bit check_read_after_write = 1;
  /// Stop on the first mismatch (fail fast) or keep counting
  bit fail_fast = 0;

  `uvm_object_utils_begin(pqc_checker_cfg)
    `uvm_field_int(check_read_data, UVM_ALL_ON)
    `uvm_field_int(check_unmapped_err, UVM_ALL_ON)
    `uvm_field_int(check_read_after_write, UVM_ALL_ON)
    `uvm_field_int(fail_fast, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "pqc_checker_cfg");
    super.new(name);
  endfunction

endclass

`endif // PQC_CHECKER_CFG__SV
