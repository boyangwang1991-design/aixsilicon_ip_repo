// =============================================================================
// File Name   : pqc_fcov.sv
// Description : PQC functional coverage
//
// Covers the register-contract and access-pattern space observed on the APB
// control interface, per docs/verification/coverage_plan.md:
//   * address region (identification / control / descriptor / interrupt /
//     performance / completion / key-slot / unmapped)
//   * access type read/write
//   * byte-strobe patterns (full / partial / zero)
//   * error response (pslverr) occurrence
//
// Protocol-level coverage (APB timings/wait states/errors) is owned by the APB
// VIP's coverage component; this covergroup only covers PQC-specific space to
// avoid double counting.
// =============================================================================

`ifndef PQC_FCOV__SV
`define PQC_FCOV__SV

class pqc_fcov extends uvm_component;

  `uvm_component_utils(pqc_fcov)

  uvm_analysis_imp_act #(pqc_apb_access, pqc_fcov) act_export;

  typedef enum {
    REGION_ID,
    REGION_CTRL,
    REGION_DESC,
    REGION_INTR,
    REGION_PERF,
    REGION_COMPLETION,
    REGION_KEYSLOT,
    REGION_UNMAPPED
  } region_e;

  covergroup cg_apb_access;
    option.per_instance = 1;

    cp_region : coverpoint region_of(tr.addr) {
      bins id         = {REGION_ID};
      bins ctrl       = {REGION_CTRL};
      bins desc       = {REGION_DESC};
      bins intr       = {REGION_INTR};
      bins perf       = {REGION_PERF};
      bins completion = {REGION_COMPLETION};
      bins keyslot    = {REGION_KEYSLOT};
      bins unmapped   = {REGION_UNMAPPED};
    }

    cp_kind : coverpoint tr.is_write { bins rd = {0}; bins wr = {1}; }

    cp_strb : coverpoint tr.strb {
      bins full    = {4'hf};
      bins partial = {[4'h1:4'he]};
      bins zero    = {4'h0};
    }

    cp_err : coverpoint tr.slverr { bins ok = {0}; bins err = {1}; }

    // Region x direction: every mapped region must be read and written where
    // the register attributes allow it.
    cx_region_kind : cross cp_region, cp_kind;

    // Unmapped addresses must actually be exercised for both directions.
    cx_unmapped_err : cross cp_region, cp_err;
  endgroup

  pqc_apb_access tr;

  function new(string name = "pqc_fcov", uvm_component parent = null);
    super.new(name, parent);
    act_export = new("act_export", this);
    tr = pqc_apb_access::type_id::create("tr");
    cg_apb_access = new();
  endfunction

  function automatic region_e region_of(logic [9:0] addr);
    if (!pqc_addr_mapped(addr))                       return REGION_UNMAPPED;
    if (addr <= PQC_REG_DESC_LAST) begin
      if (addr <= 10'h01C)                            return REGION_ID;
      return REGION_DESC;
    end
    if (addr >= 10'h07C && addr <= 10'h088)           return REGION_CTRL;
    if (addr >= 10'h090 && addr <= 10'h0A4)           return REGION_INTR;
    if (addr >= 10'h100 && addr <= 10'h110)           return REGION_PERF;
    if (addr >= 10'h1C0 && addr <= 10'h1CC)           return REGION_COMPLETION;
    if (addr >= 10'h1D0 && addr <= 10'h1D8)           return REGION_COMPLETION;
    if (addr >= 10'h200 && addr <= 10'h28C)           return REGION_KEYSLOT;
    return REGION_UNMAPPED;
  endfunction

  function void write_act(pqc_apb_access t);
    // Copy fields into the covergroup sample object (avoid retaining the handle)
    tr.is_write = t.is_write;
    tr.addr     = t.addr;
    tr.wdata    = t.wdata;
    tr.strb     = t.strb;
    tr.rdata    = t.rdata;
    tr.slverr   = t.slverr;
    cg_apb_access.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
      $sformatf("PQC functional coverage: overall=%.2f%%", cg_apb_access.get_coverage()),
      UVM_LOW)
  endfunction

endclass

`endif // PQC_FCOV__SV
