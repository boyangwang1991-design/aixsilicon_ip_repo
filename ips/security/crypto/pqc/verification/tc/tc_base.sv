// =============================================================================
// File Name   : tc_base.sv
// Description : PQC base test class
//
// Creates and configures the PQC environment, exposes the APB VIP sequencer to
// derived tests, and runs the standard enable/self-test bring-up sequence
// (CTRL.enable then CTRL.self_test) so DUT crypto commands are accepted.
// =============================================================================

`ifndef TC_BASE__SV
`define TC_BASE__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_types_pkg::*;
  import apb_pkg::*;

class tc_base extends uvm_test;

  `uvm_component_utils(tc_base)

  pqc_env     env;
  pqc_env_cfg env_cfg;

  // Handle to the APB VIP requester sequencer, resolved once in
  // end_of_elaboration_phase so directed tests can start sequences on it.
  apb_master_sequencer apb_sqr;

  function new(string name = "tc_base", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_cfg = pqc_env_cfg::type_id::create("env_cfg");
    configure_env();
    uvm_config_db #(pqc_env_cfg)::set(this, "env", "cfg", env_cfg);
    env = pqc_env::type_id::create("env", this);
  endfunction

  // Override in derived tests to change configuration
  virtual function void configure_env();
    env_cfg.enable_rm      = 1;
    env_cfg.enable_checker = 1;
    env_cfg.enable_cov     = 1;
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (env.apb_vip.master_agent == null || env.apb_vip.master_agent.sequencer == null)
      `uvm_fatal(get_type_name(),
        "APB VIP master_agent.sequencer is absent; agent_mode must be APB_ACTIVE_MASTER")
    apb_sqr = env.apb_vip.master_agent.sequencer;
  endfunction

  // ---------------------------------------------------------------------------
  // APB register access helpers built on the VIP public sequence API (ADR-13).
  // ---------------------------------------------------------------------------
  // Stimulus goes through the VIP sequence API (ADR-13): one single-access
  // sequence is started per register access. Fields are set explicitly (never
  // randomized) so directed tests stay deterministic.
  task automatic apb_write(logic [9:0] addr, logic [31:0] data, logic [3:0] strb = 4'hf);
    pqc_apb_reg_seq seq = pqc_apb_reg_seq::type_id::create("wr_seq");
    seq.is_write = 1'b1;
    seq.addr     = addr;
    seq.data     = data;
    seq.strb     = strb;       // APB4 byte enables
    // uvm_sequence::start() is a task: call it as a task (no void' cast).
    seq.start(apb_sqr);
  endtask

  task automatic apb_read(logic [9:0] addr, output logic [31:0] data, output bit err);
    pqc_apb_reg_seq seq = pqc_apb_reg_seq::type_id::create("rd_seq");
    seq.is_write = 1'b0;
    seq.addr     = addr;
    seq.strb     = 4'h0;       // reads must carry PSTRB = 0 (APB rule)
    seq.start(apb_sqr);
    data = seq.rdata;
    err  = seq.slverr;
  endtask

  // Standard bring-up: enable the accelerator and request a self test.
  task automatic bringup();
    logic [31:0] rd;
    bit          err;
    apb_write(PQC_REG_CTRL, 32'h0000_0001);   // enable
    apb_read (PQC_REG_STATUS, rd, err);
    if (err) `uvm_error(get_type_name(), "STATUS read returned pslverr during bringup")
    apb_write(PQC_REG_CTRL, 32'h0000_0008);   // self_test (singlepulse)
  endtask

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass

`endif // TC_BASE__SV
