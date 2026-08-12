# HLD 文档概述 - UART

## 1. 文档概述

本文档描述 uart IP 的高层架构设计（HLD），是 LRS 需求到 LLD 微架构设计之间的桥梁。

| 项目 | 值 |
|---|---|
| IP 名称 | uart |
| 显示名称 | UART |
| 版本 | 0.1.0 |
| 基础来源 | OpenTitan UART（`reference/opentitan/hw/ip/uart`，Apache-2.0） |
| 核心代码策略 | 保留 OpenTitan 核心 RTL 原样，仅新增 APB 接入 wrapper |

## 2. 需求概述

HLD 输入为 `model/requirements.yaml`（42 条需求）。must 需求（18 条）覆盖：
- 接口：时钟复位、TL-UL 总线、APB 总线（新增）、串行 IO、中断、alert
- 功能：串行帧、波特率、TX/RX 路径、FIFO 控制、中断管理
- 寄存器：寄存器空间、控制/状态/数据/FIFO/中断寄存器
- 性能：波特率范围、误差容限
- 约束：时钟复位、接口连接、NCO 约束、FIFO 深度

## 3. 架构目标与原则

1. **核心不变原则**：UART 核心 RTL（uart/uart_core/uart_rx/uart_tx/uart_reg_top/uart_reg_pkg）保持 OpenTitan 原版，不做功能修改。
2. **双总线接入**：TL-UL 为原始接口；APB 通过新增 `apb2tlul` wrapper 协议转换接入，二者用 FuseSoC `.core` target 隔离。
3. **寄存器权威源**：`regs/uart.rdl`（SystemRDL）为寄存器文档/C header/HTML/IP-XACT 权威源，与核心 uart_reg_top 地址一致。
4. **单时钟域**：全模块单一时钟 `clk_i`，异步复位同步释放，无内部 CDC。
5. **可综合**：所有 RTL 保持可综合 SystemVerilog，验证专用断言放 verification/。

## 复杂度评估

单时钟域、无 CDC、单从接口（双总线互斥）、寄存器 14 个、FIFO 控制为核心。预期 `complexity_level` 由 extractor 按确定性指标计算。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 03-hld-architect*
