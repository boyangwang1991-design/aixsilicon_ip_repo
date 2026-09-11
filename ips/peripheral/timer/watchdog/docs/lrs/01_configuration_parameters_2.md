# Watchdog：静态参数定义

本分册为 LRS 配置编辑入口；G0 冻结后由 19-PC 抽取参数模型。

## LRS.CFG.WATCHDOG.SUPPORT_TOKEN_QA.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.SUPPORT_TOKEN_QA.001
category: CFG
feature: support_token_qa
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

<!-- PARAM_META
name: SUPPORT_TOKEN_QA
type: int
category: compile_time
default: 0
domain:
- 0
- 1
depends_on: []
description: 动态令牌/问答服务能力
END_PARAM_META -->

#### Requirement

`SUPPORT_TOKEN_QA` 应配置动态令牌/问答服务能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `SUPPORT_TOKEN_QA=0`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.SUPPORT_SUPERVISION.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.SUPPORT_SUPERVISION.001
category: CFG
feature: support_supervision
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

<!-- PARAM_META
name: SUPPORT_SUPERVISION
type: int
category: compile_time
default: 0
domain:
- 0
- 1
depends_on: []
description: GROUP/ALIVE/FLOW 增强监督能力
END_PARAM_META -->

#### Requirement

`SUPPORT_SUPERVISION` 应配置GROUP/ALIVE/FLOW 增强监督能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `SUPPORT_SUPERVISION=0`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.SUPPORT_HW_EVENT.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.SUPPORT_HW_EVENT.001
category: CFG
feature: support_hw_event
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

<!-- PARAM_META
name: SUPPORT_HW_EVENT
type: int
category: compile_time
default: 0
domain:
- 0
- 1
depends_on: []
description: WDT 同域硬件事件接口能力
END_PARAM_META -->

#### Requirement

`SUPPORT_HW_EVENT` 应配置WDT 同域硬件事件接口能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `SUPPORT_HW_EVENT=0`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.SAFETY_EN.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.SAFETY_EN.001
category: CFG
feature: safety_en
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

<!-- PARAM_META
name: SAFETY_EN
type: int
category: compile_time
default: 0
domain:
- 0
- 1
depends_on: []
description: 自身安全诊断增强能力
END_PARAM_META -->

#### Requirement

`SAFETY_EN` 应配置自身安全诊断增强能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `SAFETY_EN=0`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.ALLOW_RUNTIME_UPDATE.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.ALLOW_RUNTIME_UPDATE.001
category: CFG
feature: allow_runtime_update
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

<!-- PARAM_META
name: ALLOW_RUNTIME_UPDATE
type: int
category: compile_time
default: 0
domain:
- 0
- 1
depends_on: []
description: 运行计时配置的原子边界切换能力
END_PARAM_META -->

#### Requirement

`ALLOW_RUNTIME_UPDATE` 应配置运行计时配置的原子边界切换能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `ALLOW_RUNTIME_UPDATE=0`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.DIAG_INJECT_EN.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.DIAG_INJECT_EN.001
category: CFG
feature: diag_inject_en
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

<!-- PARAM_META
name: DIAG_INJECT_EN
type: int
category: compile_time
default: 0
domain:
- 0
- 1
depends_on: []
description: 受控诊断注入入口，生产默认关闭
END_PARAM_META -->

#### Requirement

`DIAG_INJECT_EN` 应配置受控诊断注入入口，生产默认关闭，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `DIAG_INJECT_EN=0`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

