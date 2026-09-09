# APB CDC Bridge — LLD 交付映射

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 模块 → RTL 文件映射

| LLD 模块 | RTL 文件（预期） | 说明 |
|----------|------------------|------|
| `LLD.MOD.APB_CDC_BRIDGE.TOP` | `rtl/apb_cdc_bridge_top.sv` | 顶层 |
| `LLD.MOD.APB_CDC_BRIDGE.SOURCE` | `rtl/apb_cdc_source.sv` | 源域捕获 |
| `LLD.MOD.APB_CDC_BRIDGE.DEST` | `rtl/apb_cdc_dest.sv` | 目的域生成 |
| `LLD.MOD.APB_CDC_BRIDGE.SYNC` | `rtl/apb_cdc_sync_chain.sv` | 同步器链 |
| `LLD.MOD.APB_CDC_BRIDGE.HS_CDC` | `rtl/apb_cdc_handshake.sv` | HANDSHAKE 实现 |
| `LLD.MOD.APB_CDC_BRIDGE.FIFO_CDC` | `rtl/apb_cdc_async_fifo.sv` | ASYNC_FIFO 实现 |
| — | `rtl/include/apb_cdc_bridge_defs.svh` | 定义头 |
| — | `rtl/filelist.f` | 编译 filelist |

## 2. 验证文件映射

| 产物 | 路径 |
|------|------|
| UVM env | `verification/env/` |
| 协议 agent | `verification/env/utils/apb_utils/` |
| Testcase | `verification/tc/` |
| Harness | `verification/th/harness.sv` |
| 仿真 Makefile | `verification/sim/Makefile` |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 05-lld-microdesign*
