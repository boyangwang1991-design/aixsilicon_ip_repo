# 暂停保持与安全连续性：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.PAUSE.001
name: pause_scenarios
type: functional
description: 暂停来源×授权×通道状态×计时相位；安全/生产默认。
feature_ref:
- FL.WATCHDOG.PAUSE
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：暂停来源×授权×通道状态×计时相位；安全/生产默认。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
