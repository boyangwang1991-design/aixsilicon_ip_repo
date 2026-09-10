# AXI Memory Protection Unit（AXI MPU）— 验证方案

> **IP Name**: `axi_mpu`
> **Document**: VPLAN-AXI_MPU-V100
> **Status**: Draft

## 文档索引

| 文档 | 文件 | 内容 |
|------|------|------|
| 主方案 | [verification_plan.md](verification_plan.md) | VPLAN_META、范围、策略、signoff |
| 功能列表 | [feature_list.md](feature_list.md) | `FEATURE_META` |
| 测试矩阵 | [test_matrix.md](test_matrix.md) | `TESTCASE_META` |
| 比对器计划 | [checker_plan.md](checker_plan.md) | `ASSERTION_META`、Checker/RM 策略 |
| 覆盖率计划 | [coverage_plan.md](coverage_plan.md) | `COVERAGE_META` |
| Agent 计划 | [agent_plan.md](agent_plan.md) | Agent 结构、active/passive 模式 |

## 追踪链

```text
LRS (model/requirements.yaml)
  ↓ req_ref
Feature (FL.AXI_MPU.*)
  ├── Testcase (feature_ref) → req_to_test trace
  ├── Assertion (feature_ref)
  └── Coverage (feature_ref)
```

Testcase 通过 `feature_ref` 引用 Feature；Feature 通过 `req_ref` 引用需求。
Testcase 不直接携带 `req_ref`。

## 范围概览

- DUT：`axi_mpu`（Generator IP：AXI4 主/从 + APB4 配置 + IRQ）
- 验证对象：Read/Write Protection、Region、Master/Security/Privilege/RWX 权限、
  Burst Boundary、Write Decision Queue、多 Outstanding、Local DECERR、
  Violation Logging/IRQ、Region/Global Lock、Default Deny
- 参考模型：UVM Reference Model（transaction-level，独立于 RTL 算法）
- 工具链：VCS（simulation）、UVM 1.2、SpyGlass（lint）、VCS Assertions
