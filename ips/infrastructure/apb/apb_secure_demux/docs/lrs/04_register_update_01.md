# 配置更新与锁（1）

来源：输入契约的 UPD 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.REG.APB_SECURE_DEMUX.UPD.001

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.001
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

shadow 可单独读写；正常访问仅使用 active；禁止 shadow 更新直接作用于下游判权。

#### Acceptance Criteria

- 应满足：shadow 可单独读写；正常访问仅使用 active；禁止 shadow 更新直接作用于下游判权。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.002

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.002
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

COMMIT_MASK 指定端口的 CFG_SHADOW 和全部 PERM_SHADOW 在同一完成边沿复制至 active，任何失败全部不提交。

#### Acceptance Criteria

- 应满足：COMMIT_MASK 指定端口的 CFG_SHADOW 和全部 PERM_SHADOW 在同一完成边沿复制至 active，任何失败全部不提交。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.003

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.003
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

非零合法掩码、无相关锁且无完整性故障时提交成功；即使值未变化也增加 POLICY_VERSION。

#### Acceptance Criteria

- 应满足：非零合法掩码、无相关锁且无完整性故障时提交成功；即使值未变化也增加 POLICY_VERSION。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.004

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.004
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

提交为本地单周期 ACCESS，不等待“上游 PSEL 降低”；持续背靠背访问也必须正常提交。

#### Acceptance Criteria

- 应满足：提交为本地单周期 ACCESS，不等待“上游 PSEL 降低”；持续背靠背访问也必须正常提交。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00501

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00501
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

由于仅一个 APB 输入且无后台请求队列，处理 COMMIT 时不得有尚未完成的下游事务。

#### Acceptance Criteria

- 应满足：由于仅一个 APB 输入且无后台请求队列，处理 COMMIT 时不得有尚未完成的下游事务。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00502

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00502
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

实现若引入队列必须维持此串行契约。

#### Acceptance Criteria

- 应满足：实现若引入队列必须维持此串行契约。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00601

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00601
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

COMMIT 完成边沿之后的 SETUP 使用新版本；此前外设事务已完成，不发生跨版本事务。

#### Acceptance Criteria

- 应满足：COMMIT 完成边沿之后的 SETUP 使用新版本；此前外设事务已完成，不发生跨版本事务。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00602

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00602
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

上游桥内部尚未送入本 IP 的排队请求适用到达本 IP 时的策略。

#### Acceptance Criteria

- 应满足：上游桥内部尚未送入本 IP 的排队请求适用到达本 IP 时的策略。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00701

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00701
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

锁对 shadow 写、active 提交和 SHADOW_RELOAD 均生效；写锁只设锁，不隐式提交。

#### Acceptance Criteria

- 应满足：锁对 shadow 写、active 提交和 SHADOW_RELOAD 均生效；写锁只设锁，不隐式提交。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00702

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00702
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

软件必须先提交、读回，再设锁。

#### Acceptance Criteria

- 应满足：软件必须先提交、读回，再设锁。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

