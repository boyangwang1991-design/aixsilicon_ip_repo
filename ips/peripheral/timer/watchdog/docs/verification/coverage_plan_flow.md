# 线性流程与独立期限：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.FLOW.001
name: flow_scenarios
type: functional
description: step首/中/末×错误类别×deadline边界×主窗口。
feature_ref:
- FL.WATCHDOG.FLOW
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：step首/中/末×错误类别×deadline边界×主窗口。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
