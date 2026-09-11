# 授权注入统计与等待：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.DFX.001
name: tc_apb_secure_demux_dfx
type: error_injection
description: 授权注入统计与等待
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_dfx.sv
feature_ref:
- FL.APB_SECURE_DEMUX.DFX
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.DFX
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 测试DFX关闭、授权高低及SETUP/ACCESS撤销，目标范围/重武装/改目标错误，匹配自然合法和非法请求，一次拒绝/一次完整性/合成事件；等待阈值0/1/T、计数饱和和同沿清除。
expected_result:
- 授权不足无武装且观测零；自然非法不消耗；已捕获拒绝不撤销；真实副作用仍受权限约束；wait只计下游ACCESS，MAX完成更新，阈值同笔一次，统计饱和且先清后增。
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

激励：测试DFX关闭、授权高低及SETUP/ACCESS撤销，目标范围/重武装/改目标错误，匹配自然合法和非法请求，一次拒绝/一次完整性/合成事件；等待阈值0/1/T、计数饱和和同沿清除。

期望：授权不足无武装且观测零；自然非法不消耗；已捕获拒绝不撤销；真实副作用仍受权限约束；wait只计下游ACCESS，MAX完成更新，阈值同笔一次，统计饱和且先清后增。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
