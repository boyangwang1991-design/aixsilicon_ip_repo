// =============================================================================
// check_uvm.f - VCS elaboration filelist（相对 verification/）
// 用法: vcs -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 -f check_uvm.f
// =============================================================================
// VIP 源码只读引用自 repos/aixsilicon_vip_repo（FuseSoC depend 语义；不复制、
// 不提交到本 IP 仓库）。axi4_pkg/apb_pkg 内部以相对 src/ 根路径 include，故需
// +incdir+ 指向各自 src/ 目录。编译顺序：types_pkg → if → pkg。
// =============================================================================

+define+UVM_NO_DEPRECATED
+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR
+incdir+./env
+incdir+./tc
+incdir+./th
+incdir+../../repos/aixsilicon_vip_repo/vip/amba/axi4/src
+incdir+../../repos/aixsilicon_vip_repo/vip/amba/apb/src

// RTL（相对 verification/）
../rtl/x2p_pkg.sv
../rtl/x2p_req_mgr.sv
../rtl/x2p_scheduler.sv
../rtl/x2p_transfer_engine.sv
../rtl/x2p_cdc.sv
../rtl/x2p_apb_engine.sv
../rtl/x2p_rsp_mgr.sv
../rtl/x2p_axi_frontend.sv
../rtl/x2p_top.sv

// VIP axi4（只读引用）
../../repos/aixsilicon_vip_repo/vip/amba/axi4/src/axi4_types_pkg.sv
../../repos/aixsilicon_vip_repo/vip/amba/axi4/src/axi4_if.sv
../../repos/aixsilicon_vip_repo/vip/amba/axi4/src/axi4_pkg.sv

// VIP apb（只读引用）
../../repos/aixsilicon_vip_repo/vip/amba/apb/src/apb_types_pkg.sv
../../repos/aixsilicon_vip_repo/vip/amba/apb/src/apb_if.sv
../../repos/aixsilicon_vip_repo/vip/amba/apb/src/apb_pkg.sv

// Env
./env/x2p_env.sv

// Testcases
./tc/tc_define.sv
./tc/tc_base.sv
./tc/tc_sanity.sv
./tc/tc_burst.sv
./tc/tc_timeout.sv

// Harness (top)
./th/harness.sv
