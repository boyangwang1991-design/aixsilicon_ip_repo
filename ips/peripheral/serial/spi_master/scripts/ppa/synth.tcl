# Invoked by the FuseSoC/Edalize design_compiler target. READ_SOURCES comes from EDAM.
set IP_ROOT $::env(SPI_IP_ROOT)
source $IP_ROOT/build/rtl/pdk_setup.tcl
define_design_lib work -path ./work
source ${READ_SOURCES}.tcl
set params "NUM_CS=$::env(SPI_NUM_CS),TX_FIFO_DEPTH=$::env(SPI_TX_DEPTH),RX_FIFO_DEPTH=$::env(SPI_RX_DEPTH),CMD_FIFO_DEPTH=$::env(SPI_CMD_DEPTH)"
elaborate spi_master_top -parameters $params
# elaborate already selects the parameter-specialized design.
link
uniquify
set_operating_conditions $AIX_PDK_OPERATING_CONDITION
source $IP_ROOT/constraints/characterization.sdc
set_driving_cell -lib_cell BUFH_X4M_A9TH -pin Y [remove_from_collection [all_inputs] [get_ports {pclk preset_n}]]
redirect reports/check_pre.rpt { check_design }
compile -map_effort medium
redirect reports/check_post.rpt { check_design }
redirect reports/area.rpt { report_area -hierarchy }
redirect reports/timing.rpt { report_timing -max_paths 10 -delay_type max }
redirect reports/power.rpt { report_power }
redirect reports/constraints.rpt { report_constraint -all_violators }
redirect reports/references.rpt { report_reference -hierarchy }
redirect reports/clock.rpt { report_clock }
file mkdir outputs
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output outputs/spi_master_top_synth.v
write -format ddc -hierarchy -output outputs/spi_master_top.ddc
write_sdc outputs/spi_master_top.sdc
puts "SPI_SYNTH_COMPLETE"
exit
