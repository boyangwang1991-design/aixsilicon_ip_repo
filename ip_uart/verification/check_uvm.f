// =============================================================================
// File Name   : check_uvm.f
// Description : VCS full elaboration filelist for the complete UVM environment
//               Used with (from IP workspace root):
//   vcs -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 -f verification/check_uvm.f
//
// IMPORTANT: -ntb_opts uvm-1.2 MUST be on the VCS command line, NOT in this file.
//            All paths are relative to the IP workspace root (CWD).
// =============================================================================

// =============================================================================
// UVM Macro Definitions
// =============================================================================
+define+UVM_NO_DEPRECATED
+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR

// =============================================================================
// UVM Include Directory (required for uvm_macros.svh)
// =============================================================================
+incdir+$VCS_HOME/etc/uvm-1.2

// =============================================================================
// Include Directories (env / agent / tc / th / RTL common libs)
// =============================================================================
+incdir+verification/env
+incdir+verification/env/utils/uart_utils/src
+incdir+verification/env/utils/tlul_utils/src
+incdir+verification/env/utils/apb_utils/src
+incdir+verification/tc
+incdir+verification/th
+incdir+../ips/lowrisc/prim/0.1.0/rtl
+incdir+../ips/lowrisc/tlul/0.1.0/rtl
+incdir+../ips/lowrisc/top/0.1.0/rtl

// =============================================================================
// RTL Design Files (DUT) - via rtl/filelist.f (paths relative to root CWD)
// =============================================================================
-f rtl/filelist.f

// =============================================================================
// Protocol Agent Packages (compile order)
//   NOTE: agent list files use ./src/ relative paths; VCS resolves them against
//   CWD, so reference the package source files directly with root-relative paths.
// =============================================================================
verification/env/utils/uart_utils/src/uart_package.sv
verification/env/utils/tlul_utils/src/tlul_package.sv
verification/env/utils/apb_utils/src/apb_package.sv

// =============================================================================
// Environment Declarations + Package
// =============================================================================
verification/env/uart_env_dec.sv
verification/env/uart_env_package.sv

// =============================================================================
// Testcase Files (each tc_* includes tc_base.sv)
// =============================================================================
verification/tc/tc_define.sv
verification/tc/tc_base.sv
verification/tc/tc_uart_smoke.sv
verification/tc/tc_uart_tx_rx.sv
verification/tc/tc_uart_error.sv
verification/tc/tc_uart_fifo.sv
verification/tc/tc_uart_csr.sv
verification/tc/tc_uart_perf.sv
verification/tc/tc_uart_alert.sv
verification/tc/tc_undef.sv

// =============================================================================
// Harness (Top-level)
// =============================================================================
verification/th/harness.sv
