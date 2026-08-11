# 性能需求 - UART (uart)
# Performance Requirements - UART (uart)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md) 获取完整结构。
> 性能定义参考 OpenTitan UART `doc/theory_of_operation.md`（波特率、误差容限）与 `data/uart.hjson`（FIFO 深度）。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **PERF**：性能需求（波特率范围、波特率误差容限、FIFO 深度、资源参数等）

---

## 1. 性能需求 / Performance Requirements

### 1.1 波特率与吞吐 / Baud Rate & Throughput

#### LRS.PERF.UART.01.001 波特率范围

<!-- LRS_META
id: LRS.PERF.UART.01.001
category: PERF
ip: UART
feature: baud_rate_range
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应支持最高 1 Mbit/s 的波特率（`uart.hjson` one_line_desc）。
2. 波特率由 `CTRL.NCO`（16 位）与系统时钟频率共同决定：`f_baud = (1/16) × (NCO/2^16) × f_pclk`。
3. 实际波特率取决于系统时钟与 NCO 配置，理论上可配置范围覆盖常用波特率（1200–1M bit/s）。

##### 验证关注点

1. 配置不同波特率并测量实际 bit-time 与理论值一致。
2. 最高波特率（1 Mbit/s）下功能正确。

---

#### LRS.PERF.UART.01.002 波特率误差容限

<!-- LRS_META
id: LRS.PERF.UART.01.002
category: PERF
ip: UART
feature: baud_error_tolerance
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 模块应满足 OpenTitan 定义的波特率误差容限：无奇偶时采样窗为 ±8 tick / 144 ≈ ±5.5%，奇偶使能时为 ±8 tick / 160 ≈ ±5%。
2. 收发两侧各自相对理想波特率偏差应 ≤ ±2.5% 时能正确通信。
3. NCO 向下取整产生的波特率误差：当 NCO 计算值 ≥ 40 时，误差应 < 2.5%（满足通信要求）。

##### 验证关注点

1. 收发波特率偏差在 ±2.5% 内正常通信。
2. 超出容限时出现帧/采样错误（验证误差边界）。

---

### 1.2 FIFO 深度与资源 / FIFO Depth & Resources

#### LRS.PERF.UART.01.003 FIFO 深度参数

<!-- LRS_META
id: LRS.PERF.UART.01.003
category: PERF
ip: UART
feature: fifo_depth
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. TX FIFO 深度应为 `TxFifoDepth=32` 字节。
2. RX FIFO 深度应为 `RxFifoDepth=64` 字节。
3. FIFO 深度参数应可参数化（`uart_reg_pkg` 中 `parameter`），但受 CSR 布局约束，深度必须 < 256（`ASSERT_INIT`：TxFifoDepth/RxFifoDepth < 256）。

##### 验证关注点

1. FIFO 深度在默认 32/64 下满/空/水位行为正确。
2. 参数化深度改动后功能仍正确（边界检查）。

---

#### LRS.PERF.UART.01.004 单字节传输延迟

<!-- LRS_META
id: LRS.PERF.UART.01.004
category: PERF
ip: UART
feature: transfer_latency
priority: P2
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 单字节传输时间为 10（无奇偶）或 11（有奇偶）个 bit-time。
2. 软件写入 WDATA 后，数据应进入 FIFO 并在 TX 使能后开始发送，无额外协议延迟。

##### 验证关注点

1. 一字节发送周期测量正确。
2. WDATA 写入到串行输出开始的时间。

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 01-lrs-author*
