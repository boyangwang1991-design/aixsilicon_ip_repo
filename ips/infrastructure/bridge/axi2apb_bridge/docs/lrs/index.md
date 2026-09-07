---
id: LRS.X2P.OVERVIEW
title: X2P IP 概述
---

# X2P AXI-to-APB Bridge — 逻辑需求规格（LRS）

> 文档编号 / Document ID: LRS-X2P-V100
> IP/模块名称 / IP Name: X2P
> 文档版本 / Version: 1.00
> 文档状态 / Status: G0 Draft
> 作者 / Author: rtl-team
> 日期 / Date: 2026-09-03

---

## 0. 文档控制 / Document Control

### 0.1 修订记录

| 日期 | 版本 | 修改描述 | 作者 | 评审状态 |
|---|---|---|---|---|
| 2026-09-03 | 1.00 | 初稿完成（基于 X2P_PLAN.MD V1.0 基线） | rtl-team | Draft |

### 0.2 评审记录

| 日期 | 评审人 | 角色 | 评审意见 | 状态 |
|---|---|---|---|---|
| TBD | TBD | 架构 / 设计 / 验证 | TBD | Open |

### 0.3 文档状态说明

| 状态 | 含义 |
|---|---|
| Draft | 草稿状态，需求尚未正式评审 |
| Reviewed | 已完成评审，但仍可能修改 |
| Approved | 已批准，可作为设计与验证输入 |
| Deprecated | 已废弃 |

### 0.4 关键词

AXI4、AXI4-Lite、APB3、APB4、Bus Bridge、Burst、Narrow Transfer、Width Conversion、Write Strobe、Outstanding、Arbitration、Timeout、CDC、Reset

### 0.5 缩略语清单

| 缩略语 | 英文全名 | 中文解释 |
|---|---|---|
| AXI | Advanced eXtensible Interface | AMBA AXI 总线协议 |
| APB | Advanced Peripheral Bus | AMBA APB 外设总线协议 |
| CDC | Clock Domain Crossing | 跨时钟域 |
| INCR | Incrementing Burst | 增量突发 |
| WRAP | Wrapping Burst | 回绕突发 |
| FIXED | Fixed Burst | 固定地址突发 |
| SLVERR | Slave Error | AXI 从设备错误响应 |
| RMW | Read-Modify-Write | 读改写操作 |
| PPA | Power Performance Area | 功耗性能面积 |
| LRS | Logic Requirement Specification | 逻辑需求规格 |

### 0.6 规范及参考文档

| 编号 | 文档名称 | 版本 | 来源 | 说明 |
|---|---|---|---|---|
| REF.001 | AMBA AXI Protocol Specification | Issue L | ARM | AXI4 协议规范 |
| REF.002 | AMBA APB Protocol Specification | APB4 | ARM | APB3/APB4 协议规范 |
| REF.003 | X2P_PLAN.MD | V1.0 | rtl-team | X2P 产品/架构基线 |

---

## 1. 简介 / Introduction

### 1.1 文档目的

本文档描述 X2P（AXI-to-APB Bridge）的逻辑需求规格，作为 HLD、LLD、RTL 实现与验证的输入。

### 1.2 文档范围

1. AXI4 / AXI4-Lite 从接口
2. APB3 / APB4 主接口
3. Burst 转换（INCR/FIXED/WRAP）
4. Narrow Transfer 与数据宽度转换
5. Write Strobe 与 APB3 Partial Write 策略
6. Outstanding 与 Request Buffering
7. Read/Write 仲裁
8. APB Timeout
9. 同步/异步时钟模式、CDC
10. 输出流水与复位语义

### 1.3 目标读者

| 角色 | 关注内容 |
|---|---|
| 架构工程师 | 功能边界、拓扑、协议组合、性能 |
| RTL 设计工程师 | 功能行为、接口、状态机、异常 |
| 验证工程师 | 测试点、覆盖点、断言、异常场景 |
| 集成工程师 | 时钟复位、接口连接、参数选择 |
| 软件工程师 | 参数化能力、错误语义 |

### 1.4 需求描述规范

1. 每条需求必须具有唯一 LRS ID。
2. 每条需求只描述一个独立需求点。
3. 强制需求使用"应 / shall"。
4. 不使用不可验证描述。
5. 涉及时序、性能、资源时给出明确数值或范围。
6. 涉及配置时说明默认值、合法范围、非法值行为。
7. 涉及异常时说明检测条件、上报方式、恢复方式。

### 1.5 需求编号规范

```text
LRS.<CATEGORY>.<X2P>.<GROUP>.<INDEX>
```

| CATEGORY | 含义 |
|---|---|
| INTF | 接口需求 |
| FUNC | 功能需求 |
| PERF | 性能需求 |
| CONS | 约束需求 |

---

## 2. 文档结构 / Document Structure

| 文件 | 内容 | 需求类别 | 状态 |
|---|---|---|---|
| [00_overview.md](00_overview.md) | IP 概述、配置参数、架构框图 | - | 必填 |
| [01_interface.md](01_interface.md) | 接口需求 | INTF | 必填 |
| [02_functional.md](02_functional.md) | 功能需求 | FUNC | 必填 |
| [03_register.md](03_register.md) | 寄存器需求（X2P 无寄存器，N/A） | REG | N/A - 纯桥无寄存器 |
| [04_performance.md](04_performance.md) | 性能需求 | PERF | 必填 |
| [05_low_power.md](05_low_power.md) | 低功耗需求（N/A） | LP | N/A - 参数裁剪实现，无电源域 |
| [06_safety.md](06_safety.md) | 功能安全需求（N/A） | SAFE | N/A - 无功能安全需求 |
| [07_security.md](07_security.md) | 网络安全需求（N/A） | SEC | N/A - 桥接器不持有安全资产 |
| [08_constraint.md](08_constraint.md) | 约束需求 | CONS | 必填 |
| [09_dfx.md](09_dfx.md) | 可测性需求（N/A） | DFX | N/A - 无 DFT 需求 |
| [10_quality_checklist.md](10_quality_checklist.md) | LRS 质量检查清单 | - | 必填 |

### 2.1 类别文件状态说明

| 状态 | 含义 |
|---|---|
| 存在 | 该类别文件已生成，包含需求条目 |
| N/A - 纯桥无寄存器 | X2P 无可编程寄存器，全部为参数化配置 |
| N/A - 无功能安全需求 | X2P 不承担 ISO 26262 功能安全责任 |
| N/A - 桥接器不持有安全资产 | X2P 不做安全隔离/防火墙，无安全资产 |
| N/A - 无 DFT 需求 | X2P 不定义 scan/自测需求（由 SoC 级集成决定） |

---

## 3. 需求统计

| 类别 | 数量 |
|---|---|
| FUNC（功能需求） | TBD |
| INTF（接口需求） | TBD |
| REG（寄存器需求） | 0 (N/A) |
| PERF（性能需求） | TBD |
| LP（低功耗需求） | 0 (N/A) |
| SAFE（功能安全需求） | 0 (N/A) |
| SEC（网络安全需求） | 0 (N/A) |
| DFX（可测性需求） | 0 (N/A) |
| CONS（约束需求） | TBD |
| **总计** | **TBD** |

## 4. 优先级统计

| 优先级 | 数量 |
|---|---|
| P0（必须） | TBD |
| P1（应该） | TBD |
| P2（可以） | TBD |
| **总计** | **TBD** |