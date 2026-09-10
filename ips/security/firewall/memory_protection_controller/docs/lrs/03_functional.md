# AXI Memory Protection Unit — 功能需求（FUNC Part 1：权限模型与 Region）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 权限模型

### 1.1 Default Deny

#### LRS.FUNC.AXI_MPU.DEFAULT_DENY.001 默认拒绝策略

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.DEFAULT_DENY.001
category: FUNC
feature: default_deny
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

IP 应采用 `Default Deny + Explicit Allow` 策略：未匹配任何有效 Region 的访问
默认拒绝，不得允许。Reset 后所有可编程 Region 默认 disabled。

#### Acceptance Criteria

- 无 Region 命中时访问被拒绝；
- Reset 后任意访问（含合法 Region 范围内）均被拒绝，直到软件配置 Region；
- 断言：`No unmatched access may be allowed under DEFAULT_DENY`。

---

#### LRS.FUNC.AXI_MPU.DEFAULT_DENY.002 独立权限维度

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.DEFAULT_DENY.002
category: FUNC
feature: default_deny
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
  - formal
END_LRS_META -->

#### Requirement

权限判断应独立建模以下维度：Address、Master Identity、Security State、
Privilege State、Operation Type。最终权限 `ALLOW = region_match && master_allowed
&& master_security_valid && security_allowed && privilege_allowed &&
operation_allowed`。不得将 Master 与 Security State 直接编码为组合权限矩阵。

#### Acceptance Criteria

- 五个独立维度均可独立导致拒绝；
- 任一维度为假时 `ALLOW=0`。

---

### 1.2 Request Context

#### LRS.FUNC.AXI_MPU.REQ_CONTEXT.001 统一 Request Context

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.REQ_CONTEXT.001
category: FUNC
feature: request_context
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

每个 AXI transaction 应被转换成统一内部 Request Context，至少包含 address、
read_write、axi_id、master_id、secure、privileged、instruction、burst_type、
burst_len、burst_size、burst_start、burst_end。Read 使用 AR 通道信号，Write 使用
AW 通道信号。

#### Acceptance Criteria

- Read 与 Write 均能正确构建 Request Context；
- burst_start/burst_end 正确反映完整 burst 地址范围。

---

### 1.3 Master Identity

#### LRS.FUNC.AXI_MPU.MASTER_ID.001 Master Identity 来源

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.MASTER_ID.001
category: FUNC
feature: master_identity
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - review
END_LRS_META -->

#### Requirement

AXI `AxID` 默认不得作为 Master Identity。IP 应提供独立 Master Context
（`MASTER_ID`）或通过系统定义的 AXI USER sideband 传递。Master ID 位宽由
`MASTER_ID_WIDTH` 决定。

#### Acceptance Criteria

- 权限判定使用 `request.master_id` 而非 `AxID`；
- 配置可通过 AXI USER sideband 或独立输入指定 Master ID。

---

### 1.4 Master Security Attribution

#### LRS.FUNC.AXI_MPU.MASTER_SEC_ATTR.001 Master 安全归属

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.MASTER_SEC_ATTR.001
category: FUNC
feature: master_security_attr
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_master_attr == true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

IP 应为每个 Master 维护 `SECURE_CAPABLE` 与 `NONSECURE_CAPABLE` 属性。若
`request.secure == 1` 而 `MASTER_ATTR[master_id].SECURE_CAPABLE == 0`，访问必须
拒绝。Master Security Attribution 与 Region Security Permission 是两个独立检查
阶段。

#### Acceptance Criteria

- Secure 请求被非 Secure-capable Master 发出时拒绝；
- Non-secure 请求被非 Non-secure-capable Master 发出时拒绝；
- 两阶段检查独立可验证。

---

## 2. Region 模型

### 2.1 Region 定义

#### LRS.FUNC.AXI_MPU.REGION.001 Region 配置字段

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.REGION.001
category: FUNC
feature: region_model
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - review
END_LRS_META -->

#### Requirement

每个 Protection Region 应至少包含：`REGION_ENABLE`、`REGION_BASE`、
`REGION_LIMIT`、`MASTER_MASK`、`SECURE_ALLOW`、`NONSECURE_ALLOW`、
`PRIVILEGED_ALLOW`、`UNPRIVILEGED_ALLOW`、`READ_ALLOW`、`WRITE_ALLOW`、
`EXECUTE_ALLOW`、`REGION_LOCK`。

#### Acceptance Criteria

- 每个 Region 可通过 APB4 完整配置上述字段；
- 字段间相互独立。

---

#### LRS.FUNC.AXI_MPU.REGION.002 BASE+LIMIT 地址模型

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.REGION.002
category: FUNC
feature: region_model
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

Region 地址模型应采用 `BASE + LIMIT` 模式，Region match 条件为
`REGION_BASE <= ADDRESS <= REGION_LIMIT`。Region 必须满足 `BASE <= LIMIT`；
非法 Region 配置（`BASE > LIMIT`）不得导致未定义硬件行为，应视为 Region disabled。

#### Acceptance Criteria

- 地址在 `[BASE, LIMIT]` 内命中；
- `BASE > LIMIT` 时 Region 视为 disabled（不命中）。

---

### 2.2 Region Match 与 Priority

#### LRS.FUNC.AXI_MPU.REGION.003 Region Match 条件

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.REGION.003
category: FUNC
feature: region_match
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

对 Region `i`，`region_match[i] = REGION_ENABLE[i] && address >= REGION_BASE[i]
&& address <= REGION_LIMIT[i]`。所有 Region 的匹配应可并行计算。

#### Acceptance Criteria

- 使能与地址范围均为真时命中；
- 边界地址（`BASE`/`LIMIT` 本身）命中。

---

