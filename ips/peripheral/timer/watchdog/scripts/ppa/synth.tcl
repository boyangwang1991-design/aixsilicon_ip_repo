# Functional synthesis check; no physical PPA claims without library/activity.
set IP_ROOT [file normalize [file join [file dirname [info script]] ../..]]
set OUT [file join $IP_ROOT build rtl synth]
file mkdir $OUT
file mkdir $OUT/work
set_app_var search_path [concat $search_path [list $IP_ROOT]]
define_design_lib WORK -path $OUT/work
if {[info exists ::env(WATCHDOG_TARGET_LIBRARY)]} {
 set_app_var target_library $::env(WATCHDOG_TARGET_LIBRARY)
 set_app_var link_library [concat * $target_library]
} else {
 set_app_var target_library {}
 set_app_var link_library {* gtech.db standard.sldb}
}
if {[info exists READ_SOURCES]} {
 source ${READ_SOURCES}.tcl
} else {
 set f [open [file join $IP_ROOT build rtl lint_sources.f] r]
 set sources [split [string trim [read $f]] \n]
 close $f
 if {![analyze -format sverilog -define SYNTHESIS $sources]} {exit 1}
}
if {![elaborate watchdog_top]} {exit 1}
if {![link]} {exit 1}
redirect $OUT/check_design.rpt {check_design}
redirect $OUT/reference.rpt {report_reference -hierarchy}
write -format ddc -hierarchy -output $OUT/watchdog_elaborated.ddc
puts "WATCHDOG_SYNTH_ELAB PASS"
if {![info exists ::env(WATCHDOG_TARGET_LIBRARY)]} {
 puts "PPA_UNVERIFIED: WATCHDOG_TARGET_LIBRARY not specified; generic elaboration only"
 exit 0
}
source [file join $IP_ROOT constraints/watchdog.sdc]
set_dont_touch [get_cells -hierarchical -quiet *bar*] true
compile_ultra
redirect $OUT/area.rpt {report_area}
redirect $OUT/timing.rpt {report_timing}
redirect $OUT/power.rpt {report_power}
redirect $OUT/qor.rpt {report_qor}
write -format ddc -hierarchy -output $OUT/watchdog_mapped.ddc
puts "WATCHDOG_SYNTHESIS PASS"
exit 0
