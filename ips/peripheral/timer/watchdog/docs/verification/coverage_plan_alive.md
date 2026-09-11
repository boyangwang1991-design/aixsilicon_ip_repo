# 固定周期存活监督：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.ALIVE.001
name: alive_scenarios
type: functional
description: 计数MIN-1/MIN/MAX/MAX+1×边界事件×BOOT/RUN；饱和。
feature_ref:
- FL.WATCHDOG.ALIVE
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：计数MIN-1/MIN/MAX/MAX+1×边界事件×BOOT/RUN；饱和。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
