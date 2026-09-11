# 系统信任边界（1）

来源：输入契约的 SYS 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.CONS.APB_SECURE_DEMUX.SYS.001

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.SYS.001
category: CONS
feature: sys
priority: P0
status: active
source_ref:
- REQ-SYS-001
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

MASTERID、PPROT 必须由可信系统路径产生；本 IP 检查属性而不认证其真实性。

#### Acceptance Criteria

- 应满足：MASTERID、PPROT 必须由可信系统路径产生；本 IP 检查属性而不认证其真实性。
- 通过系统连接/复位/身份路径审查确认该约束；本 IP 局部仿真不能代替系统证据。

### LRS.CONS.APB_SECURE_DEMUX.SYS.002

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.SYS.002
category: CONS
feature: sys
priority: P0
status: active
source_ref:
- REQ-SYS-002
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

上游 X2P 必须将读请求 ARPROT、写请求 AWPROT 以及主体身份绑定到对应 APB 事务，缓冲、仲裁和 CDC 后不得错配。

#### Acceptance Criteria

- 应满足：上游 X2P 必须将读请求 ARPROT、写请求 AWPROT 以及主体身份绑定到对应 APB 事务，缓冲、仲裁和 CDC 后不得错配。
- 通过系统连接/复位/身份路径审查确认该约束；本 IP 局部仿真不能代替系统证据。

### LRS.CONS.APB_SECURE_DEMUX.SYS.003

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.SYS.003
category: CONS
feature: sys
priority: P0
status: active
source_ref:
- REQ-SYS-003
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

AXI AxID 不得在未经可信身份映射的情况下直接充当 MASTERID。

#### Acceptance Criteria

- 应满足：AXI AxID 不得在未经可信身份映射的情况下直接充当 MASTERID。
- 通过系统连接/复位/身份路径审查确认该约束；本 IP 局部仿真不能代替系统证据。

### LRS.CONS.APB_SECURE_DEMUX.SYS.004

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.SYS.004
category: CONS
feature: sys
priority: P0
status: active
source_ref:
- REQ-SYS-004
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

所有抵达被保护外设的访问路径和别名入口必须有等效保护；本 IP 无法阻止绕过自身的另一条访问路径。

#### Acceptance Criteria

- 应满足：所有抵达被保护外设的访问路径和别名入口必须有等效保护；本 IP 无法阻止绕过自身的另一条访问路径。
- 通过系统连接/复位/身份路径审查确认该约束；本 IP 局部仿真不能代替系统证据。

### LRS.CONS.APB_SECURE_DEMUX.SYS.00501

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.SYS.00501
category: CONS
feature: sys
priority: P0
status: active
source_ref:
- REQ-SYS-005
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

普通外设复位不得清除本 IP 权限或锁。

#### Acceptance Criteria

- 应满足：普通外设复位不得清除本 IP 权限或锁。
- 通过系统连接/复位/身份路径审查确认该约束；本 IP 局部仿真不能代替系统证据。

### LRS.CONS.APB_SECURE_DEMUX.SYS.00502

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.SYS.00502
category: CONS
feature: sys
priority: P0
status: active
source_ref:
- REQ-SYS-005
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

模块复位和 DFX 授权必须由可信系统控制。

#### Acceptance Criteria

- 应满足：模块复位和 DFX 授权必须由可信系统控制。
- 通过系统连接/复位/身份路径审查确认该约束；本 IP 局部仿真不能代替系统证据。

### LRS.CONS.APB_SECURE_DEMUX.SYS.006

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.SYS.006
category: CONS
feature: sys
priority: P0
status: active
source_ref:
- REQ-SYS-006
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

本 IP 不承诺抵抗任意物理故障注入、恶意时钟毛刺或篡改后的 scan 路径；完整性保护的覆盖边界见第 12 节。

#### Acceptance Criteria

- 应满足：本 IP 不承诺抵抗任意物理故障注入、恶意时钟毛刺或篡改后的 scan 路径；完整性保护的覆盖边界见第 12 节。
- 通过系统连接/复位/身份路径审查确认该约束；本 IP 局部仿真不能代替系统证据。

