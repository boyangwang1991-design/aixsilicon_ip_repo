# APB4与寄存器访问：场景覆盖

<!-- COVERAGE_META
id: COV.WATCHDOG.BUS.001
name: bus_scenarios
type: functional
description: 读写×地址类别×strobes×权限×等待周期；错误访问与邮箱忙同拍。
feature_ref:
- FL.WATCHDOG.BUS
design_ref:
- LLD.MOD.WATCHDOG.BUS
applicability:
  expr: 'true'
END_COVERAGE_META -->

必需coverpoints与cross：读写×地址类别×strobes×权限×等待周期；错误访问与邮箱忙同拍。

仅在monitor采到真实接受/执行/拒绝事件后采样；静态feature由真实子检查结果采样。
非法组合先依据PC/协议列出ignore理由；不能事后按未命中结果删bin。正确性以对应TC/checker结果判定。
