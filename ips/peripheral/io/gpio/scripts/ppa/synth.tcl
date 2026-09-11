# FuseSoC/Edalize invokes this script from an isolated build directory.
set_app_var hdlin_check_no_latch true
source $::env(GPIO_PDK_SETUP)
source ${READ_SOURCES}.tcl
if {[info exists ::env(GPIO_SYNTH_PARAMETERS)] && $::env(GPIO_SYNTH_PARAMETERS) ne ""} {
  elaborate $TOP_MODULE -parameters $::env(GPIO_SYNTH_PARAMETERS)
} else {
  elaborate $TOP_MODULE
}
link
check_design
source $::env(GPIO_SYNTH_SDC)
check_timing
compile_ultra
redirect ${REPORT_DIR}/area.rpt { report_area -hierarchy }
redirect ${REPORT_DIR}/timing.rpt { report_timing -max_paths 20 }
redirect ${REPORT_DIR}/power.rpt { report_power -hierarchy }
redirect ${REPORT_DIR}/design_check.rpt { check_design }
redirect ${REPORT_DIR}/constraints.rpt { report_constraint -all_violators }
write -format verilog -hierarchy -output ${REPORT_DIR}/gpio_netlist.v
write_sdc ${REPORT_DIR}/gpio_mapped.sdc
puts "GPIO_SYNTHESIS_COMPLETE"
exit
