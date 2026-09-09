# APB CDC Bridge — LRS 主索引

> **IP Name**: `apb_cdc_bridge`
> **VLNV**: `aixsilicon:ip:apb_cdc_bridge:1.0.0`
> **Version**: 1.0.0
> **Status**: Draft / G0 Candidate
> **协议**: AMBA APB3 / APB4
> **拓扑**: 1 APB Upstream × 1 APB Downstream
> **时钟模型**: 双时钟域（完全异步 / 快慢组合 / 同频异相 / 同源同步异频）

---

## 1. 文档控制

| 项目 | 内容 |
|------|------|
| 文档 ID | `aixsilicon:ip:apb_cdc_bridge:req` |
| 拥有者 | rtl-team |
| 创建日期 | 2026-09-07 |
| 当前版本 | v1.0 |
| 评审状态 | Draft / G0 Candidate |

## 2. 修订记录

| 版本 | 日期 | 修订说明 |
|------|------|----------|
| v0.1 | 2026-09-07 | 从 `APB-CDC-BRIDGE.MD` 需求规格整理为拆分 LRS 文档 |

## 3. 需求编号规范

```text
LRS.<CATEGORY>.<IP>.<GROUP>.<INDEX>
```

| 段 | 取值 |
|----|------|
| CATEGORY | INTF / FUNC / PERF / REG / SAFE / SEC / LP / DFX / CONS |
| IP | `APB_CDC_BRIDGE` |
| GROUP | 01 / 02 / ...（按功能分组） |
| INDEX | 001 / 002 / ...（组内序号） |

## 4. 文档结构

| 文件 | 内容 | 状态 |
|------|------|------|
| [`00_overview.md`](00_overview.md) | IP 概述、配置参数、架构框图 | ✔ 有内容 |
| [`01_interface.md`](01_interface.md) | 接口需求（INTF） | ✔ 有需求 |
| [`02_functional.md`](02_functional.md) | 功能需求（FUNC） | ✔ 有需求 |
| [`03_register.md`](03_register.md) | 寄存器需求（REG） | **N/A** - 纯 CDC 桥无软件可见寄存器，`register_model = none` |
| [`04_performance.md`](04_performance.md) | 性能需求（PERF） | ✔ 有需求 |
| [`05_low_power.md`](05_low_power.md) | 低功耗需求（LP） | ✔ 有需求 |
| [`06_safety.md`](06_safety.md) | 功能安全需求（SAFE） | **N/A** - 无 ISO 26262 功能安全目标 |
| [`07_security.md`](07_security.md) | 网络安全需求（SEC） | **N/A** - 无软件可访问资产，无攻击面 |
| [`08_constraint.md`](08_constraint.md) | 约束需求（CONS） | ✔ 有需求 |
| [`09_dfx.md`](09_dfx.md) | 可测性/可观测需求（DFX） | ✔ 有需求 |
| [`10_quality_checklist.md`](10_quality_checklist.md) | LRS 质量检查清单 | ✔ 有内容 |

## 5. 类别覆盖声明

| 类别 | 状态 | 理由 |
|------|------|------|
| INTF | ✔ | 双 APB 接口 + 双时钟 + 双复位 + 参数化 |
| FUNC | ✔ | 捕获/跨域/重新生成/响应返回 |
| REG | N/A | 无寄存器，CDC 桥为纯组合时序逻辑桥 |
| PERF | ✔ | 快慢时钟等待、延迟模型 |
| LP | ✔ | 负载寄存器低翻转、时钟门控兼容 |
| SAFE | N/A | 无功能安全目标 |
| SEC | N/A | 无软件可访问资产 |
| CONS | ✔ | CDC 约束、配置校验 |
| DFX | ✔ | 协议断言（SVA） |

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
