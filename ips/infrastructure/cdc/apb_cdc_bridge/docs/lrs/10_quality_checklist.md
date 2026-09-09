# APB CDC Bridge — LRS 质量检查清单

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 需求完整性

| 类别 | 文件 | 需求数 | 状态 |
|------|------|--------|------|
| INTF | `01_interface.md` | 6 | ✔ |
| FUNC | `02_functional.md` | 14 | ✔ |
| REG | `03_register.md` | 0 | N/A |
| PERF | `04_performance.md` | 3 | ✔ |
| LP | `05_low_power.md` | 2 | ✔ |
| SAFE | `06_safety.md` | 0 | N/A |
| SEC | `07_security.md` | 0 | N/A |
| CONS | `08_constraint.md` | 3 | ✔ |
| DFX | `09_dfx.md` | 1 | ✔ |
| **合计** | | **30** | |

## 2. 需求编号一致性

- 所有需求 ID 使用 `LRS.<CATEGORY>.APB_CDC_BRIDGE.<GROUP>.<INDEX>` 格式。
- `<IP>` 段与 `--ip-name`（`apb_cdc_bridge` → 模型 `ip_name`）保持一致（extractor 以
  `--ip-name` 为准，文档内 IP 段统一为 `APB_CDC_BRIDGE`，模型生成后以 extractor 输出核对）。

## 3. 可验证性检查

| 检查项 | 结果 |
|--------|------|
| 每条 must 需求有 `verify_method` | ✔（全部） |
| 每条需求有唯一 ID | ✔ |
| 每条需求有 title/category/feature/priority/description/status | ✔ |
| 无歧义/无冲突 | ✔ |
| 需求可追踪（TC → FL → LRS） | ✔（后续 06/16 阶段闭环） |

## 4. 优先级分布

| 优先级 | 数量 | 说明 |
|--------|------|------|
| must（P0） | 19 | 协议正确性、CDC 安全、复位语义、实现隔离为核心 |
| should（P1） | 11 | PPA、延迟、可配置性优化 |
| may（P2） | 0 | — |

## 5. 发现项 / Findings

| ID | 严重度 | 描述 | 状态 |
|----|--------|------|------|
| LRS-F1 | Info | `vc_formal` 工具缺失，formal 类验证方法需在可用工具环境补充 | 记录 |
| LRS-F2 | Info | `SYNC_BRIDGE` 实现为 V1.0 预留，不在当前验收范围 | 记录 |

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
