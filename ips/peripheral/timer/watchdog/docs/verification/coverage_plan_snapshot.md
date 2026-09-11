# 全表原子快照：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.SNAPSHOT.001
name: snapshot_scenarios
type: functional
description: 通道/客户端端点×快照并发事件×时钟比；保持到下一成功快照。
feature_ref:
- FL.WATCHDOG.SNAPSHOT
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：通道/客户端端点×快照并发事件×时钟比；保持到下一成功快照。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
