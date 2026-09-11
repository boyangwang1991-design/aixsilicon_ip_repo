# Watchdog：可信恢复与次数限制

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.REC.001

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.REC.001
category: FUNC
feature: rec
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REC-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

recovery_done 只在 LOCAL_THEN_SYSTEM、FAULT、局部请求已置位、未到最终期限、ALLOW_LOCAL_RECOVERY=1 时可接受；其他状态不得触发重启或获得宽限。它表示目标复位已经实际完成且恢复条件已满足，不是“请求收到”。

#### Acceptance Criteria

- 只在局部请求已置位、允许恢复且尚未最终到期时接受 done；其他情况不重新开始周期。

## LRS.FUNC.WATCHDOG.REC.002

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.REC.002
category: FUNC
feature: rec
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REC-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

接受后清活动局部请求/NMI，E 清零，保留历史诊断/锁/active 配置，清除旧服务序列及客户端状态，重新进入 BOOT（BOOT_EN=0 则 RUN）。握手 ack 拉高直到 done 拉低；仅接受一次。下一故障若旧 done 未回零，必须等待新的完整握手，不能自动恢复。

#### Acceptance Criteria

- 接受恢复后进入规定起始周期并保留配置/锁/历史；done 未回零不再次接受。

## LRS.FUNC.WATCHDOG.REC.003

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.REC.003
category: FUNC
feature: rec
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REC-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

LOCAL_RECOVERY_LIMIT 为 0～255；0 表示禁止局部恢复，非零为两次可信系统暖复位之间最大允许恢复次数。超出时置 RECOVERY_LIMIT 并最终升级；成功运行和喂狗不清此计数。

#### Acceptance Criteria

- LIMIT=0 禁止恢复，达到限额后下一次恢复尝试最终升级；正常服务不清次数。

## LRS.FUNC.WATCHDOG.REC.004

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.REC.004
category: FUNC
feature: rec
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REC-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

RESET_PENDING 仅由 POR 或可信 warm_reset_evt 解除；warm_reset_evt 表示已完成系统暖复位并进入启动阶段。活动通道自动重新启动，保持锁和 active 配置，恢复计数清零；不自动启动原本 DISABLED 通道。FIRST_FAULT 保留。

#### Acceptance Criteria

- warm 只重新启动原活动通道；锁、active 和 FIRST_FAULT 保留，恢复次数清零。

## LRS.FUNC.WATCHDOG.REC.005

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.REC.005
category: FUNC
feature: rec
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REC-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

任意非看门狗发起的 warm_reset_evt 对运行通道同样重启监督，因此必须限制在可信复位管理器。系统不能允许软件无限伪造该事件规避监督；看门狗不独立承担整机重复复位次数管理。

#### Acceptance Criteria

- 非 WDT 触发的可信 warm 同样重启监督；系统连接证明普通软件不能无限伪造事件。

