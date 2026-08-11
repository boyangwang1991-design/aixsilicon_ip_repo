# 功能需求 - UART (uart)
# Functional Requirements - UART (uart)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md) 获取完整结构。
> 功能定义参考 OpenTitan UART `doc/theory_of_operation.md` 与 `data/uart.hjson` 的 features 列表。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **FUNC**：功能需求（串行帧、收发、波特率、回环、错误检测、中断、FIFO、噪声滤波等）

---

## 1. 功能需求 / Functional Requirements

### 1.1 串行帧格式 / Serial Frame Format

#### LRS.FUNC.UART.01.001 串行帧格式

<!-- LRS_META
id: LRS.FUNC.UART.01.001
category: FUNC
ip: UART
feature: serial_frame
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应支持标准 UART 帧：空闲高电平 → 起始位（0）→ 8 数据位（LSB 先发）→ 可选奇偶位 → 停止位（1）。
2. 数据格式应固定为 8 位（`uart.hjson`: "The data format is restricted to 8 bits"）。
3. 奇偶使能时帧为 START + 8 data + parity + STOP（共 11 bit-time）；未使能时为 START + 8 data + STOP（共 10 bit-time）。
4. 未使能奇偶时停止位在数据第 8 位后；使能时在奇偶位后。

##### 验证关注点

1. 8 数据位 LSB 先发时序正确。
2. 奇偶使能/未使能两种帧长与采样点正确。
3. 起始/停止位电平正确。

---

### 1.2 波特率控制 / Baud Rate Control

#### LRS.FUNC.UART.01.002 波特率可编程

<!-- LRS_META
id: LRS.FUNC.UART.01.002
category: FUNC
ip: UART
feature: baud_rate
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 `CTRL.NCO`（16 位）配置波特率，满足 `UART.BAUD_RATE_CONTROL` feature。
2. 波特率计算公式：`f_baud = (1/16) × (NCO / 2^16) × f_pclk`；NCO 计数溢出产生 16x baud tick。
3. 最高支持 1 Mbit/s 波特率。
4. NCO=0 时应不产生 baud tick（模块不传输）。

##### 验证关注点

1. 不同 NCO 值对应波特率正确（测量 bit-time）。
2. NCO=0 时无传输发生。
3. 波特率误差在接收容限内可正确通信。

---

### 1.3 发送功能 / Transmission

#### LRS.FUNC.UART.01.003 TX 发送与 TX FIFO

<!-- LRS_META
id: LRS.FUNC.UART.01.003
category: FUNC
ip: UART
feature: tx_path
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应提供 TX 发送路径：写 `WDATA` 将数据字节入队到 TX FIFO（深度 `TxFifoDepth=32`）。
2. `CTRL.TX` 使能后，`uart_tx` 从 FIFO 出队并按波特率逐位发送到 `cio_tx_o`。
3. 若 TX 未使能，写入 WDATA 的数据应堆积在 FIFO 中，TX 使能后再发送。
4. 当 FIFO 在发送过程中变空时，应在最后一字节发送完成后置位 `tx_done` 中断（与 watermark 中断独立）。

##### 验证关注点

1. TX FIFO 入队/出队、空/满状态正确。
2. TX 未使能时数据堆积、使能后发送。
3. tx_done 在末字节发完后触发。

---

### 1.4 接收功能 / Reception

#### LRS.FUNC.UART.01.004 RX 接收与 RX FIFO

<!-- LRS_META
id: LRS.FUNC.UART.01.004
category: FUNC
ip: UART
feature: rx_path
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应提供 RX 接收路径：`uart_rx` 以 16x 波特率对 `cio_rx_i` 过采样。
2. 检测到低电平后应于半个 bit-time（8 个过采样周期）确认 START 位；若线已恢复高则忽略毛刺。
3. 确认 START 后应在每个 bit-time 中点采样，收集 8 数据位（及可选奇偶位）到字符缓冲。
4. STOP 位为高且奇偶正确时，数据字节应压入 RX FIFO（深度 `RxFifoDepth=64`），软件读 `RDATA` 取出。

