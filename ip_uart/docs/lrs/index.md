# 逻辑需求规格说明书 - UART (uart)
# Logic Requirement Specification - UART (uart)

> 文档编号 / Document ID: LRS-UART-V100  
> IP/模块名称 / IP Name: UART  
> 文档版本 / Version: 1.00  
> 文档状态 / Status: Draft  
> 作者 / Author: rtl-team  
> 日期 / Date: 2026-08-11

---

## 0. 文档控制 / Document Control

### 0.1 修订记录 / Revision Record

| 日期 / Date | 版本 / Version | 修改描述 / Change Description | 作者 / Author | 评审状态 / Review Status |
|---|---|---|---|---|
| 2026-08-11 | 1.00 | 初稿完成（基于 OpenTitan UART，保留核心代码，新增 APB 接入能力） / Initial revision | rtl-team | Draft |

### 0.2 评审记录 / Review Record

| 日期 / Date | 评审人 / Reviewer | 角色 / Role | 评审意见 / Comment | 状态 / Status |
|---|---|---|---|---|
| TBD | TBD | 架构 / 设计 / 验证 | TBD | Open |

### 0.3 文档状态说明 / Document Status

| 状态 | 含义 |
|---|---|
| Draft | 草稿状态，需求尚未正式评审 |
| Reviewed | 已完成评审，但仍可能修改 |
| Approved | 已批准，可作为设计与验证输入 |
| Deprecated | 已废弃，不再作为有效需求 |

### 0.4 关键词 / Keywords

`UART`, `serial`, `FIFO`, `interrupt`, `baud rate`, `loopback`, `TL-UL`, `APB`

### 0.5 缩略语清单 / Glossary

| 缩略语 | 英文全名 | 中文解释 |
|---|---|---|
| UART | Universal Asynchronous Receiver/Transmitter | 通用异步收发器 |
| TL-UL | TileLink Uncached Lightweight | TileLink-UL 轻量总线协议 |
| APB | Advanced Peripheral Bus | AMBA APB 外设总线协议 |
| NCO | Numerically Controlled Oscillator | 数控振荡器（波特率分频） |
| FIFO | First In First Out | 先进先出队列 |
| W1C | Write-One-Clear | 写 1 清除机制 |
| N/A | Not Applicable | 不适用 |

### 0.6 规范及参考文档 / Reference Documents

