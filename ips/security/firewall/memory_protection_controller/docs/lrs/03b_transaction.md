# AXI Memory Protection Unit — 功能需求（FUNC Part 2：事务处理 / Violation / Lock）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 4. Transaction 处理

### 4.1 Read 处理

#### LRS.FUNC.AXI_MPU.READ.001 合法 Read 转发

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.READ.001
category: FUNC
feature: read_handling
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

合法 Read：AR 通过 Protection Check 后应转发至下游，下游 R 响应返回上游。

#### Acceptance Criteria

- 合法 AR 出现在 `M_AXI_AR`；
- 下游 R 数据/响应完整返回。

---

#### LRS.FUNC.AXI_MPU.READ.002 非法 Read 本地 DECERR

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.READ.002
category: FUNC
feature: read_handling
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

非法 Read：不得发送 AR 至下游。IP 应在本地完成上游 transaction，返回
`RRESP=DECERR`。非法 burst read 应按 AXI transaction 语义返回对应 beat 数量，
并正确产生 `RID/RVALID/RRESP/RLAST`；所有非法 read beat 的 `RRESP=DECERR`，
`RDATA` 固定为 0。

#### Acceptance Criteria

- 非法 AR 不出现在 `M_AXI_AR`；
- 非法 burst read 返回全部 beat 且每 beat `RRESP=DECERR`、`RDATA=0`；
- `RLAST` 与 `RVALID` 时序正确。

---

### 4.2 Write 处理

#### LRS.FUNC.AXI_MPU.WRITE.001 合法 Write 转发

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.WRITE.001
category: FUNC
feature: write_handling
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

合法 Write：AW 通过 Protection Check 后应转发至下游，W beats 转发下游，
下游 B 响应返回上游。Write path 必须考虑 AXI AW/W channel 解耦。

#### Acceptance Criteria

- 合法 AW/W 出现在 `M_AXI`；
- 下游 B 响应完整返回。

---

#### LRS.FUNC.AXI_MPU.WRITE.002 非法 Write 本地 DECERR

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.WRITE.002
category: FUNC
feature: write_handling
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

非法 Write：不得发送 AW 至下游，应消费对应 W beats、丢弃 `WDATA`，并在本地生成
`BRESP=DECERR`。必须确保非法 Write 不造成 W channel deadlock、后续 transaction
串扰、AW/W ownership 丢失或下游部分写入。

#### Acceptance Criteria

- 非法 AW 不出现在 `M_AXI_AW`；
- 非法 Write 返回 `BRESP=DECERR`；
- 断言：`Denied W data shall never modify downstream state`；
- 非法 Write 后后续事务正常完成。

---

### 4.3 Write Decision Queue

#### LRS.FUNC.AXI_MPU.WRITE_QUEUE.001 Write Decision Queue

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.WRITE_QUEUE.001
category: FUNC
feature: write_queue
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

为正确支持 multiple outstanding write，IP 应维护 Write Decision Queue。每个 Entry
至少记录 `AWID`、`AWLEN`、`ALLOW/DENY`、`selected_region`；可按体系需要记录
`deny_reason`、`master_id`、`security_state`。队列必须保证 AW transaction 与后续
W beats 正确关联。

#### Acceptance Criteria

- 多 outstanding write 下 AW 决策与 W beats 正确配对；
- 队列满时背压且不破坏 AXI 握手语义。

---

### 4.4 Multiple Outstanding 与 Ordering

#### LRS.FUNC.AXI_MPU.OUTSTANDING.001 多 Outstanding 支持

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.OUTSTANDING.001
category: FUNC
feature: multiple_outstanding
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

V1.0 应支持多个 outstanding transaction。MPU 不得因为 permission check 强制 AXI
降级为单 outstanding。Read/Write outstanding 深度由 `READ_OUTSTANDING` /
`WRITE_OUTSTANDING` 决定。

#### Acceptance Criteria

- 在许可范围内可同时存在多个 outstanding read/write；
- 队列深度未满时背压不生效。

---

#### LRS.FUNC.AXI_MPU.ORDERING.001 AXI Ordering 保持

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.ORDERING.001
category: FUNC
feature: ordering
priority: P0
status: active
source_ref:
  - SRC-001
  - SRC-002
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 必须遵守 AXI ordering requirement。对于合法 transaction，不得改变原有 AXI
ordering semantics；对于非法 transaction，本地 response 仍必须满足对应 ID 的
ordering requirement。

#### Acceptance Criteria

- 合法事务保持原有 ordering；
- 非法事务本地响应满足 ordering（不提前/不重排破坏）。

---

### 4.5 Error Response

#### LRS.FUNC.AXI_MPU.ERR_RESP.001 DECERR 响应

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.ERR_RESP.001
category: FUNC
feature: error_response
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

Protection violation 默认响应应为 `DECERR`（`RRESP=DECERR` / `BRESP=DECERR`）。
不得因为权限拒绝而永久拉低 READY，也不得造成 bus hang。

#### Acceptance Criteria

- violation 时本地返回 `DECERR`；
- 拒绝后握手可继续（无永久 READY 拉低）；
- 断言：`Every accepted denied transaction shall eventually receive local error
  response`。

---

## 5. Violation 与中断

