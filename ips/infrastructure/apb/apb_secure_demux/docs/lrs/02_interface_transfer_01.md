# APB 事务行为（1）

来源：输入契约的 APB 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.INTF.APB_SECURE_DEMUX.APB.001

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.001
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

非法访问从 SETUP 开始所有下游 PSEL 必须为 0，不得引发读清除、FIFO 弹出、写启动或其他副作用。

#### Acceptance Criteria

- 应满足：非法访问从 SETUP 开始所有下游 PSEL 必须为 0，不得引发读清除、FIFO 弹出、写启动或其他副作用。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.002

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.002
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

所有本地拒绝在第一个上游 ACCESS 周期响应 PREADY=1、PSLVERR=1、PRDATA=0；包括 REGISTER_MODE=1。

#### Acceptance Criteria

- 应满足：所有本地拒绝在第一个上游 ACCESS 周期响应 PREADY=1、PSLVERR=1、PRDATA=0；包括 REGISTER_MODE=1。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.003

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.003
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

成功 CSR 访问在第一个 ACCESS 周期 PREADY=1、PSLVERR=0；CSR 副作用仅在完成边沿发生一次。

#### Acceptance Criteria

- 应满足：成功 CSR 访问在第一个 ACCESS 周期 PREADY=1、PSLVERR=0；CSR 副作用仅在完成边沿发生一次。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.004

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.004
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

正常外设访问透传下游完成响应；下游 PSLVERR=1 时上游仍返回该错误，下游 PRDATA 原样透传，不按权限拒绝处理。

#### Acceptance Criteria

- 应满足：正常外设访问透传下游完成响应；下游 PSLVERR=1 时上游仍返回该错误，下游 PRDATA 原样透传，不按权限拒绝处理。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.00501

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.00501
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

无有效 ACCESS 时上游 PSLVERR=0；PRDATA=0，PREADY=1。

#### Acceptance Criteria

- 应满足：无有效 ACCESS 时上游 PSLVERR=0；PRDATA=0，PREADY=1。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.00502

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.00502
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

复位期间按第 13 节强制值。

#### Acceptance Criteria

- 应满足：复位期间按第 13 节强制值。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.00601

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.00601
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

所有周期 m_psel 满足 one-hot-or-zero。

#### Acceptance Criteria

- 应满足：所有周期 m_psel 满足 one-hot-or-zero。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.00602

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.00602
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

未选端口 m_penable=0，选中端口遵守完整 SETUP/ACCESS 时序。

#### Acceptance Criteria

- 应满足：未选端口 m_penable=0，选中端口遵守完整 SETUP/ACCESS 时序。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.007

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.007
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- REQ-APB-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

OUTPUT_ISOLATION_EN=1 时，未选端口 PADDR/PWDATA/PSTRB/PWRITE/PPROT/MASTERID 均置零；=0 时可以广播当前请求，但 PSEL/PENABLE/身份有效不得广播。

#### Acceptance Criteria

- 应满足：OUTPUT_ISOLATION_EN=1 时，未选端口 PADDR/PWDATA/PSTRB/PWRITE/PPROT/MASTERID 均置零；=0 时可以广播当前请求，但 PSEL/PENABLE/身份有效不得广播。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

### LRS.INTF.APB_SECURE_DEMUX.APB.00801

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.APB.00801
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

支持 PSEL 连续保持的背靠背事务、读写交替、切换目标、CSR 与外设交替。

#### Acceptance Criteria

- 应满足：支持 PSEL 连续保持的背靠背事务、读写交替、切换目标、CSR 与外设交替。
- 在两种时序模式下覆盖零等待、长等待和背靠背；逐周期对照响应与下游副作用。

