# 比对器策略 - UART 验证方案

> 本文档是 [verification_plan.md](verification_plan.md) 第 9 章的详细展开（比对器策略）。

## 1. Scoreboard 比对策略

- **收发比对**：Scoreboard 维护 TX 发送队列与 RX 接收队列，比对发送字节序列与 RX FIFO 读回序列一致（配合回环模式/外部 UART agent）。
- **寄存器比对**：使用 UVM RAL 模型（源自 `verification/ral/uart.xml`），比对寄存器读写与预期。
- **中断比对**：比对事件触发的中断与 `INTR_STATE`/`INTR_STATUS` 寄存器状态一致。

## 2. 断言策略

参考 OpenTitan `uart.sv` 内置断言（`prim_assert.sv`）与 `dv/sva/uart_bind.sv`，新增时序断言。

| 断言ID | 名称 | 属性 | 严重度 |
|--------|------|------|--------|
| ASSERT.INTF.UART.01.001.TXEN | TxEnIsOne_A | cio_tx_en_o 恒为 1 | error |
| ASSERT.INTF.UART.01.002.KNOWN | TxKnown_A / 中断 KNOWN 断言 | 复位或未使能时输出已知 | error |
| ASSERT.FUNC.UART.01.001.FRAME | 帧格式断言 | START+8 data+[parity]+STOP 时序正确 | error |
| ASSERT.FUNC.UART.01.002.BAUD | 波特率 tick 断言 | NCO 分频产生 16x tick 正确 | warning |
| ASSERT.SAFE.UART.01.001.ALERT | RegWeOnehotCheck_A | reg_we one-hot 违规触发 alert | error |

<!-- ASSERTION_META
id: ASSERT.INTF.UART.01.001.TXEN
name: TxEnIsOne_A
property: cio_tx_en_o 恒为 1
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.INTF.UART.01.002.KNOWN
name: TxKnown_A
property: 复位或未使能时 TX/中断/alert 输出为已知状态
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.FUNC.UART.01.001.FRAME
name: FrameFormat_A
property: 串行帧 START+8 data+[parity]+STOP 时序正确
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.FUNC.UART.01.002.BAUD
name: BaudTick_A
property: NCO 分频产生 16x baud tick 正确
severity: warning
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.SAFE.UART.01.001.ALERT
name: RegWeOnehotCheck_A
property: 寄存器写使能 one-hot 违规触发 fatal_fault alert
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.CONS.UART.01.001.CLK
name: ClockReset_A
property: 复位后寄存器回默认值、FIFO 清空、中断/alert 输出已知状态
severity: error
feature_ref: FL.CONS.UART.01
END_ASSERTION_META -->

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 06-verification-plan*
