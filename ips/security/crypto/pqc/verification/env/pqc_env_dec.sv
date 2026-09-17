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

  // ID_VERSION reset value (see regs/pqc.rdl: 0x0100_0001)
  localparam logic [31:0] PQC_ID_VERSION_RESET = 32'h0100_0001;

  // Technical reset values used by reset/attribute checks.
  localparam logic [31:0] PQC_CAPABILITY0_RESET = 32'h0000_1EF6;
  localparam logic [31:0] PQC_CAPABILITY1_RESET = 32'h0000_0088;

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

    `uvm_object_utils_begin(pqc_apb_access)
      `uvm_field_int(is_write, UVM_ALL_ON)
      `uvm_field_int(addr,     UVM_ALL_ON)
      `uvm_field_int(wdata,    UVM_ALL_ON)
      `uvm_field_int(strb,     UVM_ALL_ON)
      `uvm_field_int(rdata,    UVM_ALL_ON)
      `uvm_field_int(slverr,   UVM_ALL_ON)
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
