# 权限判定（1）

来源：输入契约的 ACL 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00101

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00101
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

每个端口、每个主体维护独立 8 bit PERM。

#### Acceptance Criteria

- 应满足：每个端口、每个主体维护独立 8 bit PERM。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00102

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00102
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

1 允许，0 拒绝；读写与四种属性均可独立配置。

#### Acceptance Criteria

- 应满足：1 允许，0 拒绝；读写与四种属性均可独立配置。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00201

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00201
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

Secure、特权和管理主体均无隐含外设访问豁免。

#### Acceptance Criteria

- 应满足：Secure、特权和管理主体均无隐含外设访问豁免。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00202

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00202
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

管理身份访问外设时仍查端口权限表。

#### Acceptance Criteria

- 应满足：管理身份访问外设时仍查端口权限表。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00301

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00301
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

PORT_CFG[0]=ENABLE；[1]=INSTR_ALLOW。

#### Acceptance Criteria

- 应满足：PORT_CFG[0]=ENABLE；[1]=INSTR_ALLOW。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00302

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00302
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

其余位保留为零。

#### Acceptance Criteria

- 应满足：其余位保留为零。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00401

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00401
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

数据访问检查相应读写位。

#### Acceptance Criteria

- 应满足：数据访问检查相应读写位。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.00402

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.00402
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

指令读还必须 INSTR_ALLOW=1；指令写一律拒绝。

#### Acceptance Criteria

- 应满足：指令读还必须 INSTR_ALLOW=1；指令写一律拒绝。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.005

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.005
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

身份无效或越界必须拒绝，不映射为主体 0；PSTRB=0 仍执行正常写权限检查。

#### Acceptance Criteria

- 应满足：身份无效或越界必须拒绝，不映射为主体 0；PSTRB=0 仍执行正常写权限检查。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

### LRS.SEC.APB_SECURE_DEMUX.ACL.006

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.006
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

判权结果与目标在事务边界锁定，等待期间不得重新按新策略改变当前事务。

#### Acceptance Criteria

- 应满足：判权结果与目标在事务边界锁定，等待期间不得重新按新策略改变当前事务。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

