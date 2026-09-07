# 性能需求 - AXI-to-APB Bridge (X2P)
# Performance Requirements - AXI-to-APB Bridge (X2P)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **PERF**：性能需求（吞吐、延迟、无 idle bubble、解耦能力）
- **RSC**：资源需求（参数化裁剪）

---

## 2. 性能需求 / Performance Requirements

### 2.1 吞吐与解耦 / Throughput and Decoupling

#### LRS.PERF.X2P.01.001 无多余 idle

<!-- LRS_META
id: LRS.PERF.X2P.01.001
category: PERF
ip: X2P
feature: performance
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 在 PREADY 始终为 1 时，X2P 不得人为插入不必要的 APB idle cycle。
2. 若存在下一 request，APB Engine 应实现合法的 back-to-back transfer（SETUP0-ACCESS0-SETUP1-ACCESS1）。

##### 验证关注点

1. PREADY=1 时 APB 无额外 bubble。

---

#### LRS.PERF.X2P.01.002 请求缓冲解耦

<!-- LRS_META
id: LRS.PERF.X2P.01.002
category: PERF
ip: X2P
feature: performance
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. Request Buffer 应允许 AXI request acceptance 与 APB execution decouple。
2. ASYNC Profile 下，AXI 不得因为 APB clock 低频而要求 clock-level synchronous handshake。

##### 验证关注点

1. Buffer 解耦能力。
2. ASYNC 无关频率假设。

---

### 2.2 资源裁剪 / Resource Sizing

#### LRS.PERF.X2P.02.001 参数裁剪

<!-- LRS_META
id: LRS.PERF.X2P.02.001
category: PERF
ip: X2P
feature: resource
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 参数关闭的功能应尽可能被综合裁剪（PPA 需求）。
2. AXI4-Lite 小配置不应保留 AXI ID logic、Burst engine、WRAP engine、不必要的 Outstanding tracking。
3. SYNC Mode 不应保留 ASYNC CDC datapath。
4. 同宽配置不应保留 Width Split / Merge datapath。

##### 验证关注点

1. 报告综合面积/逻辑随参数裁剪变化。

---

### 2.3 Outstanding 能力

#### LRS.PERF.X2P.03.001 支持宽度组合

<!-- LRS_META
id: LRS.PERF.X2P.03.001
category: PERF
ip: X2P
feature: performance
priority: P0
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 至少支持 AXI_DATA_WIDTH = 32/64/128，APB_DATA_WIDTH = 32/64。
2. 支持合法的 Power-of-Two width ratio（含相等、宽到窄、窄到宽）。

##### 验证关注点

1. 宽度矩阵覆盖。

---

*文档版本: v1.0*
*创建日期: 2026-09-03*
*创建者: IP Development Suite - 01-lrs-author*