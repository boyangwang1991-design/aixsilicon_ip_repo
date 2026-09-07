# X2P 用户手册

> 文档版本: v1.0 · 日期: 2026-09-03

## 1. 简介

X2P（AXI-to-APB Bridge）将 AXI 系统互联连接到单一 APB 外设从设备，
支持协议转换、Burst 拆解（INCR/FIXED/WRAP）、Narrow/数据宽度转换、
Write Strobe、Read/Write 仲裁、APB Wait-State/Timeout、SYNC/ASYNC 时钟与 CDC。

## 2. 端口说明

| 端口组 | 信号 | 说明 |
|---|---|---|
| AXI Slave | AW/W/B/AR/R | 五通道（参数化位宽/ID） |
| APB Master | PADDR/PSEL/PENABLE/PWRITE/PWDATA/PRDATA/PREADY/PSLVERR(+PSTRB/PPROT) | 单 Select |
| 时钟 | aclk/pclk | 同/异步 |
| 复位 | aresetn/presetn | 低有效，独立 |

## 3. 使用建议（Profile）

| Profile | 配置 |
|---|---|
| MINIMAL | AXI4-Lite/32b/APB4/32b/SYNC/Depth1/No timeout |
| STANDARD | AXI4/64b/APB4/32b/Full/Depth4/RR/SYNC/Timeout(256) |
| ASYNC   | STANDARD + CLOCK_MODE=ASYNC + CDC depth |

## 4. 协议行为要点

- APB3 写 partial（非完整 word）→ AXI SLVERR；不做自动 RMW。
- APB PSLVERR=1 → AXI SLVERR；APB timeout → AXI SLVERR。
- ROUND_ROBIN 仲裁无永久饥饿；AXI Beat 内 sub-transfer 原子。

## 5. 已知限制

- 不支持 APB 多 slave 译码；不支持 AXI3/ACE/CHI。
- **BUG-001（未解决）**：AXI 读路径 RVALID 未建立，正式使用前需修复。