| 编号 | 文档名称 | 版本 | 来源 | 说明 |
|---|---|---|---|---|
| REF.001 | OpenTitan UART IP Documentation | 2.1.0 | lowRISC (OpenTitan) | UART 核心文档（data/uart.hjson + doc/） |
| REF.002 | OpenTitan UART RTL Sources | 2.1.0 | lowRISC (OpenTitan) | UART 核心 RTL（rtl/*.sv，Apache-2.0） |
| REF.003 | TileLink Uncached Lightweight Spec | - | SiFive | TL-UL 总线协议 |
| REF.004 | AMBA APB Protocol Specification | APB4 | ARM | APB4 总线协议规范 |

---

## 1. 简介 / Introduction

### 1.1 文档目的 / Purpose

本文档用于描述 uart（UART）的逻辑需求规格。

本文档作为以下活动的输入：

1. 架构设计 / HLD
2. RTL 详细设计
3. 寄存器规格设计
4. 验证计划制定
5. 测试点与 Testcase 提取

### 1.2 文档范围 / Scope

本文档覆盖以下内容：

1. IP 应用背景与系统位置
2. 配置与参数化需求
3. 接口需求（TL-UL 与 APB 双接入）
4. 寄存器需求
5. 功能需求
6. 性能需求
7. 功能安全需求
8. 硬件集成约束

### 1.3 目标读者 / Target Audience

| 角色 | 关注内容 |
|---|---|
| 架构工程师 | 功能边界、系统位置、配置能力、性能目标 |
| RTL 设计工程师 | 功能行为、接口协议、寄存器、状态机、异常处理 |
| 验证工程师 | 测试点、覆盖点、断言点、异常场景、性能场景 |
| 软件工程师 | 寄存器、初始化顺序、中断、错误恢复、软件约束 |
| 集成工程师 | 时钟复位、接口连接、地址空间、中断连接、总线选择 |
| 安全工程师 | 功能安全机制、故障处理、安全状态 |

### 1.4 需求描述规范 / Requirement Writing Rules

所有需求应遵守以下规则：

1. 每条需求必须具有唯一 LRS ID。
2. 每条需求只描述一个独立需求点。
3. 强制需求使用"应 / shall"描述。
4. 可选需求使用"可 / may"描述，并说明配置条件。
5. 不应使用"尽量、较高、较低、合理、灵活、适当"等不可验证描述。
6. 涉及时序、性能、资源时，应给出明确数值或范围。
7. 涉及配置时，应说明默认值、合法范围、非法值行为。
8. 涉及异常时，应说明异常检测条件、上报方式、恢复方式。
9. 涉及接口时，应说明协议、位宽、时钟域、复位、握手行为。
10. 涉及跨时钟域时，应说明 CDC 处理要求。
11. 涉及复位时，应说明复位值、复位方式、复位后状态。
12. 每条需求应给出验证建议或测试点。

### 1.5 需求编号规范 / Requirement ID Rule

需求编号格式如下：

```text
LRS.<CATEGORY>.<IP>.<GROUP>.<INDEX>
```

示例：

```text
LRS.FUNC.UART.01.001
LRS.INTF.UART.02.001
LRS.REG.UART.03.001
LRS.PERF.UART.04.001
LRS.SAFE.UART.05.001
LRS.CONS.UART.07.001
```

### CATEGORY 定义

| CATEGORY | 含义 |
|---|---|
| FUNC | 功能需求 |
| INTF | 接口需求 |
| REG | 寄存器/配置需求 |
| PERF | 性能需求 |
| SAFE | 功能安全需求 |
| SEC | 网络安全需求 |
| LP | 低功耗需求 |
| DFX | 可测性/可观测需求 |
| CONS | 约束需求 |

### 1.6 标准需求条目格式 / Standard Requirement Format

每条需求使用以下格式（注意标题层级）：

```markdown
### 1.1 子章节标题（功能分组）

#### LRS.<CATEGORY>.<IP>.<GROUP>.<INDEX> 需求标题

<!-- LRS_META
id: LRS.<CATEGORY>.<IP>.<GROUP>.<INDEX>
category: FUNC / INTF / REG / PERF / SAFE / LP / CONS
ip: UART
feature: xxx
priority: P0 / P1 / P2
verify_method: simulation / formal / review / test
status: active
END_LRS_META -->

##### 需求描述

1. xxx。
2. xxx。

##### 验证关注点

1. xxx。

---
```

**标题层级说明**：
- `##` 二级标题：需求类别（如"接口需求"）
- `###` 三级标题：子章节/功能分组（如"总线接口需求"）
- `####` 四级标题：需求条目
- `#####` 五级标题：需求描述、验证关注点

---

## 2. 文档结构 / Document Structure

本文档按需求类别拆分为以下子文件。根据 IP 复杂度，部分类别文件可能不存在（标记为 N/A + 理由）。

| 文件 | 内容 | 需求类别 | 状态 |
|---|---|---|---|
| [00_overview.md](00_overview.md) | IP 概述、配置参数、架构框图 | - | 必填 |
| [01_interface.md](01_interface.md) | 接口需求 | INTF | 必填 |
| [02_functional.md](02_functional.md) | 功能需求 | FUNC | 必填 |
| [03_register.md](03_register.md) | 寄存器需求 | REG | 必填 |
| [04_performance.md](04_performance.md) | 性能需求 | PERF | 必填 |
| [05_low_power.md](05_low_power.md) | 低功耗需求 | LP | N/A - 本 IP 为同步单时钟域设计，无独立低功耗状态机 |
| [06_safety.md](06_safety.md) | 功能安全需求 | SAFE | 必填（总线完整性 alert） |
| [07_security.md](07_security.md) | 网络安全需求 | SEC | N/A - 无特权隔离/安全资产；寄存器访问由外部总线控制器管理 |
| [08_constraint.md](08_constraint.md) | 约束需求 | CONS | 必填 |
| [09_dfx.md](09_dfx.md) | 可测性/可观测需求 | DFX | N/A - 无扫描/DFT 需求，FIFO 软复位归入 FUNC/REG |
| [10_quality_checklist.md](10_quality_checklist.md) | LRS 质量检查清单 | - | 必填 |

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
