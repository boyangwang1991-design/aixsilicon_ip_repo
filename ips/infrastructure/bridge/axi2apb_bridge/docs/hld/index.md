# HLD 主索引：X2P IP 高层设计

> 文档名称：X2P IP HLD 架构设计说明
> IP 名称：x2p
> 版本：v0.1
> 日期：2026-09-03
> 作者：rtl-team

---

## 文档控制

### 修订记录

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| v0.1 | 2026-09-03 | rtl-team | 初始版本 |

### 评审记录

| 评审日期 | 评审人 | 角色 | 评审意见 | 状态 |
|----------|--------|------|----------|------|
| TBD | TBD | 架构师 | TBD | Open |

---

## 文档结构

| 文件 | 包含章节 | 标记 | 说明 |
|------|----------|------|------|
| [00_overview.md](00_overview.md) | 1-3. 文档概述、需求概述、架构目标 | 必填 | 设计范围、设计目标与原则 |
| [01_architecture.md](01_architecture.md) | 4. 总体架构设计 | 必填 | 系统上下文、顶层框图、模块划分、接口汇总、架构分层 |
| [02_functional.md](02_functional.md) | 5,8,9. 功能/控制/数据通路设计 | 必填 | 功能分解、状态机概览、数据路径、正常/异常流程 |
| [03_interface.md](03_interface.md) | 6,7. 接口与寄存器架构设计 | 必填 | 接口概览、总线接口、寄存器分组（N/A） |
| [04_clock_power.md](04_clock_power.md) | 10,12. 时钟复位与性能设计 | 条件必填 | 时钟架构、复位架构、CDC/RDC、性能预算 |
| [05_safety.md](05_safety.md) | 11. 功能安全架构设计 | 条件必填 | N/A - 无功能安全需求 |
| [06_dfx.md](06_dfx.md) | 13,14,15. 软件/可测性/约束设计 | 可选 | 参数裁剪、约束设计 |
| [07_decomposition.md](07_decomposition.md) | 16,17. HLD 分解与验证规划 | 必填 | LLD 分解建议、RTL 约束、验证特性 |
| [08_risk_checklist.md](08_risk_checklist.md) | 18,19,20. 风险、检查清单与附录 | 必填 | 架构风险、评审检查清单 |

---

## 与 LLD 的边界

- **HLD 负责**：模块划分、职责边界、接口关系、数据流/控制流、时钟复位电源域、性能预算
- **LLD 负责**：FSM 详细设计、时序图、pipeline 详细设计、CDC 策略详细定义
- **HLD 不生成**：具体 RTL always block、FSM 状态编码、接口握手时序、寄存器字段级定义

---

## 设计 ID 命名规范

```text
HLD.MOD.L1.<IP>.<MODULE>     # 一级架构模块 ID
HLD.FLOW.<IP>.<FLOW>         # 数据流/控制流 ID
HLD.DOM.<IP>.<DOMAIN>        # 时钟/复位/电源域 ID
HLD.IF.EXT.<IP>.<INTERFACE>  # 外部接口 ID
HLD.IF.INT.<IP>.<INTERFACE>  # 内部接口 ID