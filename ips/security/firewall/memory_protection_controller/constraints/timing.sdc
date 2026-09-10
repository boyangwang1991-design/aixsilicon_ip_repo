# AXI MPU - PPA Sweep 顶层 SDC（28nm CMOS28LP / sc9_cmos28lp_base_hvt）
# Sweep 维度：时钟周期由逐点 manifest 的 freq-mhz 注入（PERIOD_NS 占位替换）。
set_clock_transition 0.15 [get_clocks clk]
set_clock_uncertainty 0.10 [get_clocks clk]
set_input_transition 0.20 [all_inputs]
set_load 0.010 [all_outputs]
set_max_fanout 32 [current_design]
