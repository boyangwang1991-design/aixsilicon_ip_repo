# LRS 质量检查清单 - UART (uart)
# LRS Quality Checklist - UART (uart)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md) 获取完整结构。

---

## 1. 需求完整性检查 / Completeness

| 检查项 | 状态 | 说明 |
|---|---|---|
| 接口需求（INTF） | ✅ | 01_interface.md，8 条需求 |
| 功能需求（FUNC） | ✅ | 02_functional.md，15 条需求 |
| 寄存器需求（REG） | ✅ | 03_register.md，7 条需求 |
| 性能需求（PERF） | ✅ | 04_performance.md，4 条需求 |
| 低功耗需求（LP） | N/A | 单时钟域设计，无独立低功耗状态机 |
| 功能安全需求（SAFE） | ✅ | 06_safety.md，2 条需求（总线完整性/alert） |
| 网络安全需求（SEC） | N/A | 无特权隔离/安全资产 |
| 约束需求（CONS） | ✅ | 08_constraint.md，6 条需求 |
| 可测性需求（DFX） | N/A | 无扫描/DFT 需求 |

## 2. 可验证性检查 / Verifiability

| 检查项 | 状态 | 说明 |
|---|---|---|
| 每条 must 需求有 verify_method | ✅ | 全部需求均含 verify_method |
| 无不可验证描述词 | ✅ | 未使用"尽量/较高/合理"等 |
| 涉及时序/数值给出明确值 | ✅ | 波特率、FIFO 深度、误差容限均已量化 |

## 3. 编号检查 / ID Check

| 检查项 | 状态 | 说明 |
|---|---|---|
| 需求 ID 唯一 | ✅ | 全部 ID 唯一 |
| ID 格式 LRS.CATEGORY.IP.GROUP.INDEX | ✅ | 符合规范 |
| IP 段与 --ip-name 一致（UART） | ✅ | 编号一致 |

## 4. 一致性检查 / Consistency

| 检查项 | 状态 | 说明 |
|---|---|---|
| 与 OpenTitan UART 文档一致 | ✅ | 参考 uart.hjson / theory_of_operation / registers.md |
| 核心代码不改动 | ✅ | 仅新增 apb2tlul wrapper，核心 RTL 原样保留 |
| 需求无冲突 | ✅ | 未发现冲突需求 |

## 5. 优先级分布 / Priority Distribution

| 优先级 | 数量 | 占比 |
|---|---|---|
| P0 | 12 | 35% |
| P1 | 14 | 41% |
| P2 | 8 | 24% |

## 6. 发现项 / Findings

| 编号 | 严重度 | 描述 | 状态 |
|---|---|---|---|
| LRS-FIND-001 | Info | APB 接入为新增能力，需在 HLD/LLD/RTL/验证中落实 | Open |
| LRS-FIND-002 | Info | RACL 默认关闭，启用需额外集成 | Open |

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
