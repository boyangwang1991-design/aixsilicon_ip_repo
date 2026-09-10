# 验收规则

动态测试零错误、mandatory bins 齐全、参数边界通过、真实综合完成、静态告警评审、追踪无孤项。最终详见 ../../reports/acceptance.md。用户授权自主执行；不代填独立审查人，不把表征约束当板级冻结。
<!-- VPLAN_GATE_META
gate: VP0
status: open
verification_plan_freeze: false
approvals:
  architecture: pending
  rtl: pending
  verification: pending
END_VPLAN_GATE_META -->

本次 G5 范围为 experimental IP 交付及 constraints/characterization.sdc 对应的 100 MHz、GF28nm TT 表征。覆盖率按 coverage_plan.md 中用户授权调整后的标准判定。板级 Pad、布线后时序及具体从设备暂停策略属于系统集成验收，不宣称已完成。静态/C proof 使用局部、可审计的评估适配器验证真实执行及哈希；原始套件结果同时保留。
