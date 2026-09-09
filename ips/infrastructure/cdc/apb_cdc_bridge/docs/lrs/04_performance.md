# APB CDC Bridge — 性能需求（PERF）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 性能需求 / Performance Requirements

### 1.1 延迟模型

#### LRS.PERF.APB_CDC_BRIDGE.01.001 事务延迟模型

<!-- LRS_META
id: LRS.PERF.APB_CDC_BRIDGE.01.001
category: PERF
feature: latency_model
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 总 APB transaction latency 由 `source capture + request CDC + destination SETUP + destination ACCESS/wait + response CDC + source completion` 组成。
2. V1.0 应避免：unnecessary intermediate FIFO、duplicate payload register stages、redundant synchronizer levels、extra destination FSM state。

##### 验证关注点

1. 记录平均/最坏事务延迟。
2. 快→慢与慢→快延迟差异合理。

---

#### LRS.PERF.APB_CDC_BRIDGE.01.002 同步器级数与延迟

<!-- LRS_META
id: LRS.PERF.APB_CDC_BRIDGE.01.002
category: PERF
feature: latency_model
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `SYNC_STAGES = 2` 为默认推荐；`SYNC_STAGES = 3` 增加 MTBF 但增加延迟与面积。
2. 慢→快模式应优先减少 synchronizer chain latency、extra buffering、unnecessary FSM states。

##### 验证关注点

1. SYNC_STAGES=2 vs 3 延迟对比。

---

## 2. 资源需求 / Resource Requirements

### 2.1 资源缩放

#### LRS.PERF.APB_CDC_BRIDGE.02.001 存储随位宽线性增长

<!-- LRS_META
id: LRS.PERF.APB_CDC_BRIDGE.02.001
category: PERF
feature: resource_scaling
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. `DATA_WIDTH` 增加 → payload storage area 线性增长；`ADDR_WIDTH` 增加 → request storage area 线性增长。
2. `SYNC_STAGES` 增加 → synchronizer FF 线性增长。
3. HANDSHAKE 实现应显著低于 full async FIFO 面积。

##### 验证关注点

1. 综合面积随参数缩放符合预期。
2. HANDSHAKE vs FIFO 面积对比。

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
