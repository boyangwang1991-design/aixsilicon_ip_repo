# HLD 质量检查报告 - X2P

## 基本信息
- IP: x2p
- 校验日期: 2026-09-03

## 抽取结果

| 项 | 数量 |
|---|---|
| L1 模块 | 7 |
| 外部接口 | 6 |
| 内部接口 | 0（无显式 HLD_INT_IF_META，回退自动派生） |
| 时钟/复位/电源域 | 4 |
| CDC 路径 | 2 |
| 复杂度等级 | simple（extractor 确定性计算：SYNC 单时钟/无 CDC 降级标签；文档定性 medium，以 extractor 为准） |

## 校验结果

| 检查项 | 结果 |
|---|---|
| 模块 ID 唯一性 | ✅ |
| 模块层级完整性 | ✅ |
| 所有模块有 req_ref | ✅ |
| 时钟/复位/电源域完整 | ✅ |
| 42 条 LRS 需求全部被模块覆盖 | ✅ |

## 结论

**G1 PASS / Architecture Freeze**：架构基线冻结。关键决策：
1. CDC 在 burst/width 拆分之后跨 APB-sized request（CDC FIFO 小）。
2. R/W 仲裁到 AXI Beat 粒度，Beat 内 sub-transfer 原子不可切分。