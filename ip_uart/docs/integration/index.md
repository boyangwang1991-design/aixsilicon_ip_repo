# UART IP 集成指南

> 本文档描述如何将 UART IP（OpenTitan 内核 + APB 接入）集成到 SoC 或子系统。

## 1. 概述

UART IP 基于 OpenTitan 的 UART 模块（TL-UL slave），并提供两种接入方式：

1. **TL-UL 接入**（默认）：直接使用 `uart` 顶层（OpenTitan 原版，未修改）。
2. **APB 接入**：通过新增的 `apb2tlul` 桥 + `uart_apb_top` 封装，将 APB4 主口转换为 TL-UL 访问。

核心 UART 功能（`uart_core`/`uart_rx`/`uart_tx`/`uart_reg_top`）为 OpenTitan 原版，
**不做任何修改**。

## 2. 集成方式

### 2.1 TL-UL 接入

```systemverilog
uart u_uart (
  .clk_i      (clk),
  .rst_ni     (rst_n),
  .tl_i       (tl_h2d),
  .tl_o       (tl_d2h),
  .alert_rx_i (alert_rx),
  .alert_tx_o (alert_tx),
  .cio_rx_i   (uart_rx),
  .cio_tx_o   (uart_tx),
  .cio_tx_en_o(uart_tx_en),
  ...
);
```

### 2.2 APB 接入

```systemverilog
uart_apb_top u_uart_apb (
  .clk_i      (clk),
  .rst_ni     (rst_n),
  .psel_i     (psel),
  .penable_i  (penable),
  .pwrite_i   (pwrite),
  .paddr_i    (paddr),
  .pwdata_i   (pwdata),
  .pstrb_i    (pstrb),
  .prdata_o   (prdata),
  .pready_o   (pready),
  .pslverr_o  (pslverr),
  .cio_rx_i   (uart_rx),
  .cio_tx_o   (uart_tx),
  .cio_tx_en_o(uart_tx_en)
);
```

## 3. 寄存器访问

寄存器偏移与 OpenTitan 一致（见 [寄存器手册](../generated/uart_regs.html)）：

| 偏移 | 寄存器 | 说明 |
|------|--------|------|
| 0x00 | INTR_STATE | 中断状态（W1C） |
| 0x04 | INTR_ENABLE | 中断使能 |
| 0x08 | INTR_TEST | 中断测试 |
| 0x0C | ALERT_TEST | Alert 测试 |
| 0x10 | CTRL | 控制（TX/RX/NF/SLPBK/LLPBK/PARITY/NCO） |
| 0x14 | STATUS | 状态 |
| 0x18 | RDATA | 接收数据 |
| 0x1C | WDATA | 发送数据 |
| 0x20 | FIFO_CTRL | FIFO 控制 |
| 0x24 | FIFO_STATUS | FIFO 状态 |
| 0x28 | OVRD | 输出覆盖 |
| 0x2C | VAL | 引脚值 |
| 0x30 | TIMEOUT_CTRL | 超时控制 |

## 4. 验证

验证环境位于 `verification/`，基于 UVM 1.2（VCS）。运行方式见
[用户手册](../user_manual/index.md) 与 `verification/sim/Makefile`。
