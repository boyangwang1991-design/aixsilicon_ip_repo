# 接口需求 - UART (uart)
# Interface Requirements - UART (uart)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md) 获取完整结构。
> 接口定义参考 OpenTitan UART 文档（`doc/interfaces.md`）与顶层 RTL（`rtl/uart.sv`）。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **INTF**：接口需求（时钟/复位、TL-UL 总线接口、APB 接口、串行 IO、中断接口、Alert 接口等）

---

## 1. 接口需求 / Interface Requirements

### 1.1 接口总览 / Interface Overview

| 接口名称 | 接口类型 | 方向 | 时钟域 | 复位域 | 协议 | 说明 |
|---|---|---|---|---|---|---|
| clk_i / rst_ni | 时钟/复位 | 输入 | - | - | - | 系统时钟与异步复位 |
| tl_i / tl_o | TL-UL 从接口 | 输入/输出 | clk_i | rst_ni | TileLink-UL | 寄存器访问总线（原始接口） |
| apb_i / apb_o（经 apb2tlul） | APB 从接口 | 输入/输出 | clk_i | rst_ni | APB4 | APB 接入（新增 wrapper） |
| cio_rx_i | 串行输入 | 输入 | clk_i | rst_ni | UART | 串行接收位 |
| cio_tx_o / cio_tx_en_o | 串行输出 | 输出 | clk_i | rst_ni | UART | 串行发送位 / 使能 |
| intr_*_o（9 个） | 中断输出 | 输出 | clk_i | rst_ni | - | tx_watermark/tx_empty/rx_watermark/tx_done/rx_overflow/rx_frame_err/rx_break_err/rx_timeout/rx_parity_err |
| alert_rx_i / alert_tx_o | Alert 接口 | 输入/输出 | 异步 | 异步 | prim_alert | fatal_fault alert |
| lsio_trigger_o | 状态触发 | 输出 | clk_i | rst_ni | - | DMA 触发信号 |
| racl_policies_i / racl_error_o | RACL 接口 | 输入/输出 | clk_i | rst_ni | top_racl_pkg | RACL 策略（EnableRacl=0 时未用） |

### 1.2 时钟与复位接口 / Clock and Reset Interface

#### LRS.INTF.UART.01.001 时钟与复位接口

<!-- LRS_META
id: LRS.INTF.UART.01.001
category: INTF
ip: UART
feature: clock_reset
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应支持单一系统时钟 `clk_i`，所有内部逻辑与寄存器均在该时钟域内工作。
2. 模块应支持低有效异步复位 `rst_ni`，采用异步复位、同步释放策略。
3. 复位后所有寄存器应复位到定义值（见寄存器文档），FIFO 应清空。
4. `uart.hjson` 定义 clocking 为 `{clock: "clk_i", reset: "rst_ni"}`。

##### 验证关注点

1. 复位释放后寄存器默认值正确。
2. 复位期间输出（TX、中断、alert）处于已知状态。
3. 复位后 FIFO 深度计数器归零、状态寄存器回默认值。

---

### 1.3 TL-UL 总线接口 / TL-UL Bus Interface

#### LRS.INTF.UART.01.002 TL-UL 从接口访问

<!-- LRS_META
id: LRS.INTF.UART.01.002
category: INTF
ip: UART
feature: tlul_bus
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 TileLink-UL 协议从接口（`tlul_pkg::tl_h2d_t tl_i` / `tl_d2h_t tl_o`）接收寄存器访问。
2. 块内地址宽度应为 `BlockAw=6`（64 字节地址空间），数据位宽 32 位。
3. 总线接口应支持读/写事务，并遵守 TL-UL 握手（valid/ready）与响应（d_h2d/d2h）时序。
4. 非法地址访问应返回 TL-UL 错误响应（`tl_o.d_error`），不得导致挂死。
5. 总线应具备端到端完整性检测（BUS.INTEGRITY），检测到完整性错误时上报 `fatal_fault` alert。

##### 验证关注点

1. 读写各寄存器地址正确、读写数据正确。
2. 非法地址返回 error 响应。
3. 总线完整性错误触发 fatal_fault alert。

---

### 1.4 APB 总线接口 / APB Bus Interface

#### LRS.INTF.UART.01.003 APB4 从接口访问（新增）

<!-- LRS_META
id: LRS.INTF.UART.01.003
category: INTF
ip: UART
feature: apb_bus
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应提供 APB4 从接口接入方式，通过新增 `apb2tlul` wrapper 将 APB 事务转换为 TL-UL 事务，再驱动 UART 核心寄存器堆。
2. APB 接口应包括 `psel_i`、`penable_i`、`pwrite_i`、`paddr_i`（位宽 ≥ 8）、`pwdata_i`、`prdata_o`、`pready_o`、`pslverr_o` 等信号。
3. APB wrapper 应仅在协议层做转换，不得改动 UART 核心 RTL 行为；核心寄存器地址映射与 TL-UL 方式一致（64 字节块）。
4. APB wrapper 应支持 32 位读写；非法地址访问应返回 `pslverr_o=1`。
5. APB 与 TL-UL 两种接入方式应通过 FuseSoC `.core` 的独立 target 隔离（`default` 用 TL-UL，`apb` 用 APB wrapper），二者不可同时实例化冲突。

