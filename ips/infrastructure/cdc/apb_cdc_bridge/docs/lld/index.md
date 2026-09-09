# APB CDC Bridge — LLD 主索引

> **IP Name**: `apb_cdc_bridge` | **VLNV**: `aixsilicon:ip:apb_cdc_bridge:1.0.0`
> **Gate**: G2 | **Status**: Draft

## 1. 文档控制

| 项目 | 内容 |
|------|------|
| 文档 ID | `aixsilicon:ip:apb_cdc_bridge:lld` |
| 拥有者 | rtl-team |
| 创建日期 | 2026-09-07 |
| 输入 | `model/architecture.yaml`、`model/external_interface.yaml`、`model/internal_interface.yaml`、`model/clock_domains.yaml`、`model/cdc_paths.yaml`（G1 PASS） |

## 2. 文档结构

| 文件 | 内容 |
|------|------|
| [`00_doc_control.md`](00_doc_control.md) | 文档控制与修订记录 |
| [`01_overview.md`](01_overview.md) | 微架构概述、模块清单 |
| [`02_global_constraints.md`](02_global_constraints.md) | 全局约束、参数契约、PPA 预算 |
| [`03_top.md`](03_top.md) | TOP 模块微设计（LLD.MOD.*.TOP） |
| [`03_source.md`](03_source.md) | SOURCE 模块微设计（LLD.MOD.*.SOURCE） |
| [`03_dest.md`](03_dest.md) | DEST 模块微设计（LLD.MOD.*.DEST） |
| [`03_sync.md`](03_sync.md) | SYNC 模块微设计（LLD.MOD.*.SYNC） |
| [`03_handshake_cdc.md`](03_handshake_cdc.md) | HANDSHAKE CDC 实现微设计（LLD.MOD.*.HS_CDC） |
| [`03_fifo_cdc.md`](03_fifo_cdc.md) | ASYNC_FIFO CDC 实现微设计（LLD.MOD.*.FIFO_CDC） |
| [`06_verification.md`](06_verification.md) | 验证要点 |
| [`07_delivery_mapping.md`](07_delivery_mapping.md) | 交付映射 |
| [`08_appendix.md`](08_appendix.md) | 附录 |

## 3. 微架构原则

1. **CDC_IMPL 参数隔离**：`CDC_IMPL = HANDSHAKE` 例化 `handshake_cdc`；`CDC_IMPL = ASYNC_FIFO` 例化 `fifo_cdc`。两者共享统一 `req_channel`/`rsp_channel` 接口契约，互不干扰。
2. **单事务**：任一时刻一个跨桥事务 active（`CDC_IMPL` 不影响该语义）。
3. **Bundled-data**：payload 打包单 toggle 握手跨域。
4. **PPA**：HANDSHAKE 为最低面积/功耗；FIFO 仅按需（REQ_DEPTH/RSP_DEPTH 1/2）。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 05-lld-microdesign*
