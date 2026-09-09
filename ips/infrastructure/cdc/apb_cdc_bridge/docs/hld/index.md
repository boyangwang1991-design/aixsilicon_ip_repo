# APB CDC Bridge — HLD 主索引

> **IP Name**: `apb_cdc_bridge` | **VLNV**: `aixsilicon:ip:apb_cdc_bridge:1.0.0`
> **Gate**: G1 | **Status**: Draft

## 1. 文档控制

| 项目 | 内容 |
|------|------|
| 文档 ID | `aixsilicon:ip:apb_cdc_bridge:hld` |
| 拥有者 | rtl-team |
| 创建日期 | 2026-09-07 |
| 当前版本 | v1.0 |
| 输入 | `model/requirements.yaml`（G0 PASS） |

## 2. 文档结构

| 文件 | 内容 |
|------|------|
| [`00_overview.md`](00_overview.md) | IP 架构概述、数据流、复杂度 |
| [`01_architecture.md`](01_architecture.md) | 系统架构、模块分解（HLD_META） |
| [`02_functional.md`](02_functional.md) | 功能行为、事务流程 |
| [`03_interface.md`](03_interface.md) | 外部接口（HLD_IF_META） |
| [`04_clock_power.md`](04_clock_power.md) | 时钟/复位/电源域（HLD_CLK_META + HLD_CDC_META） |
| [`05_safety.md`](05_safety.md) | 功能安全（N/A） |
| [`06_dfx.md`](06_dfx.md) | 可测性/可观测 |
| [`07_decomposition.md`](07_decomposition.md) | 内部接口分解（HLD_INT_IF_META） |
| [`08_risk_checklist.md`](08_risk_checklist.md) | 风险清单 |

## 3. 架构原则

1. **双时钟域隔离**：源域与目的域仅通过 CDC 原语（synchronizer/handshake/FIFO）交互。
2. **Bundled-data CDC**：payload 打包后单控制握手跨域，禁止逐 bit 同步。
3. **单事务**：任一时刻一个跨桥事务 active。
4. **HANDSHAKE 默认**：area/power 优先；ASYNC_FIFO 可选增强 decoupling。
5. **Reset-abort**：任一侧复位中止进行中事务，无 stale transfer。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 03-hld-architect*
