# APB CDC Bridge 集成指南

> **IP**: `apb_cdc_bridge` | **版本**: 1.0.0 | **日期**: 2026-09-07

## 1. 集成概述

APB CDC Bridge 连接不同时钟域的 APB Initiator 与 APB Target。上游 APB（`s_pclk` 域）
与下游 APB（`m_pclk` 域）完全独立。

## 2. 端口连接

| 端口组 | 信号 | 说明 |
|--------|------|------|
| 上游 APB | `s_pclk/s_presetn` + `s_psel/s_penable/s_paddr/s_pwrite/s_pwdata/s_pstrb/s_pprot/s_prdata/s_pready/s_pslverr` | 连接 APB Initiator |
| 下游 APB | `m_pclk/m_presetn` + `m_psel/m_penable/m_paddr/m_pwrite/m_pwdata/m_pstrb/m_pprot/m_prdata/m_pready/m_pslverr` | 连接 APB Target |

## 3. 参数配置

| 参数 | 默认 | 说明 |
|------|------|------|
| `ADDR_WIDTH` | 32 | 地址位宽（16-64） |
| `DATA_WIDTH` | 32 | 数据位宽（8/16/32/64/128） |
| `CDC_IMPL` | 0 | 0=HANDSHAKE（默认），1=ASYNC_FIFO |
| `SYNC_STAGES` | 2 | 同步器级数（>=2） |
| `REQ_DEPTH/RSP_DEPTH` | 1 | FIFO 深度（仅 ASYNC_FIFO，1/2） |
| `APB_PROFILE` | 1 | 1=APB4，0=APB3 |
| `CDC_MODE` | 0 | 0=ASYNC_SAFE（默认） |

## 4. 时钟与复位

- `s_pclk`/`m_pclk`：完全异步，无频率/相位假设。
- `s_presetn`/`m_presetn`：独立，async assert / sync deassert。
- 时钟暂停：任一域暂停时事务保持 pending，恢复后继续。

## 5. 集成注意事项

1. 地址空间由外部互连保证（Bridge 不做译码）。
2. CDC signoff：同步器/握手/FIFO 为 bundled-data 结构，要求 SpyGlass CDC 检查。
3. Reset 后事务可被中止（reset-abort），系统不得假设 reset 跨越事务仍有效。

## 6. FuseSoC 使用

```bash
fusesoc --cores-root=<ip_repo> run --target=lint aixsilicon:ip:apb_cdc_bridge
```
