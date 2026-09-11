# 地址分发（1）

来源：输入契约的 DEC 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.FUNC.APB_SECURE_DEMUX.DEC.001

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.DEC.001
category: FUNC
feature: dec
priority: P0
status: active
source_ref:
- REQ-DEC-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

SETUP 阶段分别计算本地 CSR 命中和各端口命中；必须使用全部有效地址位。

#### Acceptance Criteria

- 应满足：SETUP 阶段分别计算本地 CSR 命中和各端口命中；必须使用全部有效地址位。
- 覆盖 CSR/外设边界、空洞及多重命中；对比目标选择、错误原因和原始地址。

### LRS.FUNC.APB_SECURE_DEMUX.DEC.002

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.DEC.002
category: FUNC
feature: dec
priority: P0
status: active
source_ref:
- REQ-DEC-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

总命中数为 0，产生 ADDR_MISS；大于 1，产生 MULTI_HIT；均不得访问 CSR 或下游。

#### Acceptance Criteria

- 应满足：总命中数为 0，产生 ADDR_MISS；大于 1，产生 MULTI_HIT；均不得访问 CSR 或下游。
- 覆盖 CSR/外设边界、空洞及多重命中；对比目标选择、错误原因和原始地址。

### LRS.FUNC.APB_SECURE_DEMUX.DEC.003

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.DEC.003
category: FUNC
feature: dec
priority: P0
status: active
source_ref:
- REQ-DEC-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

本地 CSR 与外设同时命中时不得采用 CSR 优先级放行，必须按多重命中拒绝。

#### Acceptance Criteria

- 应满足：本地 CSR 与外设同时命中时不得采用 CSR 优先级放行，必须按多重命中拒绝。
- 覆盖 CSR/外设边界、空洞及多重命中；对比目标选择、错误原因和原始地址。

### LRS.FUNC.APB_SECURE_DEMUX.DEC.004

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.DEC.004
category: FUNC
feature: dec
priority: P0
status: active
source_ref:
- REQ-DEC-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

端口关闭仍属于地址命中，错误原因为 PORT_DISABLED。

#### Acceptance Criteria

- 应满足：端口关闭仍属于地址命中，错误原因为 PORT_DISABLED。
- 覆盖 CSR/外设边界、空洞及多重命中；对比目标选择、错误原因和原始地址。

### LRS.FUNC.APB_SECURE_DEMUX.DEC.005

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.DEC.005
category: FUNC
feature: dec
priority: P0
status: active
source_ref:
- REQ-DEC-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

下游透传原始地址，不减去 BASE；不存在隐式地址别名或地址转换。

#### Acceptance Criteria

- 应满足：下游透传原始地址，不减去 BASE；不存在隐式地址别名或地址转换。
- 覆盖 CSR/外设边界、空洞及多重命中；对比目标选择、错误原因和原始地址。

### LRS.FUNC.APB_SECURE_DEMUX.DEC.00601

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.DEC.00601
category: FUNC
feature: dec
priority: P0
status: active
source_ref:
- REQ-DEC-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

下游数据访问的低地址位与 PSTRB 由目标外设解释，本 IP 不增加通用未对齐拒绝规则。

#### Acceptance Criteria

- 应满足：下游数据访问的低地址位与 PSTRB 由目标外设解释，本 IP 不增加通用未对齐拒绝规则。
- 覆盖 CSR/外设边界、空洞及多重命中；对比目标选择、错误原因和原始地址。

### LRS.FUNC.APB_SECURE_DEMUX.DEC.00602

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.DEC.00602
category: FUNC
feature: dec
priority: P0
status: active
source_ref:
- REQ-DEC-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

本地 CSR 必须按 4 字节对齐访问。

#### Acceptance Criteria

- 应满足：本地 CSR 必须按 4 字节对齐访问。
- 覆盖 CSR/外设边界、空洞及多重命中；对比目标选择、错误原因和原始地址。

