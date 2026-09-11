# 硬件服务与公平仲裁：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.HW_EVENT.001
name: hw_event_scenarios
type: functional
description: 请求组合×轮询顺序×取消窗口×通道；硬件能力开/关。
feature_ref:
- FL.WATCHDOG.HW_EVENT
design_ref:
- LLD.MOD.WATCHDOG.DISPATCH
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：请求组合×轮询顺序×取消窗口×通道；硬件能力开/关。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
