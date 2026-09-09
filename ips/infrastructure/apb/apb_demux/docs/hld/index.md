# APB Demux — HLD 主索引

> **IP Name**: `apb_demux`
> **VLNV**: `aixsilicon:ip:apb_demux:1.0.0`
> **Version**: 1.0.0
> **Status**: Draft / G1 Candidate
> **协议**: AMBA APB3 / APB4
> **拓扑**: 1 APB Upstream × N APB Downstream

---

## 1. 文档控制

| 项目 | 内容 |
|------|------|
| 文档 ID | `aixsilicon:ip:apb_demux:hld` |
| 拥有者 | rtl-team |
| 创建日期 | 2026-09-09 |
| 当前版本 | v1.0 |
| 评审状态 | Draft / G1 Candidate |

## 2. 修订记录

| 版本 | 日期 | 修订说明 |
|------|------|----------|
| v0.1 | 2026-09-09 | 从冻结 LRS 创建 HLD |

## 3. 设计 ID 规范

```text
HLD.MOD.L1.APB_DEMUX.<MODULE>
HLD.IF.EXT.APB_DEMUX.<IF>
HLD.IF.INT.APB_DEMUX.<IF>
HLD.DOM.APB_DEMUX.<DOMAIN>
HLD.FLOW.APB_DEMUX.<FLOW>
HLD.POL.APB_DEMUX.<POLICY>
```

## 4. 文档结构

| 文件 | 内容 | 状态 |
|------|------|------|
| [`00_overview.md`](00_overview.md) | 文档控制 + 架构目标 + 设计输入 | ✔ |
| [`01_architecture.md`](01_architecture.md) | 模块划分（HLD_MODULE_META） | ✔ |
| [`02_functional.md`](02_functional.md) | 数据流/策略（HLD_FLOW/POLICY_META） | ✔ |
| [`03_interface.md`](03_interface.md) | 外部/内部接口（HLD_INTERFACE_META） | ✔ |
| [`04_clock_power.md`](04_clock_power.md) | 时钟/复位/CDC/性能（DOMAIN/CDC/PERF_META） | ✔ |
| [`05_safety.md`](05_safety.md) | 安全（HLD_SAFETY_META，N/A 声明） | ✔ |
| [`06_dfx.md`](06_dfx.md) | 约束（HLD_CONSTRAINT_META） | ✔ |
| [`07_decomposition.md`](07_decomposition.md) | LLD 分解建议 | ✔ |
| [`08_risk_checklist.md`](08_risk_checklist.md) | 风险 + G1 门禁（HLD_GATE_META） | ✔ |

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