##### 验证关注点

1. 正常接收一帧数据正确入 FIFO、RDATA 读回正确。
2. 毛刺（< 半 bit-time 的低脉冲）被忽略。
3. 接收中途起始位消失（glitch abort）时回到空闲。

---

### 1.5 奇偶校验 / Parity

#### LRS.FUNC.UART.01.005 奇偶校验

<!-- LRS_META
id: LRS.FUNC.UART.01.005
category: FUNC
ip: UART
feature: parity
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应满足 `UART.PARITY` feature：`CTRL.PARITY_EN` 使能后在收发方向附加/检查奇偶位。
2. `CTRL.PARITY_ODD` 选择奇偶类型：1=奇校验，0=偶校验。
3. 接收时若奇偶位极性错误，应置位 `rx_parity_err` 中断。

##### 验证关注点

1. 奇/偶两种校验的发送附加位正确。
2. 接收校验错误触发 rx_parity_err。

---

### 1.6 回环模式 / Loopback

#### LRS.FUNC.UART.01.006 系统回环 SLPBK

<!-- LRS_META
id: LRS.FUNC.UART.01.006
category: FUNC
ip: UART
feature: system_loopback
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应满足 `UART.SYSTEM_LOOPBACK` feature：`CTRL.SLPBK` 置位后，发送到 TX 的位应被 RX 侧接收。
2. SLPBK 使能时 TX 线输出应为 1。

##### 验证关注点

1. SLPBK 使能后发送的数据被自身 RX FIFO 接收。
2. TX 线在 SLPBK 时为 1。

---

#### LRS.FUNC.UART.01.007 线路回环 LLPBK

<!-- LRS_META
id: LRS.FUNC.UART.01.007
category: FUNC
ip: UART
feature: line_loopback
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应满足 `UART.LINE_LOOPBACK` feature：`CTRL.LLPBK` 置位后，输入位应被转发到 TX 侧。
2. LLPBK 使能时内部设计应视 RX 值为 1。

##### 验证关注点

1. LLPBK 使能后 RX 输入在 TX 引脚上复现。
2. LLPBK 使能时内部 RX 视为 1（无数据被真正接收）。

---

### 1.7 中断检测 / Break Detection

#### LRS.FUNC.UART.01.008 线路中断检测

<!-- LRS_META
id: LRS.FUNC.UART.01.008
category: FUNC
ip: UART
feature: break_detection
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应满足 `UART.LINE_BREAK` feature：检测 RX 引脚连续为低超过可编程字符数即为中断。
2. `CTRL.RXBLVL` 应可配置检测阈值：2/4/8/16 字符时间（enum: break2/break4/break8/break16）。
3. 检测到中断应置位 `rx_break_err` 中断；每发生一次中断只产生一次事件，线恢复高至少半 bit-time 后才可再次检测。

##### 验证关注点

1. 四种 RXBLVL 阈值的 break 检测正确。
2. 一次 break 仅产生一次中断。
3. 线恢复后再次 break 可重新触发。

---

### 1.8 RX 超时 / RX Timeout

#### LRS.FUNC.UART.01.009 RX 超时检测

<!-- LRS_META
id: LRS.FUNC.UART.01.009
category: FUNC
ip: UART
feature: rx_timeout
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应支持 RX 超时：`TIMEOUT_CTRL.EN` 使能、`TIMEOUT_CTRL.VAL`（24 位）配置超时值（UART bit-time 数）。
2. 若 RX FIFO 中有字符在程序设定时间内未被取走，应置位 `rx_timeout` 中断。

##### 验证关注点

1. 超时值到时且 FIFO 非空时触发 rx_timeout。
2. 取走数据后超时状态清除、再次计数。

---

### 1.9 噪声滤波 / Noise Filter

#### LRS.FUNC.UART.01.010 RX 噪声滤波

