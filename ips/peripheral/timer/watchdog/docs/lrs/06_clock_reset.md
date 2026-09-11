# Watchdog：时钟、复位与保留

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.RESET.WATCHDOG.RST.001

<!-- LRS_META
id: LRS.RESET.WATCHDOG.RST.001
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-RST-001
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

warm_reset_evt 必须由复位管理器转换为 wdt_clk 单周期事件，或在外部使用完整握手形成一次事件；不得在系统复位电平持续期间每拍重启 WDT。por_n 释放同步链为 SYNC_STAGES 级；AUTO_START 在同步释放后首边沿启动。

#### Acceptance Criteria

- 保持系统复位电平不造成重复 warm；SYNC_STAGES 各值下 AUTO_START 均满足释放边界。

## LRS.RESET.WATCHDOG.RST.002

<!-- LRS_META
id: LRS.RESET.WATCHDOG.RST.002
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-RST-002
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

冗余检查仅在主/影子状态均初始化后的第一个正常边沿起有效；允许的初始屏蔽不得超过 SYNC_STAGES+2 个 wdt_clk 周期。禁止使用可由软件无限保持的“初始化屏蔽”关闭安全诊断。

#### Acceptance Criteria

- 初始化诊断屏蔽不超过 SYNC_STAGES+2；之后故障必检测，软件不能延长屏蔽。

## LRS.RESET.WATCHDOG.RST.003

<!-- LRS_META
id: LRS.RESET.WATCHDOG.RST.003
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-RST-003
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

preset_n 期间 IRQ 输出可复位为低，但释放后必须由保留原始状态重新同步产生；WDT 域复位/唤醒请求不受影响。

#### Acceptance Criteria

- preset 中 IRQ 可低；释放后由保留事件重新产生，WDT 请求全过程保持。

## LRS.RESET.WATCHDOG.RST.004

<!-- LRS_META
id: LRS.RESET.WATCHDOG.RST.004
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-RST-004
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

POR 后留痕丢失属于设计行为。若整机要求断电保持，必须由外部 retention/NVM 记录；本 IP 不隐含非易失存储。

#### Acceptance Criteria

- POR 清历史；文档明确断电保持由外部 retention/NVM 提供。

