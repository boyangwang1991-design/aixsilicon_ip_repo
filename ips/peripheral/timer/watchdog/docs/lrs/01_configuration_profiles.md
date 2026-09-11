# Watchdog：通道位图、默认配置与产品配置

generation_profile: sv

## LRS.CFG.WATCHDOG.AUTO_START_MASK.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.AUTO_START_MASK.001
category: CFG
feature: auto_start_mask
priority: P0
status: active
source_ref:
- watchdog_contract.md:§3.2
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

`AUTO_START_MASK` 应为 NUM_CHANNELS 位通道位图，用于选择POR 后自动启动的通道，默认0。位图不得引用未实现通道。

#### Acceptance Criteria

- 分别选中首/末/全部/无通道核对行为。
- NUM_CHANNELS 变化后默认位图仍符合上述语义；超范围输入拒绝。

## LRS.CFG.WATCHDOG.NO_STOP_MASK.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.NO_STOP_MASK.001
category: CFG
feature: no_stop_mask
priority: P0
status: active
source_ref:
- watchdog_contract.md:§3.2
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

`NO_STOP_MASK` 应为 NUM_CHANNELS 位通道位图，用于选择启动后禁止软件停止的通道，默认全部已实现通道为 1。位图不得引用未实现通道。

#### Acceptance Criteria

- 分别选中首/末/全部/无通道核对行为。
- NUM_CHANNELS 变化后默认位图仍符合上述语义；超范围输入拒绝。

## LRS.CFG.WATCHDOG.HARD_CFG_LOCK_MASK.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.HARD_CFG_LOCK_MASK.001
category: CFG
feature: hard_cfg_lock_mask
priority: P0
status: active
source_ref:
- watchdog_contract.md:§3.2
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

`HARD_CFG_LOCK_MASK` 应为 NUM_CHANNELS 位通道位图，用于选择POR 后即配置锁定的通道，默认0。位图不得引用未实现通道。

#### Acceptance Criteria

- 分别选中首/末/全部/无通道核对行为。
- NUM_CHANNELS 变化后默认位图仍符合上述语义；超范围输入拒绝。

## LRS.CFG.WATCHDOG.DEFAULT_CFG.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.DEFAULT_CFG.001
category: CFG
feature: default_cfg
priority: P0
status: active
source_ref:
- watchdog_contract.md:§3.2、§6、§16.5
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

每个通道应具有完整合法静态 DEFAULT_CFG。自动启动通道的默认配置必须在构建阶段校验，包含服务/监督模式、阈值、策略及全部必需客户端条件。默认 BOOT_EN=1，默认服务算法为双密钥；具体时间由实例声明，不能假定一个固定时长适用于所有时钟。

#### Acceptance Criteria

- 逐通道检查 DEFAULT_CFG 满足原契约 §16.5 全部适用约束。
- 自动启动选中但默认配置不合法必须构建失败，不得静默关闭通道。

## 配置依赖与输入类型

通道位图的宽度和默认全 1 与 NUM_CHANNELS 关联；DEFAULT_CFG 是结构化每通道配置，
不能伪装为独立整数域或随意枚举。19-PC 必须明确其 schema/依赖表达和负例校验，
不得在参数模型中遗漏这四个输入。12 个标量输入与 configuration_masks/default_cfg
分册中的 4 个输入共同构成完整的 16 项 PARAM_META 契约。
运行配置的 TIMEOUT、BOOT_TIMEOUT、WIN_MIN、PRETIMEOUT、客户端与故障策略依赖
由本目录 REG/CFG/SUP 分册约束，字段结构由 SystemRDL 表达。

SAFETY 产品档要求 SAFETY_EN=1；SUPERVISOR 要求 SAFETY_EN、SUPPORT_TOKEN_QA、
SUPPORT_SUPERVISION、SUPPORT_HW_EVENT 均为 1。生产三档均默认 DIAG_INJECT_EN=0；
故障注入验证另设诊断配置，不把它登记成生产默认实例。

