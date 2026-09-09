# =============================================================================
# synth.tcl — apb_cdc_bridge 28nm Design Compiler 综合脚本（支持 PPA sweep）
# -----------------------------------------------------------------------------
# 用途: G3 真实 28nm 综合 + 20-ppa-optimization 多配置 PPA sweep
# 工艺上下文: model/pdk.yaml（ip_pdk_scan.py 固化；target/link_library 取自该文件）
# 库: sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db（tt corner, 1.00V / 25C）
# 约束: 双时钟域 s_pclk/m_pclk，默认 400MHz（period 2.5ns），可在命令行覆盖
# 用法（P sweep 每点）:
#   dc_shell -f scripts/synth.tcl -x "set CLK_PERIOD_NS 2.5; set CDC_IMPL 0; set REQ_DEPTH 1; set RSP_DEPTH 1; set RUN_TAG hs_400m"
#   或由 scripts/run_ppa_sweep.sh 批量驱动
# 产物: build/synth/<RUN_TAG>/outputs/apb_cdc_bridge_top_synth.v + reports/synth/*.rpt
# =============================================================================

# ---- 库路径（来自 model/pdk.yaml，不硬编码; 可被 -x 覆盖用于 corner 变换） ----
if {![info exists PDK_YAML]}                      { set PDK_YAML   "model/pdk.yaml" }
if {![info exists DESIGN_NAME]}                   { set DESIGN_NAME "apb_cdc_bridge_top" }
if {![info exists CLK_PERIOD_NS]}                 { set CLK_PERIOD_NS 2.5 }
if {![info exists CDC_IMPL]}                      { set CDC_IMPL 0 }
if {![info exists REQ_DEPTH]}                     { set REQ_DEPTH 1 }
if {![info exists RSP_DEPTH]}                     { set RSP_DEPTH 1 }
if {![info exists RUN_TAG]}                       { set RUN_TAG "default" }
# 输出目录随 RUN_TAG 隔离（支持多配置 sweep 并行/顺序复用）
set SYNTH_DIR "build/synth/${RUN_TAG}"

# 从 pdk.yaml 读取 HVT tt corner 库绝对路径（GF21LB004-FB bundle, r5p0）
set DB_DIR "/home/eda/pdk/CMOS28NM/extracted/GF21LB004-FB-00000-r5p0-03rel0/arm/cp/cmos28lp/sc9_base_hvt/r5p0/db"
set TARGET_LIBRARY "sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db"
set LINK_LIBRARY   "* sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db"
set OPERATING_COND "tt_nominal_max_1p00v_25c"

# ---- 创建输出目录（统一落 build/<RUN_TAG>/，不污染仓库） ----
file mkdir ${SYNTH_DIR}
file mkdir ${SYNTH_DIR}/reports
file mkdir ${SYNTH_DIR}/outputs
file mkdir ${SYNTH_DIR}/work

# ---- search_path: 库 db 目录 + rtl + rtl/include ----
set_app_var search_path [concat $search_path ${DB_DIR} ./rtl ./rtl/include]
set_app_var target_library   $TARGET_LIBRARY
set_app_var link_library     $LINK_LIBRARY
set_app_var symbol_library   ""

# ---- 读取设计（package 先于模块；analyze + elaborate 保证 SV 兼容） ----
analyze -format sverilog [list \
    ./rtl/apb_cdc_bridge_pkg.sv \
    ./rtl/apb_cdc_sync_chain.sv \
    ./rtl/apb_cdc_handshake.sv \
    ./rtl/apb_cdc_async_fifo.sv \
    ./rtl/apb_cdc_source.sv \
    ./rtl/apb_cdc_dest.sv \
    ./rtl/apb_cdc_bridge_top.sv \
]

# ---- Elaborate（带参数覆盖，实现 CDC_IMPL/REQ_DEPTH/RSP_DEPTH 配置） ----
elaborate ${DESIGN_NAME} -parameter "CDC_IMPL=${CDC_IMPL}, REQ_DEPTH=${REQ_DEPTH}, RSP_DEPTH=${RSP_DEPTH}"
current_design ${DESIGN_NAME}
link
uniquify

# ---- 约束（独立 sdc 文件见 scripts/synth_apb_cdc_28nm.sdc） ----
source -echo ./scripts/synth_apb_cdc_28nm.sdc

# ---- 检查设计（无 latch / 无组合环 / 无 unmapped） ----
check_design > ${SYNTH_DIR}/reports/check_design.rpt

# ---- 综合（真实 28nm 库, compile_ultra 兼顾面积/时序） ----
compile_ultra

# ---- 报告（随 RUN_TAG 隔离） ----
report_qor        > ${SYNTH_DIR}/reports/qor.rpt
report_timing     > ${SYNTH_DIR}/reports/timing.rpt
report_area       > ${SYNTH_DIR}/reports/area.rpt
report_power      > ${SYNTH_DIR}/reports/power.rpt
report_constraint > ${SYNTH_DIR}/reports/constraint.rpt

# ---- 输出网表 / SDC / SDF ----
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output ${SYNTH_DIR}/outputs/${DESIGN_NAME}_synth.v
write_sdc -version 2.1                 ${SYNTH_DIR}/outputs/${DESIGN_NAME}.sdc
write_sdf -version 3.0                 ${SYNTH_DIR}/outputs/${DESIGN_NAME}.sdf

# ---- 摘要 ----
puts "\n============================================================"
puts "  SYNTHESIS SUMMARY  (apb_cdc_bridge, 28nm CMOS28LP HVT)"
puts "  Design            : ${DESIGN_NAME}"
puts "  Config            : CDC_IMPL=${CDC_IMPL} REQ_DEPTH=${REQ_DEPTH} RSP_DEPTH=${RSP_DEPTH}"
puts "  Library           : ${TARGET_LIBRARY}"
puts "  Operating cond    : ${OPERATING_COND}"
puts "  Clock period      : ${CLK_PERIOD_NS} ns"
puts "  Outputs           : ${SYNTH_DIR}/outputs/${DESIGN_NAME}_synth.v / .sdc"
puts "============================================================\n"
exit