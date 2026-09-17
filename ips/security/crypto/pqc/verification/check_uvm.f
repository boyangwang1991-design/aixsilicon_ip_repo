// =============================================================================
// File Name   : check_uvm.f
// Description : VCS elaboration filelist for full design check
//               Used with: vcs -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 -f check_uvm.f
//
// IMPORTANT: -ntb_opts uvm-1.2 MUST be on the VCS command line, NOT in this file.
//            VCS reports Error-[NS-NTB_F] if -ntb_opts is placed inside a -f file.
//
//            After instantiation, replace yy with DUT name and xx with protocol.
//            Add RTL design files relative to this verification/ directory.
// =============================================================================

// =============================================================================
// UVM Macro Definitions
// =============================================================================
+define+UVM_NO_DEPRECATED
+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR

// =============================================================================
// UVM Include Directory (required for uvm_macros.svh)
// NOTE: Replace with your VCS uvm-1.2 installation path if different.
// =============================================================================
+incdir+$VCS_HOME/etc/uvm-1.2

// =============================================================================
// Agent Include Directories
// Add one +incdir+ line for each protocol agent
// =============================================================================
+incdir+./env/utils/apb_utils/src
+incdir+./env
+incdir+./tc
+incdir+./th

// =============================================================================
// RTL Design Files (DUT)
// NOTE: Adjust path relative to this verification/ directory.
//       Typical: ../../rtl/ for [ip]/verification/ -> [ip]/../rtl/
// =============================================================================
// ../../rtl/include/pqc_defs.svh
// ../../rtl/pqc_top.sv
// (Add all RTL source files here)

// =============================================================================
// Protocol Agent Packages (compile first)
// =============================================================================
./env/utils/apb_utils/src/apb_package.sv

// =============================================================================
// Environment Files (all env components)
// =============================================================================
./env/pqc_env_dec.sv
./env/pqc_dut_cfg.sv
./env/pqc_rm_cfg.sv
./env/pqc_rm.sv
./env/pqc_checker_cfg.sv
./env/pqc_checker.sv
./env/pqc_fcov.sv
./env/pqc_virtual_sequencer.sv
./env/pqc_virtual_sequence.sv
./env/pqc_env_cfg.sv
./env/pqc_env.sv

// =============================================================================
// Testcase Files (tc_sanity includes tc_base)
// =============================================================================
./tc/tc_define.sv
./tc/tc_sanity.sv
./tc/tc_undef.sv

// =============================================================================
// Harness (Top-level)
// =============================================================================
./th/harness.sv
