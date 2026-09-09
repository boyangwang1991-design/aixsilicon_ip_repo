# APB Demux — 性能需求（PERF）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 性能需求 / Performance Requirements

### 1.1 延迟

#### LRS.PERF.APB_DEMUX.01.001 低延迟组合响应

<!-- LRS_META
id: LRS.PERF.APB_DEMUX.01.001
category: PERF
feature: latency
priority: P0
status: active
verification_method:
  - simulation
  - review
END_LRS_META -->

#### Requirement

默认配置（`OUTPUT_REGISTER=0`）下，IP 应采用组合响应路径，transaction 延迟应
仅由下游端口的 wait-state 决定，IP 自身不应引入额外时钟周期。

#### Acceptance Criteria

- 下游 `PREADY=1`（immediate）时，事务在 SETUP 后下一周期完成；
- IP 自身延迟为 0 个额外时钟周期。

---

### 1.2 PPA 目标

#### LRS.PERF.APB_DEMUX.02.001 轻量级互联设计目标

<!-- LRS_META
id: LRS.PERF.APB_DEMUX.02.001
category: PERF
feature: ppa
priority: P1
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

IP 应以轻量级 peripheral interconnect 为设计目标，重点优化：地址 decoder 的
comparator 位宽与逻辑深度、response mux 的树平衡性（避免明显不平衡 mux tree）、
以及大 `NUM_SLAVES` 下请求信号的 fanout。

#### Acceptance Criteria

- 综合/面积报告显示 decoder 与 mux 结构平衡；
- RTL 不人为增加无必要 buffer/register。

---

### 1.3 规模

#### LRS.PERF.APB_DEMUX.03.001 支持规模

<!-- LRS_META
id: LRS.PERF.APB_DEMUX.03.001
category: PERF
feature: scale
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

V1.0 至少应验证 `NUM_SLAVES = 1/2/4/8/16`，建议支持 `NUM_SLAVES <= 32`。RTL
本身不强制设定绝对最大值。

#### Acceptance Criteria

- `NUM_SLAVES` 在 1~16 范围内功能正确；
- 大量 peripherals（32+）建议升级为 Hierarchical APB Interconnect。

---
