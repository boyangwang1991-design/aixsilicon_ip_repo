// ============================================================================
// pqc_apb_if - APB4 adapter around the generated CSR block
//
// Implements (LLD.IF.PQC.FE.APB, LLD.TIMING.PQC.APB.RW):
//   * bridges the flattened APB4 CSR block
//   * ORs a protection error into pslverr when software writes the busy-locked
//     command/descriptor group while the engine is BUSY (the field values are
//     held by the CSR swwe inputs driven from ~busy)
//   * gates the secure-only key slot window on the privilege attribute
// ============================================================================
`ifndef PQC_APB_IF_SV
`define PQC_APB_IF_SV

module pqc_apb_if (
  input  logic         clk,
  input  logic         rst_n,

  // APB4 slave
  input  logic         s_apb_psel,
  input  logic         s_apb_penable,
  input  logic         s_apb_pwrite,
  input  logic [2:0]   s_apb_pprot,
  input  logic [9:0]   s_apb_paddr,
  input  logic [31:0]  s_apb_pwdata,
  input  logic [3:0]   s_apb_pstrb,
  output logic         s_apb_pready,
  output logic [31:0]  s_apb_prdata,
  output logic         s_apb_pslverr,

  // CSR block flattened interface
  input  logic         csr_pready,
  input  logic [31:0]  csr_prdata,
  input  logic         csr_pslverr,
  output logic         csr_psel,
  output logic         csr_penable,
  output logic         csr_pwrite,
  output logic [2:0]   csr_pprot,
  output logic [9:0]   csr_paddr,
  output logic [31:0]  csr_pwdata,
  output logic [3:0]   csr_pstrb,

  // busy / privilege used for protection
  input  logic         busy,
  input  logic         privileged,

  output logic         busy_write_error
);

  import pqc_pkg::*;

  // Pass-through of the bus phase. The write strobes and the read data are
  // masked on a rejected access so a PSLVERR access has NO side effect and no
  // data leak: a protected write must not reach the CSR fields, and a forbidden
  // read must not return register contents.
  logic busy_protected_addr;
  logic slot_window_addr;
  logic perm_violation;
  logic access_blocked;
  logic secure_privileged, control_request, access_phase;
  assign secure_privileged = privileged && s_apb_pprot[0] && !s_apb_pprot[1];
  assign control_request = s_apb_pwrite && s_apb_paddr == 10'h010 &&
                           s_apb_pstrb[0] && (|s_apb_pwdata[2:1]);
  assign access_phase = rst_n && s_apb_psel && s_apb_penable;

  // Addresses are byte addresses; the flattened CSR core derives its word
  // index from paddr[9:2], so the comparisons below use 10-bit byte offsets.
  always_comb begin
    // COMMAND 0x018, descriptor 0x020-0x078, KEY_HANDLE 0x07C,
    // CONTEXT_LEN 0x080, DESC_ADDR 0x1D4-0x1D8
    busy_protected_addr =
      (s_apb_paddr == 10'h018) ||
      ((s_apb_paddr >= 10'h020) && (s_apb_paddr <= 10'h078)) ||
      (s_apb_paddr == 10'h07C) ||
      (s_apb_paddr == 10'h080) ||
      (s_apb_paddr == 10'h1D0) ||
      ((s_apb_paddr >= 10'h1D4) && (s_apb_paddr <= 10'h1D8));
    // KEY_SLOT_CTRL secure-only window 0x200-0x2FC
    slot_window_addr = (s_apb_paddr >= 10'h200);
    perm_violation   = (slot_window_addr || control_request) && !secure_privileged;
  end

  assign busy_write_error = access_phase && s_apb_pwrite &&
                            ((busy_protected_addr && busy) || perm_violation);

  // A rejected access is fully blocked (writes and reads alike)
  assign access_blocked = perm_violation || (|s_apb_paddr[1:0]) ||
                          (s_apb_pwrite && busy_protected_addr && busy);

  assign csr_psel    = rst_n && s_apb_psel && !access_blocked;
  assign csr_penable = rst_n && s_apb_penable && !access_blocked;
  assign csr_pwrite  = s_apb_pwrite;
  assign csr_pprot   = s_apb_pprot;
  assign csr_paddr   = s_apb_paddr;
  assign csr_pwdata  = s_apb_pwdata;
  // zero strobes on a blocked write -> the CSR sees no field change
  assign csr_pstrb   = !rst_n || access_blocked ? 4'h0 : s_apb_pstrb;

  assign s_apb_pready  = access_phase && (access_blocked || csr_pready);
  assign s_apb_prdata  = !rst_n || access_blocked ? 32'h0 : csr_prdata;
  assign s_apb_pslverr = access_phase && (access_blocked || (csr_pready && csr_pslverr));

endmodule

`endif // PQC_APB_IF_SV
