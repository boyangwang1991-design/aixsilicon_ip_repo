# Watchdog：计时、窗口与同拍优先级

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.FUNC.WATCHDOG.TIM.001

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.TIM.001
category: FUNC
feature: tim
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TIM-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

通道包含 W-bit 饱和向上计数 `C` 和分频相位 `D`。启动/成功刷新边沿设 `C=0,D=0`。此后每个 wdt_clk 边沿：若 `D=P`，产生 tick 并置 `D=0`；否则 `D=D+1`。因此每 `P+1` 个边沿产生一次 tick。

#### Acceptance Criteria

- P=0、P 最大值及代表中间值时，连续 tick 间隔精确为 P+1；成功刷新重建周期相位。

## LRS.FUNC.WATCHDOG.TIM.002

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.TIM.002
category: FUNC
feature: tim
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TIM-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

每个运行边沿先计算候选年龄 `A = tick ? sat(C+1) : C`，所有窗口、预警、超时及服务合法性均用 A。无成功刷新时 `C=A`；成功刷新则 `C=0,D=0`。启动边沿本身不执行年龄递增。

#### Acceptance Criteria

- tick 和非 tick 边沿均以候选年龄决定服务结果；启动边沿年龄为零。

## LRS.FUNC.WATCHDOG.TIM.003

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.TIM.003
category: FUNC
feature: tim
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TIM-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

正常周期：`A >= TIMEOUT` 必须判超时；窗口开启时，完整服务仅在 `WIN_MIN <= A < TIMEOUT` 合法；普通模式等效 `WIN_MIN=0`。TIMEOUT 边沿的服务必须失败。允许在 WIN_MIN 边沿成功。

#### Acceptance Criteria

- WIN_MIN-1 拒绝、WIN_MIN 接受、TIMEOUT-1 接受、TIMEOUT 拒绝；覆盖分频相位。

## LRS.FUNC.WATCHDOG.TIM.004

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.TIM.004
category: FUNC
feature: tim
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TIM-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

PRETIMEOUT 使能且 `A >= PRETIMEOUT`、本周期尚未预警时，产生一次预警事件。该边沿若有成功刷新则不产生新的预警；已存在的历史预警不自动清除。计数饱和不能导致超时消失。

#### Acceptance Criteria

- 阈值触发每周期一次；同拍成功服务抑制新预警，历史预警保持，饱和不丢失故障。

## LRS.FUNC.WATCHDOG.TIM.005

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.TIM.005
category: FUNC
feature: tim
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TIM-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

未暂停时，从刷新/启动边沿到超时故障边沿恰为 `TIMEOUT*(P+1)` 个 wdt_clk 周期。启动周期改用 BOOT_TIMEOUT。软件应按最坏时钟偏差、总线/CDC 延迟预留服务裕量。

#### Acceptance Criteria

- 无暂停时故障边沿与 TIMEOUT*(P+1) 完全一致；BOOT 使用 BOOT_TIMEOUT。

## LRS.FUNC.WATCHDOG.TIM.006

<!-- LRS_META
id: LRS.FUNC.WATCHDOG.TIM.006
category: FUNC
feature: tim
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-TIM-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

从高到低按以下顺序处理，互斥状态更新只能执行最高有效项：

1. POR 初始化。
2. 自身致命完整性/冗余故障；最终升级到期。
3. 当前监督超时、服务违规、检查点 Deadline 违规；同拍发生的各原因全部置位。
4. 可信恢复事件；不得覆盖第 2/3 项本拍新故障。
5. 完整合法服务/刷新；含已批准待提交配置的边界切换。
6. 合法 START/STOP；STOP 不得覆盖本拍超时。
7. 授权暂停进入/退出。
8. 普通计数、预警、诊断清除。

进入暂停的该边沿仍执行到期判断；退出暂停的边沿只恢复状态，下一边沿恢复递增。暂停前已锁存故障不得暂停升级。硬件置位与 W1C 同拍时硬件置位优先。

#### Acceptance Criteria

- 对每对竞争动作验证优先序；到期与暂停同拍仍故障，恢复边沿不递增，清置同拍保留新事件。

