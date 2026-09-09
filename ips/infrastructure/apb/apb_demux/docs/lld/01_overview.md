# APB Demux — LLD 概述

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 微架构概述

APB Demux 采用**单模块参数化 SystemVerilog** 实现（`apb_demux_top.sv`），
内部由以下逻辑块组成：

1. **地址译码（组合）**：`hit[i] = (PADDR & ADDR_MASK[i]) == (BASE_ADDR[i] & ADDR_MASK[i])`；
2. **PSEL 生成（组合）**：`M_PSEL[i] = upstream_PSEL & hit[i]`；
3. **请求 fanout（组合）**：`PADDR/PENABLE/PWRITE/PWDATA/PSTRB/PPROT` 广播；
4. **响应 mux（组合）**：按选中端口 mux `PRDATA/PREADY/PSLVERR`；
5. **Decode Miss 处理（组合）**：无命中时 `PREADY=1, PSLVERR=1, PRDATA=0`；
6. **可选 Timeout（时序）**：ACCESS phase + `PREADY=0` 计数；
7. **可选 Response Register（时序）**：响应路径寄存器。

默认配置（无 timeout、无 response register）下为**纯组合路径**，IP 自身零延迟。

## 2. 关键设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 模块结构 | 单文件参数化 RTL | 保持简单，避免过度拆分（LRS CONS 02.001） |
| 地址译码 | 组合（不 latch selection） | APB 要求 PADDR 稳定，wait-state 期间 selection 自然稳定 |
| 响应路径 | 默认组合 | 低延迟（LRS PERF 01.001） |
| Timeout | 可选时序逻辑 | 防 APB hang 兜底 |
| Remap | 静态地址偏移 | 仅支持静态配置（LRS FUNC 06.002） |

## 3. 模块清单

| LLD 模块 | 对应 HLD 模块 | RTL |
|----------|---------------|-----|
| LLD.MOD.APB_DEMUX.TOP | HLD.MOD.L1.APB_DEMUX.TOP | `apb_demux_top.sv` |

LLD 将 HLD 的 4 个 L1 模块（TOP/DECODE/ROUTE/ERR）合并为单一 RTL 模块内的
逻辑块（符合 HLD 07_decomposition 建议）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
