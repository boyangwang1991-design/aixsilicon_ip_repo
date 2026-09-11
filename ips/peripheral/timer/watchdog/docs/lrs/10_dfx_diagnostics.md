# Watchdog：首故障、统计与清除

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.DFX.WATCHDOG.DIA.001

<!-- LRS_META
id: LRS.DFX.WATCHDOG.DIA.001
category: DFX
feature: dia
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-DIA-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

每通道具有 EVENT_RAW、FIRST_FAULT、32-bit 饱和 FAULT_COUNT、LAST_SERVICE_SEQ、MISSING_MASK、RECOVERY_COUNT。EVENT_RAW 所有事件均可累积；FIRST_FAULT 只在进入 FAULT/最终升级时且 VALID=0 时捕获，不被普通 PREWARN/访问错误抢占。

#### Acceptance Criteria

- 非故障预警/访问错误不抢 FIRST_FAULT；故障后新原因不覆盖首次记录。

## LRS.DFX.WATCHDOG.DIA.002

<!-- LRS_META
id: LRS.DFX.WATCHDOG.DIA.002
category: DFX
feature: dia
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-DIA-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FIRST_FAULT 至少包含：原因位图、通道 ID、客户端 ID/有效位、可信来源/有效位、C 候选年龄、原通道状态、配置版本、缺失 mask、服务序号、TEST_CONTEXT。超时无唯一客户端时 client_valid=0；不得伪造某个客户端 ID。

#### Acceptance Criteria

- 首故障字段完整且时间一致；无唯一客户端时 valid=0，不能伪造来源身份。

## LRS.DFX.WATCHDOG.DIA.003

<!-- LRS_META
id: LRS.DFX.WATCHDOG.DIA.003
category: DFX
feature: dia
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-DIA-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

同拍多个原因全部记录为位图，主原因按位11～14/17、16、1/6、9、8、7、2、3、4、其余的顺序编码。多个通道同时故障分别保存，各通道不争用一个全局首次记录。

#### Acceptance Criteria

- 同时原因完整置位且主原因符合优先序；多通道同时故障分别保留。

## LRS.DFX.WATCHDOG.DIA.004

<!-- LRS_META
id: LRS.DFX.WATCHDOG.DIA.004
category: DFX
feature: dia
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-DIA-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FAULT_COUNT 每次从正常/暂停状态进入 FAULT 或直接最终升级增加一次；同一次故障后升级不重复增加。饱和后保持最大值并置 SAT 标志；统计不可影响检测。

#### Acceptance Criteria

- 每次进入故障只加一次，后续升级不重复计数；最大值饱和并置 SAT，检测继续。

## LRS.DFX.WATCHDOG.DIA.005

<!-- LRS_META
id: LRS.DFX.WATCHDOG.DIA.005
category: DFX
feature: dia
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-DIA-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IRQ_CLEAR 仅 W1C 清 EVENT_RAW；活动 NMI/复位请求不随其消失。即使清除了 TIMEOUT 历史位，活动 FAULT 仍保持。清 FIRST_FAULT 使用 DIAG_CLEAR，要求授权/解锁且无活动故障；新故障和清除同拍时保留新故障。

#### Acceptance Criteria

- 清历史位不解除活动故障；活动故障禁止清首故障，清除与新故障同拍保留新故障。

## LRS.DFX.WATCHDOG.DIA.006

<!-- LRS_META
id: LRS.DFX.WATCHDOG.DIA.006
category: DFX
feature: dia
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-DIA-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

DIAG_CLEAR 应允许独立选择清除 FIRST_FAULT 或 FAULT_COUNT；保留位非法写拒绝。不得清锁、恢复次数或活动请求，未选中诊断保持。字段编码由 SystemRDL 定义。

#### Acceptance Criteria

- DIAG_CLEAR 按选择只清首故障或次数；锁、恢复次数和活动请求均保持。

