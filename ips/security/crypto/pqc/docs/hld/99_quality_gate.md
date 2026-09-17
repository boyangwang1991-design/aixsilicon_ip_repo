# PQC HLD：G1 架构评审入口

<!-- HLD_GATE_META
gate: G1
status: pass
architecture_freeze: true
approval:
  kind: user_delegated
  approved_by: Codex architectural review under user-delegated design decisions
  reviewed_at: '2026-09-16'
  authorization_ref: docs/reviews/g1_delegated_review.md
  authorization_sha256: df3b49aed0aaa5a0247792cb463b04c493098d4858794187e6714b786cf25c76
  input_sha256: 207d9def7d937e0bbbfaa8802b61d3dbbee9dca03c77628f91cc56065f1ffbc0
END_HLD_GATE_META -->

G0 已由用户确认，吞吐预算变更另有明确授权。G1 是新的架构评审，不沿用历史文档中
未绑定证据的全 PASS 清单。本文记录候选设计完成内容与尚未关闭的安全项。

## 本轮候选方案

| 主题 | 可审查设计 |
|---|---|
| 长期/工作态密钥 | 外部 Key Manager 所有权，内部 8 KiB 单副本，专用导入/KeyGen 托管/撤销；材料与元数据分别授权 |
| 完整命令 | shadow 完整抓取后校验，算法数据依赖，输出与 completion 的写响应确认，软件 abort 与 fatal 分界 |
| 算法边界 | KEM 三操作与 DSA 三操作的数据流；Sign c*t0 检查；密钥托管成功先于 KeyGen completion |
| 存储/PPA | 固定映射 8 bank、物理端口预算、实际 lane、页授权与 Tiny 工作集复用；不宣称已实现 |
| 哈希吞吐 | 用户批准分安全等级预算：Level 0/1 为 ceil(R/8)+24/r+2；Level 2 候选为 ceil(R/8)+1896+2；均待实现验证 |
| 文档一致性 | 明确模块/接口/域对象、需求归属、复用候选、LLD 工作包；按分册抽取 |

## 架构评审结论与下游义务

用户已授权后续决策按推荐方案推进，授权原文见
`docs/reviews/delegated_design_decisions.md`。本轮实际评审覆盖：

- 84 条需求的模块归属、接口与域引用，模型由 extractor 重新生成；
- Sign 时序例外及分安全等级哈希预算均有对应 LRS 授权；
- Level 2 两 share、HPC3+、X2X 算法的 prime-modulus 转换、独立数据域与随机服务；
- 原始 X2X RTL 的参数/13-bit/背压限制，明确不能直接当成双算法生产依赖；
- Tiny 两阶段的 23/28 页分配与 w 的跨阶段搬移，转换不复制整向量；
- 全部敏感域的 zeroize 汇聚与外部永久阻塞时锁定，代码结构 PPA 口径。

架构接口、资源归属与预算已经足够作为 LLD 输入。本冻结只批准这些设计合同，
不批准未实现的算法、组合证明或物理泄漏结果。以下是强制下游义务，保持可追踪：

1. G2：确定 X2X 通用化的数学等价、实际 HPC3+ gadget 清单、随机用量、采样候选
   上限与失败概率、固定尝试长度、地址/银行/生命周期和清除完成协议。
2. G3/G4：实际 RTL 六参数集完整算法、独立功能参考、掩码重构、glitch/transition
   组合、随机 token 不复用和所有背压/错误路径验证。
3. Level 1/2 泄漏评估：必须保留实际证据，参数值、论文结果、功能 KAT 和容量
   脚本均不能代替本 IP 的安全验证；Level 2 本轮必交要求不变。

若 LLD 发现预算、表示或组合假设不成立，重新打开 G1 并修订架构，不把已有冻结
当作绕过新缺陷的理由。当前机器结果与总体实现状态以 reports/report.md 为准。
