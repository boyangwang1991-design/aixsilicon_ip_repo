# G1 评审与风险

## 架构决策

准入与路由分离以确保拒绝在下游 SETUP 前生效；策略存储独占原子更新，审计不回压事务。
用户于本轮明确批准现有 G1 评审包；后续执行授权持续有效。

## 当前风险与关闭条件

| ID | 风险/假设 | owner 与关闭条件 |
|---|---|---|
| HLD-R01 | 直接准入与完整性组合路径较长 | LLD/STA 检查完整路径；不得加未声明等待 |
| HLD-R02 | APB VIP developing，HWIF 文档含超出本 IP 的可选信号 | VPLAN/HWIF 核对 APB4 子集与 MASTERID 扩展，不直接采用额外 PWAKEUP |
| HLD-R03 | FIFO 通用 CBB 缺少本契约同步清空和深度1 | LLD 设计合同队列并覆盖清空/POP/新记录竞争 |
| HLD-R04 | 尚无受控 IHI 0024 版本核验 | 协议 owner 补齐 CR-004，不宣称兼容核验已完成 |
| HLD-R05 | 工艺、地址与信任来源为具体集成待填 | 集成/PPA owner 完成 CR-005，验证夹具不替代产品配置 |
| HLD-R06 | G1 evaluator 可能只检查追踪而忽略 freeze | 以本文件真实状态为准，不由作者自行提升 |

## 交接检查

需求分配、接口所有权、参数影响、域、寄存器组、故障边界和 LLD 工作包均已形成。
机器抽取及来源引用审计见 reports/quality/hld；G1 已取得用户批准，见 docs/reviews/g1_approval.md。
<!-- HLD_DECISION_META
id: ADR.APB_SECURE_DEMUX.ADMISSION.001
level: HLD
status: accepted
options:
- 准入与转发责任分离
- 转发后才做拒绝
decision: 选择在下游 SETUP 前完成准入，并由独立路由责任维持已发出的事务。
req_ref:
- LRS.CONS.APB_SECURE_DEMUX.PPA.014
- LRS.FUNC.APB_SECURE_DEMUX.ERRORPRIORITY.008
- LRS.INTF.APB_SECURE_DEMUX.APB.001
- LRS.INTF.APB_SECURE_DEMUX.APB.002
- LRS.INTF.APB_SECURE_DEMUX.APB.003
- LRS.INTF.APB_SECURE_DEMUX.APB.004
- LRS.INTF.APB_SECURE_DEMUX.APB.00501
- LRS.INTF.APB_SECURE_DEMUX.APB.00502
END_HLD_DECISION_META -->

<!-- HLD_GATE_META
gate: G1
status: pass
architecture_freeze: true
approvals:
  architecture: user approval recorded in docs/reviews/g1_approval.md
END_HLD_GATE_META -->

