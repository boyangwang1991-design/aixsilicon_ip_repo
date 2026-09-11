# APB 事务行为（2）

来源：输入契约的 APB 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.INTF.APB_SECURE_DEMUX.APB.00802

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.00802
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-008
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

每个新 SETUP 必须重新译码和判权。

#### Acceptance Criteria

- 应满足：每个新 SETUP 必须重新译码和判权。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.009

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.009
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-009
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

不存在 posted write 或提前成功响应；外设事务完成前不得释放上游。

#### Acceptance Criteria

- 应满足：不存在 posted write 或提前成功响应；外设事务完成前不得释放上游。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.01001

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.01001
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-010
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

不支持主动取消已发出的下游事务。

#### Acceptance Criteria

- 应满足：不支持主动取消已发出的下游事务。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.01002

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.01002
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-010
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

等待告警、DFX 授权撤销或新完整性故障均不得中途撤销 PSEL。

#### Acceptance Criteria

- 应满足：等待告警、DFX 授权撤销或新完整性故障均不得中途撤销 PSEL。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

