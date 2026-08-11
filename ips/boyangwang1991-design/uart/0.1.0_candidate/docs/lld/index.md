# LLD 主索引：UART IP 微架构设计

> 文档名称：UART IP LLD 微架构设计说明
> IP 名称：uart
> 版本：v0.1
> 日期：2026-08-11
> 作者：rtl-team

---

## 文档控制

### 修订记录

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| v0.1 | 2026-08-11 | rtl-team | 初始版本 |

### 评审记录

| 评审日期 | 评审人 | 角色 | 评审意见 | 状态 |
|----------|--------|------|----------|------|
| TBD | TBD | 设计 | | Open |

---

## 文档结构

采用精简模式（合并）：

| 文件 | 包含内容 | 状态 |
|------|----------|------|
| [01_design.md](01_design.md) | 概述 + 全局约束 + 各模块微架构设计（FSM/时序/复位/中断） | 必填 |
| [02_verification_delivery.md](02_verification_delivery.md) | 验证要点 + 交付映射 + RTL TODO 列表 | 必填 |

## 与 HLD 的关系

LLD 模块通过 `hld_ref` 引用 HLD 模块（`HLD.MOD.L1.UART.*`）。核心模块（uart/uart_core/uart_rx/uart_tx/uart_reg_top）为 OpenTitan 原版代码，LLD 描述其既有微架构；`apb2tlul` 为新增模块，LLD 定义其完整微架构。

## 与 RDL 的关系

寄存器字段级定义以 `regs/uart.rdl`（SystemRDL）为唯一权威源，LLD 不重复定义寄存器字段。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 05-lld-microdesign*
