# 复位分域与外部假设：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.RESET.001
name: reset_scenarios
type: functional
description: 复位域×握手阶段×安全状态×时钟停止；外部停钟/失电责任单独审阅。
feature_ref:
- FL.WATCHDOG.RESET
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：复位域×握手阶段×安全状态×时钟停止；外部停钟/失电责任单独审阅。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
