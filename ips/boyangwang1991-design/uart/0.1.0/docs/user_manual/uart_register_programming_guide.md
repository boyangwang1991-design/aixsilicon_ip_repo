# UART 寄存器编程指南

> 面向软件/系统工程师。寄存器偏移与 OpenTitan `uart.hjson` 一致，
> 完整字段见 [`../generated/uart_regs.html`](../generated/uart_regs.html) 与
> [`sw/include/uart_regs.h`](../../sw/include/uart_regs.h)。

## 1. 寄存器映射

| 偏移 | 名称 | 类型 | 复位值 | 说明 |
|------|------|------|--------|------|
| 0x00 | INTR_STATE | RW1C | 0 | 中断状态 |
| 0x04 | INTR_ENABLE | RW | 0 | 中断使能 |
| 0x08 | INTR_TEST | W1S | 0 | 中断测试 |
| 0x0C | ALERT_TEST | W1S | 0 | Alert 测试 |
| 0x10 | CTRL | RW | 0 | 控制 |
| 0x14 | STATUS | RO | - | 状态 |
| 0x18 | RDATA | RO | - | 接收数据（读清空） |
| 0x1C | WDATA | WO | - | 发送数据 |
| 0x20 | FIFO_CTRL | RW | 0 | FIFO 控制（rxilvl/txilvl/rrst/txrst） |
| 0x24 | FIFO_STATUS | RO | 0 | FIFO 状态（rx/tx level/empty/full） |
| 0x28 | OVRD | RW | 0 | 输出覆盖（txen/txval/rxen/rxval） |
| 0x2C | VAL | RO | - | 引脚当前值 |
| 0x30 | TIMEOUT_CTRL | RW | 0 | RX 超时控制（en + tick） |

## 2. CTRL 字段（0x10）

| 位 | 字段 | 访问 | 说明 |
|----|------|------|------|
| [0] | TX | RW | 发送使能 |
| [1] | RX | RW | 接收使能 |
| [2] | NF | RW | 噪声滤波使能 |
| [3] | SLPBK | RW | 系统回环使能 |
| [4] | LLPBK | RW | 线路回环使能 |
| [5] | PARITY_EN | RW | 奇偶校验使能 |
| [6] | PARITY_ODD | RW | 奇校验（1）/偶校验（0） |
| [9:8] | RXBLVL | RW | RX 水位档位（1/4、1/2、3/4、7/8） |
| [31:16] | NCO | RW | 波特率分频（16x 过采样） |

## 3. STATUS 字段（0x14）

| 位 | 字段 | 说明 |
|----|------|------|
| [0] | TX_FULL | TX FIFO 满 |
| [1] | TX_EMPTY | TX FIFO 空 |
| [2] | RX_EMPTY | RX FIFO 空 |
| [3] | RX_FULL | RX FIFO 满 |
| [4] | TX_OVERFLOW | TX 溢出 |
| [12:8] | TXLVL | TX FIFO 深度 |
| [20:16] | RXLVL | RX FIFO 深度 |

## 4. FIFO_CTRL / FIFO_STATUS（0x20 / 0x24）

- `FIFO_CTRL[1:0]` RXILVL（水位档）、`[3:2]` TXILVL、`[4]` RXRST、`[5]` TXRST
- `FIFO_STATUS[5:0]` RXLVL、`[12:8]` TXLVL、`[16]` RXEMPTY、`[17]` RXFULL、
  `[20]` TXEMPTY、`[21]` TXFULL

## 5. 软件配置流程

### 5.1 初始化

```c
// 复位默认即可使用；如需自定义波特率：
UART_CTRL(0) = (NCO << 16) | (1 << 0) | (1 << 1);  // TX + RX 使能
```

### 5.2 发送

```c
UART_WDATA(0) = byte;
// 等待：STATUS.TXLVL < 32 或 TX 完成中断
```

### 5.3 接收

```c
// 轮询 STATUS.RXLVL > 0
while (((UART_STATUS(0) >> 16) & 0x1F) == 0);
byte = UART_RDATA(0);
```

### 5.4 使能系统回环

```c
UART_CTRL(0) |= (1 << 3);  // SLPBK
```

### 5.5 中断处理

```c
// 使能所需中断
UART_INTR_ENABLE(0) = mask;
// ISR 中读取 INTR_STATE，处理后将对应位写 1 清除（W1C）
UART_INTR_STATE(0) = pending_mask;
```

## 6. 与 OpenTitan 一致性

本 IP 寄存器定义与 OpenTitan `hw/ip/uart` 完全一致（RDL 由 `uart.hjson` 推导），
软件驱动可直接复用 OpenTitan SW 驱动（`sw/device/lib/drivers/uart`）的寄存器访问层。
