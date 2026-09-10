# AXI Memory Protection Unit — DFX / 可观测性需求（DFX）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. DFX 需求

### 1.1 可观测性

#### LRS.DFX.AXI_MPU.OBSERVABILITY.001 Violation 可观测性

<!-- LRS_META
id: LRS.DFX.AXI_MPU.OBSERVABILITY.001
category: DFX
feature: observability
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

Violation 状态应通过软件可见寄存器可观测（`VIOL_STATUS`/`VIOL_ADDR`/
`VIOL_INFO*`/`VIOL_COUNT`），用于系统诊断与安全审计。

#### Acceptance Criteria

- violation 后软件可读取完整错误信息；
- 状态清除/计数行为符合定义。

---

### 1.2 复位可观测

#### LRS.DFX.AXI_MPU.DEBUG.001 复位与状态可观测

<!-- LRS_META
id: LRS.DFX.AXI_MPU.DEBUG.001
category: DFX
feature: observability
priority: P2
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
END_LRS_META -->

#### Requirement

软件应能读取全局状态寄存器确认 MPU 处于默认拒绝/已配置状态，便于诊断初始化
流程。

#### Acceptance Criteria

- 全局状态寄存器反映保护配置生效状态。

---

**N/A - 本 IP 不要求 scan/debug 接口集成**（复位后软件可观测性即可满足 DFX
声明，本声明作为人工可审计的覆盖声明）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
