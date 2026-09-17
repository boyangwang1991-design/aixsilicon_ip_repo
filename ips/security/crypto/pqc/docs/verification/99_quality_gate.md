# PQC 验证方案：VP0 计划门禁

<!-- VPLAN_GATE_META
gate: VP0
status: open
approvals:
  architecture: pending
  rtl: pending
  verification: pending
END_VPLAN_GATE_META -->

## 状态说明

本验证方案由本次执行 Agent 编写。VP0 仅为**计划冻结**子门禁，**不冒充 G3/G4**。
用户已授权自动推进，但未提供独立人类评审结论，因此 VP0 保持 `open`，不代填审批。

## 计划完备性自检

| 检查项 | 结果 |
|---|---|
| 六个内容卷 + index + 独立 Gate 齐备 | PASS |
| 全部 P0 需求均有 feature 承接 | PASS |
| 每个 testcase 有 implementation/feature_ref/stimulus/expected_result | PASS |
| 软件/静态 proof 使用可执行入口且路径合法 | PASS |
| 覆盖率目标与不可达项处理已定义 | PASS |
| 参考模型不接入验证环境（算法正确性走软件证明） | PASS |
| Agent 复用判定以 registry 实际状态为准 | PASS |

G3/G4 由后续 RTL 检查、Module UT、回归与覆盖率证据支撑。