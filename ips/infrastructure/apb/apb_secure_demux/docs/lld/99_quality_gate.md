# G2 微架构与寄存器检查

当前LLD/字段行为已由用户“approve and proceed all process”批准，冻结对应40个已核对哈希的评审输入。用户的剩余流程执行授权持续有效，不重复请求一般执行权限。原生寄存器生成、结构审计、vlogan及VCS接口探针证据已取得，见reports/quality/register_check.md。

检查包覆盖九个模块、122项字段行为、内部/外部接口、状态机、队列竞争、复位与实现映射。抽取结果不代表自然语言正确性或CSR实际时序通过。这些行为已批准，由02生成SystemRDL及原生CSR证据，最后运行G2机器检查；详见../reviews/g2_review.md。

G2已核验原生CSR external接口首ACCESS、RDL结构/派生物和来源；VPLAN及官方trace为随后阶段。CR-004受控协议核验及CR-005实际集成/PPA输入仍开放。禁止将这些缺口标为NA来通过完整流程。
<!-- LLD_GATE_META
gate: G2
status: pass
microarchitecture_freeze: true
register_behavior_freeze: true
approvals:
  architecture: user approval; docs/reviews/g2_behavior_approval.md
  register_behavior: user approval; docs/reviews/g2_behavior_approval.md
END_LLD_GATE_META -->
