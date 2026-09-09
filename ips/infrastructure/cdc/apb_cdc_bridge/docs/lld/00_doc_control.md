# APB CDC Bridge — LLD 文档控制

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

## 1. 修订记录

| 版本 | 日期 | 修订说明 |
|------|------|----------|
| v0.1 | 2026-09-07 | 初稿：双实现（HANDSHAKE/ASYNC_FIFO）微设计 |

## 2. 参考输入

| 模型 | 路径 |
|------|------|
| 架构模型 | `model/architecture.yaml` |
| 外部接口 | `model/external_interface.yaml` |
| 内部接口 | `model/internal_interface.yaml` |
| 时钟域 | `model/clock_domains.yaml` |
| CDC 路径 | `model/cdc_paths.yaml` |

## 3. 模块清单（LLD 粒度）

| LLD 模块 | HLD 引用 | 说明 |
|----------|----------|------|
| `LLD.MOD.APB_CDC_BRIDGE.TOP` | `HLD.MOD.L1.APB_CDC_BRIDGE.TOP` | 顶层参数化/集成 |
| `LLD.MOD.APB_CDC_BRIDGE.SOURCE` | `HLD.MOD.L1.APB_CDC_BRIDGE.SOURCE` | 源域捕获 FSM |
| `LLD.MOD.APB_CDC_BRIDGE.DEST` | `HLD.MOD.L1.APB_CDC_BRIDGE.DEST` | 目的域生成 FSM |
| `LLD.MOD.APB_CDC_BRIDGE.SYNC` | `HLD.MOD.L1.APB_CDC_BRIDGE.SYNC` | 2FF 同步器链 |
| `LLD.MOD.APB_CDC_BRIDGE.HS_CDC` | `HLD.MOD.L1.APB_CDC_BRIDGE.DEST` | HANDSHAKE CDC 实现 |
| `LLD.MOD.APB_CDC_BRIDGE.FIFO_CDC` | `HLD.MOD.L1.APB_CDC_BRIDGE.DEST` | ASYNC_FIFO CDC 实现 |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 05-lld-microdesign*
