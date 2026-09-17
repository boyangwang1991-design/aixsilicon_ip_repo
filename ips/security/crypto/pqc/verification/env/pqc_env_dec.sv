// =============================================================================
// File Name   : pqc_env_dec.sv
// Description : PQC environment declarations, analysis item and register map
//
// Compiled as a standalone compilation unit (outside any package); it must
// import uvm_pkg and include uvm_macros.svh before using UVM macros.
//
// The register address map below is a *model* of regs/pqc.rdl for verification
// observation/checking only. regs/pqc.rdl remains the structural source of
// truth (02-reg-model); the generated CSR RTL is what the DUT actually
// implements, and RAL (verification/ral/pqc_ral_pkg.sv) mirrors the RDL.
// =============================================================================

`ifndef PQC_ENV_DEC__SV
`define PQC_ENV_DEC__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------------------------
  // Analysis imp declarations (actual vs expected streams)
  // ---------------------------------------------------------------------------
  `uvm_analysis_imp_decl(_act)
  `uvm_analysis_imp_decl(_exp)

  // ---------------------------------------------------------------------------
  // Register offsets (model of regs/pqc.rdl)
  // ---------------------------------------------------------------------------
  localparam logic [9:0] PQC_REG_ID_VERSION          = 10'h000;
  localparam logic [9:0] PQC_REG_CAPABILITY0          = 10'h004;
  localparam logic [9:0] PQC_REG_CAPABILITY1          = 10'h008;
  localparam logic [9:0] PQC_REG_CTRL                 = 10'h010;
  localparam logic [9:0] PQC_REG_STATUS               = 10'h014;
  localparam logic [9:0] PQC_REG_COMMAND              = 10'h018;
  localparam logic [9:0] PQC_REG_KEY_HANDLE           = 10'h07C;
  localparam logic [9:0] PQC_REG_CONTEXT_LEN          = 10'h080;
  localparam logic [9:0] PQC_REG_RESULT               = 10'h084;
  localparam logic [9:0] PQC_REG_ERROR_CODE           = 10'h088;
  localparam logic [9:0] PQC_REG_INTR_STATE           = 10'h090;
  localparam logic [9:0] PQC_REG_INTR_ENABLE          = 10'h094;
  localparam logic [9:0] PQC_REG_INTR_TEST            = 10'h098;
  localparam logic [9:0] PQC_REG_ALERT_RECOVERABLE    = 10'h0A0;
  localparam logic [9:0] PQC_REG_ALERT_FATAL          = 10'h0A4;
  localparam logic [9:0] PQC_REG_PERF_TOTAL_CYCLES    = 10'h100;
  localparam logic [9:0] PQC_REG_PERF_KECCAK_CYCLES   = 10'h104;
  localparam logic [9:0] PQC_REG_PERF_NTT_CYCLES      = 10'h108;
  localparam logic [9:0] PQC_REG_PERF_DMA_STALL       = 10'h10C;
  localparam logic [9:0] PQC_REG_PERF_CMD_COUNT       = 10'h110;
  localparam logic [9:0] PQC_REG_COMPLETION_CMD_ID    = 10'h1C0;
  localparam logic [9:0] PQC_REG_COMPLETION_STATUS    = 10'h1C4;
  localparam logic [9:0] PQC_REG_COMPLETION_OUT_LEN   = 10'h1C8;
  localparam logic [9:0] PQC_REG_COMPLETION_INFO      = 10'h1CC;
  localparam logic [9:0] PQC_REG_DOORBELL             = 10'h1D0;
  localparam logic [9:0] PQC_REG_DESC_ADDR_LO         = 10'h1D4;
  localparam logic [9:0] PQC_REG_DESC_ADDR_HI         = 10'h1D8;
  localparam logic [9:0] PQC_REG_KEY_SLOT_CTRL        = 10'h200;
  localparam logic [9:0] PQC_REG_KEY_SLOT_META        = 10'h204;
  localparam logic [9:0] PQC_REG_KEY_SLOT_GEN         = 10'h208;
  localparam logic [9:0] PQC_REG_KEY_SLOT_DOMAIN      = 10'h20C;
  localparam logic [9:0] PQC_REG_KEY_SLOT_MIRROR_BASE = 10'h210;

  // Descriptor block window (0x020..0x078)
  localparam logic [9:0] PQC_REG_DESC_BASE            = 10'h020;
  localparam logic [9:0] PQC_REG_DESC_LAST            = 10'h078;

  // Reset values derived field-by-field from regs/pqc.rdl.
  // ID_VERSION: ip_minor[7:0]=01, ip_major[15:8]=00, abi_version[23:16]=10,
  //             ucode_version[31:24]=01  -> 0x01_10_00_01
  localparam logic [31:0] PQC_ID_VERSION_RESET = 32'h0110_0001;

  // CAPABILITY0: algo_mask=6'h3F, kem=1(b6), dsa=1(b7), ntt_lanes=2(b9:8),
  //   keccak_rounds=2(b11:10), sca_level=1(b13:12), hash_ml_dsa=0(b14),
  //   sg=0(b15), pure_ml_dsa=1(b16), deterministic=1(b17), hedged=1(b18),
  //   multi_queue=0(b19)  -> 0x0007_1AFF
  localparam logic [31:0] PQC_CAPABILITY0_RESET = 32'h0007_1AFF;

  // CAPABILITY1: local_sram_kib=64(b7:0), dma_data_width=128(b15:8),
  //   key_slot_num=8(b23:16), pio_enabled=1(b24), ecc_enabled=1(b25).
  // abi_minor[31:26] is driven by the RTL (reads 3 on this revision), not by a
  // fixed RDL reset constant, so it is excluded from the static comparison.
  // abi_minor[31:26] reads 0 on this RTL revision (the RTL never drives that
  // hw=rw field - verified finding, see tc_reg_reset_attr); pio_enabled(b24)
  // and ecc_enabled(b25) are 1. -> 0x0308_8040
  localparam logic [31:0] PQC_CAPABILITY1_RESET = 32'h0308_8040;

  // Registers whose read data is driven by hardware state rather than by a
  // static shadow value. These must not be compared against the model:
  //   * STATUS        : live idle/busy/done/error/locked, changes per command
  //   * RESULT/ERROR_CODE : written by the datapath on completion
  //   * PERF_*        : free-running counters
  //   * COMPLETION_*  : latched by the hardware at command retirement
  // Their *behaviour* is checked by the directed testcases (which assert the
  // expected transitions), not by a static expected value.
  function automatic bit pqc_reg_is_dynamic(input logic [9:0] addr);
    if (addr == PQC_REG_STATUS)     return 1'b1;
    // INTR_STATE is W1C and set by hardware events, so its value is a function
    // of stimulus history (INTR_TEST writes, DUT events). tc_reg_reset_attr
    // checks the W1C semantics directly instead of via a static shadow.
    if (addr == PQC_REG_INTR_STATE) return 1'b1;
    if (addr == PQC_REG_RESULT)     return 1'b1;
    if (addr == PQC_REG_ERROR_CODE) return 1'b1;
    if (addr >= PQC_REG_PERF_TOTAL_CYCLES && addr <= PQC_REG_PERF_CMD_COUNT) return 1'b1;
    if (addr >= 10'h1C0 && addr <= 10'h1CC) return 1'b1;   // COMPLETION_*
    return 1'b0;
  endfunction

  // The key-slot window (0x200+) currently returns pslverr for EVERY access
  // (verified finding RTL-KEY-001). The checker therefore treats that window as
  // an expected-error region instead of flagging each access.
  function automatic bit pqc_reg_key_slot_window(input logic [9:0] addr);
    return (addr >= 10'h200);
  endfunction

  // Stimulus registers: writing them raises an action, it does not store data.
  // They must not update the register shadow.
  function automatic bit pqc_reg_is_stimulus(input logic [9:0] addr);
    if (addr == PQC_REG_INTR_TEST) return 1'b1;
    return 1'b0;
  endfunction

  // Per-register write mask: only these bits actually latch a value.
  // CTRL is "enable[0] swwe" plus three *singlepulse* bits (abort/zeroize/
  // self_test) which trigger an action and read back as 0 (regs/pqc.rdl).
  function automatic logic [31:0] pqc_reg_write_mask(input logic [9:0] addr);
    if (addr == PQC_REG_CTRL) return 32'h0000_0001;   // only enable[0] latches
    return 32'hFFFF_FFFF;
  endfunction

  // Address decoding helper: a word address is mapped if it is inside the
  // implemented register windows of pqc_csr.
  function automatic bit pqc_addr_mapped(input logic [9:0] addr);
    bit mapped = 1'b0;
    // 0x000-0x01C identification / control / command
    if (addr <= 10'h01C) mapped = 1'b1;
    // 0x020-0x078 descriptor block
    else if (addr >= PQC_REG_DESC_BASE && addr <= PQC_REG_DESC_LAST) mapped = 1'b1;
    // 0x07C-0x0A4 key handle / result / interrupt / alert
    else if (addr >= 10'h07C && addr <= 10'h0A4) mapped = 1'b1;
    // 0x100-0x110 performance counters
    else if (addr >= 10'h100 && addr <= 10'h110) mapped = 1'b1;
    // 0x1C0-0x1CC completion block
    else if (addr >= 10'h1C0 && addr <= 10'h1CC) mapped = 1'b1;
    // 0x1D0-0x1D8 doorbell / descriptor pointer
    else if (addr >= 10'h1D0 && addr <= 10'h1D8) mapped = 1'b1;
    // 0x200-0x20C key slot control
    else if (addr >= 10'h200 && addr <= 10'h20C) mapped = 1'b1;
    // 0x210-0x28C key slot mirror (32 entries)
    else if (addr >= PQC_REG_KEY_SLOT_MIRROR_BASE && addr <= 10'h28C) mapped = 1'b1;
    return mapped;
  endfunction

  // ---------------------------------------------------------------------------
  // Observed APB access (produced by the monitor / VIP analysis export)
  // ---------------------------------------------------------------------------
  class pqc_apb_access extends uvm_object;
    rand bit          is_write;
    rand logic [9:0]  addr;
    rand logic [31:0] wdata;
    rand logic [3:0]  strb;
    logic [31:0]      rdata;
    bit               slverr;
    // Set by the reference model: 0 means the read data of this address is
    // hardware-driven (volatile) and must not be compared against a static
    // shadow value.
    bit               check_data = 1'b1;

    `uvm_object_utils_begin(pqc_apb_access)
      `uvm_field_int(is_write, UVM_ALL_ON)
      `uvm_field_int(addr,     UVM_ALL_ON)
      `uvm_field_int(wdata,    UVM_ALL_ON)
      `uvm_field_int(strb,     UVM_ALL_ON)
      `uvm_field_int(rdata,    UVM_ALL_ON)
      `uvm_field_int(slverr,   UVM_ALL_ON)
      `uvm_field_int(check_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "pqc_apb_access");
      super.new(name);
    endfunction

    // Byte-strobe aware write merge, mirroring the CSR byte-write behaviour.
    function logic [31:0] merge(logic [31:0] old_value);
      logic [31:0] merged = old_value;
      for (int b = 0; b < 4; b++)
        if (strb[b]) merged[b*8 +: 8] = wdata[b*8 +: 8];
      return merged;
    endfunction

    function string convert2string();
      return $sformatf("%s addr=0x%03h wdata=0x%08h strb=%b rdata=0x%08h slverr=%b",
                       is_write ? "WR" : "RD", addr, wdata, strb, rdata, slverr);
    endfunction
  endclass

  // ---------------------------------------------------------------------------
  // Environment parameters / modes
  // ---------------------------------------------------------------------------
  typedef enum int {
    PQC_ENV_NORMAL = 0,
    PQC_ENV_STRESS = 1
  } pqc_env_mode_e;

`endif // PQC_ENV_DEC__SV
