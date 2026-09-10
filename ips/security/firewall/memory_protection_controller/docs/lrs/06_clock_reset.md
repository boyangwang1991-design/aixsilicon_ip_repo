# AXI Memory Protection Unit — 时钟与复位需求（RESET）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 时钟需求

#### LRS.RESET.AXI_MPU.CLOCK.001 单时钟域

<!-- LRS_META
id: LRS.RESET.AXI_MPU.CLOCK.001
category: RESET
feature: clock
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

AXI MPU 应在单一主时钟 `CLK` 下工作。AXI datapath 与 APB4 配置接口默认位于同一
时钟域（V1.0 不引入异步 CDC）。

#### Acceptance Criteria

- 所有时序逻辑使用 `CLK`；
- 无未声明跨时钟路径。

---

## 2. 复位需求

#### LRS.RESET.AXI_MPU.RESET.001 异步复位

<!-- LRS_META
id: LRS.RESET.AXI_MPU.RESET.001
category: RESET
feature: reset
priority: P0
status: active
source_ref:
  - SRC-001
applicability:
  expr: "true"
verification_method:
  - simulation
  - static
END_LRS_META -->

#### Requirement

IP 应支持异步复位（`RST_N` 低有效）。Reset 后所有 Region disabled、默认策略
DENY、Locks 清除、Violation 状态与中断清除。

#### Acceptance Criteria

- 异步复位置位时所有寄存器回到复位值；
- 复位释放后默认拒绝策略生效；
- Reset 期间与之后无非法行为。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
