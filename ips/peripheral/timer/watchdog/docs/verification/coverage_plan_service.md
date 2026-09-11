# 软件密钥与令牌服务：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.SERVICE.001
name: service_scenarios
type: functional
description: 算法×结果×序列边界×窗口；令牌每客户端独立。
feature_ref:
- FL.WATCHDOG.SERVICE
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：算法×结果×序列边界×窗口；令牌每客户端独立。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
