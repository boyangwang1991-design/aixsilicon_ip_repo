# Watchdog：原子配置与锁

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.REG.WATCHDOG.CFG.001

<!-- LRS_META
id: LRS.REG.WATCHDOG.CFG.001
category: REG
feature: cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CFG-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件可先修改 pclk 域 staging 配置；配置仅在 CFG_COMMIT 经 WDT 域校验后成为 active。active 不得从多笔 APB 写中间状态直接取值。

#### Acceptance Criteria

- 多笔 staging 写期间 active 保持；只在完整提交校验成功后切换为新配置。

## LRS.REG.WATCHDOG.CFG.002

<!-- LRS_META
id: LRS.REG.WATCHDOG.CFG.002
category: REG
feature: cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CFG-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

CFG_COMMIT 包含完整配置快照和递增配置版本。检查模式支持、阈值、mask、权限、分频位宽、策略及高位；失败整组拒绝，不修改 active。配置写/提交不清计数。

#### Acceptance Criteria

- 每类非法项分别使整组拒绝；active 版本及计数不变化，不能出现部分生效。

## LRS.REG.WATCHDOG.CFG.003

<!-- LRS_META
id: LRS.REG.WATCHDOG.CFG.003
category: REG
feature: cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CFG-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

DISABLED 状态立即应用成功提交。RUN 且 ALLOW_RUNTIME_UPDATE=1、未锁定时仅允许 TIMEOUT/WIN_MIN/PRETIMEOUT/PRESCALE 更新，校验后置 PENDING；在下一次旧配置定义的成功刷新边沿整体应用，再将 C/D 置零。ALIVE 在成功周期边界应用；失败周期不应用。

#### Acceptance Criteria

- 禁用态提交立即生效；运行态合法计时更新等待旧周期成功刷新，ALIVE 只在健康边界应用。

## LRS.REG.WATCHDOG.CFG.004

<!-- LRS_META
id: LRS.REG.WATCHDOG.CFG.004
category: REG
feature: cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CFG-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

运行中不得更新服务算法、监督模式、客户端、身份、BOOT、暂停、故障策略和恢复策略。BOOT/PAUSED/FAULT/RESET_PENDING 不接受运行提交。已有 PENDING 时拒绝第二次提交；故障发生时丢弃 PENDING 并记录 CANCELED。可用 CANCEL_CFG 取消尚未生效的更新。

#### Acceptance Criteria

- 禁止状态/字段提交拒绝；第二次 pending 拒绝；故障取消或 CANCEL_CFG 后旧配置保持。

## LRS.REG.WATCHDOG.CFG.005

<!-- LRS_META
id: LRS.REG.WATCHDOG.CFG.005
category: REG
feature: cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CFG-005
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

UNLOCK 两笔常量依次为 `0xC0DE1234`、`0x3F21EDCB`，来源必须相同，在 32 个 wdt_clk 周期内完成；窗口从第一笔执行边沿起算，规则同服务序列。成功后提供一次敏感命令额度，在 64 个 wdt_clk 周期后过期；不暂停。敏感命令为 CFG_COMMIT/START/STOP/LOCK/DIAG_CLEAR/FAULT_INJECT。额度在命令被 WDT 域处理时消耗，失败也消耗；staging 写不消耗额度。

#### Acceptance Criteria

- 密钥来源一致且边界 32 周期有效；额度 64 周期过期，失败敏感命令也消费一次额度。

## LRS.REG.WATCHDOG.CFG.006

<!-- LRS_META
id: LRS.REG.WATCHDOG.CFG.006
category: REG
feature: cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CFG-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

CFG_LOCK、ENABLE_LOCK、DEBUG_LOCK、DIAG_LOCK 为只置位锁，置位即时生效，只能 POR 清除。HARD_CFG_LOCK_MASK 对应 CFG_LOCK POR 值为 1。CFG_LOCK 禁止配置提交但允许对合法已有配置 START；ENABLE_LOCK 禁止 STOP；DEBUG_LOCK 强制禁止调试暂停；DIAG_LOCK 禁止注入。锁不阻止合法服务。

#### Acceptance Criteria

- 四种锁只能置位；preset/warm/局部恢复不清锁，POR 使用参数默认，合法服务不受锁影响。

## LRS.REG.WATCHDOG.CFG.007

<!-- LRS_META
id: LRS.REG.WATCHDOG.CFG.007
category: REG
feature: cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CFG-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

任一 active 锁/配置在 wdt_clk 域为权威值。APB staging 的读回不代表 active 生效；软件必须检查 CFG_VERSION_ACTIVE。锁定同拍不存在跨来源命令合并，按单命令执行次序决定。

#### Acceptance Criteria

- 以 active 版本确认生效；staging 读回不代表运行配置，跨来源命令按执行先后生效。

