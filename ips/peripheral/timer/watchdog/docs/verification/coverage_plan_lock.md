# 权限解锁和只置位锁：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.LOCK.001
name: lock_scenarios
type: functional
description: 权限×命令×状态×信用年龄；同拍锁与后续命令。
feature_ref:
- FL.WATCHDOG.LOCK
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：权限×命令×状态×信用年龄；同拍锁与后续命令。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
