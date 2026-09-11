# 单在途邮箱与跨域：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.CDC.001
name: cdc_scenarios
type: functional
description: 同步级数×时钟比×复位相位×忙/完成；取消边界前/当拍/后一拍。
feature_ref:
- FL.WATCHDOG.CDC
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：同步级数×时钟比×复位相位×忙/完成；取消边界前/当拍/后一拍。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
