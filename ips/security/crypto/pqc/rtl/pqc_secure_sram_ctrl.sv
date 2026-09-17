// ============================================================================
// pqc_secure_sram_ctrl - banked working memory with page tags and zeroize
//
// PLACEHOLDER IMPLEMENTATION (per current direction): the working store is a
// plain register array rather than a real SRAM macro. This keeps the interface,
// the page-tag gating, the three-port arbitration and the bounded zeroize
// behaviour testable now; a hardened macro (banked dual-port) is substituted at
// hardening time behind the same ports.
//
// Implements (LLD.ARB.PQC.SRAM.BANK, LLD.SAFE.PQC.ECC):
//   * two compute ports plus one DMA port, round-robin arbitration that
//     never inspects coefficient values
//   * per-page metadata (valid/secret/representation/algorithm/parameter_set)
//     and a tag check performed before any primitive dispatch
//   * real SECDED (39,32) per word: single-bit error correction + double-bit
//     error detection, with a read-side correction and ded/ued reporting
//   * full-capacity zeroization driven by the independent fault path, during
//     which the array refuses every read and write
//
// Request / response protocol
//   A request is accepted on a cycle in which it is granted AND access is
//   allowed (valid page, in range, not zeroizing). The response (rdata/ready)
//   appears on the following cycle and carries the port ownership of the
//   *accepted* request. A held request is not accepted again during its
//   response cycle; the master may advance at the edge sampling ready. A
//   rejected request raises access_denied for one cycle instead of a ready.
//
// PPA notes: banks are written only when selected, the arbiter is a
// single-cycle deterministic decision, and zeroize runs on its own clock enable.
// ============================================================================
`ifndef PQC_SECURE_SRAM_CTRL_SV
`define PQC_SECURE_SRAM_CTRL_SV

