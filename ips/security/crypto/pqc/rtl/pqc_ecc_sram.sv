// ============================================================================
// pqc_ecc_sram - security working-memory storage macro for the PQC accelerator
//
// Single-write-port, asynchronous-read code-word store. It holds the SECDED
// (39,32) code words for pqc_secure_sram_ctrl; all arbitration, page tagging,
// ECC computation and zeroize sequencing live in the controller, so this module
// contains nothing but the storage array.
//
// Why this is a separate module (LLD.ARB.PQC.SRAM.BANK):
//   * it is the intended physical boundary: the register-array description is
//     replaced by a hardened banked dual-port macro behind these exact ports,
//     so the controller never changes at hardening time;
//   * it keeps the array hierarchically local, so lint and synthesis treat it
//     as an addressed memory instead of flattening 16K words into flops.
//
// Read path is purely combinational (minimal latency, mirrors the previous
// in-module array). If a hardened macro adds a read latency, raise
// READ_LATENCY and align the controller's response stage - the ports do not
// change. There is deliberately no reset term: a per-word reset initialiser
// over DEPTH words blocks RAM inference and duplicates DEPTH reset loads. The
// controller guarantees that every readable location was written (page_valid /
// word_valid gating) and that a full-capacity zeroize sweep runs from any
// power-up state, so correctness does not depend on array initial values.
// rst_n is accepted for macro-port compatibility and is intentionally unused.
// ============================================================================
`ifndef PQC_ECC_SRAM_SV
`define PQC_ECC_SRAM_SV

module pqc_ecc_sram #(
  parameter int unsigned DEPTH        = 16384,
  parameter int unsigned WIDTH        = 39,
  // 0 = combinational read (current implementation). A future macro with a
  // registered read output may set this; the controller must then align its
  // response stage accordingly.
  parameter int unsigned READ_LATENCY = 0
) (
  input  logic                     clk,
  input  logic                     rst_n,   // reserved for macro compatibility
  input  logic                     we,
  input  logic [$clog2(DEPTH)-1:0] waddr,
  input  logic [WIDTH-1:0]         wdata,
  input  logic [$clog2(DEPTH)-1:0] raddr,
  output logic [WIDTH-1:0]         rdata
);

  // synopsys template
  logic [WIDTH-1:0] mem [0:DEPTH-1];

  always_ff @(posedge clk) begin
    if (we) mem[waddr] <= wdata;
  end

  assign rdata = mem[raddr];

endmodule

`endif // PQC_ECC_SRAM_SV