### 5.1 Violation Logging

#### LRS.FUNC.AXI_MPU.VIOLATION.001 Violation 捕获字段

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.VIOLATION.001
category: FUNC
feature: violation_logging
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_violation_log == true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

IP 应支持 violation capture，至少包含：`VIOL_VALID`、`VIOL_ADDR`、
`VIOL_MASTER_ID`、`VIOL_AXID`、`VIOL_READ`、`VIOL_WRITE`、`VIOL_INSTRUCTION`、
`VIOL_SECURE`、`VIOL_PRIVILEGED`、`VIOL_REGION_ID`、`VIOL_REASON`。可选
`VIOL_COUNT`。

#### Acceptance Criteria

- 每次 violation 正确记录上述字段；
- 字段可经 APB4 读取。

---

#### LRS.FUNC.AXI_MPU.VIOLATION.002 FIRST_ERROR_STICKY 捕获策略

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.VIOLATION.002
category: FUNC
feature: violation_logging
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_violation_log == true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

V1.0 默认应采用 `FIRST_ERROR_STICKY`：发生第一次错误后 `VIOL_VALID=1`，后续错误
不得覆盖首个错误信息，直到软件显式清除。Generator 可选支持 `LAST_ERROR`，但不作为
V1.0 必需配置。

#### Acceptance Criteria

- 首个错误信息被 sticky 捕获；
- 后续错误不覆盖首个错误；
- 软件清除后可捕获新错误。

---

#### LRS.FUNC.AXI_MPU.VIOLATION.003 Violation Counter

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.VIOLATION.003
category: FUNC
feature: violation_counter
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

IP 应支持 `VIOL_COUNT` 计数器：每次 protection violation 计数加一，支持 saturation
（`MAX -> MAX`）而不是 wrap-around。

#### Acceptance Criteria

- violation 触发计数递增；
- 达到最大值后保持（饱和）。

---

### 5.2 Interrupt

#### LRS.FUNC.AXI_MPU.IRQ.001 Violation 中断

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.IRQ.001
category: FUNC
feature: violation_irq
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_irq == true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

当 `violation interrupt enable && protection violation` 时 IRQ 应置位。建议采用
sticky interrupt，由软件 W1C 清除。

#### Acceptance Criteria

- 使能后 violation 触发 IRQ；
- W1C 清除后 IRQ 释放（无新 violation）；
- 未使能时 IRQ 不触发。

---

## 6. 配置保护

### 6.1 Region Lock

#### LRS.FUNC.AXI_MPU.REGION_LOCK.001 Region Lock

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.REGION_LOCK.001
category: FUNC
feature: region_lock
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

每个 Region 应支持 `REGION_LOCK`。置位后对应 Region 的 `BASE/LIMIT/ATTR/
MASTER_MASK` 均不得再修改。推荐语义：`write 0 -> no effect`，`write 1 -> lock`。
Lock 仅通过 reset 清除。

#### Acceptance Criteria

- Lock 置位后 Region 配置写操作被忽略；
- Lock 仅 reset 清除；
- 断言：`Locked region configuration shall remain stable until reset`。

---

### 6.2 Global Lock

#### LRS.FUNC.AXI_MPU.GLOBAL_LOCK.001 Global Lock

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.GLOBAL_LOCK.001
category: FUNC
feature: global_lock
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 应提供 `GLOBAL_LOCK`。置位后所有 protection configuration frozen（Region
Configuration、Master Attribution、Global Protection Policy）。Violation status /
interrupt clear 等运行态寄存器仍允许软件访问。`GLOBAL_LOCK` 语义为 `0 -> 1`
allowed，`1 -> 0` prohibited，仅 reset 清除。

#### Acceptance Criteria

- Global Lock 置位后保护配置写被忽略；
- 运行态（violation status/IRQ clear）仍可访问；
- 断言：`GLOBAL_LOCK cannot transition 1 -> 0 except reset`。

---

## 7. Reset 与 Boot

### 7.1 Reset Behavior

#### LRS.FUNC.AXI_MPU.RESET.001 Reset 行为

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.RESET.001
category: FUNC
feature: reset_behavior
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

Reset 后必须：所有 Region disabled、default policy = DENY、locks cleared、
violation status cleared、interrupt cleared。Reset 后 AXI protected datapath 默认
deny all protected access，直到 trusted software 完成 MPU 初始化。

#### Acceptance Criteria

- Reset 后所有 Region disabled；
- Reset 后 locks 清除、violation 状态清除；
- Reset 后默认拒绝。

---

#### LRS.FUNC.AXI_MPU.BOOT_BYPASS.001 可选 Boot Bypass

<!-- LRS_META
id: LRS.FUNC.AXI_MPU.BOOT_BYPASS.001
category: FUNC
feature: boot_bypass
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "boot_bypass == true"
verification_method:
  - review
END_LRS_META -->

#### Requirement

Generator 可提供 `BOOT_BYPASS`，但 `BOOT_BYPASS=false` 应为默认配置。若启用，
必须有明确、不可由 non-secure software 控制的退出机制。V1.0 不推荐默认启用。

#### Acceptance Criteria

- 默认 `BOOT_BYPASS=false`；
- 启用时有非 non-secure 可控制的退出机制。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
