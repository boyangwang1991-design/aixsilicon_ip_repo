# AXI Memory Protection Unit — 性能需求（PERF）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 性能需求

### 1.1 吞吐

#### LRS.PERF.AXI_MPU.THROUGHPUT.001 每周期地址请求吞吐

<!-- LRS_META
id: LRS.PERF.AXI_MPU.THROUGHPUT.001
category: PERF
feature: throughput
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

Allow-path throughput 设计目标应支持 >= 1 address transaction / cycle。Permission
check 不应固定引入 bubble；pipeline latency 可参数化；Read/Write path 独立。

#### Acceptance Criteria

- 连续合法地址请求下吞吐达到 1 request/cycle；
- 无固定 permission-check bubble。

---

#### LRS.PERF.AXI_MPU.THROUGHPUT.002 Pipeline 延迟

<!-- LRS_META
id: LRS.PERF.AXI_MPU.THROUGHPUT.002
category: PERF
feature: throughput
priority: P1
status: active
source_ref:
  - SRC-001
applicability:
  expr: "pipeline == 1"
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

`PIPELINE=1` 时 permission engine 应增加 1 拍延迟但不降低吞吐；`PIPELINE=0` 时
为组合判定。不要求 V1.0 固定 zero-latency。

#### Acceptance Criteria

- 1-stage pipeline 下吞吐保持 1 request/cycle；
- 延迟符合配置。

---

### 1.2 Outstanding

#### LRS.PERF.AXI_MPU.OUTSTANDING.001 Outstanding 容量

<!-- LRS_META
id: LRS.PERF.AXI_MPU.OUTSTANDING.001
category: PERF
feature: outstanding_capacity
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

Read/Write outstanding 容量应等于配置值（默认 8），支持背压但不得破坏 AXI 握手
语义。多 outstanding 场景下不得因 permission check 强制降级为单 outstanding。

#### Acceptance Criteria

- 队列深度达到配置值时产生背压；
- 背压时无协议违约。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
