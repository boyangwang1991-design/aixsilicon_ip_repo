# APB Demux 覆盖率策略

本文档是 `verification_plan.md` 第 10 章的详细展开。

## 1. 功能覆盖率

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.01
name: direction_cov
type: functional
feature_ref: FL.FUNC.APB_DEMUX.01
description: 事务方向覆盖（read/write）
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.02
name: port_cov
type: functional
feature_ref: FL.FUNC.APB_DEMUX.01
description: 命中端口覆盖（每个下游端口被访问）
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.03
name: wait_cov
type: functional
feature_ref: FL.FUNC.APB_DEMUX.03
description: wait-state 周期数覆盖（0/1/多周期）
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.04
name: miss_cov
type: functional
feature_ref: FL.FUNC.APB_DEMUX.05
description: Decode Miss 命中覆盖
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.05
name: pslverr_cov
type: functional
feature_ref: FL.FUNC.APB_DEMUX.04
description: PSLVERR 返回覆盖
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.06
name: remap_cov
type: functional
feature_ref: FL.FUNC.APB_DEMUX.06
description: remap 开关状态覆盖
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.07
name: timeout_cov
type: functional
feature_ref: FL.FUNC.APB_DEMUX.07
description: timeout 触发覆盖
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.08
name: num_slaves_cov
type: functional
feature_ref: FL.CFG.APB_DEMUX.01
description: NUM_SLAVES 参数组合覆盖（1/2/4/8/16）
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.FUNC.APB_DEMUX.09
name: apb4_cov
type: functional
feature_ref: FL.INTF.APB_DEMUX.01
description: APB4 PSTRB/PPROT 活动覆盖
END_COVERAGE_META -->

## 2. 交叉覆盖

| ID | 维度 | 说明 |
|----|------|------|
| 方向 × 端口 | read/write × 每端口 | 每个端口读写均被覆盖 |
| wait × miss | wait 数 × decode miss | 边界组合 |
| PSLVERR × 端口 | error × 每端口 | 每端口 error 透传 |

## 3. 代码与断言覆盖

| 类型 | 目标 |
|------|------|
| code coverage（line/toggle/fsm） | ≥ 90% |
| functional coverage | ≥ 90% |
| assertion coverage | 100%（所有断言被触发） |

## 4. 排除规则

| ID | 排除项 | 理由 |
|----|--------|------|
| EXCL-001 | reset 期间 toggle | 复位状态确定性翻转，无意义 |

## 5. 覆盖率目标

- Full Regression 后合并覆盖率数据库；
- Coverage summary 记录 functional/code/assertion 的 achieved/target；
- 未达 target 项记录 waiver 并审计。

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite - 06-verification-plan*
