# APB Demux — 可测性/可观测需求（DFX）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 可测性/可观测需求 / DFX Requirements

### 1.1 协议断言

#### LRS.DFX.APB_DEMUX.01.001 One-hot Select 断言

<!-- LRS_META
id: LRS.DFX.APB_DEMUX.01.001
category: DFX
feature: protocol_assertions
priority: P0
status: active
verification_method:
  - formal
  - assertion
END_LRS_META -->

#### Requirement

IP 应提供协议断言检查 `$onehot0(M_PSEL)`，确保任意时刻下游 `M_PSEL` 为
one-hot 或全零。

#### Acceptance Criteria

- `$onehot0(M_PSEL)` 断言在所有配置下成立。

---

#### LRS.DFX.APB_DEMUX.01.002 Wait-state 期间信号稳定断言

<!-- LRS_META
id: LRS.DFX.APB_DEMUX.01.002
category: DFX
feature: protocol_assertions
priority: P0
status: active
verification_method:
  - formal
  - assertion
END_LRS_META -->

#### Requirement

IP 应提供断言检查：ACCESS phase 且 `PREADY=0` 期间，`PADDR`、`PWRITE`、
`PWDATA`、`PSTRB`、`PPROT` 以及 selected slave 必须保持稳定。

#### Acceptance Criteria

- Wait-state 期间相关信号稳定性断言成立。

---

#### LRS.DFX.APB_DEMUX.01.003 Decode 正确性断言

<!-- LRS_META
id: LRS.DFX.APB_DEMUX.01.003
category: DFX
feature: protocol_assertions
priority: P0
status: active
verification_method:
  - formal
  - assertion
END_LRS_META -->

#### Requirement

IP 应提供断言检查：命中一个地址区域时只能选择对应下游 port；未命中地址时无
下游 `PSEL` 且必须产生合法 error response。

#### Acceptance Criteria

- Decode 正确性断言在所有配置下成立。

---
