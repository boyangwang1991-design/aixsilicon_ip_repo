# Real-library synthesis. Library/corner paths come only from scanned PDK setup.
set IP_ROOT [file normalize [file join [file dirname [info script]] ../..]]
set OUT [file join $IP_ROOT build rtl synth]
if {[info exists ::env(WATCHDOG_SYNTH_OUT)]} {set OUT [file normalize $::env(WATCHDOG_SYNTH_OUT)]}
file mkdir $OUT
file mkdir $OUT/work
define_design_lib WORK -path $OUT/work
set setup [file join $IP_ROOT build rtl pdk_setup.tcl]
if {![file exists $setup]} {puts "ERROR: missing rendered real PDK setup"; exit 1}
source $setup
if {[llength $target_library]==0} {puts "ERROR: empty target_library"; exit 1}
set_app_var search_path [concat $search_path [list $IP_ROOT]]
set reuse [info exists ::env(WATCHDOG_SYNTH_REUSE_DDC)]
if {$reuse} {
 read_ddc $::env(WATCHDOG_SYNTH_REUSE_DDC)
 current_design watchdog_top
} else {
if {[info exists READ_SOURCES]} {
 source ${READ_SOURCES}.tcl
} else {
 set f [open [file join $IP_ROOT build rtl lint_sources.f] r]
 set sources [split [string trim [read $f]] \n]
 close $f
 if {![analyze -format sverilog -define SYNTHESIS $sources]} {exit 1}
}
set parameters {}
if {[info exists ::env(WATCHDOG_SYNTH_PARAMETERS)]} {set parameters $::env(WATCHDOG_SYNTH_PARAMETERS)}
if {[string length $parameters]} {
 if {![elaborate watchdog_top -parameters $parameters]} {exit 1}
} else {if {![elaborate watchdog_top]} {exit 1}}
if {![link]} {exit 1}
}
if {[string length $AIX_PDK_OPERATING_CONDITION]} {set_operating_conditions $AIX_PDK_OPERATING_CONDITION}
source [file join $IP_ROOT constraints/watchdog.sdc]
# Do not freeze generic SEQGENs: they still need technology mapping. Disable
# register merging during mapping, then protect the resulting mapped replicas.
set_app_var compile_enable_register_merging false
set generic [get_cells -hierarchical -quiet -filter {is_unmapped == true}]
if {[sizeof_collection $generic]} {set_dont_touch $generic false}
set_ungroup [get_cells -hierarchical -quiet *u_channel*] false
set_fix_hold [all_clocks]
redirect $OUT/precheck_design.rpt {check_design}
if {$reuse} {compile_ultra -incremental -no_autoungroup} else {compile_ultra -no_autoungroup}
compile -incremental_mapping -only_hold_time
set protected_cells [get_cells -hierarchical -quiet -filter {name =~ *bar* || name =~ *final_hold* || name =~ *qualification*}]
if {[sizeof_collection $protected_cells]} {set_dont_touch $protected_cells true}
redirect $OUT/check_design.rpt {check_design}
redirect $OUT/reference.rpt {report_reference -hierarchy}
redirect $OUT/area.rpt {report_area -hierarchy}
redirect $OUT/timing.rpt {report_timing -max_paths 20 -transition_time -capacitance -nets}
redirect $OUT/power.rpt {report_power -hierarchy}
redirect $OUT/qor.rpt {report_qor}
redirect $OUT/constraints.rpt {report_constraint -all_violators}
redirect $OUT/clocks.rpt {report_clock -attributes}
set activity_file [open $OUT/activity.rpt w]
puts $activity_file "No SAIF annotation: tool default switching-probability propagation estimate."
puts $activity_file "This is a characterization assumption, not measured workload activity."
close $activity_file
write -format ddc -hierarchy -output $OUT/watchdog_mapped.ddc
write -format verilog -hierarchy -output $OUT/watchdog_top_synth.v
write_sdc $OUT/watchdog_mapped.sdc
set unmapped [get_cells -hierarchical -quiet -filter {is_unmapped == true}]
set latches [all_registers -level_sensitive]
set worst [get_timing_paths -max_paths 1]
set valid [expr {[sizeof_collection $worst]>0}]
if {$valid} {set slack [lindex [lsort -real [get_attribute $worst slack]] 0]} else {set slack -999}
set shortest [get_timing_paths -delay_type min -max_paths 1]
if {[sizeof_collection $shortest]} {set hold_slack [lindex [lsort -real [get_attribute $shortest slack]] 0]} else {set hold_slack -999}
redirect $OUT/hold_timing.rpt {report_timing -delay_type min -max_paths 20}
set f [open $OUT/check_summary.txt w]
puts $f "UNMAPPED=[sizeof_collection $unmapped]"
puts $f "LATCHES=[sizeof_collection $latches]"
puts $f "WORST_SLACK_NS=$slack"
puts $f "WORST_HOLD_SLACK_NS=$hold_slack"
puts $f "ACTIVITY=tool_default_probability_propagation_no_SAIF"
close $f
if {[sizeof_collection $unmapped] || [sizeof_collection $latches] || !$valid || $slack<0 || $hold_slack<0} {
 puts "WATCHDOG_SYNTHESIS FAIL: mapping/latch/timing check";exit 1
}
puts "WATCHDOG_SYNTHESIS PASS: real 28nm mapped netlist and constrained timing"
exit 0