## 产品代表配置

以下值来自原契约配置档及现有实例输入，作为三个命名代表配置；完整支持矩阵由
PC 工具从本目录抽取并有界生成，见 reports/quality/param_matrix.md。
配置输入检查见 reports/quality/param_semantic_check.md；输入合法性通过不代表 RTL 回归通过。

## LRS.CFG.WATCHDOG.PROFILE.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.PROFILE.001
category: CFG
feature: profile
priority: P0
status: active
source_ref:
- watchdog_contract.md:§3.1、§18
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

<!-- CONFIG_META
id: CFG_STANDARD
purpose: 默认普通/窗口单通道实例
values:
  NUM_CHANNELS: 1
  COUNTER_WIDTH: 32
  PRESCALE_WIDTH: 16
  NUM_CLIENTS: 1
  SOURCE_WIDTH: 4
  SYNC_STAGES: 2
  SUPPORT_TOKEN_QA: 0
  SUPPORT_SUPERVISION: 0
  SUPPORT_HW_EVENT: 0
  SAFETY_EN: 0
  ALLOW_RUNTIME_UPDATE: 0
  DIAG_INJECT_EN: 0
END_CONFIG_META -->

#### Requirement

STANDARD 应提供默认普通/窗口单通道实例；生产默认关闭诊断注入。

#### Acceptance Criteria

- 构建参数、能力寄存器及产品档要求一致。
- 分别完成适用需求追踪、配置回归与真实 PPA 条件报告。

## LRS.CFG.WATCHDOG.PROFILE.002

<!-- LRS_META
id: LRS.CFG.WATCHDOG.PROFILE.002
category: CFG
feature: profile
priority: P0
status: active
source_ref:
- watchdog_contract.md:§3.1、§18
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

<!-- CONFIG_META
id: CFG_SAFETY
purpose: 单通道自身诊断增强实例
values:
  NUM_CHANNELS: 1
  COUNTER_WIDTH: 32
  PRESCALE_WIDTH: 16
  NUM_CLIENTS: 1
  SOURCE_WIDTH: 4
  SYNC_STAGES: 2
  SUPPORT_TOKEN_QA: 0
  SUPPORT_SUPERVISION: 0
  SUPPORT_HW_EVENT: 0
  SAFETY_EN: 1
  ALLOW_RUNTIME_UPDATE: 0
  DIAG_INJECT_EN: 0
END_CONFIG_META -->

#### Requirement

SAFETY 应提供单通道自身诊断增强实例；生产默认关闭诊断注入。

#### Acceptance Criteria

- 构建参数、能力寄存器及产品档要求一致。
- 分别完成适用需求追踪、配置回归与真实 PPA 条件报告。

## LRS.CFG.WATCHDOG.PROFILE.003

<!-- LRS_META
id: LRS.CFG.WATCHDOG.PROFILE.003
category: CFG
feature: profile
priority: P0
status: active
source_ref:
- watchdog_contract.md:§3.1、§18
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

<!-- CONFIG_META
id: CFG_SUPERVISOR
purpose: 完整增强双通道、双客户端、64-bit 代表实例
values:
  NUM_CHANNELS: 2
  COUNTER_WIDTH: 64
  PRESCALE_WIDTH: 16
  NUM_CLIENTS: 2
  SOURCE_WIDTH: 4
  SYNC_STAGES: 2
  SUPPORT_TOKEN_QA: 1
  SUPPORT_SUPERVISION: 1
  SUPPORT_HW_EVENT: 1
  SAFETY_EN: 1
  ALLOW_RUNTIME_UPDATE: 1
  DIAG_INJECT_EN: 0
END_CONFIG_META -->

#### Requirement

SUPERVISOR 应提供完整增强双通道、双客户端、64-bit 代表实例；生产默认关闭诊断注入。

#### Acceptance Criteria

- 构建参数、能力寄存器及产品档要求一致。
- 分别完成适用需求追踪、配置回归与真实 PPA 条件报告。
