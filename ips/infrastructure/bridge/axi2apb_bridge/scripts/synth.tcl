# X2P synthesis script (Design Compiler)
# Usage: dc_shell -f scripts/synth.tcl

set DESIGN x2p_top
set TOPDIR [file normalize [file dirname [info script]]/..]

define_design_lib WORK -path ${TOPDIR}/build/synth/WORK

set FILELIST [list \
  ${TOPDIR}/rtl/x2p_pkg.sv \
  ${TOPDIR}/rtl/x2p_req_mgr.sv \
  ${TOPDIR}/rtl/x2p_scheduler.sv \
  ${TOPDIR}/rtl/x2p_transfer_engine.sv \
  ${TOPDIR}/rtl/x2p_cdc.sv \
  ${TOPDIR}/rtl/x2p_apb_engine.sv \
  ${TOPDIR}/rtl/x2p_rsp_mgr.sv \
  ${TOPDIR}/rtl/x2p_axi_frontend.sv \
  ${TOPDIR}/rtl/x2p_top.sv \
]

set_app_var target_library ""
set_app_var link_library ""

analyze -library WORK -format sverilog $FILELIST
elaborate ${DESIGN}
check_design

if {[llength [get_designs -quiet]] > 0} {
  current_design ${DESIGN}
  link
  write -format verilog -hierarchy -output ${TOPDIR}/build/synth/x2p_top_synth.v
  report_area > ${TOPDIR}/reports/synth/area.rpt
  report_qor > ${TOPDIR}/reports/synth/qor.rpt
  report_hierarchy > ${TOPDIR}/reports/synth/hierarchy.rpt
  puts "SYNTH_OK"
} else {
  puts "SYNTH_EMPTY_DESIGN"
}

exit