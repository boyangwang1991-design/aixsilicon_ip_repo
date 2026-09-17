# PQC LRS：G0 门禁

<!-- LRS_GATE_META
gate: G0
status: pass
requirement_freeze: true
note: 当前状态由用户分级预算授权绑定；下方旧开放状态正文仅作历史追溯。
approval:
  kind: user_delegated
  approved_by: user approved security-tier cycle budgets; recorded by Codex
  reviewed_at: '2026-09-16'
  authorization_ref: docs/reviews/g0_security_tier_budget_authorization.md
  authorization_sha256: 27f05956223f0a43f3f18d2cad507d630f93dffb60ecd6455d254cfe92a429ea
  input_sha256: ea56b134b7985c81083c8658b79e9072ee35202027917d333bdc81f8d5e6dd49
END_LRS_GATE_META -->

## 状态说明

本 LRS 由本次执行 Agent 编写并完成作者自校验，`LRS_DOC_META.status` 保持 `reviewed`。
用户已授权自动推进本 IP 的开发流程，但未提供独立人类评审结论，因此按 01-lrs-author
合同要求 G0 保持 `open`、`requirement_freeze` 保持 `false`，不代填审批人。

需求语义变更（接口、验收条件、applicability）时必须重开 G0 并重新校验。

## 作者自校验摘要

| 检查项 | 结果 |
|---|---|
| 需求 ID 全局唯一 | PASS |
| 每条需求含 Requirement 与 Acceptance Criteria | PASS |
| P0 需求均有 verification_method | PASS |
| 条件需求均有 applicability | PASS |
| 无 offset/bit 级寄存器定义泄露进 LRS | PASS |
| 无 RTL 文件/模块/FSM 实现细节泄露进 LRS | PASS |
| 类别覆盖（含 N/A 声明） | PASS |

## 2026-09-16 本轮恢复检查

本轮按用户明确决定修正工作态私钥与长期托管边界，补充专用接口、完整导入、
撤销及 KeyGen 托管确认需求；删除普通私钥输出的歧义，修正错误长度与隐式拒绝
验收条件的冲突。PPA 签核范围改为代码结构评估，不删除功能或多配置要求。

每次分册变更后运行 owning extractor；抽取通过仅表示结构检查成功。
上方历史自校验表不能代替本次实际内容绑定和技术冻结。G0 仍为 open，
尚无对应当前输入的真实审批；既有 HLD/LLD/RTL/验证产物继续保留为待重验候选。
