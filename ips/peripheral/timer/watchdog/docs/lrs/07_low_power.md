# Watchdog：低功耗与调试暂停

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.LP.WATCHDOG.PWR.001

<!-- LRS_META
id: LRS.LP.WATCHDOG.PWR.001
category: LP
feature: pwr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PWR-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

PAUSE_SLEEP/PAUSE_DEBUG 为 active 配置位，默认均 0。sleep_req 且 PAUSE_SLEEP 可进入 PAUSED；debug_req 且 debug_auth 且 PAUSE_DEBUG 且 !DEBUG_LOCK 可暂停。任一有效暂停源存在则保持暂停，两者均解除后恢复原 BOOT/RUN 状态。

#### Acceptance Criteria

- 分别、同时施加两个暂停源；任一有效源维持暂停，两者解除才恢复原 BOOT/RUN。

## LRS.LP.WATCHDOG.PWR.002

<!-- LRS_META
id: LRS.LP.WATCHDOG.PWR.002
category: LP
feature: pwr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PWR-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

暂停冻结 C、D、服务序列年龄、客户端 Deadline；不改变 active 配置、令牌及本轮 SEEN/ALIVE。进入/退出不授予新周期、不清故障。PAUSED 拒绝服务，不缓存待恢复执行的服务。

#### Acceptance Criteria

- 暂停前后周期相位、序列、客户端、token 保持；PAUSED 服务拒绝且恢复后不重放。

## LRS.LP.WATCHDOG.PWR.003

<!-- LRS_META
id: LRS.LP.WATCHDOG.PWR.003
category: LP
feature: pwr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PWR-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

故障升级、自身完整性检查、锁和诊断逻辑不暂停。自身故障在 PAUSED 仍直接升级。由 debug_auth 失效导致暂停撤销时，下一个运行边沿恢复监督。

#### Acceptance Criteria

- 暂停期间注入自身异常仍升级；debug_auth 撤销后按规定边沿恢复监督。

## LRS.LP.WATCHDOG.PWR.004

<!-- LRS_META
id: LRS.LP.WATCHDOG.PWR.004
category: LP
feature: pwr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PWR-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

sleep 参数切换不另设隐式模式：若需要睡眠专用期限，软件在允许更新的配置中提交新期限并确认其已生效后才能睡眠。禁止以睡眠请求直接重载计数或修改阈值。

#### Acceptance Criteria

- sleep 请求本身不重载阈值；睡眠专用期限只能经已生效的配置提交流程启用。

## LRS.LP.WATCHDOG.PWR.005

<!-- LRS_META
id: LRS.LP.WATCHDOG.PWR.005
category: LP
feature: pwr
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-PWR-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

系统允许无限期暂停时，暂停期间没有时间监督覆盖；若需要暂停时长上限，应由不暂停的其他 WDT 通道或独立电源管理计时器监督。生产安全配置应禁用普通调试冻结。

#### Acceptance Criteria

- 安全说明披露无限暂停期间无时间覆盖，列明外部上限监督者及生产调试策略。

