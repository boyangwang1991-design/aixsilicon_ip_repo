# 构建参数与能力：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.CONFIG.001
name: config_scenarios
type: functional
description: 参数×合法性×能力裁剪；通道1/16、客户端1/32、W32/48/64、同步2/3/4及16参数风险组合。
feature_ref:
- FL.WATCHDOG.CONFIG
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：参数×合法性×能力裁剪；通道1/16、客户端1/32、W32/48/64、同步2/3/4及16参数风险组合。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
