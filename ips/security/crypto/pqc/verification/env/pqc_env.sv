// =============================================================================
// File Name   : pqc_env.sv
// Description : PQC verification environment (top-level uvm_env)
//
// Composition:
//   apb_env   (VIP)  : APB4 protocol agents + unique monitor + protocol checker
//                      + protocol coverage + RAL predictor
//   axi4_env  (VIP)  : AXI4 slave responder for the DUT DMA master
//   pqc_apb_adapter  : translates VIP apb_item -> pqc_apb_access
//   pqc_rm           : register-contract reference model
//   pqc_checker      : register-contract scoreboard
//   pqc_fcov         : PQC-specific functional coverage
//
// The protocol VIPs own everything protocol-related (drivers, monitors,
// protocol SVA, protocol coverage, RAL adapter/predictor). PQC-side logic is
// limited to the register contract and IP-specific checking, matching the reuse
// boundary in docs/reuse_plan.md.
// =============================================================================

`ifndef PQC_ENV__SV
`define PQC_ENV__SV

  import pqc_ral_pkg::*;

class pqc_env extends uvm_env;

  `uvm_component_utils(pqc_env)

  pqc_env_cfg cfg;

  // Protocol VIP. Only the APB VIP is instantiated here: the AXI4 VIP uses a
  // different interface specialisation (32-bit) than pqc_top's 128-bit DMA
  // master, and the DMA data path is still open in RTL, so DMA verification is
  // deferred with that work (see the AXI4 note in verification/th/harness.sv).
  apb_env                apb_vip;

  // RAL model (generated from regs/pqc.rdl) + the VIP register adapter
  pqc_csr                regmodel;
  apb_reg_adapter        reg_adapter;

  // PQC-side verification components
  pqc_apb_adapter        adapter;
  pqc_rm                 rm;
  pqc_checker            scb;
  pqc_fcov               fcov;

  function new(string name = "pqc_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db #(pqc_env_cfg)::get(this, "", "cfg", cfg)) begin
      `uvm_fatal(get_type_name(), "pqc_env_cfg 'cfg' not set")
    end

    // --- APB VIP (protocol agents / monitor / checker / coverage) ----------
    // Use the wildcard scope: UVM config_db exact scope does not cascade into
    // deeper components, and the VIP's internal checker/predictor look the
    // config up on themselves (APB VIP user-guide §9).
    uvm_config_db #(apb_config)::set(null, "*", "config", cfg.apb_cfg);
    apb_vip = apb_env::type_id::create("apb_vip", this);

    // --- RAL model (bound to the VIP predictor in connect_phase) -----------
    regmodel = new("regmodel");
    regmodel.build();
    regmodel.lock_model();
    reg_adapter = apb_reg_adapter::type_id::create("reg_adapter");
    reg_adapter.configure(cfg.apb_cfg);

    // --- PQC-side components ----------------------------------------------
    adapter = pqc_apb_adapter::type_id::create("adapter", this);

    if (cfg.enable_rm) begin
      uvm_config_db #(pqc_rm_cfg)::set(this, "rm", "cfg", cfg.rm_cfg);
      rm = pqc_rm::type_id::create("rm", this);
    end

    if (cfg.enable_checker) begin
      uvm_config_db #(pqc_checker_cfg)::set(this, "scb", "cfg", cfg.checker_cfg);
      scb = pqc_checker::type_id::create("scb", this);
    end

    if (cfg.enable_cov) begin
      fcov = pqc_fcov::type_id::create("fcov", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // --- RAL: bind the VIP predictor and the adapter -----------------------
    // The VIP env always connects its monitor to apb_reg_predictor, whose
    // wrapped uvm_reg_predictor dereferences .map on every observed
    // transaction; the map must be bound (VIP user-guide §5). Done here because
    // the VIP's sub-components only exist after its own build_phase.
    apb_vip.predictor.reg_predictor.map = regmodel.default_map;
    regmodel.default_map.set_sequencer(apb_vip.master_agent.sequencer, reg_adapter);
    regmodel.default_map.set_auto_predict(1);

    // VIP authoritative APB observation stream -> PQC adapter
    apb_vip.monitor.transaction_ap.connect(adapter.analysis_export);

    // Adapter -> model / checker / coverage
    if (cfg.enable_rm)      adapter.ap.connect(rm.act_export);
    if (cfg.enable_checker) adapter.ap.connect(scb.act_export);
    if (cfg.enable_cov)     adapter.ap.connect(fcov.act_export);

    // Model expectations -> checker
    if (cfg.enable_rm && cfg.enable_checker)
      rm.exp_ap.connect(scb.exp_export);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
      $sformatf("PQC env: observed=%0d expected=%0d checked=%0d mismatches=%0d",
                adapter.num_seen,
                (cfg.enable_rm      ? rm.exp_count : 0),
                (cfg.enable_checker ? scb.num_checked : 0),
                (cfg.enable_checker ? scb.num_mismatch : 0)),
      UVM_LOW)
  endfunction

endclass

`endif // PQC_ENV__SV
