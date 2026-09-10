# Auto-generated for PPA sweep point CFG_R16_P1_500M; library context from model/pdk.yaml
set_app_var search_path [list . /home/eda/pdk/CMOS28NM/extracted/GF21LB004-FB-00000-r5p0-03rel0/arm/cp/cmos28lp/sc9_base_hvt/r5p0/db /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/rtl /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/rtl/include /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/rtl/generated]
set_app_var target_library sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db
set_app_var link_library [list * sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db]

set rtl_dir /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/rtl
set rtl_files [list \
    $rtl_dir/generated/axi_mpu_csr_pkg.sv \
    $rtl_dir/generated/axi_mpu_csr.sv \
    $rtl_dir/axi_mpu_permission.sv \
    $rtl_dir/axi_mpu_read.sv \
    $rtl_dir/axi_mpu_write.sv \
    $rtl_dir/axi_mpu.sv ]

define_design_lib WORK -path ./CFG_R16_P1_500M_500MHz_d916efef_work
analyze -format sverilog $rtl_files
elaborate axi_mpu -parameters "REGION_NUM=16,PIPELINE=1"
current_design axi_mpu
link

set_operating_conditions tt_nominal_max_1p00v_25c

create_clock -name clk -period 2.0 [get_ports clk]
set_input_delay 0.4 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.4 -clock clk [all_outputs]
set_load 0.010 [all_outputs]

compile -map_effort medium

report_area  > /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/evidence/ppa/CFG_R16_P1_500M_500MHz_d916efef/area.rpt
report_timing > /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/evidence/ppa/CFG_R16_P1_500M_500MHz_d916efef/timing.rpt
report_power  > /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/evidence/ppa/CFG_R16_P1_500M_500MHz_d916efef/power.rpt
report_qor    > /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/evidence/ppa/CFG_R16_P1_500M_500MHz_d916efef/qor.rpt
exit
