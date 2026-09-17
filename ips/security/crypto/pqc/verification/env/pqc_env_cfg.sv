// =============================================================================
// File Name   : pqc_env_cfg.sv
// Description : PQC environment configuration
//
// Aggregates the PQC-side sub-configurations and the protocol-VIP
// configurations. Protocol agents are owned by the VIPs (see
// docs/reuse_plan.md); this config only selects their modes.
// =============================================================================

`ifndef PQC_ENV_CFG__SV
`define PQC_ENV_CFG__SV

class pqc_env_cfg extends uvm_object;

  pqc_env_mode_e env_mode = PQC_ENV_NORMAL;

  pqc_dut_cfg     dut_cfg;
  pqc_rm_cfg      rm_cfg;
  pqc_checker_cfg checker_cfg;

  // Protocol VIP configuration (aixsilicon:vip:apb).
  // The AXI4 VIP is not part of this increment: its interface specialisation
  // does not match pqc_top's DMA master and the DMA path is still open in RTL.
  apb_config             apb_cfg;

  bit enable_rm      = 1;
  bit enable_checker = 1;
  bit enable_cov     = 1;

  `uvm_object_utils_begin(pqc_env_cfg)
    `uvm_field_enum(pqc_env_mode_e, env_mode, UVM_ALL_ON)
    `uvm_field_object(dut_cfg, UVM_ALL_ON)
    `uvm_field_object(rm_cfg, UVM_ALL_ON)
    `uvm_field_object(checker_cfg, UVM_ALL_ON)
    `uvm_field_object(apb_cfg, UVM_ALL_ON)
    `uvm_field_int(enable_rm, UVM_ALL_ON)
    `uvm_field_int(enable_checker, UVM_ALL_ON)
    `uvm_field_int(enable_cov, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "pqc_env_cfg");
    super.new(name);

    dut_cfg     = pqc_dut_cfg::type_id::create("dut_cfg");
    rm_cfg      = pqc_rm_cfg::type_id::create("rm_cfg");
    checker_cfg = pqc_checker_cfg::type_id::create("checker_cfg");

    // --- APB VIP: DUT is an APB Completer, so the VIP acts as Requester ----
    apb_cfg = apb_config::type_id::create("apb_cfg");
    apb_cfg.protocol_version = APB4;                 // DUT is APB4 (PPROT+PSTRB)
    apb_cfg.addr_width       = 10;                   // pqc_top CSR window
    apb_cfg.data_width       = 32;
    apb_cfg.enable_strb      = 1;                    // PSTRB is present on APB4
    apb_cfg.enable_prot      = 1;
    apb_cfg.agent_mode       = APB_ACTIVE_MASTER;    // VIP drives the DUT
    apb_cfg.role             = APB_ACTIVE_MASTER;
    apb_cfg.enable_checker   = 1;                    // VIP protocol SVA/checker
    apb_cfg.enable_coverage  = 1;                    // VIP protocol coverage
    apb_cfg.enable_x_check   = 1;
    apb_cfg.allow_protocol_violation = 0;            // never emit illegal APB

  endfunction

  function void post_randomize();
    super.post_randomize();
  endfunction

endclass

`endif // PQC_ENV_CFG__SV
