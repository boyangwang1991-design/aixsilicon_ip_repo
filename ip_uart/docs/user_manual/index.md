# UART IP 用户手册

## 1. 简介

UART IP 提供通用异步收发器功能，支持：

- 8 位数据帧 + 可选奇偶校验 + 停止位
- 可配置波特率（NCO 分频）
- TX/RX FIFO（32 深度）
- 系统回环（SLPBK）与线路回环（LLPBK）
- 噪声滤波（NF）
- 9 类中断 + fatal_fault alert
- TL-UL 与 APB 两种总线接入

## 2. 软件接口

C 头文件：[`sw/include/uart_regs.h`](../../sw/include/uart_regs.h)（PeakRDL 生成）。

### 2.1 初始化序列

```c
// 1. 使能 TX + RX（NCO=16，即默认波特率）
uart_ctrl = (16 << 16) | (1 << 0) | (1 << 1);  // NCO | TX | RX
```

### 2.2 发送一字节

```c
// 写入 WDATA；轮询 STATUS.TXLVL 或等待 tx_empty 中断
UART_WDATA(0) = data;
```

### 2.3 接收一字节

```c
// 轮询 STATUS.RXLVL > 0，然后读 RDATA
if ((UART_STATUS(0) >> 16) & 0x1F) {
    data = UART_RDATA(0);
}
```

### 2.4 使能系统回环

```c
UART_CTRL(0) |= (1 << 3);  // SLPBK
```

## 3. 中断

| 中断 | 说明 |
|------|------|
| tx_watermark | TX FIFO 超过水位 |
| tx_empty | TX FIFO 空 |
| rx_watermark | RX FIFO 超过水位 |
| tx_done | TX 完成 |
| rx_overflow | RX 溢出 |
| rx_frame_err | 帧错误 |
| rx_break_err | Break 错误 |
| rx_timeout | RX 超时 |
| rx_parity_err | 奇偶错误 |

## 4. 验证环境

### 4.1 编译

```bash
cd verification/sim
make compile           # VCS 编译（UVM 1.2）
```

### 4.2 运行单测

```bash
make run TEST=tc_uart_smoke
```

### 4.3 运行回归

```bash
make regress
```

### 4.4 测试列表

回归列表见 [`verification/sim/regression_list.yaml`](../../verification/sim/regression_list.yaml)，
覆盖 smoke/regression/extended 全部分组。

## 5. 参考

- [集成指南](../integration/index.md)
- [寄存器手册](../generated/uart_regs.html)
- [OpenTitan UART 文档](../../../reference/opentitan/hw/ip/uart/doc/theory_of_operation.md)
