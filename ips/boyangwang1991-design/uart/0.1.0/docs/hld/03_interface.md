# HLD 接口与寄存器架构设计 - UART

## 6. 接口架构设计

### 6.1 接口概览 / Interface Overview

| 接口 | 类型 | 方向 | 协议 | 时钟域 | 说明 |
|---|---|---|---|---|---|
| tl_i / tl_o | 总线 | slave | TileLink-UL | CLK_SYS | 寄存器访问（TL-UL target） |
| apb_i / apb_o | 总线 | slave | APB4 | CLK_SYS | 寄存器访问（经 apb2tlul，APB target） |
| cio_rx_i | 串行 | input | UART | CLK_SYS | 串行接收 |
| cio_tx_o | 串行 | output | UART | CLK_SYS | 串行发送 |
| cio_tx_en_o | 串行 | output | - | CLK_SYS | TX 输出使能（恒 1） |
| intr_*_o | 中断 | output | - | CLK_SYS | 9 个中断 |
| alert_rx_i/alert_tx_o | alert | input/output | prim_alert | 异步 | fatal_fault |
| lsio_trigger_o | 触发 | output | - | CLK_SYS | DMA 触发 |
| racl_policies_i/racl_error_o | RACL | input/output | top_racl | CLK_SYS | RACL（默认关闭） |
| clk_i / rst_ni | 时钟复位 | input | - | - | 系统时钟/复位 |

### 6.2 外部接口定义（HLD_IF_META）

#### TL-UL 从接口

<!-- HLD_IF_META
# === 接口定义 ===
id: HLD.IF.EXT.UART.TLUL
name: tlul_slave
type: custom
direction: slave
description: TileLink-UL 从接口，寄存器访问（BlockAw=6，32 位数据）

# === 端口定义 ===
ports:
  - name: tl_i
    direction: input
    width: 1
    clock_domain: CLK_SYS
  - name: tl_o
    direction: output
    width: 1
    clock_domain: CLK_SYS

# === 时序定义 ===
timing:
  clock_frequency: 100
  latency_cycles: 1
  throughput: "TL-UL 握手，每事务 1 周期"

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.002
END_HLD_IF_META -->

#### APB4 从接口（新增）

<!-- HLD_IF_META
# === 接口定义 ===
id: HLD.IF.EXT.UART.APB
name: apb_slave
type: APB
direction: slave
description: APB4 从接口，经 apb2tlul wrapper 转换为 TL-UL 访问核心寄存器堆

# === 端口定义 ===
ports:
  - name: psel
    direction: input
    width: 1
    clock_domain: CLK_SYS
  - name: penable
    direction: input
    width: 1
    clock_domain: CLK_SYS
  - name: pwrite
    direction: input
    width: 1
    clock_domain: CLK_SYS
  - name: paddr
    direction: input
    width: 8
    clock_domain: CLK_SYS
  - name: pwdata
    direction: input
    width: 32
    clock_domain: CLK_SYS
  - name: prdata
    direction: output
    width: 32
    clock_domain: CLK_SYS
  - name: pready
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: pslverr
    direction: output
    width: 1
    clock_domain: CLK_SYS

# === 时序定义 ===
timing:
  clock_frequency: 100
  latency_cycles: 1
  throughput: "APB4 两相握手（setup/access）"

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.003
END_HLD_IF_META -->

#### 串行 IO 接口

<!-- HLD_IF_META
# === 接口定义 ===
id: HLD.IF.EXT.UART.SERIAL
name: serial_io
type: Custom
direction: bidirectional
description: 串行收发接口（rx 输入 / tx 输出 / tx_en 输出）

# === 端口定义 ===
ports:
  - name: cio_rx_i
    direction: input
    width: 1
    clock_domain: CLK_SYS
  - name: cio_tx_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: cio_tx_en_o
    direction: output
    width: 1
    clock_domain: CLK_SYS

# === 时序定义 ===
timing:
  clock_frequency: 100
  latency_cycles: 0
  throughput: "最高 1 Mbit/s"

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.004
END_HLD_IF_META -->

