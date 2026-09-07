# LLD 主索引：X2P IP 微架构设计

> 文档名称：X2P IP LLD 微设计说明
> IP 名称：x2p
> 版本：v0.1
> 日期：2026-09-03
> 作者：rtl-team

---

## 文档控制

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| v0.1 | 2026-09-03 | rtl-team | 初始版本 |

## 文档结构

| 文件 | 包含内容 | 状态 |
|------|----------|------|
| [01_design.md](01_design.md) | 合并：概述 + 全局约束 + 7 模块微架构设计 | 必填 |
| [02_verification_delivery.md](02_verification_delivery.md) | 合并：验证要点 + RTL TODO + 交付 | 必填 |

## 设计 ID 命名规范

```text
LLD.MOD.X2P.<MODULE>         # 微架构模块 ID（必须引用 HLD.MOD.L1.X2P.<MODULE>）
LLD.FSM.X2P.<MODULE>.<NAME>  # FSM ID
LLD.IRQ.X2P.<MODULE>.<NAME>  # 中断 ID（X2P 无中断，N/A）