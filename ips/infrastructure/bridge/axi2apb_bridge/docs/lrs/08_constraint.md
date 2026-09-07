# 约束需求 - AXI-to-APB Bridge (X2P)
# Constraint Requirements - AXI-to-APB Bridge (X2P)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **CONS**：约束需求（协议边界、参数合法性、不支持场景）

---

## 2. 约束需求 / Constraint Requirements

### 2.1 拓扑约束

#### LRS.CONS.X2P.01.001 拓扑固定

<!-- LRS_META
id: LRS.CONS.X2P.01.001
category: CONS
ip: X2P
feature: topology
priority: P0
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. X2P 拓扑固定为 1 AXI Slave → 1 APB Master。
2. X2P 不负责 APB 多 Slave 地址译码及分发。

##### 验证关注点

1. 输出为单一 PSEL。

---

### 2.2 参数合法性

#### LRS.CONS.X2P.02.001 参数合法性

<!-- LRS_META
id: LRS.CONS.X2P.02.001
category: CONS
ip: X2P
feature: parameter_legality
priority: P0
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. AXI_PROFILE ∈ {AXI4, AXI4_LITE}；APB_PROFILE ∈ {APB3, APB4}。
2. READ/WRITE_REQUEST_DEPTH ∈ {1, 2, 4, 8}。
3. AXI_DATA_WIDTH ∈ {32, 64, 128}；APB_DATA_WIDTH ∈ {32, 64}；宽度比必须为合法 Power-of-Two 且 AXI≥APB 或 AXI<APB 均允许。
4. ARB_POLICY ∈ {ROUND_ROBIN, READ_PRIORITY, WRITE_PRIORITY}；ARB_GRANULARITY ∈ {AXI_BEAT, AXI_TRANSACTION}。
5. TIMEOUT_ENABLE ∈ {0, 1}；TIMEOUT_CYCLES ≥ 1。
6. CLOCK_MODE ∈ {SYNC, ASYNC}。
7. AXI4-Lite 下不支持 outstanding>1 语义（按单事务模型处理）。
8. WRAP Burst 只允许 AXI4（AXI4-Lite 不支持 WRAP）。

##### 验证关注点

1. 非法参数组合报错或行为明确。

---

### 2.3 不支持场景

#### LRS.CONS.X2P.03.001 不支持场景

<!-- LRS_META
id: LRS.CONS.X2P.03.001
category: CONS
ip: X2P
feature: unsupported_scenario
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. X2P V1.0 不支持：APB multi-slave decode、APB interconnect、多 APB Master output、AXI3、ACE、CHI、security firewall、power isolation、level shifter、clock generation、interrupt aggregation。

##### 验证关注点

1. 上述场景不承诺支持。

---

*文档版本: v1.0*
*创建日期: 2026-09-03*
*创建者: IP Development Suite - 01-lrs-author*