#### LRS.FUNC.AXI_MPU.REGION.004 固定优先级

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.REGION.004
category: FUNC
feature: region_priority
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

允许 Region overlap。Region 优先级固定为 `Lowest Region Index Wins`：若一个
transaction 同时命中多个 Region，`selected_region = 最小索引命中 Region`。该规则
必须确定且不可依赖综合实现。

#### Acceptance Criteria

- overlap 时命中最小索引 Region；
- 任意综合/实现下优先级结果一致。

---

### 2.3 Burst Protection

#### LRS.FUNC.AXI_MPU.BURST.001 完整 burst 范围检查

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.BURST.001
category: FUNC
feature: burst_protection
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

Burst transaction 必须同时满足完整 burst 地址范围位于 Region 内，即
`burst_start >= REGION_BASE && burst_end <= REGION_LIMIT`。不得只判断
`ARADDR/AWADDR` 首地址。

#### Acceptance Criteria

- 首地址在 Region 内但 burst 跨越边界的访问被拒绝；
- 完整 burst 在 Region 内的访问允许。

---

#### LRS.FUNC.AXI_MPU.BURST.002 跨边界整事务拒绝

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.BURST.002
category: FUNC
feature: burst_protection
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

若 burst 跨越 Region 边界，默认应 `DENY WHOLE TRANSACTION`。不得允许
"部分 beat 合法、部分 beat 非法"的 transaction 进入下游。IP 应支持 INCR、FIXED、
WRAP 三种 burst 的地址范围计算。

#### Acceptance Criteria

- 跨边界 burst 整体拒绝（无 beat 进入下游）；
- INCR/FIXED/WRAP 均正确计算地址范围并检查。

---

## 3. 权限判定

### 3.1 Master 权限

#### LRS.FUNC.AXI_MPU.PERM_MASTER.001 MASTER_MASK 判定

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.PERM_MASTER.001
category: FUNC
feature: master_permission
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

每个 Region 应包含 `MASTER_MASK[MASTER_NUM-1:0]`。
`master_allowed = MASTER_MASK[request.master_id]`。非法 Master ID
（`master_id >= MASTER_NUM`）必须被拒绝。

#### Acceptance Criteria

- `MASTER_MASK` 对应位为 1 时允许；
- 非法 Master ID 拒绝。

---

### 3.2 Security / Privilege / Operation

#### LRS.FUNC.AXI_MPU.PERM_SECURITY.001 Security 权限

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.PERM_SECURITY.001
category: FUNC
feature: security_permission
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

Region 应独立支持 `SECURE_ALLOW` 与 `NONSECURE_ALLOW`，可表达 Secure-only、
Non-secure-only、Both、Neither 四种策略。Region Security Permission 不负责判断
Master 是否具有声明该 Security State 的资格（该判断由 Master Security
Attribution 完成）。

#### Acceptance Criteria

- Secure 请求命中 `SECURE_ALLOW=0` Region 时拒绝；
- Non-secure 请求命中 `NONSECURE_ALLOW=0` Region 时拒绝；
- 四种策略组合均正确。

---

#### LRS.FUNC.AXI_MPU.PERM_PRIVILEGE.001 Privilege 权限

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.PERM_PRIVILEGE.001
category: FUNC
feature: privilege_permission
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

使用 `AxPROT[0]` 判定 Privilege。Region 应独立提供 `PRIVILEGED_ALLOW` 与
`UNPRIVILEGED_ALLOW`，可表达 Privileged-only、Unprivileged-only、Both、None。

#### Acceptance Criteria

- Privileged 请求命中 `PRIVILEGED_ALLOW=0` Region 时拒绝；
- Unprivileged 请求命中 `UNPRIVILEGED_ALLOW=0` Region 时拒绝。

---

#### LRS.FUNC.AXI_MPU.PERM_OP.001 R/W/X 操作权限

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.PERM_OP.001
category: FUNC
feature: operation_permission
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

Region 应提供 `READ_ALLOW`、`WRITE_ALLOW`、`EXECUTE_ALLOW`。Read transaction 应
要求 `READ_ALLOW`；Write transaction 应要求 `WRITE_ALLOW`；Instruction access
应要求 `READ_ALLOW && EXECUTE_ALLOW`。Execute 权限属于 system-level secondary
protection，不替代 CPU MMU/MPU 的 architectural execute permission。

#### Acceptance Criteria

- Write 访问只读 Region 时拒绝；
- Instruction 访问 NX（`EXECUTE_ALLOW=0`）Region 时拒绝；
- Data read 不要求 `EXECUTE_ALLOW`。

---

### 3.3 权限判定与 deny_reason

#### LRS.FUNC.AXI_MPU.PERM_DECISION.001 完整权限判定

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.PERM_DECISION.001
category: FUNC
feature: permission_decision
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

完整权限判定应为：`selected_region = priority_encode(region_match)`；若
`no region match` 则 `DENY`；否则
`ALLOW = master_allowed && master_security_valid && security_allowed &&
privilege_allowed && operation_allowed`。

#### Acceptance Criteria

- 判定逻辑与需求公式一致；
- 每种拒绝条件有明确原因。

---

#### LRS.FUNC.AXI_MPU.PERM_DECISION.002 deny_reason 输出

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.PERM_DECISION.002
category: FUNC
feature: permission_decision
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_violation_log == true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

IP 应产生内部 `deny_reason`，至少包括：`NO_REGION`、`MASTER_DENY`、
`MASTER_SECURITY_DENY`、`SECURITY_DENY`、`PRIVILEGE_DENY`、`READ_DENY`、
`WRITE_DENY`、`EXECUTE_DENY`、`BURST_BOUNDARY_DENY`、`INVALID_CONTEXT`。

#### Acceptance Criteria

- 每种拒绝场景产生对应的 `deny_reason` 编码。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
