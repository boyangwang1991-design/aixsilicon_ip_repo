# 配置原子提交与生效：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.COMMIT.001
name: commit_scenarios
type: functional
description: 配置状态×合法性×锁×pending×版本；UNSUPPORTED与BAD_CONFIG优先级。
feature_ref:
- FL.WATCHDOG.COMMIT
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：配置状态×合法性×锁×pending×版本；UNSUPPORTED与BAD_CONFIG优先级。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
