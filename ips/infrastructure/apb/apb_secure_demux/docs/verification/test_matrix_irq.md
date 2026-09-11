# 通知与W1C竞争：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.IRQ.001
name: tc_apb_secure_demux_irq
type: directed
description: 通知与W1C竞争
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_irq.sv
feature_ref:
- FL.APB_SECURE_DEMUX.IRQ
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.IRQ
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 逐一触发9类源，遍历INTR_ENABLE/ALERT_ENABLE掩码；同沿事件/W1C，FATAL下清bit4，测试INTR_TEST与合成日志区别。
expected_result:
- raw捕获不受屏蔽，输出分别归约；新事件优先清除，FATAL持续置位；通知测试仅bit8，不新增日志/真实拒绝计数；锁不阻断诊断。
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

激励：逐一触发9类源，遍历INTR_ENABLE/ALERT_ENABLE掩码；同沿事件/W1C，FATAL下清bit4，测试INTR_TEST与合成日志区别。

期望：raw捕获不受屏蔽，输出分别归约；新事件优先清除，FATAL持续置位；通知测试仅bit8，不新增日志/真实拒绝计数；锁不阻断诊断。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
