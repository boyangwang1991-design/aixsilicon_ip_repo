# 配置完整性（2）

来源：输入契约的 INT 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.SAFE.APB_SECURE_DEMUX.INT.009

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.009
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-009
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

本保护不覆盖任意多 bit 错误、组合译码/比较逻辑故障、日志存储完整性或外部总线传输完整性，不宣称满足特定 ASIL 或安全认证等级。

#### Acceptance Criteria

- 应满足：本保护不覆盖任意多 bit 错误、组合译码/比较逻辑故障、日志存储完整性或外部总线传输完整性，不宣称满足特定 ASIL 或安全认证等级。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

