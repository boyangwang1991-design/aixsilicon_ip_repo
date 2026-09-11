# 配置更新与锁（2）

来源：输入契约的 UPD 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.REG.APB_SECURE_DEMUX.UPD.008

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.008
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-008
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

GLOBAL_LOCK=1 后不得修改任何权限/端口配置或执行 reload/commit；PORT_LOCK 的额外置位仍允许，属于收紧保护。

#### Acceptance Criteria

- 应满足：GLOBAL_LOCK=1 后不得修改任何权限/端口配置或执行 reload/commit；PORT_LOCK 的额外置位仍允许，属于收紧保护。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00901

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00901
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-009
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

锁写 0 无效果，读回保留；只有 preset_ni 解除锁。

#### Acceptance Criteria

- 应满足：锁写 0 无效果，读回保留；只有 preset_ni 解除锁。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.00902

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.00902
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-009
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

无软件解锁口令或软复位绕过。

#### Acceptance Criteria

- 应满足：无软件解锁口令或软复位绕过。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.010

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.010
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-010
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

策略锁不阻止日志读取清除、中断处理和授权 DFX 诊断；完整性故障锁存只能可信模块复位恢复。

#### Acceptance Criteria

- 应满足：策略锁不阻止日志读取清除、中断处理和授权 DFX 诊断；完整性故障锁存只能可信模块复位恢复。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

### LRS.REG.APB_SECURE_DEMUX.UPD.011

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.UPD.011
category: REG
feature: upd
priority: P0
status: active
source_ref:
- REQ-UPD-011
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

版本仅为诊断关联号，32 bit 自然回绕；不用于授权、不作为跨复位唯一编号。

#### Acceptance Criteria

- 应满足：版本仅为诊断关联号，32 bit 自然回绕；不用于授权、不作为跨复位唯一编号。
- 对比操作前后全部选中和未选中端口、版本与锁状态；失败必须全量保持原 active。

