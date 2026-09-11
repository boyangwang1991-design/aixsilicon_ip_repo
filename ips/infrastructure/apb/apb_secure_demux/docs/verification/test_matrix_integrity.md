# 真实保护位故障：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.INTEGRITY.001
name: tc_apb_secure_demux_integrity
type: error_injection
description: 真实保护位故障
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_integrity.sv
feature_ref:
- FL.APB_SECURE_DEMUX.INTEGRITY
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 逐类翻转active/shadow PERM/CFG及保护位、global/port lock合法码的一位；测试多故障优先位置；在SETUP和已发在途两种时刻注入，包含PARITY关闭。
expected_result:
- 当前raw错误组合阻断新SETUP，最迟下一沿FATAL；在途继续完成；首位置保持且排序正确；配置写/reload/commit拒绝，诊断开放；关闭保护时状态零但普通权限仍执行。
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

激励：逐类翻转active/shadow PERM/CFG及保护位、global/port lock合法码的一位；测试多故障优先位置；在SETUP和已发在途两种时刻注入，包含PARITY关闭。

期望：当前raw错误组合阻断新SETUP，最迟下一沿FATAL；在途继续完成；首位置保持且排序正确；配置写/reload/commit拒绝，诊断开放；关闭保护时状态零但普通权限仍执行。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
