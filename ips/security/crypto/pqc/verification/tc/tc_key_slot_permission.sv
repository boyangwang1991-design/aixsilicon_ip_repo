// TC.PQC.KEY.001: APB permission, blocked side effects and metadata RO policy.
// This tests the CSR window, not trusted key import or slot lifecycle.
`ifndef TC_KEY_SLOT_PERMISSION__SV
`define TC_KEY_SLOT_PERMISSION__SV
class tc_key_slot_permission extends tc_base;
  `uvm_component_utils(tc_key_slot_permission)
  function new(string name = "tc_key_slot_permission", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task access_slot(bit wr, logic [9:0] addr, logic [31:0] data,
                   logic [2:0] prot, output logic [31:0] rd, output bit err);
    pqc_apb_reg_seq seq = pqc_apb_reg_seq::type_id::create("slot_seq");
    seq.is_write = wr; seq.addr = addr; seq.data = data;
    seq.strb = wr ? 4'hf : 4'h0; seq.prot = prot;
    seq.start(apb_sqr);
    rd = seq.rdata; err = seq.slverr;
  endtask

  task run_phase(uvm_phase phase);
    logic [31:0] rd;
    bit err, allowed;
    phase.raise_objection(this);
    for (int prot = 0; prot < 8; prot++) begin
      allowed = (prot & 3) == 1;
      access_slot(1, PQC_REG_KEY_SLOT_CTRL, 2, 3'b001, rd, err);
      if (err) `uvm_fatal("KEY_PERMISSION", "secure privileged setup rejected")
      access_slot(1, PQC_REG_KEY_SLOT_CTRL, 3, 3'(prot), rd, err);
      if (err !== !allowed) `uvm_error("KEY_PERMISSION", $sformatf("write prot=%0d err=%b", prot, err))
      access_slot(0, PQC_REG_KEY_SLOT_CTRL, 0, 3'(prot), rd, err);
      if (err !== !allowed || rd !== (allowed ? 32'd3 : 32'd0))
        `uvm_error("KEY_PERMISSION", $sformatf("read prot=%0d err=%b data=%h", prot, err, rd))
      access_slot(0, PQC_REG_KEY_SLOT_CTRL, 0, 3'b001, rd, err);
      if (err || rd !== (allowed ? 32'd3 : 32'd2))
        `uvm_error("KEY_PERMISSION", "blocked write changed selected slot")
    end
    // At reset these metadata fields are zero; software cannot populate them.
    begin
      logic [9:0] ro_addrs [2] = '{PQC_REG_KEY_SLOT_DOMAIN, 10'h210};
      foreach (ro_addrs[i]) begin
        access_slot(1, ro_addrs[i], 32'hCAFE_F00D, 3'b001, rd, err);
        access_slot(0, ro_addrs[i], 0, 3'b001, rd, err);
        if (err || rd !== 0) `uvm_error("KEY_PERMISSION", "RO metadata changed or read failed")
      end
    end
    phase.drop_objection(this);
  endtask
endclass
`endif
