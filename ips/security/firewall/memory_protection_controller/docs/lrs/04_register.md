# AXI Memory Protection Unit — 寄存器需求（REG）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 寄存器概述

AXI MPU 通过 APB4 配置接口提供软件可见寄存器。寄存器模型采用
`register_model: required`。寄存器结构（offset/field/bit）由 `regs/*.rdl`
（SystemRDL）定义；本节只描述**软件可见能力需求**（LRS 职责），不画 offset/bit 表。

## 2. 寄存器能力需求

### 2.1 全局控制

#### LRS.REG.AXI_MPU.GLOBAL.001 全局控制寄存器

<!-- LRS_META
id: LRS.REG.AXI_MPU.GLOBAL.001
category: REG
feature: global_regs
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

IP 应提供全局控制寄存器，包含全局保护使能、Global Lock 状态等能力（
`GLOBAL_CTRL`/`GLOBAL_STATUS`/`GLOBAL_LOCK` 语义）。

#### Acceptance Criteria

- 全局控制/状态寄存器可正确读写；
- Global Lock 置位后保护配置冻结。

---

### 2.2 中断控制

#### LRS.REG.AXI_MPU.IRQ.001 中断控制寄存器

<!-- LRS_META
id: LRS.REG.AXI_MPU.IRQ.001
category: REG
feature: irq_regs
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_irq == true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

IP 应提供中断使能、中断状态与中断清除寄存器（`IRQ_ENABLE`/`IRQ_STATUS`/
`IRQ_CLEAR`）。中断状态应 sticky，由软件 W1C 清除。

#### Acceptance Criteria

- 中断使能寄存器可读写；
- 中断状态 sticky 且 W1C 清除正确。

---

### 2.3 Violation 状态

#### LRS.REG.AXI_MPU.VIOLATION.001 Violation 状态寄存器

<!-- LRS_META
id: LRS.REG.AXI_MPU.VIOLATION.001
category: REG
feature: violation_regs
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

IP 应提供 Violation 状态寄存器组，至少包含 `VIOL_STATUS`、`VIOL_ADDR_LO/HI`、
`VIOL_INFO0/INFO1`（master_id/axi_id/读写/指令/secure/privileged/region_id/
reason）与可选的 `VIOL_COUNT`。

#### Acceptance Criteria

- violation 后状态寄存器正确反映首错信息；
- W1C/sticky 清除行为正确。

---

### 2.4 Master Attribute

#### LRS.REG.AXI_MPU.MASTER_ATTR.001 Master Attribute 寄存器

<!-- LRS_META
id: LRS.REG.AXI_MPU.MASTER_ATTR.001
category: REG
feature: master_attr_regs
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "has_master_attr == true"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

IP 应为每个 Master 提供 `MASTER_ATTR` 寄存器，包含 `SECURE_CAPABLE` 与
`NONSECURE_CAPABLE` 字段。未来版本可扩展 TRUST_LEVEL/DOMAIN/VMID 等，V1.0 不
要求实现。

#### Acceptance Criteria

- 每个 Master 的 SECURE/NONSECURE_CAPABLE 可配置；
- Global Lock 后不可改写。

---

### 2.5 Region 配置

#### LRS.REG.AXI_MPU.REGION.001 Region 配置寄存器

<!-- LRS_META
id: LRS.REG.AXI_MPU.REGION.001
category: REG
feature: region_regs
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

每个 Region 应提供配置寄存器：`REGIONx_BASE_LO/HI`、`REGIONx_LIMIT_LO/HI`、
`REGIONx_MASTER_MASK`、`REGIONx_PERMISSION`、`REGIONx_CONTROL`（含 ENABLE 与
LOCK）。字段必须保持独立，不得实现为 Master×Security 笛卡尔积式 permission
table。

#### Acceptance Criteria

- Region 字段独立可配置；
- 独立权限维度（SECURE/NONSECURE/PRIV/UNPRIV/R/W/X）保持独立字段；
- Region Lock 置位后配置不可改写。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
