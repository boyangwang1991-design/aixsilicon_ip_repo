// UART IP RTL filelist (compilation order)
// Common libraries referenced from unified repo via FuseSoC .core depend:
//   lowrisc:prim:all / lowrisc:ip:tlul / lowrisc:top:constants
// Core UART RTL (OpenTitan original, unchanged) + generated CSR + APB wrapper.

// --- Unified-repo common libraries (all files) ---
-f rtl/filelist_libs.f

// --- Core UART RTL (OpenTitan original, unchanged) ---
rtl/uart_reg_pkg.sv
rtl/uart_reg_top.sv
rtl/uart_rx.sv
rtl/uart_tx.sv
rtl/uart_core.sv
rtl/uart.sv

// --- Generated CSR (APB-flat, for APB target) ---
rtl/generated/uart_csr_pkg.sv
rtl/generated/uart_csr.sv

// --- New APB2TLUL wrapper ---
rtl/apb2tlul.sv
rtl/uart_apb_top.sv
