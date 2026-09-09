# =============================================================================
# synth_apb_cdc_28nm.sdc — apb_cdc_bridge 双时钟域 28nm 约束
# 工艺: CMOS28LP 28nm (ARM SC9 HVT), tt corner 1.00V / 25C
# 时钟: s_pclk / m_pclk 双时钟域（完全异步；bridge 内为 CDC 路径）
# 默认 400MHz（2.5ns），由 synth.tcl 的 CLK_PERIOD_NS 统一控制
# =============================================================================

# ---- 时钟定义（双时钟域，各自独立） ----
# 注意：不能用 {0 [expr ...]} 花括号内嵌（DC 报 CMD-036，导致时钟创建失败、设计无约束）
set WAVEFORM_HALF [expr {${CLK_PERIOD_NS}/2.0}]
create_clock -period ${CLK_PERIOD_NS} -name s_pclk -waveform "0 ${WAVEFORM_HALF}" [get_ports s_pclk]
create_clock -period ${CLK_PERIOD_NS} -name m_pclk -waveform "0 ${WAVEFORM_HALF}" [get_ports m_pclk]
set_clock_uncertainty 0.10 [get_clocks s_pclk]
set_clock_uncertainty 0.10 [get_clocks m_pclk]
set_clock_transition  0.10 [get_clocks s_pclk]
set_clock_transition  0.10 [get_clocks m_pclk]

# ---- 异步时钟域（true CDC: s <-> m 不做同步路径约束，交由 CDC 静态检查） ----
set_clock_groups -asynchronous -group [get_clocks s_pclk] -group [get_clocks m_pclk]

# ---- 输入延时（相对各自时钟域） ----
set_input_delay -max 0.5 -clock s_pclk [get_ports s_psel]
set_input_delay -min 0.2 -clock s_pclk [get_ports s_psel]
set_input_delay -max 0.5 -clock s_pclk [get_ports s_penable]
set_input_delay -min 0.2 -clock s_pclk [get_ports s_penable]
set_input_delay -max 0.5 -clock s_pclk [remove_from_collection [all_inputs] [get_ports {s_pclk s_presetn s_psel s_penable}]]
set_input_delay -min 0.2 -clock s_pclk [remove_from_collection [all_inputs] [get_ports {s_pclk s_presetn s_psel s_penable}]]

# ---- 输出延时 ----
set_output_delay -max 0.5 -clock m_pclk [all_outputs]
set_output_delay -min 0.2 -clock m_pclk [all_outputs]

# ---- 环境/驱动（PDK 实测: BUFH_X4M_A9TH 输出 pin 为 Y） ----
set_driving_cell -lib_cell BUFH_X4M_A9TH -pin Y [remove_from_collection [all_inputs] [get_ports {s_pclk m_pclk}]]
set_load -pin_load 0.01 [all_outputs]

set_operating_conditions ${OPERATING_COND}

# ---- 设计约束 ----
set_max_fanout 20 [current_design]
set_max_transition 0.5 [current_design]
set_max_area 0