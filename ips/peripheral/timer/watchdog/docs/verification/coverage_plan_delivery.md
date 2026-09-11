# 软件集成与实现签核：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.DELIVERY.001
name: delivery_scenarios
type: functional
description: 三个产品档×交付视图；所有静态/软件子检查必须分别有命令与原始结果。
feature_ref:
- FL.WATCHDOG.DELIVERY
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：三个产品档×交付视图；所有静态/软件子检查必须分别有命令与原始结果。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
