# =============================================================================
# uart_synth.tcl - Design Compiler synthesis script
# Top: uart (OpenTitan TL-UL UART core)
# Purpose: G3 synth gate - verify synthesizability + check_design
# =============================================================================

set DESIGN_NAME uart
set TOP_MODULE uart

set search_path [list .]

# No PDK library -> structure-only check (synthesizability + check_design)
set target_library [list]
set link_library [list]
set symbol_library {}

# Include dirs so `include "prim_assert.sv"` resolves (prim/tlul/top libs)
set prim_dir [file normalize ../ips/lowrisc/prim/0.1.0/rtl]
set tlul_dir [file normalize ../ips/lowrisc/tlul/0.1.0/rtl]
set top_dir  [file normalize ../ips/lowrisc/top/0.1.0/rtl]
set rtl_dir  [file normalize rtl]
set hdlin_verilog_include_dir [list $rtl_dir $prim_dir $tlul_dir $top_dir]

# Define SYNTHESIS so prim_assert uses dummy macros (synthesizable subset)
define_design_lib WORK -path ./work_lib

# Read common library files + core RTL in dependency order (from rtl/filelist.f)
# libs first (filelist_libs.f lists them in dependency order)
set lib_files [list]
set fh [open "rtl/filelist_libs.f" r]
while {[gets $fh line] >= 0} {
  set line [string trim $line]
  if {$line eq ""} { continue }
  if {[string match "//*" $line]} { continue }
  lappend lib_files $line
}
close $fh

# Core RTL (from rtl/filelist.f, non-comment, non -f lines)
set core_files [list]
set fh [open "rtl/filelist.f" r]
while {[gets $fh line] >= 0} {
  set line [string trim $line]
  if {$line eq ""} { continue }
  if {[string match "//*" $line]} { continue }
  if {[string match "-f*" $line]} { continue }
  lappend core_files $line
}
close $fh

puts "Analyzing library files..."
foreach f $lib_files {
  if {[file exists $f]} {
    puts "  analyze $f"
    analyze -format sverilog $f
  }
}

puts "Analyzing core RTL files..."
foreach f $core_files {
  if {[file exists $f]} {
    puts "  analyze $f"
    analyze -format sverilog $f
  }
}

puts "Elaborating $TOP_MODULE"
elaborate $TOP_MODULE
link
uniquify

# Design checks
check_design > reports/synth/check_design.log

# Area / hierarchy reports
report_area > reports/synth/area.log
report_hierarchy > reports/synth/hierarchy.log

puts "Synth check completed for $DESIGN_NAME"
