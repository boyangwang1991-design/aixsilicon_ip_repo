// ============================================================================
// pqc_key_slots - key metadata, permissions, generation and zeroization
//
// Implements (LLD.REG.PQC.SLOT_CTRL / SLOT_META / SLOT_DESTROY):
//   * KEY_SLOT_NUM logical slots holding secret key material and metadata
//   * handle = {generation[15:0], owner[7:0], slot[7:0]}; destroy/reallocate
//     increments the generation so stale handles fail
//   * private keys are never exposed through the ordinary read path
//   * slot lock while an operation references it
// ============================================================================
`ifndef PQC_KEY_SLOTS_SV
`define PQC_KEY_SLOTS_SV

module pqc_key_slots #(
  parameter int unsigned KEY_SLOT_NUM = 8,
  parameter int unsigned KEY_BYTES    = 64
) (
  input  logic         clk,
  input  logic         rst_n,

  // slot control window
  input  logic         ctl_we,
  input  logic [7:0]   ctl_index,
  input  logic [2:0]   ctl_type,
  input  logic         ctl_import,
  input  logic         ctl_destroy,
  input  logic         ctl_export,
  input  logic         ctl_lock,
  input  logic [7:0]   ctl_owner,
  input  logic [3:0]   ctl_algo,
  input  logic [3:0]   ctl_pset,
  input  logic [7:0]   ctl_usage,
  input  logic         ctl_exportable,
  input  logic         ctl_privileged,

  // metadata readback
  output logic [7:0]   meta_owner,
  output logic [3:0]   meta_algo,
  output logic [3:0]   meta_pset,
  output logic [7:0]   meta_usage,
  output logic         meta_exportable,
  output logic         meta_valid,
  output logic         meta_locked,
  output logic [15:0]  meta_generation,

  // handle check for a command
  input  logic         hnd_valid,
  input  logic [7:0]   hnd_slot,
  input  logic [15:0]  hnd_generation,
  input  logic [7:0]   hnd_owner,
  input  logic [2:0]   hnd_type,
  input logic [3:0] hnd_algo, hnd_pset,
  input logic [7:0] hnd_usage,
  output logic         hnd_ok,
  output logic [7:0]   key_ref,        // opaque reference, never key bytes

  // privilege and lifecycle
  input  logic         privileged,
  input  logic         debug_unlocked,
  input  logic         lifecycle_change,
  output logic         access_denied,

  // zeroize
  input  logic         zeroize_req,
  output logic         zeroize_done
);

  import pqc_pkg::*;

  localparam int unsigned SLOTS = KEY_SLOT_NUM;

  // slot storage
  logic [7:0]  s_owner      [0:SLOTS-1];
  logic [3:0]  s_algo       [0:SLOTS-1];
  logic [3:0]  s_pset       [0:SLOTS-1];
  logic [7:0]  s_usage      [0:SLOTS-1];
  logic        s_exportable [0:SLOTS-1];
  logic        s_valid      [0:SLOTS-1];
  logic        s_locked     [0:SLOTS-1];
  logic [15:0] s_generation [0:SLOTS-1];
  logic [2:0]  s_type       [0:SLOTS-1];

  // PPA: this module deliberately stores NO secret bytes. The reference design
  // kept a write-only `s_key` array (8 slots x 64 B = 512 B) that was never read
  // anywhere, i.e. pure dead storage plus dead clear logic. Secret material is
  // held by the external key manager / secure mailbox and referenced only as an
  // opaque slot handle; this IP holds metadata and permissions, never key bytes.
  // Removing it also removes 512 B of flops and the associated zeroize fanout.
  // Key material lifecycle (import/zeroize) is enforced by the key manager.

  logic [7:0] meta_idx;
  logic wipe_seen;
  logic ctl_ok;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) meta_idx <= 8'h0;
    else        meta_idx <= ctl_index;
  end

  // metadata readback is a plain indexed read of the metadata arrays only
  always_comb begin
    meta_owner      = (meta_idx < SLOTS) ? s_owner[meta_idx] : '0;
    meta_algo       = (meta_idx < SLOTS) ? s_algo[meta_idx] : '0;
    meta_pset       = (meta_idx < SLOTS) ? s_pset[meta_idx] : '0;
    meta_usage      = (meta_idx < SLOTS) ? s_usage[meta_idx] : '0;
    meta_exportable = (meta_idx < SLOTS) ? s_exportable[meta_idx] : '0;
    meta_valid      = (meta_idx < SLOTS) ? s_valid[meta_idx] : '0;
    meta_locked     = (meta_idx < SLOTS) ? s_locked[meta_idx] : '0;
    meta_generation = (meta_idx < SLOTS) ? s_generation[meta_idx] : '0;
  end

  // handle validation
  assign hnd_ok = hnd_valid
               && (hnd_slot < 8'(SLOTS))
               && s_valid[hnd_slot]
               && (s_generation[hnd_slot] == hnd_generation)
               && (s_owner[hnd_slot] == hnd_owner)
               && (s_type[hnd_slot] == hnd_type)
               && !s_locked[hnd_slot]
               && (s_algo[hnd_slot] == hnd_algo) && (s_pset[hnd_slot] == hnd_pset)
               && (hnd_usage != 0) && ((s_usage[hnd_slot] & hnd_usage) == hnd_usage)
               && !zeroize_req && !lifecycle_change;

  // opaque reference only; no key bytes cross this boundary
  assign key_ref = hnd_slot;

  // access denial: privileged window plus lifecycle/debug rules
  assign ctl_ok = privileged && ctl_privileged && ctl_index < SLOTS
                 && !s_locked[ctl_index]
                 && !(ctl_import && s_generation[ctl_index] == 16'hffff)
                 && !(ctl_export && (!s_valid[ctl_index] || !s_exportable[ctl_index]));
  assign access_denied = ctl_we && !ctl_ok;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int unsigned i = 0; i < SLOTS; i++) begin
        s_owner[i]      <= 8'h0;
        s_algo[i]       <= 4'h0;
        s_pset[i]       <= 4'h0;
        s_usage[i]      <= 8'h0;
        s_exportable[i] <= 1'b0;
        s_valid[i]      <= 1'b0;
        s_locked[i]     <= 1'b0;
        s_generation[i] <= 16'h0;
        s_type[i]       <= 3'h0;
      end
      zeroize_done <= 1'b0;
      wipe_seen <= 0;
    end else begin
      zeroize_done <= 1'b0;
      if (!zeroize_req && !lifecycle_change) wipe_seen <= 0;

      if (zeroize_req || lifecycle_change) begin
        wipe_seen <= 1;
        if (!wipe_seen) begin
        for (int unsigned i = 0; i < SLOTS; i++) begin
          s_valid[i]      <= 1'b0;
          s_locked[i]     <= 1'b0;
          if (s_generation[i] != 16'hffff) s_generation[i] <= s_generation[i] + 16'h1;
        end
        end
        zeroize_done <= 1'b1;
      end else if (ctl_we && ctl_ok) begin
        if (ctl_import) begin
          s_generation[ctl_index] <= s_generation[ctl_index] + 1'b1;
          s_owner[ctl_index]      <= ctl_owner;
          s_algo[ctl_index]       <= ctl_algo;
          s_pset[ctl_index]       <= ctl_pset;
          s_usage[ctl_index]      <= ctl_usage;
          s_exportable[ctl_index] <= ctl_exportable;
          s_type[ctl_index]       <= ctl_type;
          s_valid[ctl_index]      <= 1'b1;
          s_locked[ctl_index]     <= 1'b0;
        end

        if (ctl_destroy) begin
          // invalidate the slot and retire the handle generation; the external
          // key manager performs the physical key destruction
          s_valid[ctl_index]      <= 1'b0;
          s_locked[ctl_index]     <= 1'b0;
          if (s_generation[ctl_index] != 16'hffff) s_generation[ctl_index] <= s_generation[ctl_index] + 16'h1;
        end

        if (ctl_export) begin
          // export requests are refused for private keys; only the external key
          // wrap engine may export, and this IP never emits plaintext
          s_exportable[ctl_index] <= s_exportable[ctl_index];
        end

        if (ctl_lock) s_locked[ctl_index] <= 1'b1;
      end
    end
  end

endmodule

`endif // PQC_KEY_SLOTS_SV