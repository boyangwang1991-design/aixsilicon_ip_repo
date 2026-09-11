# Watchdog：外部接口与信任边界

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.INTF.WATCHDOG.IF.001

<!-- LRS_META
id: LRS.INTF.WATCHDOG.IF.001
category: INTF
feature: if
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-IF-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

未使用可信来源功能的系统必须将来源固定为 0，并在外部限制服务访问者；不得宣称任务身份隔离。权限拒绝不得转化为喂狗。

#### Acceptance Criteria

- 无可信来源时固定来源 0，并记录外部访问控制；拒绝事务不刷新任何通道。

## LRS.INTF.WATCHDOG.IF.002

<!-- LRS_META
id: LRS.INTF.WATCHDOG.IF.002
category: INTF
feature: if
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-IF-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IRQ 依赖 pclk 同步；pclk 停止时，安全告警、唤醒和复位请求仍必须工作。复位请求不得依赖 IRQ 被软件处理。

#### Acceptance Criteria

- 停止 pclk 后触发预警/故障，WDT 域唤醒及复位请求照常产生并保持。

## LRS.INTF.WATCHDOG.IF.003

<!-- LRS_META
id: LRS.INTF.WATCHDOG.IF.003
category: INTF
feature: if
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-IF-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

任意异步输入必须由集成层同步或握手，禁止异步脉冲直接接入。硬件事件基础接口仅接受 wdt_clk 同域输入；其他域使用外部无丢失事件桥，不直接接裸脉冲。

#### Acceptance Criteria

- 接口连接审查确认异步输入有同步或完整握手，跨域硬件事件不使用裸脉冲。

## LRS.INTF.WATCHDOG.IF.004

<!-- LRS_META
id: LRS.INTF.WATCHDOG.IF.004
category: INTF
feature: if
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-IF-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IP 不检测自身时钟整体停振；系统必须用独立参考时基或外部看门狗覆盖。若 IP 失电，输出也不能保证有效，系统安全分析必须覆盖电源故障。

#### Acceptance Criteria

- 集成假设明确独立停钟和电源故障检测者；不把本 IP 标成可自检整体停振。

