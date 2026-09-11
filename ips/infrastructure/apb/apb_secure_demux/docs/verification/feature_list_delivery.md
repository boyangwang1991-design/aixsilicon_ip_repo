# 交付与证据完整性

<!-- FEATURE_META
id: FL.APB_SECURE_DEMUX.DELIVERY
name: 交付与证据完整性
description: 交付与证据完整性
priority: must
req_ref:
- LRS.CONS.APB_SECURE_DEMUX.VERIFICATION.015
- LRS.CONS.APB_SECURE_DEMUX.DELIVERY.016
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
proof_methods:
- static
END_FEATURE_META -->

## 逐需求验收范围

- `LRS.CONS.APB_SECURE_DEMUX.VERIFICATION.015`：强制需求须建立 REQ→Feature→Test/Assertion 追踪，必需测试和强制功能 bins 应通过或有真实评审豁免；拒绝无副作用、锁不可绕过、原子提交及 onehot0 须具有形式或等效可审计穷尽证据。
- `LRS.CONS.APB_SECURE_DEMUX.DELIVERY.016`：完整交付应包含参数化 RTL、HWIF 契约、寄存器描述及派生软件接口、初始化/更新/锁定/中断示例、UVM 验证、集成配置检查、FuseSoC、用户和集成文档及质量证据。
