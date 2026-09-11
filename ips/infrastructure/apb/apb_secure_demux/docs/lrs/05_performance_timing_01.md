# 两种时序模式（1）

来源：输入契约的 TIM 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.PERF.APB_SECURE_DEMUX.TIM.001

<!-- LRS_META
id: LRS.PERF.APB_SECURE_DEMUX.TIM.001
category: PERF
feature: tim
priority: P0
status: active
source_ref:
- REQ-TIM-001
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

SETUP 的组合权限路径须纳入 STA，包括地址/身份/PPROT 到下游 PSEL 的路径；不承诺物理意义的无毛刺安全隔离。

#### Acceptance Criteria

- 应满足：SETUP 的组合权限路径须纳入 STA，包括地址/身份/PPROT 到下游 PSEL 的路径；不承诺物理意义的无毛刺安全隔离。
- 测量 SETUP 至完成的周期数并检查受控时序报告，分别报告直接和寄存模式。

### LRS.PERF.APB_SECURE_DEMUX.TIM.002

<!-- LRS_META
id: LRS.PERF.APB_SECURE_DEMUX.TIM.002
category: PERF
feature: tim
priority: P0
status: active
source_ref:
- REQ-TIM-002
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

零等待下游比直接模式多一个上游等待周期；该模式寄存请求路径，不保证切断下游响应到上游响应的组合路径。

#### Acceptance Criteria

- 应满足：零等待下游比直接模式多一个上游等待周期；该模式寄存请求路径，不保证切断下游响应到上游响应的组合路径。
- 测量 SETUP 至完成的周期数并检查受控时序报告，分别报告直接和寄存模式。

### LRS.PERF.APB_SECURE_DEMUX.TIM.003

<!-- LRS_META
id: LRS.PERF.APB_SECURE_DEMUX.TIM.003
category: PERF
feature: tim
priority: P0
status: active
source_ref:
- REQ-TIM-003
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

本地 CSR 和权限拒绝不走下游转发状态机，仍在第一个 ACCESS 周期完成。

#### Acceptance Criteria

- 应满足：本地 CSR 和权限拒绝不走下游转发状态机，仍在第一个 ACCESS 周期完成。
- 测量 SETUP 至完成的周期数并检查受控时序报告，分别报告直接和寄存模式。

### LRS.PERF.APB_SECURE_DEMUX.TIM.004

<!-- LRS_META
id: LRS.PERF.APB_SECURE_DEMUX.TIM.004
category: PERF
feature: tim
priority: P0
status: active
source_ref:
- REQ-TIM-004
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

寄存模式必须锁存 PADDR/PWDATA/PSTRB/PWRITE/PPROT/MASTERID 和版本，禁止仅锁存地址却使用下一笔数据。

#### Acceptance Criteria

- 应满足：寄存模式必须锁存 PADDR/PWDATA/PSTRB/PWRITE/PPROT/MASTERID 和版本，禁止仅锁存地址却使用下一笔数据。
- 测量 SETUP 至完成的周期数并检查受控时序报告，分别报告直接和寄存模式。

