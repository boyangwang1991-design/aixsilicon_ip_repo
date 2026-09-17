// =============================================================================
// File Name   : pqc_dut_cfg.sv
// Description : PQC DUT configuration (mirrors the elaborated parameters)
// =============================================================================

`ifndef PQC_DUT_CFG__SV
`define PQC_DUT_CFG__SV

class pqc_dut_cfg extends uvm_object;

  // Elaboration configuration under verification (harness parameters)
  int unsigned ntt_lanes               = 2;
  int unsigned keccak_rounds_per_cycle = 2;
  int unsigned local_sram_kib          = 64;
  int unsigned dma_data_width          = 128;
  int unsigned key_slot_num            = 8;
  int unsigned sca_level               = 1;

  // CSR window
  int unsigned apb_addr_width = 10;
  int unsigned apb_data_width = 32;

  `uvm_object_utils_begin(pqc_dut_cfg)
    `uvm_field_int(ntt_lanes, UVM_ALL_ON)
    `uvm_field_int(keccak_rounds_per_cycle, UVM_ALL_ON)
    `uvm_field_int(local_sram_kib, UVM_ALL_ON)
    `uvm_field_int(dma_data_width, UVM_ALL_ON)
    `uvm_field_int(key_slot_num, UVM_ALL_ON)
    `uvm_field_int(sca_level, UVM_ALL_ON)
    `uvm_field_int(apb_addr_width, UVM_ALL_ON)
    `uvm_field_int(apb_data_width, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "pqc_dut_cfg");
    super.new(name);
  endfunction

endclass

`endif // PQC_DUT_CFG__SV
