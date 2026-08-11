# UART 验证方案

<!-- VPLAN_META
schema_version: 1.0
ip_name: uart
verification_level: smoke
status: draft
END_VPLAN_META -->

> 相关文档：
> - [feature_list.md](feature_list.md) — 功能列表
> - [test_matrix.md](test_matrix.md) — 测试矩阵
> - [checker_plan.md](checker_plan.md) — 比对器策略
> - [coverage_plan.md](coverage_plan.md) — 覆盖率策略
> - [agent_plan.md](agent_plan.md) — Agent 规划

## 1. DUT 概述

UART 全双工串行通信接口 IP（基于 OpenTitan UART，核心 RTL 不改动）。TX FIFO 32 字节、RX FIFO 64 字节，波特率可编程最高 1 Mbit/s，8 位数据 + 可选奇偶，9 个中断，fatal_fault alert。提供 TL-UL 与 APB 双总线接入。

## 2. 时钟与复位

- 单时钟域 `clk_i`（CLK_SYS）。
- `rst_ni` 低有效异步复位，同步释放。
- 复位后寄存器回默认值、FIFO 清空、中断/alert 已知状态。

## 3. 接口列表

| 接口 | 方向 | 协议 | 说明 |
|---|---|---|---|
| tl_i/tl_o | slave | TL-UL | 寄存器访问 |
| apb_i/apb_o | slave | APB4 | APB 接入（经 apb2tlul） |
| cio_rx_i / cio_tx_o / cio_tx_en_o | in/out | UART | 串行收发 |
| intr_*_o ×9 | out | - | 中断 |
| alert_rx_i/alert_tx_o | in/out | prim_alert | fatal_fault |
| lsio_trigger_o | out | - | DMA 触发 |

## 4. Agent 列表

| Agent | 用途 |
|---|---|
| uart_interface_agent | 串行帧收发 |
| tlul_interface_agent | TL-UL 寄存器访问 |
| apb_interface_agent | APB 寄存器访问（APB target） |

详见 [agent_plan.md](agent_plan.md)。

## 5. 寄存器验证范围

- 全部 14 个寄存器（CTRL/STATUS/RDATA/WDATA/FIFO_CTRL/FIFO_STATUS/OVRD/VAL/TIMEOUT_CTRL/INTR_STATE/INTR_ENABLE/INTR_TEST/INTR_STATUS/ALERT_TEST）。
- 复位值、RW/RO/WO/W1C 行为、非法地址错误响应。
- 使用 UVM RAL（源自 `verification/ral/uart.xml`）。

## 6. 功能验证范围

- 串行帧格式、波特率、TX/RX 路径、奇偶、回环（SLPBK/LLPBK）、FIFO、中断管理、噪声滤波、TX 覆盖、过采样观测。

## 7. 错误注入范围

- 帧错误、奇偶错误、break、RX 溢出、RX 超时、总线完整性错误、ALERT_TEST。

## 8. 参考模型策略

- 行为参考模型（`04-behavioral-model`）仅用于仿真探索，不接入验证环境。
- **验证以 UVM RM 为唯一参考来源**：RM 建模 FIFO 收发、波特率分频、错误检测与中断事件，与 DUT 行为比对。

## 9. 比对器策略（概述）

- Scoreboard 比对 TX/RX 字节序列与寄存器访问。
- 断言校验帧格式、输出已知、reg_we one-hot 违规。
- 详见 [checker_plan.md](checker_plan.md)。

## 10. 功能覆盖率策略（概述）

- 覆盖波特率配置、帧格式、FIFO 水位、错误事件、回环模式、寄存器访问。
- 目标 ≥ 90%。
- 详见 [coverage_plan.md](coverage_plan.md)。

## 11. 测试矩阵（摘要）

- 7 个参数化测试：smoke（1）、regression（4）、extended（2）。
- 完整矩阵见 [test_matrix.md](test_matrix.md)。

## 12. 回归策略

- **smoke tier**：tc_uart_smoke（快速确定性）。
- **regression tier**：tc_uart_tx_rx / tc_uart_error / tc_uart_fifo / tc_uart_csr。
- **extended tier**：tc_uart_perf / tc_uart_alert。
- 运行：`verification/sim/Makefile`，VCS + UVM 1.2。

## 13. Signoff 标准

- 所有 test_matrix testcase 通过（G4）。
- 功能覆盖率 ≥ 90%，无未覆盖 must 需求。
- lint/elab 通过，无 blocker finding。

## 14. 假设与待确认项

| 假设/待确认 | 状态 |
|---|---|
| 验证主要用 TL-UL 总线接入；APB 接入作为可选 target 单独验证 | 假设 |
| 波特率误差测试在 ±2.5% 内 | 假设 |
| 核心 RTL 保持 OpenTitan 原版不变 | 确认（用户要求） |

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 06-verification-plan*