#### 中断接口

<!-- HLD_IF_META
# === 接口定义 ===
id: HLD.IF.EXT.UART.IRQ
name: interrupt_out
type: interrupt
direction: output
description: 9 个中断输出（tx_watermark/tx_empty/rx_watermark/tx_done/rx_overflow/rx_frame_err/rx_break_err/rx_timeout/rx_parity_err）

# === 端口定义 ===
ports:
  - name: intr_tx_watermark_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_tx_empty_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_rx_watermark_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_tx_done_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_rx_overflow_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_rx_frame_err_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_rx_break_err_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_rx_timeout_o
    direction: output
    width: 1
    clock_domain: CLK_SYS
  - name: intr_rx_parity_err_o
    direction: output
    width: 1
    clock_domain: CLK_SYS

# === 时序定义 ===
timing:
  latency_cycles: 1
  throughput: "电平或脉冲中断"

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.005
END_HLD_IF_META -->

#### Alert 接口

<!-- HLD_IF_META
# === 接口定义 ===
id: HLD.IF.EXT.UART.ALERT
name: alert_if
type: custom
direction: bidirectional
description: prim_alert 接口，fatal_fault alert（NumAlerts=1）

# === 端口定义 ===
ports:
  - name: alert_rx_i
    direction: input
    width: 1
    clock_domain: async
  - name: alert_tx_o
    direction: output
    width: 1
    clock_domain: async

# === 时序定义 ===
timing:
  latency_cycles: 1
  throughput: "alert 事件上报"

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.006
  - LRS.SAFE.UART.01.001
  - LRS.SAFE.UART.01.002
END_HLD_IF_META -->

#### 时钟/复位接口

<!-- HLD_IF_META
# === 接口定义 ===
id: HLD.IF.EXT.UART.CLK_RST
name: clk_rst
type: clock_reset
direction: input
description: 系统时钟与异步复位输入

# === 端口定义 ===
ports:
  - name: clk_i
    direction: input
    width: 1
  - name: rst_ni
    direction: input
    width: 1

# === 时序定义 ===
timing:
  clock_frequency: 100
  latency_cycles: 0
  throughput: "单时钟域，异步复位同步释放"

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.001
  - LRS.CONS.UART.01.001
END_HLD_IF_META -->

#### lsio_trigger 接口

<!-- HLD_IF_META
# === 接口定义 ===
id: HLD.IF.EXT.UART.LSIO
name: lsio_trigger
type: custom
direction: output
description: lsio_trigger DMA 触发信号（自清除状态触发）

# === 端口定义 ===
ports:
  - name: lsio_trigger_o
    direction: output
    width: 1
    clock_domain: CLK_SYS

# === 时序定义 ===
timing:
  latency_cycles: 1
  throughput: "FIFO 水位触发事件"

# === 追溯定义 ===
req_ref:
  - LRS.INTF.UART.01.007
END_HLD_IF_META -->

### 6.3 寄存器架构 / Register Architecture

寄存器分组与概要（详见 `regs/uart.rdl` / LRS 03_register.md）：

| 分组 | 寄存器 | 偏移 | 访问 |
|---|---|---|---|
| 控制 | CTRL | 0x00 | rw |
| 状态 | STATUS | 0x04 | ro |
| 数据 | RDATA / WDATA | 0x08 / 0x0C | ro / wo |
| FIFO | FIFO_CTRL / FIFO_STATUS | 0x10 / 0x14 | rw / ro |
| 覆盖 | OVRD | 0x18 | rw |
| 观测 | VAL | 0x1C | ro |
| 超时 | TIMEOUT_CTRL | 0x20 | rw |
| 中断 | INTR_STATE/ENABLE/TEST/STATUS | 0x24–0x30 | rw1c/rw/rw/ro |
| Alert | ALERT_TEST | 0x34 | rw |

寄存器堆在 TL-UL target 由 `uart_reg_top` 实现；APB target 由 `apb2tlul` 桥接到同一 `uart_reg_top`。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 03-hld-architect*
