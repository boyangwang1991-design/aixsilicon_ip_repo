# G2 微架构与寄存器检查

当前 LLD 为 draft，尚未取得针对本版新增周期/字段行为的独立冻结输入。用户的剩余流程执行授权持续有效，不重复请求一般执行权限。G2不能由作者将本轮新增设计直接自封通过。

检查包覆盖九个模块、122项字段行为、内部/外部接口、状态机、队列竞争、复位与实现映射。抽取结果不代表自然语言正确性或CSR实际时序通过。需先评审这些行为，再由02生成SystemRDL及原生CSR证据，最后运行G2机器检查；详见../reviews/g2_review.md。

未闭合：实际CSR external接口首ACCESS语义、RDL字段结构/派生物/hash、独立微架构/字段行为冻结、VPLAN及官方trace。CR-004受控协议核验及CR-005实际集成/PPA输入仍开放。禁止将这些缺口标为NA来通过完整流程。
<!-- LLD_GATE_META
gate: G2
status: open
microarchitecture_freeze: false
register_behavior_freeze: false
approvals:
  architecture: pending review of current LLD
  register_behavior: pending review of current field behavior
END_LLD_GATE_META -->
