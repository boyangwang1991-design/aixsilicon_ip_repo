# AXI Memory Protection Unit（AXI MPU）— 逻辑详细设计（LLD）

> **IP Name**: `axi_mpu`
> **Document**: LLD-AXI_MPU-V100
> **Status**: Draft

## 文档索引

| 章节 | 文件 | 内容 |
|------|------|------|
| 0 | [00_doc_control.md](00_doc_control.md) | 文档控制（含 `LLD_DOC_META`） |
| 1 | [01_overview.md](01_overview.md) | 概览 |
| 2 | [02_global_constraints.md](02_global_constraints.md) | 全局约束 |
| 3 | [03_axi_mpu_top.md](03_axi_mpu_top.md) | 顶层 + 主要模块微架构 |
| 7 | [07_delivery_mapping.md](07_delivery_mapping.md) | RTL 交付映射（`RTL_MAP_META`） |
| 8 | [08_appendix.md](08_appendix.md) | 验证关注点 + G2 门禁 |

## 上游输入

| 输入 | Baseline | 状态 |
|------|----------|------|
| LRS | LRS-AXI_MPU-V100 | Frozen |
| HLD | HLD-AXI_MPU-V100 | Draft |
| AXI4/APB4 Spec | IHI0022/IHI0024 | Approved |
