# 复位状态及恢复：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.RESET.001
name: tc_apb_secure_demux_reset
type: reset
description: 复位状态及恢复
priority: must
tier: smoke
implementation: verification/tc/tc_apb_secure_demux_reset.sv
feature_ref:
- FL.APB_SECURE_DEMUX.RESET
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 在IDLE/SETUP/LOCAL/REG_SETUP/ACCESS/等待、日志满、锁/FATAL/武装/非零启动权限状态拉低可信复位；另独立复位下游外设。
expected_result:
- 复位期间选择/响应/通知零，全部状态和掩码恢复约定；active/shadow与参数一致；无先行SETUP的ACCESS不被接收；下游普通复位不能清本IP策略/锁。
timeout_policy: 200000 pclk cycles for simulation; 1200 s tool timeout
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
- CFG_MAX_DIRECT
- CFG_MAX_REGISTER
- CFG_MIN_NOFIFO
- CFG_MIN_FIFO1
- CFG_NONPOWER
- CFG_TRIMMED
END_TESTCASE_META -->

激励：在IDLE/SETUP/LOCAL/REG_SETUP/ACCESS/等待、日志满、锁/FATAL/武装/非零启动权限状态拉低可信复位；另独立复位下游外设。

期望：复位期间选择/响应/通知零，全部状态和掩码恢复约定；active/shadow与参数一致；无先行SETUP的ACCESS不被接收；下游普通复位不能清本IP策略/锁。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
