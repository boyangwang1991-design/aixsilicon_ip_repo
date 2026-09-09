# APB CDC Bridge IP 概述 - 00 Overview

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 应用背景 / Context

APB CDC Bridge 用于连接位于不同 Clock Domain 的 APB Initiator 与 APB Target，
在保持 APB 协议语义的前提下完成安全的跨时钟域访问。典型应用包括：

- CPU / 互联域（快时钟）访问外设域（慢时钟）的 APB 寄存器；
- 低频低功耗外设域访问高频系统域；
- 两个完全异步 IP 之间通过 APB 直接互联。

系统位置：

```mermaid
flowchart LR
    M[APB Initiator] -->|s_pclk domain| B[APB CDC Bridge]
    B -->|m_pclk domain| S[APB Target]
```

本 IP 定位为 **Single-Transaction APB Protocol-Preserving Clock-Domain-Crossing
Bridge**：上游 APB 事务被捕获 → CDC 传输 → 下游 APB 事务重新生成 → 响应返回。

## 2. 功能简介 / Feature Overview

- 上游 APB 事务捕获与锁存（Request bundle）
- 安全的 Request / Response bundled-data CDC handshake
- 下游 APB 事务重新生成（SETUP / ACCESS / COMPLETE）
- PRDATA / PSLVERR / completion 状态安全返回上游
- 支持完全异步、快→慢、慢→快、同频异相、同源同步异频
- 独立源/目的时钟域与复位
- HANDSHAKE（默认）/ ASYNC_FIFO 两种 CDC 实现
- 协议 profile 自动裁剪（APB3 / APB4）

## 3. 配置参数 / Parameters

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `ADDR_WIDTH` | 32 | 地址位宽（16 ~ 64） |
| `DATA_WIDTH` | 32 | 数据位宽（8/16/32/64/128） |
| `USER_WIDTH` | 0 | APB5 扩展预留（V1.0 不启用） |
| `CDC_IMPL` | HANDSHAKE | HANDSHAKE / ASYNC_FIFO |
| `SYNC_STAGES` | 2 | 同步器级数（>= 2，推荐 2/3） |
| `REQ_DEPTH` | 1 | Request FIFO 深度（仅 ASYNC_FIFO，1/2） |
| `RSP_DEPTH` | 1 | Response FIFO 深度（仅 ASYNC_FIFO，1/2） |
| `RESET_MODE` | ASYNC | 复位风格（ASYNC assert / SYNC deassert） |
| `APB_PROFILE` | APB4 | APB3 / APB4 |
| `CDC_MODE` | ASYNC_SAFE | `ASYNC_SAFE`（默认，覆盖完全异步/快慢/同频异相等所有异步关系）或 `SYNC_RATIO`（预留，仅同源同步异频专用优化，V1.0 未实现，不提供该值） |

## 4. 推荐 Profile / Recommended Profiles

| Profile | 配置 |
|---------|------|
| LOW_AREA | CDC_IMPL=HANDSHAKE, SYNC_STAGES=2 |
| BALANCED | CDC_IMPL=HANDSHAKE, SYNC_STAGES=2 |
| HIGH_RELIABILITY | CDC_IMPL=HANDSHAKE, SYNC_STAGES=3 |
| BUFFERED | CDC_IMPL=FIFO, REQ_DEPTH=2, RSP_DEPTH=2 |

## 5. 关键设计原则 / Key Principles

1. **协议正确性第一**：所有时钟关系下不得出现事务丢失/重复/部分传输/伪 PREADY。
2. **最小协议状态**：APB 为单事务非流水协议，优先低复杂度 CDC 架构，不无条件引入深 Async FIFO。
3. **Bundled-data CDC**：Request/Response payload 打包后用单一控制握手跨域保护，
   禁止 multi-bit 逐 bit 双触发器同步。
4. **仅同步必要 control**：只同步 control，不把 PADDR/PWDATA/PRDATA 逐 bit 2FF。
5. **快→慢用 wait-state + request holding**；慢→快最小化 CDC 延迟。
6. **未知时钟关系 → Async-safe**；已知同步关系 → 可选专用优化（V1.0 预留）。

## 6. 不支持范围 / Out of Scope

APB 1×N / N×1 译码、多 Initiator 仲裁、AXI/AHB 转换、数据位宽转换、地址重映射、
Multiple Outstanding、Burst、Timeout、Retry、Firewall、ECC/Parity、功能安全监控。

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
