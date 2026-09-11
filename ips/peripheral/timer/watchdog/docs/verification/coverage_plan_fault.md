# 故障记录与升级：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.FAULT.001
name: fault_scenarios
type: functional
description: 故障位×策略×响应模式×清除；FIRST有效×多原因×计数饱和。
feature_ref:
- FL.WATCHDOG.FAULT
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：故障位×策略×响应模式×清除；FIRST有效×多原因×计数饱和。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
