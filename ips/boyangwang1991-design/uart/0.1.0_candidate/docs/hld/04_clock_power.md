# HLD 时钟复位与性能设计 - UART

## 10. 时钟架构 / Clock Architecture

模块为单时钟域设计。时钟、复位、电源域定义如下：

### 时钟/复位/电源域定义（HLD_CLK_META）

<!-- HLD_CLK_META
# === 时钟/复位域定义 ===
id: HLD.DOM.UART.CLK_SYS
name: CLK_SYS
type: clock
description: 系统时钟域，所有逻辑与寄存器同步于此域

# === 属性定义 ===
frequency: 100
source: SoC 时钟树

# === 影响范围 ===
affected_modules:
  - HLD.MOD.L1.UART

# === 追溯定义 ===
req_ref:
  - LRS.CONS.UART.01.001
END_HLD_CLK_META -->

<!-- HLD_CLK_META
# === 时钟/复位域定义 ===
id: HLD.DOM.UART.RST_SYS_N
name: RST_SYS_N
type: reset
description: 系统异步复位（低有效），异步复位同步释放

# === 属性定义 ===
active_level: low
source: SoC 复位控制

# === 影响范围 ===
affected_modules:
  - HLD.MOD.L1.UART

# === 追溯定义 ===
req_ref:
  - LRS.CONS.UART.01.001
END_HLD_CLK_META -->

<!-- HLD_CLK_META
# === 时钟/复位域定义 ===
id: HLD.DOM.UART.PD_ALWAYS_ON
name: PD_ALWAYS_ON
type: power
description: 常开电源域

# === 影响范围 ===
affected_modules:
  - HLD.MOD.L1.UART

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.001
END_HLD_CLK_META -->

### 10.1 时钟架构要点

- 单一 `clk_i` 时钟，所有模块（uart_reg_top/uart_core/uart_rx/uart_tx/apb2tlul）同步于 CLK_SYS。
- 波特率通过 `CTRL.NCO` 分频产生 16x baud tick，属于域内分频逻辑（非独立时钟域）。

### 10.2 复位架构要点

- `rst_ni` 低有效异步复位，同步释放。
- 复位后寄存器回默认值，FIFO 清空，中断/alert 输出已知状态。

## 11. CDC/RDC 分析

模块内部无跨时钟域路径（单时钟域）。alert 接口支持异步（`AlertAsyncOn=1`，由 `prim_alert_sender` 内部处理 CDC），不产生独立 CDC 路径需求。

## 12. 性能预算 / Performance Budget

| 项目 | 指标 | 依据 |
|---|---|---|
| 波特率 | 最高 1 Mbit/s | LRS.PERF.UART.01.001 |
| 波特率误差容限 | ±2.5%（单侧） | LRS.PERF.UART.01.002 |
| TX FIFO | 32 字节 | LRS.PERF.UART.01.003 |
| RX FIFO | 64 字节 | LRS.PERF.UART.01.003 |
| 单字节延迟 | 10/11 bit-time | LRS.PERF.UART.01.004 |
| 时钟频率 | 依系统（示例 100 MHz） | 集成约束 |

## 低功耗

本模块无独立低功耗状态机，未定义时钟门控需求（LRS LP 标记 N/A）。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 03-hld-architect*
