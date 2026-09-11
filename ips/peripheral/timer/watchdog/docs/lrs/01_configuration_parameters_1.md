# Watchdog：静态参数定义

本分册为 LRS 配置编辑入口；G0 冻结后由 19-PC 抽取参数模型。

## LRS.CFG.WATCHDOG.NUM_CHANNELS.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.NUM_CHANNELS.001
category: CFG
feature: num_channels
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
name: NUM_CHANNELS
type: int
category: compile_time
default: 1
domain:
  min: 1
  max: 16
depends_on: []
description: 独立监督通道数
END_PARAM_META -->

#### Requirement

`NUM_CHANNELS` 应配置独立监督通道数，合法值为 `1～16`，默认 `1`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `NUM_CHANNELS=1`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.COUNTER_WIDTH.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.COUNTER_WIDTH.001
category: CFG
feature: counter_width
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
name: COUNTER_WIDTH
type: int
category: compile_time
default: 32
domain:
- 32
- 48
- 64
depends_on: []
description: 计数及阈值的统一位宽
END_PARAM_META -->

#### Requirement

`COUNTER_WIDTH` 应配置计数及阈值的统一位宽，合法值为 `[32, 48, 64]`，默认 `32`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `COUNTER_WIDTH=32`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.PRESCALE_WIDTH.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.PRESCALE_WIDTH.001
category: CFG
feature: prescale_width
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
name: PRESCALE_WIDTH
type: int
category: compile_time
default: 16
domain:
  min: 1
  max: 16
depends_on: []
description: 分频配置有效位宽
END_PARAM_META -->

#### Requirement

`PRESCALE_WIDTH` 应配置分频配置有效位宽，合法值为 `1～16`，默认 `16`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `PRESCALE_WIDTH=16`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.NUM_CLIENTS.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.NUM_CLIENTS.001
category: CFG
feature: num_clients
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
name: NUM_CLIENTS
type: int
category: compile_time
default: 1
domain:
  min: 1
  max: 32
depends_on: []
description: 每通道客户端数
END_PARAM_META -->

#### Requirement

`NUM_CLIENTS` 应配置每通道客户端数，合法值为 `1～32`，默认 `1`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `NUM_CLIENTS=1`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.SOURCE_WIDTH.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.SOURCE_WIDTH.001
category: CFG
feature: source_width
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
name: SOURCE_WIDTH
type: int
category: compile_time
default: 4
domain:
  min: 1
  max: 16
depends_on: []
description: 可信来源 ID 位宽
END_PARAM_META -->

#### Requirement

`SOURCE_WIDTH` 应配置可信来源 ID 位宽，合法值为 `1～16`，默认 `4`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `SOURCE_WIDTH=4`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

## LRS.CFG.WATCHDOG.SYNC_STAGES.001

<!-- LRS_META
id: LRS.CFG.WATCHDOG.SYNC_STAGES.001
category: CFG
feature: sync_stages
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
name: SYNC_STAGES
type: int
category: compile_time
default: 2
domain:
- 2
- 3
- 4
depends_on: []
description: 同步释放及跨域单比特传递的配置级数
END_PARAM_META -->

#### Requirement

`SYNC_STAGES` 应配置同步释放及跨域单比特传递的配置级数，合法值为 `[2, 3, 4]`，默认 `2`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

#### Acceptance Criteria

- 默认实例读回/体现 `SYNC_STAGES=2`；合法值域端点及代表中间点可构建。
- 越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

