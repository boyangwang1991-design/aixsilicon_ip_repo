# 覆盖率策略 - UART 验证方案

> 本文档是 [verification_plan.md](verification_plan.md) 第 10 章的详细展开（覆盖率策略）。

## 1. 覆盖率目标

覆盖率衡量激励/状态是否到达，不代替 checker 证明正确性。目标：功能覆盖率 ≥ 90%，关键 Covergroup 100% 命中。

## 2. Covergroup 定义

| 覆盖点ID | 名称 | 类型 | 描述 |
|--------|------|------|------|
| COV.FUNC.UART.01.BAUD | baud_rate_cg | functional | 波特率配置组合（NCO 值/常用波特率） |
| COV.FUNC.UART.02.FRAME | frame_cg | functional | 帧格式（奇偶开关、数据位、停止位） |
| COV.FUNC.UART.03.FIFO | fifo_cg | functional | FIFO 水位档位、满/空状态 |
| COV.FUNC.UART.04.ERR | error_cg | functional | 各错误事件（frame/parity/break/overflow/timeout） |
| COV.INTF.UART.01.MODE | mode_cg | functional | 回环模式（SLPBK/LLPBK/NF）组合 |
| COV.REG.UART.01.ACC | reg_access_cg | functional | 寄存器读写访问类型覆盖 |

<!-- COVERAGE_META
id: COV.FUNC.UART.01.BAUD
name: baud_rate_cg
description: 波特率配置组合覆盖（多种 NCO/常用波特率）
type: functional
feature_ref: FL.FUNC.UART.01
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.UART.02.FRAME
name: frame_cg
description: 帧格式覆盖（奇偶开关、数据位、停止位）
type: functional
feature_ref: FL.FUNC.UART.01
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.UART.03.FIFO
name: fifo_cg
description: FIFO 水位档位与满/空状态覆盖
type: functional
feature_ref: FL.FUNC.UART.01
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.UART.04.ERR
name: error_cg
description: 各错误事件覆盖（frame/parity/break/overflow/timeout）
type: functional
feature_ref: FL.FUNC.UART.01
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.INTF.UART.01.MODE
name: mode_cg
description: 回环模式与噪声滤波组合覆盖
type: functional
feature_ref: FL.INTF.UART.01
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.REG.UART.01.ACC
name: reg_access_cg
description: 寄存器读写访问类型覆盖
type: functional
feature_ref: FL.REG.UART.01
END_COVERAGE_META -->

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 06-verification-plan*
