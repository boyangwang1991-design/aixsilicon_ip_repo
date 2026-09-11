# 多客户端组监督：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.GROUP.001
name: group_scenarios
type: functional
description: 客户端首/末×重复×窗口；require稀疏/全置位。
feature_ref:
- FL.WATCHDOG.GROUP
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：客户端首/末×重复×窗口；require稀疏/全置位。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