<!-- LRS_META
id: LRS.FUNC.UART.01.010
category: FUNC
ip: UART
feature: noise_filter
priority: P2
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应满足 `UART.NOISE_FILTER` feature：`CTRL.NF` 置位后，RX 线经过 3-tap 重复码滤波。
2. 噪声滤波应能忽略单周期 IP 时钟毛刺。

##### 验证关注点

1. NF 使能后单周期毛刺被滤除。
2. NF 关闭时无滤波行为。

---

### 1.10 FIFO 控制 / FIFO Control

#### LRS.FUNC.UART.01.011 FIFO 复位与水位

<!-- LRS_META
id: LRS.FUNC.UART.01.011
category: FUNC
ip: UART
feature: fifo_control
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 `FIFO_CTRL.RXRST`/`FIFO_CTRL.TXRST` 提供 RX/TX FIFO 软复位（写 1 复位，读返回 0）。
2. `FIFO_CTRL.RXILVL` 应配置 RX watermark 触发电平（1/2/4/8/16/32/62 字符，`rx_watermark`）。
3. `FIFO_CTRL.TXILVL` 应配置 TX watermark 触发电平（1/2/4/8/16 字符，`tx_watermark`）。
4. `FIFO_STATUS.TXLVL`/`FIFO_STATUS.RXLVL` 应提供当前 FIFO 填充水平。
5. `STATUS` 寄存器应提供 TXFULL/RXFULL/TXEMPTY/TXIDLE/RXIDLE/RXEMPTY 状态。

##### 验证关注点

1. FIFO 软复位后深度计数清零。
2. watermark 触发与 FIFO 水位关系正确（RX ≥ level、TX < level）。
3. FIFO_STATUS 与 STATUS 反映实时水位。

---

#### LRS.FUNC.UART.01.012 RX FIFO 溢出

<!-- LRS_META
id: LRS.FUNC.UART.01.012
category: FUNC
ip: UART
feature: rx_overflow
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应满足 `UART.FIFO_INTERRUPTS` feature：RX FIFO 满时若再收到字符，应置位 `rx_overflow` 中断并丢弃该字符。

##### 验证关注点

1. FIFO 满时额外字符触发 rx_overflow 且不写入 FIFO。

---

### 1.13 中断管理 / Interrupt Management

#### LRS.FUNC.UART.01.013 中断状态/使能/测试

<!-- LRS_META
id: LRS.FUNC.UART.01.013
category: FUNC
ip: UART
feature: interrupt_management
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 `INTR_STATE`（W1C 清除）、`INTR_ENABLE`、`INTR_TEST`（软件置位）、`INTR_STATUS`（state & enable）管理 9 个中断。
2. 电平型中断（tx_watermark/tx_empty/rx_watermark）持续保持，不能通过写状态寄存器清除。
3. 事件型中断在 `INTR_STATE` 写 1 后清除。

##### 验证关注点

1. 中断使能/屏蔽/测试/状态清除行为正确。
2. 电平型中断持续有效。

---

### 1.14 TX 覆盖 / TX Override

#### LRS.FUNC.UART.01.014 TX 引脚覆盖

<!-- LRS_META
id: LRS.FUNC.UART.01.014
category: FUNC
ip: UART
feature: tx_override
priority: P2
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 `OVRD.TXEN` 使能 TX 引脚覆盖，`OVRD.TXVAL` 设定覆盖电平，直接控制 TX 引脚状态。
2. 覆盖使能会强制 TX 输出为 OVRD.TXVAL（可能造成协议违规，供调试用）。

##### 验证关注点

1. OVRD 使能后 TX 引脚电平受控。
2. 关闭覆盖后恢复正常发送。

---

### 1.15 过采样观测 / Oversample Observation

#### LRS.FUNC.UART.01.015 过采样值读取

<!-- LRS_META
id: LRS.FUNC.UART.01.015
category: FUNC
ip: UART
feature: oversample_observation
priority: P2
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应通过 `VAL.RX`（16 位）提供最近 16 次 RX 过采样值，最近位在 bit0，最旧位在 bit15。

##### 验证关注点

1. VAL 寄存器反映 RX 过采样历史。

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
