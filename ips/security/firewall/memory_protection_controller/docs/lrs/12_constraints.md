# AXI Memory Protection Unit — 集成约束（CONS）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 集成约束

#### LRS.CONS.AXI_MPU.DEPLOY.001 部署位置

<!-- LRS_META
id: LRS.CONS.AXI_MPU.DEPLOY.001
category: CONS
feature: integration
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
END_LRS_META -->

#### Requirement

推荐部署于受保护 Slave 侧（Master→Interconnect→AXI MPU→Protected Slave），也允许
部署于 Master 侧。V1.0 不依赖特定部署位置。

#### Acceptance Criteria

- 集成文档说明两种部署场景；
- 行为不依赖部署位置。

---

#### LRS.CONS.AXI_MPU.CONFIG_BUS.001 配置总线依赖

<!-- LRS_META
id: LRS.CONS.AXI_MPU.CONFIG_BUS.001
category: CONS
feature: integration
priority: P0
status: active
source_ref:
  - SRC-001
  - SRC-004
applicability:
  expr: "true"
verification_method:
  - review
END_LRS_META -->

#### Requirement

系统必须确保仅 trusted software / trusted master 能访问 MPU configuration
interface（APB4）。MPU 自身提供 Region Lock / Global Lock 作为第二层保护。

#### Acceptance Criteria

- 集成指南明确配置总线安全要求；
- 无系统级访问控制时 MPU 配置可被任意改写（文档明确风险）。

---

#### LRS.CONS.AXI_MPU.PROFILE.001 FULL AXI4 Profile

<!-- LRS_META
id: LRS.CONS.AXI_MPU.PROFILE.001
category: CONS
feature: integration
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
END_LRS_META -->

#### Requirement

Full AXI4 Profile 默认支持 WRAP burst；Generator 可裁剪 WRAP 支持但 INCR/FIXED
必须始终支持。用户手册应说明 Profile 差异。

#### Acceptance Criteria

- 默认配置支持 WRAP；
- 裁剪配置在文档中明确。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
