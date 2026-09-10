# AXI Memory Protection Unit — 功能安全需求（SAFE）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 功能安全需求

#### LRS.SAFE.AXI_MPU.SAFETY.001 功能安全声明

<!-- LRS_META
id: LRS.SAFE.AXI_MPU.SAFETY.001
category: SAFE
feature: functional_safety
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

MPU V1.0 baseline 不要求 ISO 26262 功能安全机制。若用于功能安全场景，可在未来
Profile 增加配置寄存器 parity、Region table parity、lockstep checker、violation
escalation、fault injection、safety interrupt。

#### Acceptance Criteria

- V1.0 不引入上述机制（作为范围声明）；
- 未来 Profile 扩展不破坏 V1.0 软件接口。

---

**N/A - 本 IP V1.0 baseline 不要求功能安全机制**（如用于功能安全场景需走独立
Profile 扩展，本声明作为人工可审计的覆盖声明）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
