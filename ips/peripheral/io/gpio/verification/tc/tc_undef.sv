// =============================================================================
// File Name   : tc_undef.sv
// Description : Undefine test case macros (cleanup)
// =============================================================================

`ifndef TC_UNDEF__SV
`define TC_UNDEF__SV

// Undefine macros defined in tc_define.sv
`undef TC_DEFAULT_TIMEOUT

`endif
