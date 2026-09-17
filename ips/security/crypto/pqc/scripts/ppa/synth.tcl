# Design Compiler synthesis script for the PQC accelerator G3 reachability check.
#
# Invoked by the FuseSoC design_compiler backend from an isolated build
# directory; the backend has already generated:
#   <name>.tcl            -> sets TOP_MODULE / READ_SOURCES / REPORT_DIR
#   <name>-read-sources.tcl -> analyze -format sverilog for every source file
#
# The PDK technology profile and the characterization SDC are supplied as
# absolute paths through environment variables by scripts/run_synth.sh so that
# the checked-in script never hardcodes a local PDK or IP location.

if {![info exists ::env(PQC_PDK_SETUP)]} {
  puts "PQC_SYNTH_ERROR: PQC_PDK_SETUP is not set"
  exit 1
}
if {![info exists ::env(PQC_SYNTH_SDC)]} {
  puts "PQC_SYNTH_ERROR: PQC_SYNTH_SDC is not set"
  exit 1
}

source $::env(PQC_PDK_SETUP)

# Report (do not hide) latch inference so the G3 log carries the evidence.
set_app_var hdlin_check_no_latch false

source ${READ_SOURCES}.tcl

elaborate $TOP_MODULE
current_design $TOP_MODULE
link
check_design
source $::env(PQC_SYNTH_SDC)
check_timing
compile_ultra
check_design

redirect ${REPORT_DIR}/area.rpt { report_area -hierarchy }
redirect ${REPORT_DIR}/timing.rpt { report_timing -max_paths 20 }
redirect ${REPORT_DIR}/power.rpt { report_power -hierarchy }
redirect ${REPORT_DIR}/design_check.rpt { check_design }
redirect ${REPORT_DIR}/constraints.rpt { report_constraint -all_violators }
write -format verilog -hierarchy -output ${REPORT_DIR}/pqc_netlist.v
write_sdc ${REPORT_DIR}/pqc_mapped.sdc
puts "PQC_SYNTHESIS_COMPLETE"
exit