##### 验证关注点

1. APB 读写各寄存器与 TL-UL 方式结果一致。
2. APB 非法地址返回 pslverr。
3. APB wrapper 与核心的时序握手（setup/access phase）符合 APB4 规范。

---

### 1.5 串行 IO 接口 / Serial IO Interface

#### LRS.INTF.UART.01.004 串行收发接口

<!-- LRS_META
id: LRS.INTF.UART.01.004
category: INTF
ip: UART
feature: serial_io
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应提供串行接收输入 `cio_rx_i` 与串行发送输出 `cio_tx_o`。
2. 模块应提供 `cio_tx_en_o` 输出使能，正常工作时恒为 1（`uart.sv` 中 `assign cio_tx_en_o = 1'b1`）。
3. 空闲状态下 TX/RX 线应为高电平；帧起始位为低电平（1→0）。
4. `available_input_list`/`available_output_list` 定义 `rx` 与 `tx` 为对外 IO。

##### 验证关注点

1. 空闲电平正确、起始位检测正确。
2. cio_tx_en_o 恒为 1。
3. 8 数据位 LSB 先发、可选奇偶位、停止位时序正确。

---

### 1.6 中断接口 / Interrupt Interface

#### LRS.INTF.UART.01.005 中断输出接口

<!-- LRS_META
id: LRS.INTF.UART.01.005
category: INTF
ip: UART
feature: interrupt
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应输出 9 个中断：`intr_tx_watermark_o`、`intr_tx_empty_o`、`intr_rx_watermark_o`、`intr_tx_done_o`、`intr_rx_overflow_o`、`intr_rx_frame_err_o`、`intr_rx_break_err_o`、`intr_rx_timeout_o`、`intr_rx_parity_err_o`。
2. `tx_watermark`、`tx_empty`、`rx_watermark` 为电平型 status 中断（`interrupt_list` type=status），复位后 `tx_watermark`、`tx_empty` 默认置 1。
3. 其余中断（tx_done、rx_overflow、rx_frame_err、rx_break_err、rx_timeout、rx_parity_err）为事件型，通过 `INTR_STATE`/`INTR_ENABLE`/`INTR_TEST`/`INTR_STATUS` 寄存器管理（W1C 清除）。

##### 验证关注点

1. 每个中断的触发条件、使能、状态清除、测试置位行为正确。
2. 电平型中断持续保持、事件型中断清除后撤销。

---

### 1.7 Alert 接口 / Alert Interface

#### LRS.INTF.UART.01.006 Alert 接口

<!-- LRS_META
id: LRS.INTF.UART.01.006
category: INTF
ip: UART
feature: alert
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 `prim_alert_pkg::alert_rx_t`/`alert_tx_t` 接口上报 `fatal_fault` alert（`NumAlerts=1`）。
2. `fatal_fault` alert 应由 TL-UL 总线完整性错误触发。
3. 应支持 `ALERT_TEST` 寄存器测试注入 alert。

##### 验证关注点

1. 总线完整性错误触发 fatal_fault。
2. ALERT_TEST 写入后 alert_tx_o 行为正确。
3. alert 信号异步路径正确（AlertAsyncOn=1）。

---

### 1.8 其他接口 / Other Interfaces

#### LRS.INTF.UART.01.007 lsio_trigger 触发输出

<!-- LRS_META
id: LRS.INTF.UART.01.007
category: INTF
ip: UART
feature: lsio_trigger
priority: P2
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应输出 `lsio_trigger_o`，为自清除的状态触发信号（供 DMA 使用）。
2. 当 RX 或 TX FIFO 越过配置水位（与 watermark 中断行为一致）时应触发该信号。
3. 触发行为应与 `inter_signal_list` 中 `lsio_trigger` 定义一致。

##### 验证关注点

1. FIFO 水位触发时 lsio_trigger_o 有效。
2. 触发后自清除。

---

#### LRS.INTF.UART.01.008 RACL 接口

<!-- LRS_META
id: LRS.INTF.UART.01.008
category: INTF
ip: UART
feature: racl
priority: P2
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应提供 RACL 输入 `racl_policies_i` 与错误输出 `racl_error_o`（`top_racl_pkg`）。
2. 默认 `EnableRacl=0`，RACL 功能关闭；`racl_error_o` 应输出已知值。

##### 验证关注点

1. EnableRacl=0 时 RACL 路径不影响正常功能。
2. racl_error_o 输出已知值。

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
