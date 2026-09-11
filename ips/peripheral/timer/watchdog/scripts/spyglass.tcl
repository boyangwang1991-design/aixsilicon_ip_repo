set IP_ROOT [file normalize [file join [file dirname [info script]] ..]]
set OUT [file join $IP_ROOT build rtl spyglass]
file mkdir $OUT
new_project watchdog -projectwdir $OUT -force
set_option enableSV09 yes
set_option mthresh 1048576
set_option language_mode mixed
set_option top watchdog_top
set_option define SYNTHESIS
set_option incdir [list [file join $IP_ROOT rtl]]
foreach f {rtl/watchdog_pkg.sv rtl/generated/watchdog_csr_pkg.sv rtl/generated/watchdog_csr.sv rtl/generated/watchdog_reg_adapter.sv rtl/watchdog_channel.sv rtl/watchdog_top.sv} {
 read_file -type sourcelist [file join $IP_ROOT build rtl lint_sources.f]
 break
}
current_goal lint/lint_rtl
run_goal
save_project
exit
