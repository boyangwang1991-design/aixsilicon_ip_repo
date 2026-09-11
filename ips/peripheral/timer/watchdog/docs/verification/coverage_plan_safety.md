# 独立数字诊断链：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.SAFETY.001
name: safety_scenarios
type: functional
description: 故障位置×状态×诊断授权×锁×检测延迟；未激活/共因明确不计覆盖。
feature_ref:
- FL.WATCHDOG.SAFETY
design_ref:
- LLD.MOD.WATCHDOG.SAFETY
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：故障位置×状态×诊断授权×锁×检测延迟；未激活/共因明确不计覆盖。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
