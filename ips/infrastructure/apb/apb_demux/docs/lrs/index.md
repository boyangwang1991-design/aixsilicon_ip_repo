# APB Demux — LRS 主索引

> **IP Name**: `apb_demux`
> **VLNV**: `aixsilicon:ip:apb_demux:1.0.0`
> **Version**: 1.0.0
> **Status**: Draft / G0 Candidate
> **协议**: AMBA APB3 / APB4
> **拓扑**: 1 APB Upstream × N APB Downstream（1→N APB Router）
> **时钟模型**: 单时钟域（同源同步）

---

## 1. 文档控制

| 项目 | 内容 |
|------|------|
| 文档 ID | `aixsilicon:ip:apb_demux:req` |
| 拥有者 | rtl-team |
| 创建日期 | 2026-09-09 |
| 当前版本 | v1.0 |
| 评审状态 | Draft / G0 Candidate |

## 2. 修订记录

| 版本 | 日期 | 修订说明 |
|------|------|----------|
| v0.1 | 2026-09-09 | 从 `APB2NAPB_BRIDGE.MD` 需求规格归并整理为 APB Demux（INF-005）LRS 文档；原 INF-007 `apb_interconnect` 需求并入本 IP |

## 3. 需求编号规范

```text
LRS.<CATEGORY>.<IP>.<GROUP>.<INDEX>
```

| 段 | 取值 |
|----|------|
| CATEGORY | INTF / FUNC / CFG / PERF / RESET / SAFE / SEC / LP / DFX / CONS |
| IP | `APB_DEMUX` |
| GROUP | 01 / 02 / ...（按功能分组） |
| INDEX | 001 / 002 / ...（组内序号） |

## 4. 文档结构

| 文件 | 内容 | 状态 |
|------|------|------|
| [`00_overview.md`](00_overview.md) | IP 概述、配置参数、架构框图 | ✔ 有内容 |
| [`01_configuration.md`](01_configuration.md) | 配置需求（CFG） | ✔ 有需求 |
| [`02_interface.md`](02_interface.md) | 接口需求（INTF） | ✔ 有需求 |
| [`03_functional.md`](03_functional.md) | 功能需求（FUNC） | ✔ 有需求 |
| [`04_performance.md`](04_performance.md) | 性能需求（PERF） | ✔ 有需求 |
| [`05_clock_reset.md`](05_clock_reset.md) | 时钟/复位需求（RESET） | ✔ 有需求 |
| [`06_low_power.md`](06_low_power.md) | 低功耗需求（LP） | **N/A** - 无专用低功耗需求 |
| [`07_safety.md`](07_safety.md) | 功能安全需求（SAFE） | **N/A** - 无 ISO 26262 功能安全目标 |
| [`08_security.md`](08_security.md) | 网络安全需求（SEC） | **N/A** - 无软件可访问资产，无安全隔离需求 |
| [`09_dfx.md`](09_dfx.md) | 可测性/可观测需求（DFX） | ✔ 有需求 |
| [`10_constraints.md`](10_constraints.md) | 约束需求（CONS） | ✔ 有需求 |
| [`11_quality_gate.md`](11_quality_gate.md) | G0 门禁（LRS_GATE_META） | ✔ 有内容 |

## 5. 类别覆盖声明

| 类别 | 状态 | 理由 |
|------|------|------|
| INTF | ✔ | 1 上游 APB + N 下游 APB + APB3/APB4 profile |
| FUNC | ✔ | 地址译码 / PSEL 生成 / 请求 fanout / 响应 mux / wait-state / PSLVERR 透传 / Decode Miss / Timeout / Remap / Response Register |
| CFG | ✔ | NUM_SLAVES / ADDR_WIDTH / DATA_WIDTH / 地址映射数组 / 可选特性参数 |
| REG | N/A | 无软件可见寄存器，纯参数化组合/时序互联逻辑 |
| PERF | ✔ | 低延迟组合响应、PPA 目标 |
| RESET | ✔ | PRESETn 复位行为 |
| LP | N/A | 无专用低功耗需求，时钟门控兼容 |
| SAFE | N/A | 无功能安全目标 |
| SEC | N/A | 无软件可访问资产，无攻击面 |
| CONS | ✔ | 配置合法性校验、地址不重叠约束 |
| DFX | ✔ | 协议断言（SVA） |

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
