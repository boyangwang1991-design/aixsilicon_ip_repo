# AXI Memory Protection Unit（AXI MPU）— 高层设计（HLD）

> **IP Name**: `axi_mpu`
> **Document**: HLD-AXI_MPU-V100
> **Status**: Draft

## 文档索引

| 章节 | 文件 | 内容 |
|------|------|------|
| 0 | [00_overview.md](00_overview.md) | 文档控制 + 架构目标/复杂度（含 `HLD_DOC_META`） |
| 1 | [01_architecture.md](01_architecture.md) | 模块划分（`HLD_MODULE_META`） |
| 2 | [02_functional.md](02_functional.md) | 数据流/策略（`HLD_FLOW/POLICY_META`） |
| 3 | [03_interface.md](03_interface.md) | 外部/内部接口（`HLD_INTERFACE_META`） |
| 4 | [04_clock_power.md](04_clock_power.md) | 时钟/复位/CDC/性能（`DOMAIN/CDC/PERF_META`） |
| 5 | [05_safety.md](05_safety.md) | 安全（`HLD_SAFETY_META`） |
| 6 | [06_dfx.md](06_dfx.md) | DFX/约束（`HLD_CONSTRAINT_META`） |
| 7 | [07_decomposition.md](07_decomposition.md) | LLD 分解建议 |
| 8 | [08_risk_checklist.md](08_risk_checklist.md) | 风险 + G1 门禁（`HLD_GATE_META`） |

## 上游输入

| 输入 | Baseline | 状态 |
|------|----------|------|
| LRS | LRS-AXI_MPU-V100 | Frozen |
| AXI4 Spec (IHI0022) | Approved | Approved |
| APB4 Spec (IHI0024) | Approved | Approved |
| 契约 | memory_protection_controller_contract.md | Draft Baseline |
