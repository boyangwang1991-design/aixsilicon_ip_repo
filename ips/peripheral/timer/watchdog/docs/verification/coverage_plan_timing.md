# 计时窗口与周期优先级：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.TIMING.001
name: timing_scenarios
type: functional
description: tick×窗口边界×预警×服务；宽度与分频端点。
feature_ref:
- FL.WATCHDOG.TIMING
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：tick×窗口边界×预警×服务；宽度与分频端点。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
