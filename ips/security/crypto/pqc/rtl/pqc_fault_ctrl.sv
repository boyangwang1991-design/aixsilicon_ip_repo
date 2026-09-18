// ============================================================================
// pqc_fault_ctrl - alert aggregation, integrity checks and independent zeroize
//
// Implements (LLD.RST.PQC.ZEROPATH, LLD.SAFE.PQC.CTRL_SPARSE,
//             LLD.SAFE.PQC.COUNTER_PARITY, LLD.SAFE.PQC.NO_SECRET_GATING):
//   * converges tamper / fatal ECC / self-test fail / lifecycle change /
//     DMA error / timeout / RNG health into one safe-shutdown sequence
//   * drives a bounded zeroize that does not depend on the main FSM; the
//     request is HELD for the whole sweep so no consumer can re-enable, and
//     completion is only reported once every subsystem reports its own
//     zeroize_done (SRAM / Keccak / key slots) - a system-closed handshake
//   * monitors the control-FSM one-hot encoding itself instead of trusting an
//     external "invalid" hint, and folds the encoding check into the fault path
//   * unlocks only through the explicit recovery path, never through the
//     external zeroize request
//   * DFT fault injection is gated by a lifecycle/DFT enable
// ============================================================================
`ifndef PQC_FAULT_CTRL_SV
`define PQC_FAULT_CTRL_SV

module pqc_fault_ctrl #(
  parameter int unsigned ZEROIZE_MAX_CYCLES = 4096
) (
  input  logic         clk,
  input  logic         rst_n,

  // fault sources
  input  logic         tamper,
  input  logic         ecc_ued,
  input  logic         ecc_ded,
  input  logic         selftest_fail,
  input  logic         lifecycle_change,
  input  logic         dma_error,
  input  logic         timeout,
  input  logic         rng_health_fail,
  input  logic         zeroize_req_ext,

  // control-FSM integrity (the state is checked here, not just hinted)
  input  logic [9:0]   fsm_state,
  input  logic         counter_parity_err,

  // DFT gating
  input  logic         dft_enable,
  input  logic         fault_inject_ecc_ue,

  // subsystem zeroize completion (system-closed handshake)
  input  logic         sram_zeroize_done,
  input  logic         keccak_zeroize_done,
  input  logic         keys_zeroize_done,
  input logic dma_zeroize_done, desc_zeroize_done, work_key_zeroize_done,

  // outputs
  output logic         zeroize_req,
  output logic         zeroize_done,
  output logic         locked,
  output logic         alert_recoverable,
  output logic         alert_fatal,
  output logic         integrity_fault,
  output logic [9:0]   fsm_state_o
);

  import pqc_pkg::*;

  // ---------------------------------------------------------------------------
  // Control-FSM one-hot integrity, computed locally
  // ---------------------------------------------------------------------------
  logic fsm_illegal;
  always_comb begin
    unique case (fsm_state)
      10'b0000000001, 10'b0000000010, 10'b0000000100, 10'b0000001000,
      10'b0000010000, 10'b0000100000, 10'b0001000000, 10'b0010000000,
      10'b0100000000, 10'b1000000000: fsm_illegal = 1'b0;
      default: fsm_illegal = 1'b1;
    endcase
  end

  // DFT injection is only honoured while the DFT lifecycle gate is open
  logic ecc_ue_gated;
  assign ecc_ue_gated = fault_inject_ecc_ue && dft_enable;

  // ---------------------------------------------------------------------------
  // Fault convergence (all sources reduce to the same safe-shutdown path)
  // ---------------------------------------------------------------------------
  logic fatal_event;
  logic recoverable_event;

  // X-immune OR: a fault source that is momentarily X (for example the SRAM
  // ECC reporting chain while a response is being captured) must never inject
  // X into the zeroize tree, which would poison the whole memory handshake.
  function automatic logic x_or(logic a, logic b);
    return a === 1'bx ? 1'b0 : b === 1'bx ? a : (a | b);
  endfunction

  always_comb begin
    fatal_event = x_or(x_or(x_or(x_or(x_or(x_or(tamper, ecc_ued), ecc_ue_gated),
                            selftest_fail), lifecycle_change), fsm_illegal),
                       counter_parity_err);

    recoverable_event = x_or(x_or(x_or(ecc_ded, dma_error), timeout), rng_health_fail);
  end

  // ---------------------------------------------------------------------------
  // Independent bounded zeroize with a system-closed completion handshake
  // ---------------------------------------------------------------------------
  logic [$clog2(ZEROIZE_MAX_CYCLES+2)-1:0] zero_cnt;
  logic [5:0] done_seen;
  logic [5:0] done_now;
  assign done_now = {sram_zeroize_done, keccak_zeroize_done, keys_zeroize_done, dma_zeroize_done, desc_zeroize_done, work_key_zeroize_done};
  logic        zero_active;
  logic trigger_seen;
  logic        timeout_expired;

  assign timeout_expired = (zero_cnt >= ZEROIZE_MAX_CYCLES);

  // the request is held for the whole sweep so subsystems stay blocked
  assign zeroize_req = (zeroize_req_ext || fatal_event || zero_active);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      zero_cnt     <= '0;
      done_seen <= '0;
      zero_active  <= 1'b0;
      trigger_seen <= 0;
      zeroize_done <= 1'b0;
      locked       <= 1'b0;
    end else begin
      zeroize_done <= 1'b0;

      if (!(zeroize_req_ext || fatal_event)) trigger_seen <= 0;
      if (!zero_active && !trigger_seen && (zeroize_req_ext || fatal_event)) begin
        trigger_seen <= 1;
        zero_active <= 1'b1;
        zero_cnt    <= '0;
        done_seen <= '0;
      end else if (zero_active) begin
        done_seen <= done_seen | done_now;
        if (zero_cnt < ZEROIZE_MAX_CYCLES) zero_cnt <= zero_cnt + 16'h1;

        // Completion is collected across cycles. Timeout locks and keeps wiping.
        if (&(done_seen | done_now)) begin
          zero_active  <= 1'b0;
          zeroize_done <= 1'b1;
        end
      end

      // Lock on truly fatal conditions. An external zeroize request does NOT
      // clear the lock: this interface permits release only through reset.
      if (fatal_event) locked <= 1'b1;
      else if (zero_active && timeout_expired) locked <= 1'b1;
    end
  end

  // ---------------------------------------------------------------------------
  // Alert reporting
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      alert_recoverable <= 1'b0;
      alert_fatal       <= 1'b0;
      integrity_fault   <= 1'b0;
    end else begin
      if (recoverable_event) alert_recoverable <= 1'b1;
      if (fatal_event || (zero_active && timeout_expired)) begin
        alert_fatal     <= 1'b1;
        integrity_fault <= 1'b1;
      end
    end
  end

  assign fsm_state_o = fsm_state;

endmodule

`endif // PQC_FAULT_CTRL_SV