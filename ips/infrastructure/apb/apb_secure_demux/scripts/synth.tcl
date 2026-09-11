# FuseSoC/Edalize calls this with READ_SOURCES and TOP_MODULE.
# Commercial library paths are supplied only through an ignored local setup file.
if {![info exists env(ASD_PDK_SETUP)] || ![file exists $env(ASD_PDK_SETUP)]} {
    puts stderr "ASD_SYNTH_FAIL: missing local PDK setup"
    exit 2
}
source $env(ASD_PDK_SETUP)
file mkdir work
file mkdir outputs
file mkdir reports
define_design_lib work -path work
source ${READ_SOURCES}.tcl
if {![elaborate $TOP_MODULE]} { puts "ASD_SYNTH_FAIL: elaborate"; exit 3 }
current_design $TOP_MODULE
if {![link]} { puts "ASD_SYNTH_FAIL: link"; exit 4 }
source [file join [file dirname [info script]] .. constraints characterization.sdc]
redirect reports/check_design_before.rpt { check_design }
set_fix_multiple_port_nets -all -buffer_constants
compile_ultra
redirect reports/check_design.rpt { check_design }
redirect reports/check_timing.rpt { check_timing }
redirect reports/timing.rpt { report_timing -max_paths 20 }
redirect reports/area.rpt { report_area -hierarchy }
redirect reports/power.rpt { report_power }
redirect reports/qor.rpt { report_qor }
redirect reports/constraints.rpt { report_constraint -all_violators }
set unmapped [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical == false && is_unmapped == true"]]
set latches [sizeof_collection [all_registers -level_sensitive]]
puts "ASD_SYNTH_UNMAPPED=$unmapped"
puts "ASD_SYNTH_LATCHES=$latches"
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output outputs/apb_secure_demux_synth.v
write_sdc outputs/apb_secure_demux.sdc
if {$unmapped != 0 || $latches != 0} { puts "ASD_SYNTH_FAIL: structural checks"; exit 5 }
puts "ASD_SYNTH_MAPPING_COMPLETE"
exit 0
