// =============================================================================
// File Name   : pqc_rm.sv
// Description : PQC register-level reference model (RM)
//
// Scope (VPLAN RM section): the RM models the *software-visible register
// contract* of pqc_csr, which is the part the APB protocol agent can observe:
//   * address decode / unmapped-address rejection
//   * reset values of read-only identification and capability fields
//   * byte-strobe aware writes and swwe (software write-enable) gating while BUSY
//   * W1C semantics of the interrupt state register
//   * RO fields ignoring writes
//
// It deliberately does NOT model the KEM/DSA mathematics: algorithm
// correctness is proven by scripts/run_pqc_algo_proof.py (software proof per
// VPLAN) and must not be replaced by an in-environment golden model.
//
// Expected values come from regs/pqc.rdl (structural source of truth, frozen by
// generated CSR). The RM tracks a shadow copy against the *same* reset values
// the RDL declares so a divergence is reported by the checker.
// =============================================================================

`ifndef PQC_RM__SV
`define PQC_RM__SV

class pqc_rm extends uvm_component;

  `uvm_component_utils(pqc_rm)

  // Actual / expected transaction streams to the checker
  uvm_analysis_imp_act #(pqc_apb_access, pqc_rm) act_export;
  uvm_analysis_port    #(pqc_apb_access)         exp_ap;

  // Shadow of the software-visible register state
  protected logic [31:0] shadow [logic [9:0]];

  // Number of expected-model observations produced (for the report phase)
  int unsigned exp_count;
  virtual pqc_main_if sideband;

  function new(string name = "pqc_rm", uvm_component parent = null);
    super.new(name, parent);
    act_export = new("act_export", this);
    exp_ap     = new("exp_ap", this);
  endfunction

  // ---------------------------------------------------------------------------
  // Initialise the shadow state to the RDL reset values.
  // ---------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reset_shadow();
    if(!uvm_config_db#(virtual pqc_main_if)::get(this,"","main_bus",sideband))
      `uvm_fatal("RM","missing externally observed security sideband")
  endfunction

  // Predict from external stimulus only, never from DUT alert/lock values.
  // DFT lifecycle is tied closed by this harness. Internal ECC/integrity
  // campaigns need their own independent fault-source monitor.
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge sideband.clk);
      if(!sideband.rst_n) reset_shadow();
      else if(sideband.tamper)
        shadow[PQC_REG_ALERT_FATAL] |= 32'h2;
    end
  endtask

  function void reset_shadow();
    shadow.delete();

    // ID_VERSION / capabilities are read-only reset constants (see regs/pqc.rdl)
    shadow[PQC_REG_ID_VERSION] = PQC_ID_VERSION_RESET;
    shadow[PQC_REG_CAPABILITY0] = PQC_CAPABILITY0_RESET;
    shadow[PQC_REG_CAPABILITY1] = PQC_CAPABILITY1_RESET;

    // CTRL resets to 0 (enable/abort/zeroize/self_test all cleared)
    shadow[PQC_REG_CTRL] = 32'h0000_0000;
    // STATUS idle by default (idle=1)
    shadow[PQC_REG_STATUS] = 32'h0000_0001;
    // COMMAND keeps its ABI byte at reset (abi[31:24] = 8'h01)
    shadow[PQC_REG_COMMAND] = 32'h0100_0000;
    // RESULT / ERROR_CODE
    shadow[PQC_REG_RESULT] = 32'h0000_0000;
    shadow[PQC_REG_ERROR_CODE] = 32'h0000_0000;
    // Interrupt state is W1C and clears at reset
    shadow[PQC_REG_INTR_STATE] = 32'h0000_0000;
    shadow[PQC_REG_INTR_ENABLE] = 32'h0000_0000;
    // Alerts clear at reset
    shadow[PQC_REG_ALERT_RECOVERABLE] = 32'h0000_0000;
    shadow[PQC_REG_ALERT_FATAL] = 32'h0000_0000;
    // Performance counters clear at reset
    shadow[PQC_REG_PERF_TOTAL_CYCLES]  = 32'h0000_0000;
    shadow[PQC_REG_PERF_KECCAK_CYCLES] = 32'h0000_0000;
    shadow[PQC_REG_PERF_NTT_CYCLES]    = 32'h0000_0000;
    shadow[PQC_REG_PERF_DMA_STALL]     = 32'h0000_0000;
    shadow[PQC_REG_PERF_CMD_COUNT]     = 32'h0000_0000;
    // Completion block
    shadow[PQC_REG_COMPLETION_CMD_ID]  = 32'h0000_0000;
    shadow[PQC_REG_COMPLETION_STATUS]  = 32'h0000_0000;
    shadow[PQC_REG_COMPLETION_OUT_LEN] = 32'h0000_0000;
    shadow[PQC_REG_COMPLETION_INFO]    = 32'h0000_0000;
    // Doorbell / descriptor pointer
    shadow[PQC_REG_DOORBELL]     = 32'h0000_0000;
    shadow[PQC_REG_DESC_ADDR_LO] = 32'h0000_0000;
    shadow[PQC_REG_DESC_ADDR_HI] = 32'h0000_0000;
    // Descriptor / lengths / addresses all reset to zero
    for (int unsigned a = PQC_REG_DESC_BASE; a <= PQC_REG_DESC_LAST; a += 4)
      shadow[a] = 32'h0000_0000;
    shadow[PQC_REG_KEY_HANDLE]  = 32'h0000_0000;
    shadow[PQC_REG_CONTEXT_LEN] = 32'h0000_0000;
    // Key slot control
    shadow[PQC_REG_KEY_SLOT_CTRL]   = 32'h0000_0000;
    shadow[PQC_REG_KEY_SLOT_META]   = 32'h0000_0000;
    shadow[PQC_REG_KEY_SLOT_GEN]    = 32'h0000_0000;
    shadow[PQC_REG_KEY_SLOT_DOMAIN] = 32'h0000_0000;
    for (int unsigned i = 0; i < 32; i++)
      shadow[PQC_REG_KEY_SLOT_MIRROR_BASE + 10'(i*4)] = 32'h0000_0000;
  endfunction

  // ---------------------------------------------------------------------------
  // Register attribute helpers, derived from regs/pqc.rdl
  // ---------------------------------------------------------------------------
  // Software write-enable gated while BUSY (descriptor probes / command group).
  function automatic bit is_swwe(logic [9:0] addr);
    if (addr == PQC_REG_COMMAND) return 1'b1;
    if (addr >= PQC_REG_DESC_BASE && addr <= PQC_REG_DESC_LAST) return 1'b1;
    return 1'b0;
  endfunction

  // Write-1-to-clear register.
  function automatic bit is_w1c(logic [9:0] addr);
    return (addr == PQC_REG_INTR_STATE || addr == PQC_REG_ALERT_FATAL ||
            addr == PQC_REG_ALERT_RECOVERABLE);
  endfunction

  // Read-only register (software writes are ignored).
  function automatic bit is_ro(logic [9:0] addr);
    if (addr == PQC_REG_ID_VERSION)  return 1'b1;
    if (addr == PQC_REG_CAPABILITY0) return 1'b1;
    if (addr == PQC_REG_CAPABILITY1) return 1'b1;
    if (addr == PQC_REG_STATUS)      return 1'b1;
    if (addr == PQC_REG_RESULT)      return 1'b1;
    if (addr == PQC_REG_ERROR_CODE)  return 1'b1;
    if (addr >= PQC_REG_PERF_TOTAL_CYCLES && addr <= PQC_REG_PERF_CMD_COUNT) return 1'b1;
    if (addr >= 10'h1C0 && addr <= 10'h1CC) return 1'b1;   // COMPLETION_*
    return 1'b0;
  endfunction

  // ---------------------------------------------------------------------------
  // Predicted response for one observed access
  // ---------------------------------------------------------------------------
  function void predict(pqc_apb_access tr, output bit unmapped, output logic [31:0] rdata);
    unmapped = !pqc_addr_mapped(tr.addr);
    if (unmapped) begin
      // Unmapped accesses must be rejected and must not change any state.
      rdata = 32'h0000_0000;
      return;
    end

    if (tr.is_write) begin
      if (is_w1c(tr.addr)) begin
        // Write-1-to-clear: only the written 1 bits clear the shadow.
        logic [31:0] old = shadow.exists(tr.addr) ? shadow[tr.addr] : 32'h0;
        shadow[tr.addr] = old & ~tr.merge(32'h0);
        if(tr.addr == PQC_REG_ALERT_FATAL && sideband.tamper)
          shadow[tr.addr] |= 32'h2; // hardware set wins same-cycle W1C
      end else if (is_ro(tr.addr)) begin
        // Read-only: value must not change.
      end else if (pqc_reg_is_stimulus(tr.addr)) begin
        // INTR_TEST raises an interrupt; it does not store the written value.
      end else if (is_swwe(tr.addr) && busy()) begin
        // Software write-enable gated by BUSY: write is ignored.
      end else begin
        logic [31:0] old = shadow.exists(tr.addr) ? shadow[tr.addr] : 32'h0;
        // Only the bits in the write mask latch; singlepulse action bits do not.
        shadow[tr.addr] = tr.merge(old) & pqc_reg_write_mask(tr.addr);
      end
      rdata = 32'h0000_0000;   // APB write data phase returns 0 (no read data)
    end else begin
      rdata = shadow.exists(tr.addr) ? shadow[tr.addr] : 32'h0000_0000;
    end
  endfunction

  // Busy state used for swwe gating. Driven by the test through a simple
  // override so the RM stays a pure register model (no DUT internals).
  bit busy_override = 1'b0;
  function automatic bit busy();
    return busy_override;
  endfunction

  // ---------------------------------------------------------------------------
  // Analysis import: predict, publish the expected transaction
  // ---------------------------------------------------------------------------
  function void write_act(pqc_apb_access tr);
    pqc_apb_access exp;
    bit            unmapped;
    logic [31:0]   rdata;

    predict(tr, unmapped, rdata);

    exp = pqc_apb_access::type_id::create("exp");
    exp.is_write = tr.is_write;
    exp.addr     = tr.addr;
    exp.wdata    = tr.wdata;
    exp.strb     = tr.strb;
    exp.rdata    = rdata;
    exp.slverr   = unmapped;      // unmapped accesses must return pslverr
    // Hardware-driven (volatile) registers are not compared against a static
    // shadow; their transitions are asserted by the directed testcases.
    // The key-slot window (0x200+) is a recorded expected-error region
    // (RTL-KEY-001): it returns pslverr and no data, so it is excluded too.
    exp.check_data = !pqc_reg_is_dynamic(tr.addr) && !pqc_reg_key_slot_window(tr.addr);
    exp_count++;
    exp_ap.write(exp);
  endfunction

endclass

`endif // PQC_RM__SV
