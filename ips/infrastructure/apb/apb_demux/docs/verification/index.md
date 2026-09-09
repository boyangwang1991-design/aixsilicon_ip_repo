# APB Demux — 验证方案主索引

> **IP Name**: `apb_demux`
> **VLNV**: `aixsilicon:ip:apb_demux:1.0.0`
> **Version**: 1.0.0
> **Status**: Draft
> **验证级别**: regression

---

## 1. 文档结构

| 文件 | 内容 |
|------|------|
| [`verification_plan.md`](verification_plan.md) | 主方案（VPLAN_META） |
| [`feature_list.md`](feature_list.md) | 功能列表（FEATURE_META） |
| [`test_matrix.md`](test_matrix.md) | 测试矩阵（TESTCASE_META） |
| [`checker_plan.md`](checker_plan.md) | 比对器策略（ASSERTION_META） |
| [`coverage_plan.md`](coverage_plan.md) | 覆盖率策略（COVERAGE_META） |
| [`agent_plan.md`](agent_plan.md) | Agent 规划 |

## 2. 追踪链

```text
TC → FL → LRS
TESTCASE_META.feature_ref → FEATURE_META → FEATURE_META.req_ref → LRS
```

## 3. 范围概览

- 验证对象：`apb_demux_top`（1→N APB Router）；
- 协议：APB3/APB4；
- 验证方法：UVM 1.2 + SVA 断言 + 功能覆盖率；
- 关键特性：地址译码 / PSEL onehot / wait-state / PSLVERR 透传 / Decode Miss /
  remap / timeout / response register / 参数组合。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 06-verification-plan*
