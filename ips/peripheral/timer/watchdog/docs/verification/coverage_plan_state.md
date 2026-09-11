# 启动停止与启动期：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.STATE.001
name: state_scenarios
type: functional
description: 控制状态×命令×锁；POR与首个可用WDT边沿。
feature_ref:
- FL.WATCHDOG.STATE
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：控制状态×命令×锁；POR与首个可用WDT边沿。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
