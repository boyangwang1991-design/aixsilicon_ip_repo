# APB Demux — 时钟/复位需求（RESET）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 时钟/复位需求 / Clock & Reset Requirements

### 1.1 时钟

#### LRS.RESET.APB_DEMUX.01.001 单时钟域

<!-- LRS_META
id: LRS.RESET.APB_DEMUX.01.001
category: RESET
feature: clock
priority: P0
status: active
verification_method:
  - review
END_LRS_META -->

#### Requirement

IP 应使用单一 `PCLK` 时钟域，所有内部逻辑（地址译码、路由、响应 mux、可选
timeout/response register）均在同一时钟域内工作。

#### Acceptance Criteria

- 无跨时钟域逻辑，无 CDC 路径。

---

### 1.2 复位

#### LRS.RESET.APB_DEMUX.02.001 PRESETn 复位

<!-- LRS_META
id: LRS.RESET.APB_DEMUX.02.001
category: RESET
feature: reset
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

IP 应使用 `PRESETn`（低有效）作为复位输入。

#### Acceptance Criteria

- 复位释放后 IP 进入确定状态。

---

#### LRS.RESET.APB_DEMUX.02.002 复位期间无有效事务

<!-- LRS_META
id: LRS.RESET.APB_DEMUX.02.002
category: RESET
feature: reset
priority: P0
status: active
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

Reset 期间不得产生有效 downstream transaction，所有 `M_PSEL[i]` 应保持无效。

#### Acceptance Criteria

- 复位期间所有下游 `M_PSEL[i]=0`；
- 复位期间无 `M_PENABLE=1` 与 `M_PSEL=1` 组合。

---

#### LRS.RESET.APB_DEMUX.02.003 内部状态确定复位

<!-- LRS_META
id: LRS.RESET.APB_DEMUX.02.003
category: RESET
feature: reset
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

若实现 timeout counter、response register 或 selection register，这些内部状态
必须进入确定的 reset state。

#### Acceptance Criteria

- 复位后 timeout counter 清零、response register 无效、selection 无效。

---
