# X2P IP 概述 - 00 Overview

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 应用背景 / Context

X2P 是一个可参数化 AXI-to-APB Bridge，用于连接 AXI 系统互联与 APB 外设子系统。

系统位置：

```mermaid
flowchart LR
    M[AXI Master / AXI Fabric] --> X[X2P AXI-to-APB Bridge]
    X --> P[Single APB Master]
    P --> S[APB Slave Subsystem]
```

拓扑固定为 1 AXI Slave → 1 APB Master。X2P 不负责 APB 多 Slave 地址译码。

## 2. 功能简介 / Feature Overview

X2P V1.0 为 Full Feature 版本，包含：

- AXI4 / AXI4-Lite 到 APB3 / APB4 的协议转换
- AXI Read/Write Channel 管理
- AXI Burst（INCR/FIXED/WRAP）到 APB Single Transfer 拆解
- Narrow Access
- AXI/APB 数据宽度转换（Wide-to-Narrow / Narrow-to-Wide / Same Width）
- Write Strobe 转换（WSTRB → PSTRB）
- APB3 Partial Write 策略（返回 SLVERR）
- AXI/APB Response 转换（OKAY/SLVERR）
- APB Wait-State 与 Timeout
- Request Buffering（可配置深度）
- Read/Write Arbitration（ROUND_ROBIN/READ_PRIORITY/WRITE_PRIORITY）
- 同步/异步时钟域（SYNC/ASYNC）
- 可选输入/输出流水（AXI_INPUT_REG / AXI_OUTPUT_REG / APB_OUTPUT_REG）
- AXI Protection Attribute 转换（AWPROT/ARPROT → PPROT）

## 3. 配置参数 / Parameters

| 参数 | 默认值 | 说明 |
|---|---|---|
| AXI_PROFILE | AXI4 | AXI4 / AXI4_LITE |
| APB_PROFILE | APB4 | APB3 / APB4 |
| AXI_ADDR_WIDTH | 32 | AXI 地址位宽 |
| AXI_DATA_WIDTH | 64 | AXI 数据位宽（32/64/128） |
| AXI_ID_WIDTH | 4 | AXI ID 位宽 |
| APB_ADDR_WIDTH | 32 | APB 地址位宽 |
| APB_DATA_WIDTH | 32 | APB 数据位宽（32/64） |
| READ_REQUEST_DEPTH | 4 | 读请求队列深度（1/2/4/8） |
| WRITE_REQUEST_DEPTH | 4 | 写请求队列深度（1/2/4/8） |
| ARB_POLICY | ROUND_ROBIN | ROUND_ROBIN/READ_PRIORITY/WRITE_PRIORITY |
| ARB_GRANULARITY | BEAT | AXI_BEAT/AXI_TRANSACTION |
| TIMEOUT_ENABLE | 1 | APB 超时使能 |
| TIMEOUT_CYCLES | 256 | APB 超时周期数 |
| CLOCK_MODE | SYNC | SYNC/ASYNC |
| CDC_REQ_DEPTH | 4 | 请求侧 CDC FIFO 深度 |
| CDC_RSP_DEPTH | 4 | 响应侧 CDC FIFO 深度 |
| AXI_INPUT_REG | 0 | AXI 输入流水 |
| AXI_OUTPUT_REG | 0 | AXI 输出流水 |
| APB_OUTPUT_REG | 1 | APB 输出流水 |

## 4. 推荐 Profile / Recommended Profiles

| Profile | 配置 |
|---|---|
| MINIMAL | AXI4-Lite, 32b AXI, 32b APB4, SYNC, Depth=1, No timeout, No regslice |
| STANDARD | AXI4, 64b AXI, 32b APB4, Full burst, Depth=4, RR, SYNC, Timeout |
| ASYNC | AXI4, 64b AXI, 32b APB4, Full burst, Depth=4, RR, ASYNC, CDC, Timeout |

## 5. 关键设计原则 / Key Principles

1. **AXI Frontend 与 APB Backend 通过内部 Transaction Request/Response 接口解耦**。
2. **Width Conversion 在 CDC 之前完成**（APB-sized request 跨域，缩小 CDC FIFO）。
3. **R/W 仲裁粒度到 AXI Beat，但 AXI Beat 内部的 APB Sub-Transfer 不可切分**（原子调度单元）。
4. **APB Backend 永远串行执行单个 APB Transfer**；Request Buffer 提供 AXI 侧解耦。
5. **CDC 在 Transaction Level 完成**，不直接跨 PSEL/PENABLE/PREADY 信号。

---

*文档版本: v1.0*
*创建日期: 2026-09-03*
*创建者: IP Development Suite - 01-lrs-author*