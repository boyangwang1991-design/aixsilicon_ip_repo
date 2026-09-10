# AXI Memory Protection Unit — 低功耗需求（LP）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 低功耗需求

#### LRS.LP.AXI_MPU.LOW_POWER.001 低功耗声明

<!-- LRS_META
id: LRS.LP.AXI_MPU.LOW_POWER.001
category: LP
feature: low_power
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

V1.0 不要求专用低功耗特性。寄存器访问（APB4 配置接口）应在无访问时保持静止；
datapath 信号在无事务时不应翻转。

#### Acceptance Criteria

- 无事务时 datapath 无无效翻转；
- 无专用电源域/门控要求（可由 SoC 级低功耗统一管理）。

---

**N/A - 本 IP V1.0 不要求独立低功耗机制**（时钟门控与电源管理由 SoC 级统一处理，
本声明作为人工可审计的覆盖声明）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
