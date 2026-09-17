// =============================================================================
// File Name   : pqc_apb_adapter.sv
// Description : Adapter from the APB VIP observation stream to the PQC model
//
// The APB VIP is the authoritative observer of the APB bus (ADR-1: one monitor
// per bus, owned by the VIP). PQC-side components must not duplicate that
// observation logic; this adapter only *translates* the VIP's apb_item into the
// PQC register-contract item (pqc_apb_access) used by the reference model,
// checker and functional coverage.
// =============================================================================

`ifndef PQC_APB_ADAPTER__SV
`define PQC_APB_ADAPTER__SV

class pqc_apb_adapter extends uvm_subscriber #(apb_item);

  `uvm_component_utils(pqc_apb_adapter)

  // Downstream: PQC model / checker / coverage all observe the translated item
  uvm_analysis_port #(pqc_apb_access) ap;

  int unsigned num_seen;

  function new(string name = "pqc_apb_adapter", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void write(apb_item t);
    pqc_apb_access tr = pqc_apb_access::type_id::create("tr");

    tr.is_write = (t.direction == APB_WRITE);
    tr.addr     = t.addr[9:0];
    tr.wdata    = t.wdata[31:0];
    tr.strb     = t.strb[3:0];
    tr.rdata    = t.rdata[31:0];
    tr.slverr   = t.slverr;

    num_seen++;
    ap.write(tr);
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
      $sformatf("APB observation adapter forwarded %0d accesses", num_seen), UVM_LOW)
  endfunction

endclass

`endif // PQC_APB_ADAPTER__SV