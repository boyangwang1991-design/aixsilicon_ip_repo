// =============================================================================
// File Name   : pqc_rm_cfg.sv
// Description : PQC reference model configuration
// =============================================================================

`ifndef PQC_RM_CFG__SV
`define PQC_RM_CFG__SV

class pqc_rm_cfg extends uvm_object;

  /// Model the BUSY-driven swwe gating of the descriptor/command group
  bit model_swwe_gating = 1;
  /// Model the W1C behaviour of INTR_STATE
  bit model_w1c = 1;
  /// Model unmapped-address rejection
  bit model_addr_decode = 1;

  `uvm_object_utils_begin(pqc_rm_cfg)
    `uvm_field_int(model_swwe_gating, UVM_ALL_ON)
    `uvm_field_int(model_w1c, UVM_ALL_ON)
    `uvm_field_int(model_addr_decode, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "pqc_rm_cfg");
    super.new(name);
  endfunction

endclass

`endif // PQC_RM_CFG__SV
