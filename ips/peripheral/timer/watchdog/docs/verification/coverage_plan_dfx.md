# 诊断测试和中断路径：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.DFX.001
name: dfx_scenarios
type: functional
description: 测试类别×授权×实例×IRQ屏蔽；真实故障与测试并发。
feature_ref:
- FL.WATCHDOG.DFX
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：测试类别×授权×实例×IRQ屏蔽；真实故障与测试并发。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