module pqc_secure_sram_ctrl #(
  parameter int unsigned LOCAL_SRAM_KIB = 64,
  parameter int unsigned NUM_PAGES      = 96,
  // Capacity in 32-bit words follows the configured KiB. SIM_WORDS may be
  // overridden explicitly by small unit fixtures; production keeps the default.
  parameter int unsigned SIM_WORDS      = LOCAL_SRAM_KIB * 256,
  // Words per page: 256 x 32-bit = 1 KiB per page.
  parameter int unsigned WORDS_PER_PAGE = 256
) (
  input  logic         clk,
  input  logic         rst_n,

  // compute port 0
  input  logic         c0_req,
  input  logic         c0_we,
  input  logic [15:0]  c0_addr,
  input  logic [31:0]  c0_wdata,
  output logic [31:0]  c0_rdata,
  output logic         c0_ready,

  // compute port 1
  input  logic         c1_req,
  input  logic         c1_we,
  input  logic [15:0]  c1_addr,
  input  logic [31:0]  c1_wdata,
  output logic [31:0]  c1_rdata,
  output logic         c1_ready,

  // DMA port
  input  logic         d_req,
  input  logic         d_we,
  input  logic [15:0]  d_addr,
  input  logic [31:0]  d_wdata,
  input  logic [3:0]   d_wstrb,
  output logic [31:0]  d_rdata,
  output logic         d_ready,

  // page tag programming
  input  logic         tag_we,
  input  logic [7:0]   tag_page,
  input  logic [3:0]   tag_rep,
  input  logic [3:0]   tag_algo,
  input  logic [3:0]   tag_pset,
  input  logic         tag_secret,
  input  logic         tag_valid,

  // tag check before primitive dispatch
  input  logic         tag_check_req,
  input  logic [7:0]   tag_check_page,
  output logic         tag_check_ok,

  // access rejection (invalid page / out of range / zeroizing)
  output logic         access_denied,

  // ECC status
  output logic         ecc_ded,
  output logic         ecc_ued,

  // DFT/extension fault injection: XOR a bit mask into the ECC word of a
  // selected location so SECDED correction and reporting can be exercised.
  // Tied off in normal operation; driven only under the DFT lifecycle gate.
  input  logic         ecc_inject_en,
  input  logic [15:0]  ecc_inject_idx,
  input  logic [38:0]  ecc_inject_mask,

  // zeroize
  input  logic         zeroize_req,
  output logic         zeroize_done
);

  import pqc_pkg::*;

  localparam int unsigned DEPTH = SIM_WORDS;
  localparam int unsigned PAGE_IDX_W = 8;
  localparam int unsigned IDX_W = $clog2(DEPTH);

  logic [DEPTH-1:0] word_valid;

  // page metadata
  logic [3:0]  page_rep    [0:NUM_PAGES-1];
  logic [3:0]  page_algo   [0:NUM_PAGES-1];
  logic [3:0]  page_pset   [0:NUM_PAGES-1];
  logic        page_secret [0:NUM_PAGES-1];
  logic        page_valid  [0:NUM_PAGES-1];

  // ---------------------------------------------------------------------------
  // SECDED (39,32): 32 data bits, 6 Hamming parity bits, 1 overall parity bit.
  // Positions are 1-based; data occupies every non-power-of-two position.
  // ---------------------------------------------------------------------------
  `include "pqc_secded_functions.svh"

  // ---------------------------------------------------------------------------
  // Round-robin arbitration across compute0, compute1 and DMA.
  // Priority depends only on request presence, never on data.
  // ---------------------------------------------------------------------------
  logic acc_valid;
  logic [1:0] acc_port;
  logic [1:0] next_port;
  logic [2:0] eligible;
  logic grant0, grant1, grantd;
  // Response ownership also suppresses resubmission of that held request.
  // Another client can be accepted while the previous client consumes ready.
  always_comb begin
    eligible = {d_req,c1_req,c0_req};
    if (acc_valid) eligible[acc_port] = 0;
    {grantd,grant1,grant0} = 0;
    case (next_port)
      0: if(eligible[0]) grant0=1; else if(eligible[1]) grant1=1; else if(eligible[2]) grantd=1;
      1: if(eligible[1]) grant1=1; else if(eligible[2]) grantd=1; else if(eligible[0]) grant0=1;
      default: if(eligible[2]) grantd=1; else if(eligible[0]) grant0=1; else if(eligible[1]) grant1=1;
    endcase
  end

  logic [15:0] sel_addr;
  logic        sel_we;
  logic [31:0] sel_wdata;
  logic [3:0] sel_wstrb;
  logic [31:0] merged_wdata;
  logic partial_write, partial_ue, response_revoked;
  logic [7:0] acc_page;
  logic [1:0]  sel_port;
  logic        any_grant;

  always_comb begin
    any_grant = grant0 | grant1 | grantd;
    sel_wstrb = (grant0 || grant1) ? 4'hf : d_wstrb;
    if (grant0)      begin sel_addr = c0_addr; sel_we = c0_we; sel_wdata = c0_wdata; sel_port = 2'd0; end
    else if (grant1) begin sel_addr = c1_addr; sel_we = c1_we; sel_wdata = c1_wdata; sel_port = 2'd1; end
    else             begin sel_addr = d_addr;  sel_we = d_we;  sel_wdata = d_wdata;  sel_port = 2'd2; end
  end

  // bank view used by the NTT address generator
  logic [2:0] bank_sel;
  always_comb bank_sel = {1'b0, sel_addr[1:0]};

  // ---------------------------------------------------------------------------
  // Access qualification: in-range word, page marked valid, not zeroizing.
  // ---------------------------------------------------------------------------
  logic [31:0] addr_word;
  logic [PAGE_IDX_W-1:0] addr_page;
  logic [IDX_W-1:0]      addr_idx;
  logic addr_in_range;
  logic page_ok;

  always_comb begin
    addr_word     = 32'(sel_addr);
    addr_page     = sel_addr[15:8];
    addr_in_range = (addr_word < 32'(DEPTH)) && (32'(addr_page) < 32'(NUM_PAGES));
    // clamp the array index so a denied out-of-range request can never index
    // past the end of the storage arrays
    addr_idx      = addr_in_range ? addr_word[IDX_W-1:0] : {IDX_W{1'b0}};
    // A write may create/tag a page; a read additionally requires the page to
    // already be valid so an uninitialised page is never presented.
    page_ok = addr_in_range && (sel_we || (page_valid[addr_page] && word_valid[addr_idx])) &&
              !(sel_port == 2 && page_secret[addr_page]) &&
              !(tag_we && tag_page == addr_page);
  end

  // ---------------------------------------------------------------------------
  // Storage macro. The code words live in pqc_ecc_sram (the intended hardening
  // boundary) instead of a local array, so the array stays an addressed memory
  // rather than being flattened into flops by lint and synthesis, which cannot
  // compile the 16K-word configuration otherwise. `ecc_word` is the macro read
  // output; it is kept under its historical name so the module UT hierarchy
  // probes (ecc_word[i] -> now u_store.mem[i]) keep their meaning.
  //
  // Declaration order matters: the instance must follow the addr_idx
  // declaration, otherwise the port connection would create an implicit net.
  // ---------------------------------------------------------------------------
  logic                   store_we;
  logic [IDX_W-1:0]       store_waddr;
  logic [SECDED_BITS-1:0] store_wdata;
  logic [IDX_W-1:0]       store_raddr;
  logic [SECDED_BITS-1:0] ecc_word;

  pqc_ecc_sram #(
    .DEPTH (DEPTH),
    .WIDTH (SECDED_BITS)
  ) u_store (
    .clk   (clk),
    .rst_n (rst_n),
    .we    (store_we),
    .waddr (store_waddr),
    .wdata (store_wdata),
    .raddr (store_raddr),
    .rdata (ecc_word)
  );

  // ---------------------------------------------------------------------------
  // Zeroize sequencer state is declared up front so every write path can gate
  // on it without multiple-driver conflicts.
  // ---------------------------------------------------------------------------
  logic [31:0] zwr_idx;
  logic        zwr_active;
  logic zero_seen;
  logic        accept;


  assign accept        = rst_n && any_grant && page_ok && !partial_ue && !response_revoked &&
                         !zwr_active && !zeroize_req;
  assign access_denied = rst_n && !zeroize_req && any_grant && !zwr_active &&
                         (!page_ok || partial_ue);

  // ---------------------------------------------------------------------------
  // Read address. Normal operation reads the clamped access index, which feeds
  // both the response data and the read-modify-write sources so that a partial
  // write preserves the untouched byte lanes. Fault injection is its own
  // read-modify-write of the *injection* location, so while it is active and no
  // access is in flight the read address follows ecc_inject_idx; otherwise the
  // XOR would be based on an unrelated word. Declared after zwr_active for
  // correct elaboration.
  // ---------------------------------------------------------------------------
  always_comb begin
    store_raddr = addr_idx;
    if (ecc_inject_en && (!any_grant) && (!zwr_active) &&
        (32'(ecc_inject_idx) < 32'(DEPTH)))
      store_raddr = ecc_inject_idx[IDX_W-1:0];
  end

  // ---------------------------------------------------------------------------
  // Single procedural owner for the register array (DUT writes and zeroize).
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      zwr_idx      <= 32'h0;
      zwr_active   <= 1'b0;
      zero_seen <= 1'b0;
      zeroize_done <= 1'b0;
      // PPA: no full-array reset. A per-word reset initialiser over DEPTH words
      // is synthesised as DEPTH parallel reset terms and (for a real macro) it
      // also blocks RAM inference. Correctness does not depend on it: the array
      // is fully written by the zeroize sweep (which runs from any power-up
      // state) and reads before that sweep are guarded by page_valid / ready.
    end else begin
      zeroize_done <= 1'b0;
      if (!zeroize_req) zero_seen <= 1'b0;
      if (zeroize_req && !zero_seen) begin
        zero_seen <= 1'b1;
        zwr_active <= 1'b1;
        zwr_idx    <= 32'h0;
      end else if (zwr_active) begin
        if (zwr_idx < 32'(DEPTH)) zwr_idx <= zwr_idx + 32'h1;
        else begin
          zwr_active   <= 1'b0;
          zeroize_done <= 1'b1;
        end
      end
    end
  end

  // ---------------------------------------------------------------------------
  // Single write port into the storage macro. Exactly one source drives it per
  // cycle with a fixed priority that preserves the previous in-array behaviour:
  //   1. zeroize sweep       (unconditional physical overwrite of code words)
  //   2. normal write        (accepted access with at least one byte enabled)
  //   3. DFT fault injection (single-cycle XOR into the selected code word)
  // The read-modify-write sources (partial write, injection) consume the macro's
  // combinational read output, which is stable before the clock edge.
  // ---------------------------------------------------------------------------
  always_comb begin
    store_we    = 1'b0;
    store_waddr = addr_idx;
    store_wdata = secded_enc(merged_wdata);
    if (zwr_active) begin
      if (zwr_idx < 32'(DEPTH)) begin
        store_we    = 1'b1;
        store_waddr = zwr_idx[IDX_W-1:0];
        store_wdata = secded_enc(32'h0);
      end
    end else if (accept && sel_we && (|sel_wstrb)) begin
      store_we    = 1'b1;
      store_waddr = addr_idx;
      store_wdata = secded_enc(merged_wdata);
    end else if (ecc_inject_en && (!zeroize_req) &&
                 (32'(ecc_inject_idx) < 32'(DEPTH))) begin
      // DFT single/double-bit fault injection into the stored code word.
      store_we    = 1'b1;
      store_waddr = ecc_inject_idx[IDX_W-1:0];
      store_wdata = ecc_word ^ ecc_inject_mask;
    end
  end

  // ---------------------------------------------------------------------------
  // Registered response: rdata and the owning port are captured together so a
  // request accepted on port X can never be reported on port Y.
  // ---------------------------------------------------------------------------
  logic [31:0] rd_data;



  logic [SECDED_BITS-1:0] raw_ecc;
  logic [5:0]             rd_syn;
  logic                   rd_ovr;
  logic [31:0]            corr_data;

  always_comb begin
    raw_ecc   = ecc_word;
    rd_syn    = secded_syn(raw_ecc);
    rd_ovr    = ^raw_ecc;                        // total parity over all bits
    corr_data = (rd_ovr && (rd_syn != 6'h0)) ? secded_corr(raw_ecc, rd_syn)
                                             : secded_data(raw_ecc);
  end

  assign partial_write = sel_we && (|sel_wstrb) && sel_wstrb != 4'hf;
  assign partial_ue = partial_write && word_valid[addr_idx] && !rd_ovr && rd_syn != 0;
  always_comb begin
    merged_wdata = 0;
    if (sel_wstrb == 4'hf) merged_wdata = sel_wdata;
    else if (|sel_wstrb) begin
      merged_wdata = word_valid[addr_idx] ? corr_data : 32'd0;
      for (int b=0;b<4;b++)
        if (sel_wstrb[b]) merged_wdata[b*8+:8] = sel_wdata[b*8+:8];
    end
  end
  assign response_revoked = tag_we && tag_page == acc_page &&
                            (!tag_valid || (acc_port == 2 && tag_secret));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc_valid <= 1'b0;
      acc_port  <= 2'h0;
      acc_page  <= 8'd0;
      rd_data   <= 32'h0;
    end else if (zeroize_req || response_revoked) begin
      // Clear/reclassification revokes and physically wipes the pending response.
      acc_valid <= 1'b0;
      acc_port  <= 2'h0;
      acc_page  <= 8'd0;
      rd_data   <= 32'h0;
    end else begin
      acc_valid <= accept;
      acc_port  <= sel_port;
      if (accept) acc_page <= addr_page;
      if (accept) begin
        if (sel_we) rd_data <= merged_wdata;
        else        rd_data <= corr_data;
      end
    end
  end

  assign c0_rdata = c0_ready ? rd_data : 32'h0;
  assign c1_rdata = c1_ready ? rd_data : 32'h0;
  assign d_rdata  = d_ready ? rd_data : 32'h0;
  assign c0_ready = rst_n && !zeroize_req && !zwr_active && !response_revoked && acc_valid && (acc_port == 2'd0);
  assign c1_ready = rst_n && !zeroize_req && !zwr_active && !response_revoked && acc_valid && (acc_port == 2'd1);
  assign d_ready  = rst_n && !zeroize_req && !zwr_active && !response_revoked && acc_valid && (acc_port == 2'd2);

  // ---------------------------------------------------------------------------
  // ECC reporting on the accepted read
  //   ded: any odd number of errors (single-bit or overall-parity bit)
  //   ued: even number of errors with a non-zero syndrome -> double-bit error
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ecc_ded <= 1'b0;
      ecc_ued <= 1'b0;
    end else if (zeroize_req) begin
      ecc_ded <= 1'b0;
      ecc_ued <= 1'b0;
    end else begin
      ecc_ded <= accept && (!sel_we || (partial_write && word_valid[addr_idx])) && rd_ovr;
      ecc_ued <= ((accept && !sel_we) ||
                  (any_grant && page_ok && !zwr_active && partial_write && word_valid[addr_idx])) &&
                 !rd_ovr && (rd_syn != 6'h0);
    end
  end

  // ---------------------------------------------------------------------------
  // Page tag programming and check
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int unsigned i = 0; i < NUM_PAGES; i++) begin
        page_rep[i]    <= 4'h0;
        page_algo[i]   <= 4'h0;
        page_pset[i]   <= 4'h0;
        page_secret[i] <= 1'b0;
        page_valid[i]  <= 1'b0;
      end
    end else if (zeroize_req) begin
      for (int unsigned i = 0; i < NUM_PAGES; i++) begin
        page_rep[i]    <= 4'h0;
        page_algo[i]   <= 4'h0;
        page_pset[i]   <= 4'h0;
        page_secret[i] <= 1'b0;
        page_valid[i]  <= 1'b0;
      end
    end else if (!zwr_active && tag_we && (32'(tag_page) < 32'(NUM_PAGES))) begin
      page_rep[tag_page]    <= tag_rep;
      page_algo[tag_page]   <= tag_algo;
      page_pset[tag_page]   <= tag_pset;
      page_secret[tag_page] <= tag_secret;
      page_valid[tag_page]  <= tag_valid;
    end else if (accept && sel_we && (|sel_wstrb)) begin
      // auto-tag: a page becomes valid once its first word is written, so a
      // later read or primitive dispatch on that page is admitted while an
      // untouched page stays blocked. Explicit tag_we above can still override.
      page_valid[addr_page] <= 1'b1;
    end
  end

  assign tag_check_ok = rst_n && !zeroize_req && !zwr_active && (32'(tag_check_page) < 32'(NUM_PAGES)) &&
                        page_valid[tag_check_page];

  // Validity is per word: publishing one write must not expose stale neighbours.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) word_valid <= '0;
    else if (zeroize_req) word_valid <= '0;
    else if (tag_we && !tag_valid && (tag_page < NUM_PAGES)) begin
      for (int i=0; i<WORDS_PER_PAGE; i++)
        if ((int'(tag_page)*WORDS_PER_PAGE+i) < DEPTH)
          word_valid[int'(tag_page)*WORDS_PER_PAGE+i] <= 1'b0;
    end else if (accept && sel_we && (|sel_wstrb)) word_valid[addr_idx] <= 1'b1;
  end


  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) next_port <= 0;
    else if(zeroize_req) next_port <= 0;
    else if(accept || access_denied) next_port <= (sel_port == 2) ? 0 : sel_port+1'b1;
  end
endmodule

`endif // PQC_SECURE_SRAM_CTRL_SV
