# 局部恢复与暖复位：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.RECOVERY.001
name: recovery_scenarios
type: functional
description: done阶段×最终边界×预算×BOOT；warm与新致命故障同拍。
feature_ref:
- FL.WATCHDOG.RECOVERY
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：done阶段×最终边界×预算×BOOT；warm与新致命故障同拍。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
