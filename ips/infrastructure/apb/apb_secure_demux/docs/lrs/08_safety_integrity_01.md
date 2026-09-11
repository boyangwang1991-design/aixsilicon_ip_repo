# 配置完整性（1）

来源：输入契约的 INT 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.SAFE.APB_SECURE_DEMUX.INT.001

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.001
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

POLICY_PARITY_EN=1 时，对每个 active/shadow PERM[7:0] 配置偶校验位，对每个 active/shadow CFG[1:0] 配置偶校验位；正常写、复制、复位同步更新校验。

#### Acceptance Criteria

- 应满足：POLICY_PARITY_EN=1 时，对每个 active/shadow PERM[7:0] 配置偶校验位，对每个 active/shadow CFG[1:0] 配置偶校验位；正常写、复制、复位同步更新校验。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.002

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.002
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

PORT_LOCK 与 GLOBAL_LOCK 使用互补双位编码，合法解锁为 01、合法锁定为 10；00/11 为完整性错误，不得解码为解锁。

#### Acceptance Criteria

- 应满足：PORT_LOCK 与 GLOBAL_LOCK 使用互补双位编码，合法解锁为 01、合法锁定为 10；00/11 为完整性错误，不得解码为解锁。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.00301

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.00301
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

必须持续检查上述全部存储，稳定单 bit 错误最迟在下一 pclk 边沿置 INTEGRITY_FATAL。

#### Acceptance Criteria

- 应满足：必须持续检查上述全部存储，稳定单 bit 错误最迟在下一 pclk 边沿置 INTEGRITY_FATAL。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.00302

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.00302
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

用于当前 SETUP 的组合判权同时受当前原始完整性错误指示门控，不能仅等待粘滞位生效。

#### Acceptance Criteria

- 应满足：用于当前 SETUP 的组合判权同时受当前原始完整性错误指示门控，不能仅等待粘滞位生效。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.004

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.004
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

任一 active/shadow/lock 完整性错误触发全局 FATAL；新外设请求全部拒绝；现有已经发到下游的事务继续完成，不承诺撤销已有副作用。

#### Acceptance Criteria

- 应满足：任一 active/shadow/lock 完整性错误触发全局 FATAL；新外设请求全部拒绝；现有已经发到下游的事务继续完成，不承诺撤销已有副作用。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.005

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.005
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FATAL 后管理诊断入口仍开放，允许读状态/日志/配置和清除普通事件；shadow 写、reload、commit 返回 CFG_INTEGRITY，不支持通过写新 parity 清除 FATAL。

#### Acceptance Criteria

- 应满足：FATAL 后管理诊断入口仍开放，允许读状态/日志/配置和清除普通事件；shadow 写、reload、commit 返回 CFG_INTEGRITY，不支持通过写新 parity 清除 FATAL。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.006

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.006
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

首个完整性位置记录在 INTEGRITY_STATUS；多处同时错误按 global lock、端口升序，每端口 lock→active CFG→shadow CFG→active PERM 主体升序→shadow PERM 主体升序的优先级选择。

#### Acceptance Criteria

- 应满足：首个完整性位置记录在 INTEGRITY_STATUS；多处同时错误按 global lock、端口升序，每端口 lock→active CFG→shadow CFG→active PERM 主体升序→shadow PERM 主体升序的优先级选择。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.00701

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.00701
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

LOCATION_TYPE：0=global lock，1=port lock，2=active CFG，3=shadow CFG，4=active PERM，5=shadow PERM，6=DFX synthetic。

#### Acceptance Criteria

- 应满足：LOCATION_TYPE：0=global lock，1=port lock，2=active CFG，3=shadow CFG，4=active PERM，5=shadow PERM，6=DFX synthetic。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.00702

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.00702
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

MASTER 仅 PERM 类型有效，其余为零。

#### Acceptance Criteria

- 应满足：MASTER 仅 PERM 类型有效，其余为零。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

### LRS.SAFE.APB_SECURE_DEMUX.INT.008

<!-- LRS_META
id: LRS.SAFE.APB_SECURE_DEMUX.INT.008
category: SAFE
feature: int
priority: P0
status: active
source_ref:
- REQ-INT-008
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

POLICY_PARITY_EN=0 时不实现上述存储保护和注入功能，完整性状态读零，普通安全权限仍完整实现。

#### Acceptance Criteria

- 应满足：POLICY_PARITY_EN=0 时不实现上述存储保护和注入功能，完整性状态读零，普通安全权限仍完整实现。
- 注入真实存储单 bit 和锁非法编码，检查当前 SETUP 阻断、下一边沿 FATAL 及在途事务完成；DFX 合成不能替代真实翻转。

