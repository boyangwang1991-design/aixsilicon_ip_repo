# 软件访问语义（1）

来源：输入契约的 CSR 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.REG.APB_SECURE_DEMUX.CSR.00101

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00101
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

所有配置、日志、中断、DFX 寄存器的读写必须通过管理授权。

#### Acceptance Criteria

- 应满足：所有配置、日志、中断、DFX 寄存器的读写必须通过管理授权。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.00102

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00102
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

PUBLIC_ID_EN=1 时仅 0x000～0x00C 的数据读取例外，但仍要求身份有效且在范围内。

#### Acceptance Criteria

- 应满足：PUBLIC_ID_EN=1 时仅 0x000～0x00C 的数据读取例外，但仍要求身份有效且在范围内。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.002

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.002
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

管理权限不可通过本 IP CSR 修改；管理授权不等同于外设访问授权。

#### Acceptance Criteria

- 应满足：管理权限不可通过本 IP CSR 修改；管理授权不等同于外设访问授权。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.00301

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00301
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

本地 CSR 仅支持 32 bit 对齐访问。

#### Acceptance Criteria

- 应满足：本地 CSR 仅支持 32 bit 对齐访问。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.00302

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00302
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

所有写要求 PSTRB=4'b1111，包括 W1C、命令和锁；否则返回 CSR_STROBE 错误，无写副作用。

#### Acceptance Criteria

- 应满足：所有写要求 PSTRB=4'b1111，包括 W1C、命令和锁；否则返回 CSR_STROBE 错误，无写副作用。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.00401

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00401
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

写 RO、读 WO、访问未实现地址、访问已裁剪功能寄存器均返回错误。

#### Acceptance Criteria

- 应满足：写 RO、读 WO、访问未实现地址、访问已裁剪功能寄存器均返回错误。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.00402

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00402
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

已实现寄存器保留位 RAZ/WI。

#### Acceptance Criteria

- 应满足：已实现寄存器保留位 RAZ/WI。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.005

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.005
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

未授权读返回零，未授权写不改变目标状态；允许产生一次违规日志/计数/中断，这是规定的审计副作用。

#### Acceptance Criteria

- 应满足：未授权读返回零，未授权写不改变目标状态；允许产生一次违规日志/计数/中断，这是规定的审计副作用。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.00601

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00601
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

RW 不受影响位保留当前值；W1C 写 1 清除、写 0 不变；W1S 只允许置位。

#### Acceptance Criteria

- 应满足：RW 不受影响位保留当前值；W1C 写 1 清除、写 0 不变；W1S 只允许置位。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.00602

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.00602
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

命令仅在完成边沿触发。

#### Acceptance Criteria

- 应满足：命令仅在完成边沿触发。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

