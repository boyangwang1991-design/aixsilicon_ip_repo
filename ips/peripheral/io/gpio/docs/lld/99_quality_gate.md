# GPIO 微设计门禁

<!-- LLD_GATE_META
gate: G2
status: pass
microarchitecture_freeze: true
register_definition_freeze: true
approvals:
  basis: 'user delegated continuation: approve, complete the rest'
  status: user_delegated_design_approval
approval:
  kind: user_delegated
  approved_by: execution_agent_under_existing_user_delegation
  reviewed_at: '2026-09-14T04:42:47.513692+00:00'
  authorization_ref: docs/reviews/lld_authorization.md
  authorization_sha256: 8ae89bdce24d99ad38fcc89803ef6e1ca472df14885cd0ef8ae49b0d1848b382
  input_sha256: 22e6c6398b8974d7cc296d39acef18b462e51fa789052b882dd6bb70bee41738
END_LLD_GATE_META -->

依据用户 `approve, complete the rest` 的继续执行授权，记录委托设计批准。
G2 owning evaluator 已通过：12模块具备细化对象、FSM结构有效、110字段行为完整，
CSR来源哈希一致且VCS编译通过。寄存器结构检查核对753实例的合同地址和名称。
证据见 reports/quality/gate_report.md、reports/quality/register_check.md 和
reports/registers/contract_structure.json。该批准不代表RTL功能、CDC或覆盖率通过。
